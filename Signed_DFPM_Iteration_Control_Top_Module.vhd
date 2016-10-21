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

entity Signed_DFPM_Iteration_Control_Top_Module is
	Port ( 	  VECTOR_A_IN : IN  DFPM_SIGNED_VECTOR_25X32_BIT;
				  VECTOR_B_IN : IN  DFPM_SIGNED_VECTOR_5X32_BIT;				  
				  
				  DATA_READY_FROM_UART_RX : IN  STD_LOGIC;
				  
				  CLK : IN  STD_LOGIC;
				  RST : IN  STD_LOGIC;
				  
				  VECTOR_B_AX : OUT  DFPM_SIGNED_VECTOR_5X32_BIT;
				  
				  DATA_READY_FROM_ONE_ITERATION 	 : OUT  STD_LOGIC;
				  DATA_READY_FROM_DFPM_ITERATIONS : OUT  STD_LOGIC;
				  VECTOR_X_OUT : OUT  DFPM_SIGNED_VECTOR_5X32_BIT);
end Signed_DFPM_Iteration_Control_Top_Module;

architecture Behavioral of Signed_DFPM_Iteration_Control_Top_Module is

	COMPONENT Signed_DFPM_One_Iteration
        Port (   VECTOR_A_IN : in  DFPM_SIGNED_VECTOR_25X32_BIT;
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
			END COMPONENT;
			
		
		
		Signal Sig_VECTOR_A_IN : DFPM_SIGNED_VECTOR_25X32_BIT;
		Signal Sig_VECTOR_B_IN : DFPM_SIGNED_VECTOR_5X32_BIT;
		
		Signal Sig_DATA_READY_FROM_UART_RX, Sig_DATA_READY_FROM_DFPM_ITERATIONS 		: STD_LOGIC := '0';
		Signal Sig_NEW_ITERATION_IN, Sig_ITERATE_AGAIN, Sig_ITERATION_STAGE_COMPLETE 	: STD_LOGIC;
		
		Signal Sig_Temp_ITERATION_STAGE_COMPLETE : STD_LOGIC := '0';
		
		Signal Sig_NEW_DFPM_ITERATION : STD_LOGIC := '0';
		
		Signal Sig_B_AX_OUT : DFPM_SIGNED_VECTOR_5X32_BIT;
		
		Signal Sig_FINAL_VECTOR_X_OUT : DFPM_SIGNED_VECTOR_5X32_BIT;
		
		Signal Sig_NO_OF_ITERATIONS : integer := 0;
		
		-- Signal for storing the current value of Vector V for both input and and output of each stage of each iteration
		Signal Sig_VECTOR_V_IN, Sig_NEW_V_OUT, Sig_Temp_New_V : DFPM_SIGNED_VECTOR_5X32_BIT	:= (	"000000000000000000000000000000000",
																																"000000000000000000000000000000000",
																																"000000000000000000000000000000000",
																																"000000000000000000000000000000000",
																																"000000000000000000000000000000000");
		
		-- Signal for storing the current value of Vector X for both input and and output of each stage of each iteration
		Signal Sig_VECTOR_X_IN, Sig_NEW_X_OUT, Sig_Temp_New_X : DFPM_SIGNED_VECTOR_5X32_BIT 	:= (	"000000000000000000000000000000000",
																																	"000000000000000000000000000000000",
																																	"000000000000000000000000000000000",
																																	"000000000000000000000000000000000",
																																	"000000000000000000000000000000000");
																
		
		
		
		Constant Const_SCALAR_MU : Signed(32 downto 0) := "000000000000000010000000000000000";
		Constant Const_SCALAR_DT : Signed(32 downto 0) := "000000000000000000001100110011001";
		
		-- The Vector V for the first Iteration initialized to 1.0 for each element
		Constant Const_Init_VECTOR_V_IN : DFPM_SIGNED_VECTOR_5X32_BIT := ("000000000000000010000000000000000",
																								"000000000000000010000000000000000",
																								"000000000000000010000000000000000",
																								"000000000000000010000000000000000",
																								"000000000000000010000000000000000");
		
		-- The Vector X for the first Iteration initialized to 1.0 for each element																						
		Constant Const_Init_VECTOR_X_IN : DFPM_SIGNED_VECTOR_5X32_BIT := ("000000000000000010000000000000000",
																								"000000000000000010000000000000000",
																								"000000000000000010000000000000000",
																								"000000000000000010000000000000000",
																								"000000000000000010000000000000000");
																					
		
	
	begin					
		Sig_DATA_READY_FROM_UART_RX <= DATA_READY_FROM_UART_RX;
		
		-- Connecting the one clk cycle delayed signal
		-- of New Vector X from the "one iteration" module
		-- to the output of this top module
--		VECTOR_X_OUT <= Sig_Temp_New_X;--Sig_Temp_New_X;
		
		
		
		VECTOR_B_AX <= Sig_B_AX_OUT;
		
		-- This output signal, when raised high, indicates the end of all the iterations
		-- and availability of the final value of Vector X.
		-- It's one clk cycle delayed.
		DATA_READY_FROM_DFPM_ITERATIONS <= Sig_DATA_READY_FROM_DFPM_ITERATIONS;
		
		
		
		-- These two (2) signals are used to connect to the input matrices A and B
		-- for each iteration of the "one iteration" module
		Sig_VECTOR_A_IN <= VECTOR_A_IN;
		Sig_VECTOR_B_IN <= VECTOR_B_IN;
		
		-- These two (2) signals are used to connect to the input matrices V and X
		-- for each iteration of the "one iteration" module
		Sig_VECTOR_V_IN <= Sig_Temp_New_V;
		Sig_VECTOR_X_IN <= Sig_Temp_New_X;
		

		DATA_READY_FROM_ONE_ITERATION <= Sig_ITERATION_STAGE_COMPLETE;		
		
		process(CLK, Sig_ITERATE_AGAIN)
			begin
				if rising_edge(CLK) then
					if (Sig_ITERATE_AGAIN = '1') then
						Sig_Temp_ITERATION_STAGE_COMPLETE <= Sig_DATA_READY_FROM_UART_RX 
																			or Sig_ITERATION_STAGE_COMPLETE;
					else
						Sig_Temp_ITERATION_STAGE_COMPLETE <= '0';
					end if;
				end if;
			end process;
		
		process(CLK, Sig_ITERATION_STAGE_COMPLETE)
			begin
				if rising_edge(CLK) then
					if (Sig_ITERATION_STAGE_COMPLETE = '1') then
						Sig_Temp_New_V <= Sig_NEW_V_OUT;
						Sig_Temp_New_X <= Sig_NEW_X_OUT;	
						VECTOR_X_OUT	<= Sig_NEW_X_OUT;	
					end if;
				end if;
			end process;
			
		process(CLK)
			begin
				if rising_edge(CLK) then
					Sig_NEW_ITERATION_IN <= Sig_Temp_ITERATION_STAGE_COMPLETE;
				end if;
			end process;
		
		-- This sprocess signals the end of all the iterations in the algorithm
		-- i.e. when the number of iterations required have already been done
		process(CLK, Sig_ITERATE_AGAIN, Sig_ITERATION_STAGE_COMPLETE)
			begin
			if rising_edge(CLK) then
				if (Sig_ITERATE_AGAIN = '0') and (Sig_ITERATION_STAGE_COMPLETE = '1') then
					Sig_DATA_READY_FROM_DFPM_ITERATIONS <= '1';											
				else
					Sig_DATA_READY_FROM_DFPM_ITERATIONS <= '0';
				end if;
			end if;
			end process;


--------- Port MApping-----------------------------------------------------		
		Inst_Signed_DFPM_One_Iteration: Signed_DFPM_One_Iteration PORT MAP (
          VECTOR_A_IN => Sig_VECTOR_A_IN,
          VECTOR_B_IN => Sig_VECTOR_B_IN,
          VECTOR_X_IN => Sig_VECTOR_X_IN,
          VECTOR_V_IN => Sig_VECTOR_V_IN,
          Mu_IN => Const_SCALAR_MU,
          DT_IN => Const_SCALAR_DT,
          NEW_ITERATION_IN => Sig_NEW_ITERATION_IN, --Sig_Temp_ITERATION_STAGE_COMPLETE,
          CLK => CLK,
          RST => RST,
          B_AX_OUT => Sig_B_AX_OUT,
          NEW_V_OUT => Sig_NEW_V_OUT,
          NEW_X_OUT => Sig_NEW_X_OUT,
          ITERATION_STAGE_COMPLETE => Sig_ITERATION_STAGE_COMPLETE,
			 ITERATE_AGAIN => Sig_ITERATE_AGAIN);
---------------------------------------------------------------------------

	end Behavioral;

