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
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity UART_INTERFACE is
    Port ( 	RXD : in  STD_LOGIC := '1';
				DATA_UART_TO_DFPM : out  STD_LOGIC_VECTOR (7 downto 0);
				RDA_SIG : out  STD_LOGIC;
				DATA_READY_FROM_UART : out  STD_LOGIC := '0';
				
				WAITING_FOR_DFPM : out  STD_LOGIC := '0';
				           
				CLK : in  STD_LOGIC;
				RST : in  STD_LOGIC := '0';
				LEDS : out STD_LOGIC_VECTOR (7 downto 0) := "00000000";
				
				TXD : out  STD_LOGIC := '1';
				DATA_DFPM_TO_UART : in  STD_LOGIC_VECTOR (7 downto 0);
				TBE_SIG : out  STD_LOGIC;
				DATA_READY_FROM_DFPM : in  STD_LOGIC := '0');
end UART_INTERFACE;

architecture Behavioral of UART_INTERFACE is

	component RS232RefComp
		Port (TXD 	: out	std_logic	:= '1';
				RXD 	: in	std_logic;					
				CLK 	: in	std_logic;							
				DBIN 	: in	std_logic_vector (7 downto 0);
				DBOUT 	: out	std_logic_vector (7 downto 0);
				RDA		: inout	std_logic;							
				TBE		: inout	std_logic 	:= '1';				
				RD		: in	std_logic;							
				WR		: in	std_logic;							
				PE		: out	std_logic;							
				FE		: out	std_logic;							
				OE		: out	std_logic;											
				RST		: in	std_logic	:= '0');				
		end component;	
	
	-------------------------------------------------------------------------
	type mainState is (
		stReceive,
		stWaitForDFPMOutput,
		stSend,
		stRepeatSend);
	-------------------------------------------------------------------------
	
	signal dbInSig		:	std_logic_vector(7 downto 0):= "00000000";
	signal dbOutSig	:	std_logic_vector(7 downto 0):= "00000000";
	signal rdaSig	:	std_logic;
	signal tbeSig	:	std_logic;
	signal rdSig	:	std_logic;
	signal wrSig	:	std_logic;
	signal peSig	:	std_logic;
	signal feSig	:	std_logic;
	signal oeSig	:	std_logic;
	
	signal stCur	:	mainState := stReceive;
	signal stNext	:	mainState;
	
	Signal TxCount, RxCount : integer := 0;
	
	Signal RxFlag, TxFlag, TbeFlag, RdaFlag, clearSendCount : std_logic := '0';
	
	Signal TxDataReadStartPos : integer := 7;
	Signal RxDataReadStartPos : integer := 0;
	
	Signal Sig_Waiting_For_DFPM_Results : std_logic := '0';
	
	Constant endOfRxMessage : std_logic_vector(7 downto 0) := "00111010";-- ASCII representation of the colon
	Constant endOfTxMessage : std_logic_vector(7 downto 0) := "11111111";
	
	Constant numberOfTxTransmissions : integer := 252;
	Constant numberOfRxTransmissions : integer := 8;
	
	
	
	begin
		
		WAITING_FOR_DFPM <= Sig_Waiting_For_DFPM_Results;
		
		TBE_SIG <= tbeSig;
		
		RDA_SIG <= rdaSig;
		
		
		Instantiating_the_UART: RS232RefComp port map (	TXD 	=> TXD,
																		RXD 	=> RXD,
																		CLK 	=> CLK,
																		DBIN 	=> dbInSig,
																		DBOUT	=> dbOutSig,
																		RDA	=> rdaSig,
																		TBE	=> tbeSig,	
																		RD		=> rdSig,
																		WR		=> wrSig,
																		PE		=> peSig,
																		FE		=> feSig,
																		OE		=> oeSig,
																		RST 	=> RST);
		
		-------------------------------------------------------------------------
		process (CLK, RST)
			begin
				if (CLK = '1' and CLK'Event) then
					if RST = '1' then
						stCur <= stReceive;
					else
						stCur <= stNext;
					end if;
				end if;
			end process;
		-------------------------------------------------------------------------
		
		process (stCur, rdaSig, dboutsig, tbeSig, TxCount,DATA_READY_FROM_DFPM, DATA_DFPM_TO_UART)
			Variable TXFlagVar : std_logic:= '0';
			begin
				case stCur is
					when stReceive =>
						rdSig <= '0';
						wrSig <= '0';
						Sig_Waiting_For_DFPM_Results <= '0';
						DATA_READY_FROM_UART <= '0';
						if (dbOutSig = endOfRxMessage) then
							stNext <= stWaitForDFPMOutput;
							DATA_READY_FROM_UART <= '1';
						else 
							stNext <= stReceive;
						end if;
						if (rdaSig = '1') then																				
							rdSig <= '1';
							DATA_READY_FROM_UART <= '0';
							LEDS <= dbOutSig;
							-- Send the newly received data to DFPM
							DATA_UART_TO_DFPM <= dbOutSig;
						end if;
					
					when stWaitForDFPMOutput =>
						Sig_Waiting_For_DFPM_Results <= '1';
						-- Signal with the LEDS
						LEDS <= (Others => '1');
						-- Prevent the RX from receiving and the TX from transmitting
						rdSig <= '1';
						wrSig <= '0';
						-- Do nothing else. Just wait until output is ready from the DFPM
						if (DATA_READY_FROM_DFPM = '1') then
							stNext <= stSend;
						else 
							stNext <= stWaitForDFPMOutput;
						end if;
					
					when stSend =>
						Sig_Waiting_For_DFPM_Results <= '0';
						LEDS <=  "11000011";
						--LEDS(0) <= '1';
						if (TxCount = numberOfTxTransmissions) then					
							stNext <= stReceive;
						else
							rdSig <= '1';
							wrSig <= '1';												
							stNext <= stRepeatSend;
						end if;
										
					when stRepeatSend =>
						LEDS <= "10011001";
						wrSig <= '0';										
						if (tbeSig = '1') then
							--SEnd the newly received data to UART TX
							dbInSig <= DATA_DFPM_TO_UART;							
							stNext <= stSend;
						else
							stNext <= stRepeatSend;
						end if;						
				end case;
			end process;
		
		---- Determining the number of tx transmissions to be sent 
		---- and which positioon in memory is to be printed out.
			process(RST, tbeSig, stCur)
				Variable TxCountVar : integer := 0;
				--Variable TxDataReadStartPosVar : integer := 0;
				begin					
						if rising_edge(wrSig) then													
							if (stCur = stSend) then
								TxCountVar := TxCount;
								TxCount <= TxCountVar + 1;
							end if;
							
							--TxDataReadStartPosVar := TxDataReadStartPos;
							--TxDataReadStartPos <= TxDataReadStartPosVar - 1;
						end if;					
				end process;

	end Behavioral;

