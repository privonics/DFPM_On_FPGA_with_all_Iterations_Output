----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:29:18 10/19/2014 
-- Design Name: 
-- Module Name:    Vector_Mult_5x5 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package DFPM_VECTOR_5X32_BIT is
	type DFPM_VECTOR_5X32_BIT is array (0 to 4) of STD_LOGIC_VECTOR (32 downto 0);
end DFPM_VECTOR_5X32_BIT;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.DFPM_VECTOR_5X32_BIT.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Vector_Mult_5x5 is
	 Generic (VectorSize : integer := 32;
				 ArrayDimension : integer := 5;
				 Input_Data_Size : integer := 25);
    Port (V_A : in DFPM_VECTOR_5X32_BIT;
			 V_B : in DFPM_VECTOR_5X32_BIT;
			 CLK : in  STD_LOGIC;			 				
			 V_Out : out STD_LOGIC_VECTOR(VectorSize downto 0));
end Vector_Mult_5x5;

architecture Behavioral of Vector_Mult_5x5 is

		COMPONENT Multiplier_32_bit
			PORT(
				data_a : IN std_logic_vector(31 downto 0);
				data_b : IN std_logic_vector(31 downto 0);
				d_a_sign : IN std_logic;
				d_b_sign : IN std_logic;
				clk : IN std_logic;          
				data_64out : OUT std_logic_vector(63 downto 0);
				d_out_sign : OUT std_logic;
				data_out : OUT std_logic_vector(31 downto 0)
				);
			END COMPONENT;
		
		COMPONENT Adder_32_bit_2
			PORT(
				data_a : IN std_logic_vector(31 downto 0);
				data_b : IN std_logic_vector(31 downto 0);
				d_a_sign : IN std_logic;
				d_b_sign : IN std_logic;
				clk : IN std_logic;          
				data_out : OUT std_logic_vector(31 downto 0);
				d_out_sign : OUT std_logic;
				cout : OUT std_logic
				);
			END COMPONENT;	

		COMPONENT Adder_32_bit_5_In_3_Out
			PORT(
				Vector_A : IN std_logic_vector(32 downto 0);
				Vector_B : IN std_logic_vector(32 downto 0);
				Vector_C : IN std_logic_vector(32 downto 0);
				Vector_D : IN std_logic_vector(32 downto 0);
				Vector_E_In : IN std_logic_vector(32 downto 0);
				Clk : IN std_logic;          
				Vector_A_Plus_B : OUT std_logic_vector(32 downto 0);
				Vector_C_Plus_D : OUT std_logic_vector(32 downto 0);
				Vector_E_Out : OUT std_logic_vector(32 downto 0)
				);
			END COMPONENT;
		
		COMPONENT Adder_32_bit_3_In_2_Out
			PORT(
				Vector_AB_Sum : IN std_logic_vector(32 downto 0);
				Vector_CD_Sum : IN std_logic_vector(32 downto 0);
				Vector_E_In : IN std_logic_vector(32 downto 0);
				Clk : IN std_logic;          
				Vector_AB_Plus_CD : OUT std_logic_vector(32 downto 0);
				vector_E_Out : OUT std_logic_vector(32 downto 0)
				);
			END COMPONENT;
		
		

		signal RESULT_MULT_0, RESULT_MULT_1, RESULT_MULT_2, RESULT_MULT_3, RESULT_MULT_4 : 
																			std_logic_vector(32 downto 0):=(others => '0');
		signal RESULT_ADD_MULT_01, RESULT_ADD_MULT_23, RESULT_ADD_MULT_4, RESULT_ADD_MULT_01_MULT_23,RESULT_ADD_MULT_4_STAGE_2 : 
																			std_logic_vector(32 downto 0):=(others => '1');

begin	
	
	MULT_0: Multiplier_32_bit PORT MAP(
		data_a => V_A(0)(31 downto 0),data_b => V_B(0)(31 downto 0),d_a_sign => V_A(0)(32),d_b_sign => V_B(0)(32),
		clk => CLK,data_64out => open,
		d_out_sign => RESULT_MULT_0(32),data_out => RESULT_MULT_0(31 downto 0));

	MULT_1: Multiplier_32_bit PORT MAP(
		data_a => V_A(1)(31 downto 0),data_b => V_B(1)(31 downto 0),d_a_sign => V_A(1)(32),d_b_sign => V_B(1)(32),
		clk => CLK,data_64out => open,
		d_out_sign => RESULT_MULT_1(32),data_out => RESULT_MULT_1(31 downto 0));	

	MULT_2: Multiplier_32_bit PORT MAP(
		data_a => V_A(2)(31 downto 0),data_b => V_B(2)(31 downto 0),d_a_sign => V_A(2)(32),d_b_sign => V_B(2)(32),
		clk => CLK,data_64out => open,
		d_out_sign => RESULT_MULT_2(32),data_out => RESULT_MULT_2(31 downto 0));
	
	MULT_3: Multiplier_32_bit PORT MAP(
		data_a => V_A(3)(31 downto 0),data_b => V_B(3)(31 downto 0),d_a_sign => V_A(3)(32),d_b_sign => V_B(3)(32),
		clk => CLK,data_64out => open,
		d_out_sign => RESULT_MULT_3(32),data_out => RESULT_MULT_3(31 downto 0));

	MULT_4: Multiplier_32_bit PORT MAP(
		data_a => V_A(4)(31 downto 0),data_b => V_B(4)(31 downto 0),d_a_sign => V_A(4)(32),d_b_sign => V_B(4)(32),
		clk => CLK,data_64out => open,
		d_out_sign => RESULT_MULT_4(32),data_out => RESULT_MULT_4(31 downto 0));
		
	ADDING_PRODUCTS_STAGE_1: Adder_32_bit_5_In_3_Out PORT MAP(
		Vector_A => RESULT_MULT_0,
		Vector_B => RESULT_MULT_1,
		Vector_C => RESULT_MULT_2,
		Vector_D => RESULT_MULT_3,
		Vector_E_In => RESULT_MULT_4,
		Clk => CLK,
		Vector_A_Plus_B => RESULT_ADD_MULT_01,
		Vector_C_Plus_D => RESULT_ADD_MULT_23,
		Vector_E_Out => RESULT_ADD_MULT_4);

	ADDING_PRODUCTS_STAGE_2: Adder_32_bit_3_In_2_Out PORT MAP(
		Vector_AB_Sum => RESULT_ADD_MULT_01,
		Vector_CD_Sum => RESULT_ADD_MULT_23,
		Vector_E_In => RESULT_ADD_MULT_4,
		Clk => CLK,
		Vector_AB_Plus_CD => RESULT_ADD_MULT_01_MULT_23,
		vector_E_Out => RESULT_ADD_MULT_4_STAGE_2);
	
	ADDING_PRODUCS_STAGE_3: Adder_32_bit_2 PORT MAP(
		data_a => RESULT_ADD_MULT_01_MULT_23(31 downto 0),data_b => RESULT_ADD_MULT_4_STAGE_2(31 downto 0),
		d_a_sign => RESULT_ADD_MULT_01_MULT_23(32),d_b_sign => RESULT_ADD_MULT_4_STAGE_2(32),
		clk => CLK,
		data_out => V_Out(31 downto 0),d_out_sign => V_Out(32),cout => open);
		
end Behavioral;