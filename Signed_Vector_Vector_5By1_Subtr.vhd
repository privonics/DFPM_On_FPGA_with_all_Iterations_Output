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

entity Signed_Vector_Vector_5By1_Subtr is
    Port ( Vector_1 : in  DFPM_SIGNED_VECTOR_5X32_BIT;
           vector_2 : in  DFPM_SIGNED_VECTOR_5X32_BIT;
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           Vector_Out : out  DFPM_SIGNED_VECTOR_5X32_BIT);
end Signed_Vector_Vector_5By1_Subtr;

architecture Behavioral of Signed_Vector_Vector_5By1_Subtr is

	Signal Subtr0, Subtr1, Subtr2, Subtr3, Subtr4 : Signed(33 downto 0);

begin
	
	Subtr0 <=  '0' & Vector_1(0) - vector_2(0);
	Subtr1 <=  '0' & Vector_1(1) - vector_2(1);
	Subtr2 <=  '0' & Vector_1(2) - vector_2(2);
	Subtr3 <=  '0' & Vector_1(3) - vector_2(3);
	Subtr4 <=  '0' & Vector_1(4) - vector_2(4);
	
	Vector_Out(0) <= Subtr0(32 downto 0);
	Vector_Out(1) <= Subtr1(32 downto 0);
	Vector_Out(2) <= Subtr2(32 downto 0);
	Vector_Out(3) <= Subtr3(32 downto 0);
	Vector_Out(4) <= Subtr4(32 downto 0);

	
end Behavioral;

