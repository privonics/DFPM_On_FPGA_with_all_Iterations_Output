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
USE ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use work.DFPM_ARRAY_5X32_BIT.all;	-- 5 by 1 of Signed signed vectors package
use work.DFPM_ARRAY_25X32_BIT.all;	

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DFPM_TO_UART is
	port(	CLK, RST : in STD_LOGIC;
			
			VECTOR_X_FROM_DFPM : in DFPM_SIGNED_VECTOR_5X32_BIT;
			ITERATIONS_COMPLETE : in STD_LOGIC;
			DATA_READY_FROM_ONE_ITERATION : IN std_logic;
			
			DATA_READY_FROM_DFPM : out STD_LOGIC;
			DATA_TO_UART_INTERFACE : out STD_LOGIC_VECTOR(7 downto 0);
			 
			COUNT_LEDS : out std_logic_vector(7 downto 0);
			
			TBE_IN : in STD_LOGIC);
end DFPM_TO_UART;

architecture Behavioral of DFPM_TO_UART is
	
	
	type storage_type_dfpm is array (0 to 50) of std_logic_vector(40 downto 0);-- Larger so as to make room for the New line character
	
	
	Signal Sig_DFPM_storage_array : storage_type_dfpm := ("00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000001010",
																			"00000000000000000000000000000000000000000");
	
		
	Signal Sig_UART_READ_Pos : integer := 0;
	
	Signal SIG_NO_OF_ITERATIONS : integer := 0;
	
	Signal Sig_ARRAY_INDEX : integer := 0;
	
	Signal Sig_UART_READ_Pos_8BitPart : integer := 4;
	
	Signal Sig_MIN, SIg_MAX : integer := 1;
	
	Signal Sig_Count_LEDS : std_logic_vector(7 downto 0) := "00000000";
	
	Signal Sig_DATA_READY_FROM_ONE_ITERATION : STD_LOGIC;
	
	
	-----------------------------------------------------------------------------------
	Constant Const_Newline 	 			: std_logic_vector(7 downto 0) := "00001010";

	
	
	begin
	
	
	
	process(clk)
		begin
			if rising_edge(clk) then
				DATA_READY_FROM_DFPM <= ITERATIONS_COMPLETE;
				Sig_DATA_READY_FROM_ONE_ITERATION <= DATA_READY_FROM_ONE_ITERATION;
			end if;
		end process;
	
		
		------------------------------------------------------------------
	
	process(TBE_IN, Sig_UART_READ_Pos, Sig_UART_READ_Pos_8BitPart)
		Variable var_readPos, var_ReadPos_8bitPart : integer := 0;
		begin
			if rising_edge(TBE_IN) then
				if (Sig_UART_READ_Pos < 50) then
					
					--Bits 31 downto 24, 	then 23 downto 16, then 15 downto 8, then 7 downto 0
					--in successive bit transmissions through the UART is equivalent to ->
					--(8(x + 1) - 1) downto (8*x) where x is the Sig_UART_READ_Pos_8BitPart
					-- This approach will transmit the data contained in each element of the solution vector
					-- in series if 8 bits starting from the MSB to the LSB
					--------------------------------------
					if (Sig_UART_READ_Pos_8BitPart = 4) then
						DATA_TO_UART_INTERFACE <= Sig_DFPM_storage_array(Sig_UART_READ_Pos)(39 downto 32);
					elsif (Sig_UART_READ_Pos_8BitPart = 3) then
						DATA_TO_UART_INTERFACE <= Sig_DFPM_storage_array(Sig_UART_READ_Pos)(31 downto 24);
					elsif (Sig_UART_READ_Pos_8BitPart = 2) then
						DATA_TO_UART_INTERFACE <= Sig_DFPM_storage_array(Sig_UART_READ_Pos)(23 downto 16);
					elsif (Sig_UART_READ_Pos_8BitPart = 1) then
						DATA_TO_UART_INTERFACE <= Sig_DFPM_storage_array(Sig_UART_READ_Pos)(15 downto 8);
					elsif (Sig_UART_READ_Pos_8BitPart = 0) then
						DATA_TO_UART_INTERFACE <= Sig_DFPM_storage_array(Sig_UART_READ_Pos)(7 downto 0);
					end if;
					
																				
					if (Sig_UART_READ_Pos_8BitPart = 0) then
						Sig_UART_READ_Pos_8BitPart <= 4;
						
						var_readPos := Sig_UART_READ_Pos;
						Sig_UART_READ_Pos <= var_readPos + 1;
					else
						var_ReadPos_8bitPart := Sig_UART_READ_Pos_8BitPart;
						Sig_UART_READ_Pos_8BitPart <= var_ReadPos_8bitPart - 1;
					end if;
				end if;
			end if;
		end process;
	------------------------------------------------------------------
	
	process(DATA_READY_FROM_ONE_ITERATION)
		Variable Var_NO_OF_ITERATIONS : integer := 0;
		
		Variable Var_Count_LEDS : std_logic_vector(7 downto 0) := "00000000";
		begin
			if rising_edge(DATA_READY_FROM_ONE_ITERATION) then	
--				if (DATA_READY_FROM_ONE_ITERATION = '1') then
					Var_NO_OF_ITERATIONS := SIG_NO_OF_ITERATIONS;
					SIG_NO_OF_ITERATIONS <= Var_NO_OF_ITERATIONS + 1;	

					Var_Count_LEDS := Sig_Count_LEDS;
					Sig_Count_LEDS <= Var_Count_LEDS + "00000001";
					
					COUNT_LEDS <= Sig_Count_LEDS;
--				end if;
			end if;
		end process;
		
	
	
--	process(clk, DATA_READY_FROM_ONE_ITERATION, Sig_ARRAY_INDEX)
--		Variable Var_ARRAY_INDEX : integer := 0;
--		begin
--			if rising_edge(DATA_READY_FROM_ONE_ITERATION) then
----				if (DATA_READY_FROM_ONE_ITERATION = '1') then					
--					if (Sig_ARRAY_INDEX = 20) then
--						Sig_ARRAY_INDEX <= 0;
--					else
--						-- Array index increments in fives since the array being read in fives - i.e. the 5 elements in X
--						Var_ARRAY_INDEX := Sig_ARRAY_INDEX;
--						Sig_ARRAY_INDEX <= Var_ARRAY_INDEX + 5;
--					end if;
----				end if;
--			end if;
--		end process;
	
		-------------------------------------------------------------------------------------
	
	process(DATA_READY_FROM_ONE_ITERATION, SIG_NO_OF_ITERATIONS)
		begin
		if rising_edge(DATA_READY_FROM_ONE_ITERATION) then
--			if (DATA_READY_FROM_ONE_ITERATION = '1') then
				if (SIG_NO_OF_ITERATIONS = 10) then	
					Sig_DFPM_storage_array(0) 		<= std_logic_vector(VECTOR_X_FROM_DFPM(0)) & Const_Newline;
					Sig_DFPM_storage_array(1) 		<= std_logic_vector(VECTOR_X_FROM_DFPM(1)) & Const_Newline;
					Sig_DFPM_storage_array(2) 		<= std_logic_vector(VECTOR_X_FROM_DFPM(2)) & Const_Newline;
					Sig_DFPM_storage_array(3) 		<= std_logic_vector(VECTOR_X_FROM_DFPM(3)) & Const_Newline;
					Sig_DFPM_storage_array(4) 		<= std_logic_vector(VECTOR_X_FROM_DFPM(4)) & Const_Newline;	
				elsif (SIG_NO_OF_ITERATIONS = 11) then	
					Sig_DFPM_storage_array(5) 		<= std_logic_vector(VECTOR_X_FROM_DFPM(0)) & Const_Newline;
					Sig_DFPM_storage_array(6) 		<= std_logic_vector(VECTOR_X_FROM_DFPM(1)) & Const_Newline;
					Sig_DFPM_storage_array(7) 		<= std_logic_vector(VECTOR_X_FROM_DFPM(2)) & Const_Newline;
					Sig_DFPM_storage_array(8) 		<= std_logic_vector(VECTOR_X_FROM_DFPM(3)) & Const_Newline;
					Sig_DFPM_storage_array(9) 		<= std_logic_vector(VECTOR_X_FROM_DFPM(4)) & Const_Newline;	
				elsif (SIG_NO_OF_ITERATIONS = 12) then					
					Sig_DFPM_storage_array(10) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(0)) & Const_Newline;
					Sig_DFPM_storage_array(11) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(1)) & Const_Newline;
					Sig_DFPM_storage_array(12) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(2)) & Const_Newline;
					Sig_DFPM_storage_array(13) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(3)) & Const_Newline;
					Sig_DFPM_storage_array(14) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(4)) & Const_Newline;	
				elsif (SIG_NO_OF_ITERATIONS = 13) then	
					Sig_DFPM_storage_array(15) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(0)) & Const_Newline;
					Sig_DFPM_storage_array(16) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(1)) & Const_Newline;
					Sig_DFPM_storage_array(17) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(2)) & Const_Newline;
					Sig_DFPM_storage_array(18) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(3)) & Const_Newline;
					Sig_DFPM_storage_array(19) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(4)) & Const_Newline;
				elsif (SIG_NO_OF_ITERATIONS = 14) then					
					Sig_DFPM_storage_array(20) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(0)) & Const_Newline;
					Sig_DFPM_storage_array(21) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(1)) & Const_Newline;
					Sig_DFPM_storage_array(22) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(2)) & Const_Newline;
					Sig_DFPM_storage_array(23) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(3)) & Const_Newline;
					Sig_DFPM_storage_array(24) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(4)) & Const_Newline;	
				elsif (SIG_NO_OF_ITERATIONS = 15) then															
					Sig_DFPM_storage_array(25) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(0)) & Const_Newline;
					Sig_DFPM_storage_array(26) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(1)) & Const_Newline;
					Sig_DFPM_storage_array(27) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(2)) & Const_Newline;
					Sig_DFPM_storage_array(28) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(3)) & Const_Newline;
					Sig_DFPM_storage_array(29) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(4)) & Const_Newline;	
				elsif (SIG_NO_OF_ITERATIONS = 16) then										
					Sig_DFPM_storage_array(30) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(0)) & Const_Newline;
					Sig_DFPM_storage_array(31) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(1)) & Const_Newline;
					Sig_DFPM_storage_array(32) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(2)) & Const_Newline;
					Sig_DFPM_storage_array(33) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(3)) & Const_Newline;
					Sig_DFPM_storage_array(34) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(4)) & Const_Newline;	
				elsif (SIG_NO_OF_ITERATIONS = 17) then	
					Sig_DFPM_storage_array(35) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(0)) & Const_Newline;
					Sig_DFPM_storage_array(36) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(1)) & Const_Newline;
					Sig_DFPM_storage_array(37) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(2)) & Const_Newline;
					Sig_DFPM_storage_array(38) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(3)) & Const_Newline;
					Sig_DFPM_storage_array(39) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(4)) & Const_Newline;	
				elsif (SIG_NO_OF_ITERATIONS = 18) then										
					Sig_DFPM_storage_array(40) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(0)) & Const_Newline;
					Sig_DFPM_storage_array(41) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(1)) & Const_Newline;
					Sig_DFPM_storage_array(42) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(2)) & Const_Newline;
					Sig_DFPM_storage_array(43) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(3)) & Const_Newline;
					Sig_DFPM_storage_array(44) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(4)) & Const_Newline;	
				elsif (SIG_NO_OF_ITERATIONS = 19) then	
					Sig_DFPM_storage_array(45) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(0)) & Const_Newline;
					Sig_DFPM_storage_array(46) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(1)) & Const_Newline;
					Sig_DFPM_storage_array(47) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(2)) & Const_Newline;
					Sig_DFPM_storage_array(48) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(3)) & Const_Newline;
					Sig_DFPM_storage_array(49) 	<= std_logic_vector(VECTOR_X_FROM_DFPM(4)) & Const_Newline;	
				end if;				
--			end if;
		end if;
		end process;
	------------------------------------------------------------------		
		
	end Behavioral;

