
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
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE ieee.std_logic_signed.all;
use IEEE.NUMERIC_STD.ALL;

use work.DFPM_VECTOR_5X32_BIT.all;	-- 5 by 1 matrix of std logic vectors package
use work.DFPM_VECTOR_25X32_BIT.all; -- 5 by 5 matrix of std_logic_vectors package
use work.DFPM_ARRAY_5X32_BIT.all;	-- 5 by 1 of Signed signed vectors package
use work.DFPM_ARRAY_25X32_BIT.all;	-- 5 by 5 matrix of signed vectors package

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DFPM_ALL_ITER_OUT_10_TO_19_2nd_Version is
    Port ( RXD : in  STD_LOGIC;
           TXD: out  STD_LOGIC;
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;--Connected to button 0			  
           LEDS : out  STD_LOGIC_VECTOR (7 downto 0));
end DFPM_ALL_ITER_OUT_10_TO_19_2nd_Version;

architecture Behavioral of DFPM_ALL_ITER_OUT_10_TO_19_2nd_Version is
	
	COMPONENT UART_INTERFACE
		PORT(
			RXD : IN std_logic;
			CLK : IN std_logic;
			RST : IN std_logic;
			DATA_DFPM_TO_UART : IN std_logic_vector(7 downto 0);
			LEDS : out STD_LOGIC_VECTOR (7 downto 0);
			DATA_READY_FROM_DFPM : IN std_logic;      
			
			WAITING_FOR_DFPM : out  STD_LOGIC := '0';
			
			DATA_UART_TO_DFPM : OUT std_logic_vector(7 downto 0);
			RDA_SIG : OUT std_logic;
			DATA_READY_FROM_UART : OUT std_logic;
			TXD : OUT std_logic;
			TBE_SIG : OUT std_logic);
		END COMPONENT;
	
	COMPONENT Signed_DFPM_Iteration_Control_Top_Module
		Port ( 	  VECTOR_A_IN : IN  DFPM_SIGNED_VECTOR_25X32_BIT;
					  VECTOR_B_IN : IN  DFPM_SIGNED_VECTOR_5X32_BIT;				  
					  
					  DATA_READY_FROM_UART_RX : IN  STD_LOGIC;
					  
					  CLK : IN  STD_LOGIC;
					  RST : IN  STD_LOGIC;
					  
					  VECTOR_B_AX : OUT  DFPM_SIGNED_VECTOR_5X32_BIT;
				  
					  DATA_READY_FROM_ONE_ITERATION 	 : OUT  STD_LOGIC := '0';				  
					  DATA_READY_FROM_DFPM_ITERATIONS : OUT  STD_LOGIC;
					  
					  VECTOR_X_OUT : OUT  DFPM_SIGNED_VECTOR_5X32_BIT);
		END COMPONENT;

	COMPONENT DFPM_TO_UART
		PORT(
				CLK : IN std_logic;
				RST : IN std_logic;
				
				VECTOR_X_FROM_DFPM : IN DFPM_SIGNED_VECTOR_5X32_BIT;
				ITERATIONS_COMPLETE : IN std_logic;
				DATA_READY_FROM_ONE_ITERATION : IN std_logic;
				
				TBE_IN : IN std_logic;     
				
				COUNT_LEDS : out std_logic_vector(7 downto 0);
				
				DATA_READY_FROM_DFPM : OUT std_logic;
				DATA_TO_UART_INTERFACE : OUT std_logic_vector(7 downto 0));
		END COMPONENT;
	
	COMPONENT UART_TO_DFPM
		PORT(
				CLK : IN std_logic;
				RST : IN std_logic;
				
				DATA_FROM_UART_INTERFACE : IN std_logic_vector(7 downto 0);
				RDA_IN : IN std_logic;
				DATA_READY_FROM_UART : IN std_logic;
				WAITING_FOR_DFPM : IN std_logic;          
				
				DFPM_START_COMPUTATION : OUT std_logic;
				VECTOR_A : OUT DFPM_SIGNED_VECTOR_25X32_BIT;
				VECTOR_B : OUT DFPM_SIGNED_VECTOR_5X32_BIT);
		END COMPONENT;
	----------------------------------------------------------------
	
Signal Sig_RDA, Sig_TBE : STD_LOGIC := '0';

Signal Sig_WAITING_FOR_DFPM, Sig_DataReady_From_UART, Sig_start_DFPM_computation: STD_LOGIC:= '0';
Signal Sig_DATA_READY_FROM_UART, Sig_Result_Ready, Sig_Iterations_Complete : STD_LOGIC:= '0';
Signal Sig_DATA_READY_FROM_ONE_ITERATION : STD_LOGIC;

Signal Sig_DATA_OUT_UART_INTERFACE : std_logic_vector(7 downto 0);	
Signal Sig_DATA_IN_UART_INTERFACE : std_logic_vector(7 downto 0);

Signal Sig_VECTOR_A_IN_TO_DFPM : DFPM_SIGNED_VECTOR_25X32_BIT;
Signal Sig_VECTOR_B_IN_TO_DFPM : DFPM_SIGNED_VECTOR_5X32_BIT;

Signal Sig_VECTOR_X_OUT_FROM_DFPM : DFPM_SIGNED_VECTOR_5X32_BIT;	



begin
	
	Inst_UART_INTERFACE: UART_INTERFACE PORT MAP(
				RXD => RXD,
				DATA_UART_TO_DFPM => Sig_DATA_OUT_UART_INTERFACE,
				RDA_SIG => Sig_RDA,
				DATA_READY_FROM_UART => Sig_DATA_READY_FROM_UART,
				
				CLK => CLK,
				RST => RST,
				LEDS => open,
				
				WAITING_FOR_DFPM => Sig_WAITING_FOR_DFPM,
				
				TXD => TXD,
				DATA_DFPM_TO_UART => Sig_DATA_IN_UART_INTERFACE,
				TBE_SIG => Sig_TBE,
				DATA_READY_FROM_DFPM => Sig_Result_Ready);
				
	Inst_UART_TO_DFPM: UART_TO_DFPM PORT MAP(
				CLK => CLK,
				RST => RST,
				DATA_FROM_UART_INTERFACE => Sig_DATA_OUT_UART_INTERFACE,
				RDA_IN => Sig_RDA,
				DATA_READY_FROM_UART => Sig_DATA_READY_FROM_UART,
				WAITING_FOR_DFPM => Sig_WAITING_FOR_DFPM,
				DFPM_START_COMPUTATION => Sig_start_DFPM_computation,
				VECTOR_A => Sig_VECTOR_A_IN_TO_DFPM,
				VECTOR_B => Sig_VECTOR_B_IN_TO_DFPM);
	
	
	Inst_DFPM_TO_UART: DFPM_TO_UART PORT MAP(
				CLK => CLK,
				RST => RST,
				VECTOR_X_FROM_DFPM => Sig_VECTOR_X_OUT_FROM_DFPM,
				ITERATIONS_COMPLETE => Sig_Iterations_Complete,
				DATA_READY_FROM_ONE_ITERATION => Sig_DATA_READY_FROM_ONE_ITERATION,
				DATA_READY_FROM_DFPM => Sig_Result_Ready,
				DATA_TO_UART_INTERFACE => Sig_DATA_IN_UART_INTERFACE,
				COUNT_LEDS => LEDS,
				TBE_IN => Sig_TBE);
	
	Inst_Signed_DFPM_Iteration_Control_Top_Module: Signed_DFPM_Iteration_Control_Top_Module PORT MAP(
				VECTOR_A_IN => Sig_VECTOR_A_IN_TO_DFPM,
				VECTOR_B_IN => Sig_VECTOR_B_IN_TO_DFPM,
				DATA_READY_FROM_UART_RX => Sig_start_DFPM_computation,
				CLK => CLK,
				RST => RST,
				VECTOR_B_AX => open,				  
				DATA_READY_FROM_ONE_ITERATION => Sig_DATA_READY_FROM_ONE_ITERATION,
				DATA_READY_FROM_DFPM_ITERATIONS => Sig_Iterations_Complete,
				VECTOR_X_OUT => Sig_VECTOR_X_OUT_FROM_DFPM);
				
	

	---------------------------------------------------------------------


end Behavioral;

