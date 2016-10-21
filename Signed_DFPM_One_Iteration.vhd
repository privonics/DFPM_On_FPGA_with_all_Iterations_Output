----------------------------------------------------------------------------------
-- Company: 			Mid Sweden University
-- Engineer: 			Taiyelolu O. Adeboye (Student)
-- 
-- Create Date:    	14:56:46 02/06/2015 
-- Design Name: 		DFPM ON FPGA 
-- Module Name:    	DFPM_ON_FPGA_PROJECT_DEMO_TOP_MODULE - Behavioral 
-- Project Name: 		DFPM ON FPGA - An implementation of the Dynamic Functional Particle Method on Spartan 3E FPGA (Thesis work)
-- Target Devices: 	Xilinx's xc3s1200e-4fg320 - Spartan 3E on Nexys2 board
-- Tool versions: 	Xilinx ISE Project Navigator, Digilent's Adept (for programming) and other associated design, synthesis 
--							and verification tools
-- Description: 		This project is a thesis work, done in partial fulfilment of the requirements for the 
--							award of the degree of Bachelor in Electronics design in Mid Sweden University.
--							It is a design on Xilinx Spartan 3E FPGA using VHDL to implement the Dynamic Functional
--							Particle Method as invented by Prof. Sverker Edvardsson et al. 
--							
--							The complete and compiled design includes a UART module that facilitates the input of 
--							problem statements to be solved using the DFPM and the output of the solution 
--							in signed binary format. An accompanying MATLAB code is available for communicating
--							with the FPGA running this design.
--							
--							This thesis work was done under suprérvision of Asst. Prof. Kent Bertilsson and initial 
--							instructional guidance from Prof. Sverker.
--
-- Dependencies: 
--
-- Revision: 			I have lost count of the number of revisions. LOL. But let's say version 1.5 :-)
-- Revision 0.01 - File Created
-- Additional Comments: This specific file is an adaptation of Dan Pederson's design provided 
--								as a sample project for the UART on Nexys2
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_signed.all;
use work.DFPM_ARRAY_5X32_BIT.all;
use work.DFPM_ARRAY_25X32_BIT.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Signed_DFPM_One_Iteration is
    Port ( VECTOR_A_IN : in  DFPM_SIGNED_VECTOR_25X32_BIT;
           VECTOR_B_IN : in  DFPM_SIGNED_VECTOR_5X32_BIT;
           VECTOR_X_IN : in  DFPM_SIGNED_VECTOR_5X32_BIT;
           VECTOR_V_IN : in  DFPM_SIGNED_VECTOR_5X32_BIT;
           Mu_IN 		: in  Signed (32 downto 0);
           DT_IN 		: in  Signed (32 downto 0);
			  NEW_ITERATION_IN : in  STD_LOGIC;
			  
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           
           B_AX_OUT 		: out  DFPM_SIGNED_VECTOR_5X32_BIT;
           NEW_V_OUT 	: out  DFPM_SIGNED_VECTOR_5X32_BIT;
           NEW_X_OUT 	: out  DFPM_SIGNED_VECTOR_5X32_BIT;
			  
           ITERATION_STAGE_COMPLETE : out  STD_LOGIC;
			  ITERATE_AGAIN : out STD_LOGIC);
end Signed_DFPM_One_Iteration;

architecture Behavioral of Signed_DFPM_One_Iteration is


	COMPONENT Signed_SubtrAndMult_Ops_Module
		 Port ( Vector_A : in  DFPM_SIGNED_VECTOR_25X32_BIT;
				  Vector_B : in  DFPM_SIGNED_VECTOR_5X32_BIT;
				  Vector_X : in  DFPM_SIGNED_VECTOR_5X32_BIT;
				  Scalar_Mu : in  SIGNED (32 downto 0);
				  Vector_V : in  DFPM_SIGNED_VECTOR_5X32_BIT;
				  
				  CLK : in  STD_LOGIC;
				  RST : in  STD_LOGIC;
				  NEW_ITERATION : in  STD_LOGIC := '0';
				  ITERATION_COMPLETE : out  STD_LOGIC:= '0';
				  
				  B_Minus_AX : out  DFPM_SIGNED_VECTOR_5X32_BIT;
				  B_Minus_Ax_Minus_muV : out  DFPM_SIGNED_VECTOR_5X32_BIT);
		 END COMPONENT;
	
		COMPONENT Signed_New_V_Ops
			 Port ( B_Ax_Muv : in  DFPM_SIGNED_VECTOR_5X32_BIT;
					  Vector_V : in  DFPM_SIGNED_VECTOR_5X32_BIT;
					  
					  DT 	: in  Signed (32 downto 0);
					  CLK : in  STD_LOGIC;
					  RST : in  STD_LOGIC;
					  ITERATION_COMPLETE : in  STD_LOGIC;
					  
					  VECTOR_NEW_V : out  DFPM_SIGNED_VECTOR_5X32_BIT;
					  NEW_V_READY : out  STD_LOGIC);
			 END COMPONENT;
	
		COMPONENT Signed_New_X_Ops
			 Port ( VECTOR_X : in  DFPM_SIGNED_VECTOR_5X32_BIT;
					  VECTOR_NEW_V : in  DFPM_SIGNED_VECTOR_5X32_BIT;
					  DT : in  Signed(32 downto 0);
					  
					  CLK : in  STD_LOGIC;
					  RST : in  STD_LOGIC;
					  NEW_V_READY : in  STD_LOGIC;
					  
					  VECTOR_NEW_X : out  DFPM_SIGNED_VECTOR_5X32_BIT;
					  NEW_X_READY : out  STD_LOGIC);
			 END COMPONENT;
			 
	COMPONENT Signed_Tolerance_Check
			 Port ( Vector_B_AX : in  DFPM_SIGNED_VECTOR_5X32_BIT;
					  Tolerance_Limit : in  Signed (32 downto 0);
					  Iteration_Complete : in STD_LOGIC:= '0';
					  
					  
					  
					  CLK : in STD_LOGIC:= '0';
					  RST : in STD_LOGIC:= '0';
					  
					  Tolerance_Limit_Squared, Vector_B_AX_Sum : out Signed (32 downto 0);
					  
					  Iterate : out  STD_LOGIC := '1');
			 END COMPONENT;
	
------------------------------------------------------------------------------------------------


	Signal Sig_VECTOR_A_IN :  DFPM_SIGNED_VECTOR_5X32_BIT;
	Signal Sig_VECTOR_B_IN :  DFPM_SIGNED_VECTOR_5X32_BIT;
	Signal Sig_VECTOR_V_IN :  DFPM_SIGNED_VECTOR_5X32_BIT;
	Signal Sig_VECTOR_X_IN :  DFPM_SIGNED_VECTOR_5X32_BIT;
	Signal Sig_Mu_IN : Signed(32 downto 0);
	Signal Sig_DT_IN : Signed(32 downto 0);
	Signal Sig_B_AX_OUT 	  :  DFPM_SIGNED_VECTOR_5X32_BIT;
	
	Signal Sig_Start_SubtrMultOps_To_NewVOps : STD_LOGIC := '0';
	Signal Sig_Start_NewVOps_To_NewXOps : STD_LOGIC := '0';
	Signal Sig_New_X_Is_Ready				: STD_LOGIC;
	
	Signal Sig_B_Ax_MuV 		:  DFPM_SIGNED_VECTOR_5X32_BIT;
	Signal Sig_New_V			:  DFPM_SIGNED_VECTOR_5X32_BIT;
	Signal Sig_New_X			:  DFPM_SIGNED_VECTOR_5X32_BIT;
	
	Constant Const_Tolerance_Limit : Signed (32 downto 0) := "000000000000000000000001000000000"; -- 1*2^(-7)
	


begin

	Sig_DT_IN <= DT_IN;
	Sig_Mu_IN <= Mu_IN;
	Sig_VECTOR_V_IN <= VECTOR_V_IN;
	Sig_VECTOR_X_IN <= VECTOR_X_IN;
	ITERATION_STAGE_COMPLETE <= Sig_New_X_Is_Ready;
	B_AX_OUT <= Sig_B_AX_OUT;
	NEW_V_OUT <= Sig_New_V;
	NEW_X_OUT <= Sig_New_X;

	Inst_Signed_SubtrAndMult_Ops_Module: Signed_SubtrAndMult_Ops_Module PORT MAP(
			Vector_A => VECTOR_A_IN,
			Vector_B => VECTOR_B_IN,
			Vector_X => Sig_VECTOR_X_IN,
			Scalar_Mu => Mu_IN,
			Vector_V => Sig_VECTOR_V_IN,
			CLK => CLK,
			RST => RST,
			NEW_ITERATION => NEW_ITERATION_IN,
			ITERATION_COMPLETE => Sig_Start_SubtrMultOps_To_NewVOps,
			B_Minus_AX => Sig_B_AX_OUT,
			B_Minus_Ax_Minus_muV => Sig_B_Ax_MuV);
		
	
	Inst_Signed_New_V_Ops: Signed_New_V_Ops PORT MAP(
			B_Ax_Muv => Sig_B_Ax_MuV,
			Vector_V => Sig_VECTOR_V_IN,
			DT => Sig_DT_IN,
			CLK => CLK,
			RST => RST,
			ITERATION_COMPLETE => Sig_Start_SubtrMultOps_To_NewVOps,
			VECTOR_NEW_V => Sig_New_V,
			NEW_V_READY => Sig_Start_NewVOps_To_NewXOps);
	
	
	Inst_Signed_New_X_Ops: Signed_New_X_Ops PORT MAP(
			VECTOR_X => Sig_VECTOR_X_IN,
			VECTOR_NEW_V => Sig_New_V,
			DT => Sig_DT_IN,
			CLK => CLK,
			RST => RST,
			NEW_V_READY => Sig_Start_NewVOps_To_NewXOps,
			VECTOR_NEW_X => Sig_New_X,
			NEW_X_READY => Sig_New_X_Is_Ready);
			
	Inst_Signed_Tolerance_Check: Signed_Tolerance_Check PORT MAP (
          Vector_B_AX => Sig_B_AX_OUT,
          Tolerance_Limit => Const_Tolerance_Limit,
          Iteration_Complete => Sig_Start_SubtrMultOps_To_NewVOps,
          CLK => CLK,
          RST => RST,
			 Tolerance_Limit_Squared => open, 
			 Vector_B_AX_Sum => open,
          Iterate => ITERATE_AGAIN);
	

end Behavioral;

