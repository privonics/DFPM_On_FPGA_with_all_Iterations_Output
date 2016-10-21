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
USE ieee.std_logic_signed.all;
use IEEE.NUMERIC_STD.ALL;
use work.DFPM_ARRAY_5X32_BIT.all;	-- 5 by 1 of Signed signed vectors package
use work.DFPM_ARRAY_25X32_BIT.all;	-- 5 by 5 matrix of signed vectors package
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_TO_DFPM is
	Port(	CLK, RST : in STD_LOGIC;
			
			DATA_FROM_UART_INTERFACE : in STD_LOGIC_VECTOR(7 downto 0);
			RDA_IN : in STD_LOGIC;
			DATA_READY_FROM_UART : in STD_LOGIC;
			WAITING_FOR_DFPM : in STD_LOGIC;
			
			DFPM_START_COMPUTATION : out STD_LOGIC;
			VECTOR_A : out DFPM_SIGNED_VECTOR_25X32_BIT;
			VECTOR_B : out DFPM_SIGNED_VECTOR_5X32_BIT);
end UART_TO_DFPM;

architecture Behavioral of UART_TO_DFPM is

	type type_DFPM_Format is array (0 to 30) of Signed(32 downto 0);
	------------------------------------------------------------------
	Signal Sig_DFPM_Input_array : type_DFPM_Format := (	"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000",
																			"000000000000000000000000000000000"	);
	
	Signal Sig_UART_STORE_Pos : integer := 0;
	
	Signal Sig_UART_Data_Storage_Complete : STD_LOGIC := '0';
	
	Signal Sig_start_DFPM_computation : STD_LOGIC := '0';
	
	
	
	
	
	Signal Sig_DFPMStartFlag : std_logic := '0';
	
	----------------------------------------------------------------
	--ASCII REpresentations
	Constant Const_SemiColon 			: std_logic_vector(7 downto 0) := "00111011";
	Constant Const_Colon 	 			: std_logic_vector(7 downto 0) := "00111010";
	Constant Const_Space		 			: std_logic_vector(7 downto 0) := "00100000";
	Constant Const_Opening_Bracket  	: std_logic_vector(7 downto 0) := "01011011";
	Constant Const_Closing_Bracket  	: std_logic_vector(7 downto 0) := "01011101";
	
	
	Constant Const_Zero 	: std_logic_vector(7 downto 0) := "00110000";
	Constant Const_One 	: std_logic_vector(7 downto 0) := "00110001";
	Constant Const_Two	: std_logic_vector(7 downto 0) := "00110010";
	Constant Const_Three	: std_logic_vector(7 downto 0) := "00110011";
	Constant Const_Four	: std_logic_vector(7 downto 0) := "00110100";
	Constant Const_Five 	: std_logic_vector(7 downto 0) := "00110101";
	Constant Const_Six	: std_logic_vector(7 downto 0) := "00110110";
	Constant Const_Seven	: std_logic_vector(7 downto 0) := "00110111";
	Constant Const_Eight	: std_logic_vector(7 downto 0) := "00111000";
	Constant Const_Nine	: std_logic_vector(7 downto 0) := "00111001";
	
	-- Other constants
	Constant Const_9_Zeros : signed(8 downto 0) 		:= "000000000";
	Constant Const_16_Zeros : signed(15 downto 0) 	:= "0000000000000000";
	
	
	Constant Const_0 	: Signed(7 downto 0) := "00000000";
	Constant Const_1 	: Signed(7 downto 0) := "00000001";
	Constant Const_2	: Signed(7 downto 0) := "00000010";
	Constant Const_3	: Signed(7 downto 0) := "00000011";
	Constant Const_4	: Signed(7 downto 0) := "00000100";
	Constant Const_5 	: Signed(7 downto 0) := "00000101";
	Constant Const_6	: Signed(7 downto 0) := "00000110";
	Constant Const_7	: Signed(7 downto 0) := "00000111";
	Constant Const_8	: Signed(7 downto 0) := "00001000";
	Constant Const_9	: Signed(7 downto 0) := "00001001";
	
	Constant C9 	: signed(8 downto 0) 		:= "000000000";
	Constant C16 	: signed(15 downto 0) 		:= "0000000000000000";
	
	
	begin
		
		process(RDA_IN, Sig_UART_Data_Storage_Complete)
			begin
				if rising_edge(RDA_IN) then
				
					-- Direct assignment of Data received from the UART RX pin (which were stored after conversion)											
--					VECTOR_A <= (	(Sig_DFPM_Input_array(0), Sig_DFPM_Input_array(1), Sig_DFPM_Input_array(2), Sig_DFPM_Input_array(3), Sig_DFPM_Input_array(4)), 
--															(Sig_DFPM_Input_array(5), Sig_DFPM_Input_array(6), Sig_DFPM_Input_array(7), Sig_DFPM_Input_array(8), Sig_DFPM_Input_array(9)), 
--															(Sig_DFPM_Input_array(10), Sig_DFPM_Input_array(11), Sig_DFPM_Input_array(12), Sig_DFPM_Input_array(13), Sig_DFPM_Input_array(14)), 
--															(Sig_DFPM_Input_array(15), Sig_DFPM_Input_array(16), Sig_DFPM_Input_array(17), Sig_DFPM_Input_array(18), Sig_DFPM_Input_array(19)), 
--															(Sig_DFPM_Input_array(20), Sig_DFPM_Input_array(21), Sig_DFPM_Input_array(22), Sig_DFPM_Input_array(23), Sig_DFPM_Input_array(24)) );
					
					VECTOR_A(0)( 0) <= Sig_DFPM_Input_array(0);
					VECTOR_A(0)( 1) <= Sig_DFPM_Input_array(1);
					VECTOR_A(0)( 2) <= Sig_DFPM_Input_array(2);
					VECTOR_A(0)( 3) <= Sig_DFPM_Input_array(3);
					VECTOR_A(0)( 4) <= Sig_DFPM_Input_array(4);
					VECTOR_A(1)( 0) <= Sig_DFPM_Input_array(5);
					VECTOR_A(1)( 1) <= Sig_DFPM_Input_array(6);
					VECTOR_A(1)( 2) <= Sig_DFPM_Input_array(7);
					VECTOR_A(1)( 3) <= Sig_DFPM_Input_array(8);
					VECTOR_A(1)( 4) <= Sig_DFPM_Input_array(9);
					VECTOR_A(2)( 0) <= Sig_DFPM_Input_array(10);
					VECTOR_A(2)( 1) <= Sig_DFPM_Input_array(11);
					VECTOR_A(2)( 2) <= Sig_DFPM_Input_array(12);
					VECTOR_A(2)( 3) <= Sig_DFPM_Input_array(13);
					VECTOR_A(2)( 4) <= Sig_DFPM_Input_array(14);
					VECTOR_A(3)( 0) <= Sig_DFPM_Input_array(15);
					VECTOR_A(3)( 1) <= Sig_DFPM_Input_array(16);
					VECTOR_A(3)( 2) <= Sig_DFPM_Input_array(17);
					VECTOR_A(3)( 3) <= Sig_DFPM_Input_array(18);
					VECTOR_A(3)( 4) <= Sig_DFPM_Input_array(19);
					VECTOR_A(4)( 0) <= Sig_DFPM_Input_array(20);
					VECTOR_A(4)( 1) <= Sig_DFPM_Input_array(21);
					VECTOR_A(4)( 2) <= Sig_DFPM_Input_array(22);
					VECTOR_A(4)( 3) <= Sig_DFPM_Input_array(23);
					VECTOR_A(4)( 4) <= Sig_DFPM_Input_array(24);
					
					VECTOR_B(0) <= Sig_DFPM_Input_array(25);
					VECTOR_B(1) <= Sig_DFPM_Input_array(26);
					VECTOR_B(2) <= Sig_DFPM_Input_array(27);
					VECTOR_B(3) <= Sig_DFPM_Input_array(28);
					VECTOR_B(4) <= Sig_DFPM_Input_array(29);				
					
--					--	
--					Sig_VECTOR_A_IN_TO_DFPM <= (	(C9&Const_9&C16, C9&Const_2&C16, C9&Const_3&C16, C9&Const_4&C16, C9&Const_5&C16),
--															(C9&Const_1&C16, C9&Const_7&C16, C9&Const_3&C16, C9&Const_4&C16, C9&Const_5&C16),
--															(C9&Const_1&C16, C9&Const_2&C16, C9&Const_9&C16, C9&Const_4&C16, C9&Const_5&C16),
--															(C9&Const_1&C16, C9&Const_2&C16, C9&Const_3&C16, C9&Const_8&C16, C9&Const_5&C16),
--															(C9&Const_1&C16, C9&Const_2&C16, C9&Const_3&C16, C9&Const_4&C16, C9&Const_9&C16));
--						
--						
--					Sig_VECTOR_B_IN_TO_DFPM <= (C9&Const_1&C16, C9&Const_2&C16, C9&Const_3&C16, C9&Const_4&C16, C9&Const_5&C16);
		

				end if;
			end process;
		
		-- Determining the position in which incoming data is to be stored
		process(RDA_IN, Sig_UART_STORE_Pos, DATA_FROM_UART_INTERFACE)
			variable varPos : integer := 0;
			begin
				if falling_edge(RDA_IN) then				
					if (Sig_UART_STORE_Pos < 30) then
						if ((DATA_FROM_UART_INTERFACE = Const_SemiColon)
								--or (DATA_FROM_UART_INTERFACE = Const_Colon)
								or (DATA_FROM_UART_INTERFACE = Const_Space)
								or (DATA_FROM_UART_INTERFACE = Const_Closing_Bracket)) then
								
							varPos := Sig_UART_STORE_Pos;
							Sig_UART_STORE_Pos <= varPos + 1;						
						end if;
					end if;	
				end if;
			end process;
		
		-- The actual data storage
		process(RDA_IN, Sig_UART_STORE_Pos, DATA_FROM_UART_INTERFACE)
			begin
				if falling_edge(RDA_IN) then
					--if (RDA_IN = '1') then
						if (Sig_UART_STORE_Pos < 30) then 
							if ((DATA_FROM_UART_INTERFACE = Const_One) 
									or (DATA_FROM_UART_INTERFACE = Const_Two) or (DATA_FROM_UART_INTERFACE = Const_Three) 
									or (DATA_FROM_UART_INTERFACE = Const_Four) or (DATA_FROM_UART_INTERFACE = Const_Five) 
									or (DATA_FROM_UART_INTERFACE = Const_Six) or (DATA_FROM_UART_INTERFACE = Const_Seven) 
									or (DATA_FROM_UART_INTERFACE = Const_Eight) or (DATA_FROM_UART_INTERFACE = Const_Nine)) then
								-- Storing the 4 LSBs - the part of ASCII numerical representation that contains the number being transmitted						
								-- Sig_DFPM_Input_array(Sig_UART_STORE_Pos)(19 downto 16) <=  Signed(DATA_FROM_UART_INTERFACE(3 downto 0));						
								
								Sig_DFPM_Input_array(Sig_UART_STORE_Pos)(19 downto 16) <=  Signed(DATA_FROM_UART_INTERFACE(3 downto 0));
							
							end if;
						end if;
					--end if;
				end if;
			end process;
		------------------------------------------------------------------
		--Signalling that storage is complete
		process(CLK, DATA_FROM_UART_INTERFACE, RST, Sig_UART_STORE_Pos)
			begin
				if rising_edge(CLK) then
					--if (Sig_UART_STORE_Pos = 29) then
					if (DATA_FROM_UART_INTERFACE = Const_Colon) then
						Sig_UART_Data_Storage_Complete <= '1';
					end if;
				end if;
			end process;
		
		-- Signalling that the DFPM computation should start
		process(clk, Sig_UART_Data_Storage_Complete, Sig_DFPMStartFlag)
			variable var_DFPMStartFlag : std_logic := '0';
			begin
				if rising_edge(clk) then
					if (Sig_DFPMStartFlag = '0') then
						if (Sig_UART_Data_Storage_Complete = '1') then					
							Sig_start_DFPM_computation <= '1';
							Sig_DFPMStartFlag <= '1';
						else
							Sig_start_DFPM_computation <= '0';
						end if;
					else
						Sig_start_DFPM_computation <= '0';
					end if;
				end if;
			end process;
		
		DFPM_START_COMPUTATION <= Sig_start_DFPM_computation;

	end Behavioral;

