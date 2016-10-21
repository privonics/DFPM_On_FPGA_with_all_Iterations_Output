    --------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:25:52 01/15/2015
-- Design Name:   
-- Module Name:   C:/Users/Temilolu/Documents/Digital Design workspace - VHDL and VERILOG/Test_Codes_For_Project/test_Signed_DFPM_Iteration_Control_Top_Module.vhd
-- Project Name:  Test_Codes_For_Project
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Signed_DFPM_Iteration_Control_Top_Module
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.DFPM_ARRAY_5X32_BIT.all;
use work.DFPM_ARRAY_25X32_BIT.all; 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY test_Signed_DFPM_Iteration_Control_Top_Module IS
END test_Signed_DFPM_Iteration_Control_Top_Module;
 
ARCHITECTURE behavior OF test_Signed_DFPM_Iteration_Control_Top_Module IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Signed_DFPM_Iteration_Control_Top_Module
		 Port ( 	  VECTOR_A_IN : IN  DFPM_SIGNED_VECTOR_25X32_BIT;
					  VECTOR_B_IN : IN  DFPM_SIGNED_VECTOR_5X32_BIT;				  
					  
					  DATA_READY_FROM_UART_RX : IN  STD_LOGIC;
					   
					  CLK : IN  STD_LOGIC;
					  RST : IN  STD_LOGIC;
					  
					  VECTOR_B_AX : OUT  DFPM_SIGNED_VECTOR_5X32_BIT;
					  
					  DATA_READY_FROM_ONE_ITERATION 	 : OUT  STD_LOGIC := '0';
					  DATA_READY_FROM_DFPM_ITERATIONS : OUT  STD_LOGIC := '0';
					  VECTOR_X_OUT : OUT  DFPM_SIGNED_VECTOR_5X32_BIT);
		 END COMPONENT;
    

   --Inputs
   signal VECTOR_A_IN : DFPM_SIGNED_VECTOR_25X32_BIT;
   signal VECTOR_B_IN : DFPM_SIGNED_VECTOR_5X32_BIT;
   signal DATA_READY_FROM_UART_RX : std_logic := '0';
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';

 	--Outputs
	Signal VECTOR_B_AX : DFPM_SIGNED_VECTOR_5X32_BIT;
	Signal DATA_READY_FROM_ONE_ITERATION 	: STD_LOGIC := '0';
   signal DATA_READY_FROM_DFPM_ITERATIONS : std_logic;
   signal VECTOR_X_OUT : DFPM_SIGNED_VECTOR_5X32_BIT;

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Signed_DFPM_Iteration_Control_Top_Module PORT MAP (
          VECTOR_A_IN => VECTOR_A_IN,
          VECTOR_B_IN => VECTOR_B_IN,
          DATA_READY_FROM_UART_RX => DATA_READY_FROM_UART_RX,
          CLK => CLK,
          RST => RST,
			 VECTOR_B_AX => VECTOR_B_AX, 
			 DATA_READY_FROM_ONE_ITERATION =>DATA_READY_FROM_ONE_ITERATION,
          DATA_READY_FROM_DFPM_ITERATIONS => DATA_READY_FROM_DFPM_ITERATIONS,
          VECTOR_X_OUT => VECTOR_X_OUT
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
	Variable Var_A_Sig_0_0, Var_A_Sig_0_1, Var_A_Sig_0_2, Var_A_Sig_0_3, Var_A_Sig_0_4 : signed(32 downto 0) := (Others => '0');
	Variable Var_A_Sig_1_0, Var_A_Sig_1_1, Var_A_Sig_1_2, Var_A_Sig_1_3, Var_A_Sig_1_4 : signed(32 downto 0) := (Others => '0');
	Variable Var_A_Sig_2_0, Var_A_Sig_2_1, Var_A_Sig_2_2, Var_A_Sig_2_3, Var_A_Sig_2_4 : signed(32 downto 0) := (Others => '0');
	Variable Var_A_Sig_3_0, Var_A_Sig_3_1, Var_A_Sig_3_2, Var_A_Sig_3_3, Var_A_Sig_3_4 : signed(32 downto 0) := (Others => '0');
	Variable Var_A_Sig_4_0, Var_A_Sig_4_1, Var_A_Sig_4_2, Var_A_Sig_4_3, Var_A_Sig_4_4 : signed(32 downto 0) := (Others => '0');
	
   begin		
      -- hold reset state for 100 ns.
      wait for 200 ns;	

      wait for CLK_period*10;
		-----------***Variables to be inserted in the 25X5 A Vector***------------------
		Var_A_Sig_0_0 := "000000000000000010000000000000000"; -- 1*2^(16)
		Var_A_Sig_0_1 := "000000000000000100000000000000000"; -- 2*2^(16)
		Var_A_Sig_0_2 := "000000000000000110000000000000000"; -- 3*2^(16)
		Var_A_Sig_0_3 := "000000000000001000000000000000000"; -- 4*2^(16)
		Var_A_Sig_0_4 := "000000000000001010000000000000000"; -- 5*2^(16)
		
		Var_A_Sig_1_0 := "000000000000000100000000000000000"; -- 2*2^(16)
		Var_A_Sig_1_1 := "000000000000000100000000000000000"; -- 2*2^(16)
		Var_A_Sig_1_2 := "000000000000000110000000000000000"; -- 3*2^(16)
		Var_A_Sig_1_3 := "000000000000001000000000000000000"; -- 4*2^(16)
		Var_A_Sig_1_4 := "000000000000001010000000000000000"; -- 5*2^(16)
		
		Var_A_Sig_2_0 := "000000000000000110000000000000000"; -- 3*2^(16)
		Var_A_Sig_2_1 := "000000000000000110000000000000000"; -- 3*2^(16)
		Var_A_Sig_2_2 := "000000000000000110000000000000000"; -- 3*2^(16)
		Var_A_Sig_2_3 := "000000000000001000000000000000000"; -- 4*2^(16)
		Var_A_Sig_2_4 := "000000000000001010000000000000000"; -- 5*2^(16)
		
		Var_A_Sig_3_0 := "000000000000001000000000000000000"; -- 4*2^(16)
		Var_A_Sig_3_1 := "000000000000001000000000000000000"; -- 4*2^(16)
		Var_A_Sig_3_2 := "000000000000001000000000000000000"; -- 4*2^(16)
		Var_A_Sig_3_3 := "000000000000001000000000000000000"; -- 4*2^(16)
		Var_A_Sig_3_4 := "000000000000001010000000000000000"; -- 5*2^(16)
		
		Var_A_Sig_4_0 := "000000000000001010000000000000000"; -- 5*2^(16)
		Var_A_Sig_4_1 := "000000000000001010000000000000000"; -- 5*2^(16)
		Var_A_Sig_4_2 := "000000000000001010000000000000000"; -- 5*2^(16)
		Var_A_Sig_4_3 := "000000000000001010000000000000000"; -- 5*2^(16)
		Var_A_Sig_4_4 := "000000000000001010000000000000000"; -- 5*2^(16)
		-----------------------------------------------------------------

      -- insert stimulus here 
		DATA_READY_FROM_UART_RX <= '1';
		
		Vector_A_IN(0) <= ("000000000000010010000000000000000", Var_A_Sig_0_1, Var_A_Sig_0_2, Var_A_Sig_0_3, Var_A_Sig_0_4);
		Vector_A_IN(1) <= (Var_A_Sig_0_0, "000000000000001110000000000000000", Var_A_Sig_0_2, Var_A_Sig_0_3, Var_A_Sig_0_4);
		Vector_A_IN(2) <= (Var_A_Sig_0_0, Var_A_Sig_0_1, "000000000000010010000000000000000", Var_A_Sig_0_3, Var_A_Sig_0_4);
		Vector_A_IN(3) <= (Var_A_Sig_0_0, Var_A_Sig_0_1, Var_A_Sig_0_2, "000000000000010000000000000000000", Var_A_Sig_0_4);
		Vector_A_IN(4) <= (Var_A_Sig_0_0, Var_A_Sig_0_1, Var_A_Sig_0_2, Var_A_Sig_0_3, "000000000000010010000000000000000");
		
		Vector_B_IN(0) <= "000000000000000010000000000000000"; -- 1*2^(16)
		Vector_B_IN(1) <= "000000000000000100000000000000000"; -- 2*2^(16)
		Vector_B_IN(2) <= "000000000000000110000000000000000"; -- 3*2^(16)
		Vector_B_IN(3) <= "000000000000001000000000000000000"; -- 4*2^(16)
		Vector_B_IN(4) <= "000000000000001010000000000000000"; -- 5*2^(16)
		 
		
		
		wait for CLK_period;
		DATA_READY_FROM_UART_RX <= '0';
		
		wait until DATA_READY_FROM_DFPM_ITERATIONS = '1';
		
		wait for CLK_period*10;
		
		--RST <= '1';
		
		wait for CLK_period;
		
		RST <= '0';
		
		wait for CLK_period;
		
--		DATA_READY_FROM_UART_RX <= '1';
--		
--		Vector_A_IN(0) <= ("000000000000010000000000000000000", Var_A_Sig_0_1, Var_A_Sig_0_2, Var_A_Sig_0_3, Var_A_Sig_0_4);
--		Vector_A_IN(1) <= (Var_A_Sig_0_0, "000000000000001110000000000000000", Var_A_Sig_0_2, Var_A_Sig_0_3, Var_A_Sig_0_4);
--		Vector_A_IN(2) <= (Var_A_Sig_0_0, Var_A_Sig_0_1, "000000000000010010000000000000000", Var_A_Sig_0_3, Var_A_Sig_0_4);
--		Vector_A_IN(3) <= (Var_A_Sig_0_0, Var_A_Sig_0_1, Var_A_Sig_0_2, "000000000000010000000000000000000", Var_A_Sig_0_4);
--		Vector_A_IN(4) <= (Var_A_Sig_0_0, Var_A_Sig_0_1, Var_A_Sig_0_2, Var_A_Sig_0_3, "000000000000010010000000000000000");
--		
--		Vector_B_IN(0) <= "000000000000000010000000000000000"; -- 1*2^(16)
--		Vector_B_IN(1) <= "000000000000000100000000000000000"; -- 2*2^(16)
--		Vector_B_IN(2) <= "000000000000000110000000000000000"; -- 3*2^(16)
--		Vector_B_IN(3) <= "000000000000001000000000000000000"; -- 4*2^(16)
--		Vector_B_IN(4) <= "000000000000001010000000000000000"; -- 5*2^(16)
--		
--		
--		
--		wait for CLK_period;
--		DATA_READY_FROM_UART_RX <= '0';
		

      wait;
   end process;

END;

