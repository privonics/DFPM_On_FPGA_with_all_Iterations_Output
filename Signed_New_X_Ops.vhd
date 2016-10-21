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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Signed_New_X_Ops is
    Port ( VECTOR_X : in  DFPM_SIGNED_VECTOR_5X32_BIT;
           VECTOR_NEW_V : in  DFPM_SIGNED_VECTOR_5X32_BIT;
           DT : in  Signed(32 downto 0);
			  
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           NEW_V_READY : in  STD_LOGIC;
			  
           VECTOR_NEW_X : out  DFPM_SIGNED_VECTOR_5X32_BIT;
           NEW_X_READY : out  STD_LOGIC);
end Signed_New_X_Ops;

architecture Behavioral of Signed_New_X_Ops is

		Signal Sig_Vector_V 			 	: DFPM_SIGNED_VECTOR_5X32_BIT;
		Signal Sig_Vector_X				: DFPM_SIGNED_VECTOR_5X32_BIT;
		Signal Sig_Vector_V_Mult_Dt 	: DFPM_SIGNED_VECTOR_5X32_BIT;
		
		
		Signal Sig_Position : integer := 0;
		
		Signal Sig_ShiftPosition, Sig_NEW_X_READY : STD_LOGIC:= '0';

begin
	
	process(CLK, RST, NEW_V_READY, Sig_ShiftPosition, Sig_Position, Sig_NEW_X_READY)	
			variable Var_NEW_V_READY : STD_LOGIC := '0';
			Variable Var_Position : integer := 0;
			begin
				if rising_edge(CLK) then
					if (RST = '1') then
						Sig_ShiftPosition <= '0';
						Var_Position := 0;
						Sig_Position <= 0;
						Var_NEW_V_READY := '0';
						Sig_NEW_X_READY <= '0';
					elsif (NEW_V_READY = '0') then
						Var_NEW_V_READY := '0';
--					elsif (NEW_V_READY = '1') and (Var_NEW_V_READY = '1') then
--						Var_NEW_V_READY := '0';
					elsif (NEW_V_READY = '1') and (Var_NEW_V_READY = '0') then
						Var_NEW_V_READY := '1';
						Sig_ShiftPosition <= '1';
						Sig_Position <= 0;
						Sig_NEW_X_READY <= '0';
					end if;
					
					if (Sig_ShiftPosition = '1') then
						if (Sig_Position = 4) then
							Sig_ShiftPosition <= '0';
							Sig_NEW_X_READY <= '1';
						else
							Var_Position := Sig_Position;
							Sig_Position <= Var_Position + 1;
						end if;
					end if;
					
					if (Sig_NEW_X_READY = '1') then
						Sig_NEW_X_READY <= '0';
					end if;
					
				end if;
			end process;
		
		
		process(RST, NEW_V_READY)
			begin
				if rising_edge(NEW_V_READY) then
					Sig_Vector_V <= VECTOR_NEW_V;
					Sig_Vector_X <= VECTOR_X;
				end if;
			end process;
		
		
		process(CLK, RST, Sig_ShiftPosition)
			Variable productTempStore : Signed(65 downto 0) := (Others => '0');
			begin
				if rising_edge(CLK) then
					if (Sig_ShiftPosition = '1') then
						productTempStore := Sig_Vector_V(Sig_Position) * DT;
						
						Sig_Vector_V_Mult_Dt(Sig_Position) <= productTempStore(48 downto 16);
					end if;
				end if;
			end process;
		
		process(clk)
			begin
				if rising_edge(clk) then
					NEW_X_READY <= Sig_NEW_X_READY;
				end if;
			end process;
		
		
		
		VECTOR_NEW_X(0) <= (Sig_Vector_X(0) + Sig_Vector_V_Mult_Dt(0));
		VECTOR_NEW_X(1) <= (Sig_Vector_X(1) + Sig_Vector_V_Mult_Dt(1));
		VECTOR_NEW_X(2) <= (Sig_Vector_X(2) + Sig_Vector_V_Mult_Dt(2));
		VECTOR_NEW_X(3) <= (Sig_Vector_X(3) + Sig_Vector_V_Mult_Dt(3));
		VECTOR_NEW_X(4) <= (Sig_Vector_X(4) + Sig_Vector_V_Mult_Dt(4));
		
end Behavioral;

