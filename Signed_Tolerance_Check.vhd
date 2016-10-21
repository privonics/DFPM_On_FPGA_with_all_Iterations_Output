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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Signed_Tolerance_Check is
    Port ( Vector_B_AX : in  DFPM_SIGNED_VECTOR_5X32_BIT;
           Tolerance_Limit : in  Signed (32 downto 0);
			  Iteration_Complete : in STD_LOGIC:= '0';
			  
			  CLK : in STD_LOGIC:= '0';
			  RST : in STD_LOGIC:= '0';
			  
			  Tolerance_Limit_Squared, Vector_B_AX_Sum : out Signed (32 downto 0);
			  
           Iterate : out  STD_LOGIC := '1');
end Signed_Tolerance_Check;

architecture Behavioral of Signed_Tolerance_Check is
	
	Signal Sig_Vector_B_AX, Sig_Vector_B_AX_Squared : DFPM_SIGNED_VECTOR_5X32_BIT;
	Signal Sig_Tolerance_Limit, Sig_Tolerance_Limit_Squared : Signed (32 downto 0);
	
	Signal Sig_Vector_B_AX_Sum : Signed(32 downto 0);
	
	Signal Sig_Position : integer := 0;
	
	Signal Sig_ShiftPosition, Sig_Multiplication_Is_Complete, Sig_Check_Tolerance_Limit : STD_LOGIC := '0';
	

	

	begin
		
		Tolerance_Limit_Squared <= Sig_Tolerance_Limit_Squared;
		Vector_B_AX_Sum <= Sig_Vector_B_AX_Sum;
	
		--  This process determines when data stored innternally are to be serially multiplied
		-- They are serially multiplied to save on Multipliers
		process(CLK, RST, Iteration_Complete, Sig_ShiftPosition, Sig_Position)
			Variable Var_Position: integer := 0;
			begin
				if rising_edge(CLK) then
					if (RST = '1') then
						Sig_Position <= 0;
						Sig_ShiftPosition <= '0';
						Sig_Multiplication_Is_Complete <= '0';
					elsif (Iteration_Complete = '1') then
						Sig_Check_Tolerance_Limit <= '0';
						Sig_Position <= 0;
						Sig_ShiftPosition <= '1';
						Sig_Multiplication_Is_Complete <= '0';
					elsif (Sig_Multiplication_Is_Complete = '1') then
						Sig_Check_Tolerance_Limit <= '1';
					else
						if (Sig_ShiftPosition = '1') then
							if (Sig_Position = 5) then
								Sig_Position <= 0;
								Sig_Multiplication_Is_Complete <= '1';
								Sig_ShiftPosition <= '0';
							else
								Var_Position := Sig_Position;
								Sig_Position <= Var_Position + 1;
							end if;
						end if;
					end if;
				end if;
			end process;
		
		-- Storing data internally at when signal from SubtrAndMult Module is high
		process(RST, Iteration_Complete)
			Variable productTempStore : Signed(65 downto 0) := (Others => '0');
			begin
				if rising_edge(Iteration_Complete) then
					Sig_Tolerance_Limit <= Tolerance_Limit;
					Sig_Vector_B_AX <= Vector_B_AX;
				end if;
			end process;
		
		-- Serial multiplication
		process(CLK, RST, Sig_ShiftPosition, Sig_Position)
			Variable productTempStore : Signed(65 downto 0);
			begin
				if rising_edge(clk) then
					if (Sig_ShiftPosition <= '1') then
						Case Sig_Position is
							when 0 =>
								productTempStore := (Sig_Vector_B_AX(Sig_Position) * Sig_Vector_B_AX(Sig_Position));
								Sig_Vector_B_AX_Squared(Sig_Position) <= productTempStore(48 downto 16);
							when 1 =>
								productTempStore := (Sig_Vector_B_AX(Sig_Position) * Sig_Vector_B_AX(Sig_Position));
								Sig_Vector_B_AX_Squared(Sig_Position) <= productTempStore(48 downto 16);
							when 2 =>
								productTempStore := (Sig_Vector_B_AX(Sig_Position) * Sig_Vector_B_AX(Sig_Position));
								Sig_Vector_B_AX_Squared(Sig_Position) <= productTempStore(48 downto 16);
							when 3 =>
								productTempStore := (Sig_Vector_B_AX(Sig_Position) * Sig_Vector_B_AX(Sig_Position));
								Sig_Vector_B_AX_Squared(Sig_Position) <= productTempStore(48 downto 16);
							when 4 =>
								productTempStore := (Sig_Vector_B_AX(Sig_Position) * Sig_Vector_B_AX(Sig_Position));
								Sig_Vector_B_AX_Squared(Sig_Position) <= productTempStore(48 downto 16);
							when 5 =>
								productTempStore := Sig_Tolerance_Limit * Sig_Tolerance_Limit;
								Sig_Tolerance_Limit_Squared <= productTempStore(48 downto 16);
							when others =>
								NULL;
						End case;
					end if;
				end if;
			end process;
			
		process(RST, Sig_Multiplication_Is_Complete)
			variable Var_Vector_B_AX_Sum : Signed (36 downto 0);
			begin
				if rising_edge(Sig_Multiplication_Is_Complete) then
					Var_Vector_B_AX_Sum := ("0000" & Sig_Vector_B_AX_Squared(0) + Sig_Vector_B_AX_Squared(1) 
															 + Sig_Vector_B_AX_Squared(2) + Sig_Vector_B_AX_Squared(3)
															 + Sig_Vector_B_AX_Squared(4));
					
					Sig_Vector_B_AX_Sum <= Var_Vector_B_AX_Sum(32 downto 0);
				end if;			end process;
			
		process(CLK, RST, Sig_Check_Tolerance_Limit, Sig_Vector_B_AX_Sum, Sig_Tolerance_Limit_Squared)
			begin
				if rising_edge(CLK) then
					if (Sig_Check_Tolerance_Limit = '1') then
						if (Sig_Vector_B_AX_Sum < Sig_Tolerance_Limit_Squared) then
							Iterate <= '0';
						else
							Iterate <= '1';
						end if;
					end if;
				end if;
			end process;
	end Behavioral;

