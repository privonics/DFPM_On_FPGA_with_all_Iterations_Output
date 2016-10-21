----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:10:43 11/11/2014 
-- Design Name: 
-- Module Name:    Vector_Mult_25X5 - Behavioral 
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
use work.DFPM_VECTOR_5X32_BIT.all;

package DFPM_VECTOR_25X32_BIT is
	type DFPM_VECTOR_25X32_BIT is array (0 to 4) of DFPM_VECTOR_5X32_BIT;
end DFPM_VECTOR_25X32_BIT;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
use work.DFPM_VECTOR_5X32_BIT.all;
use work.DFPM_VECTOR_25X32_BIT.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Vector_Mult_25X5 is
    Port ( Vector_A : in  DFPM_VECTOR_25X32_BIT;
           Vector_B : in  DFPM_VECTOR_5X32_BIT;
           CLK : in  STD_LOGIC;
           Vector_Out : out  DFPM_VECTOR_5X32_BIT);
end Vector_Mult_25X5;

architecture Behavioral of Vector_Mult_25X5 is
	
	COMPONENT Vector_Mult_5x5
		 PORT(
				V_A : IN  DFPM_VECTOR_5X32_BIT;
				V_B : IN  DFPM_VECTOR_5X32_BIT;
				CLK : IN  std_logic;
				V_Out : OUT  std_logic_vector(32 downto 0)
			  );
		 END COMPONENT;

begin

	Vector_Group_0: Vector_Mult_5x5 PORT MAP(
		V_A => Vector_A(0),
		V_B => vector_B,
		CLK => CLK,
		V_Out => Vector_Out(0));

	Vector_Group_1: Vector_Mult_5x5 PORT MAP(
		V_A => Vector_A(1),
		V_B => vector_B,
		CLK => CLK,
		V_Out => Vector_Out(1));
		
	Vector_Group_2: Vector_Mult_5x5 PORT MAP(
		V_A => Vector_A(2),
		V_B => vector_B,
		CLK => CLK,
		V_Out => Vector_Out(2));
		
	Vector_Group_3: Vector_Mult_5x5 PORT MAP(
		V_A => Vector_A(3),
		V_B => vector_B,
		CLK => CLK,
		V_Out => Vector_Out(3));

	Vector_Group_4: Vector_Mult_5x5 PORT MAP(
		V_A => Vector_A(4),
		V_B => vector_B,
		CLK => CLK,
		V_Out => Vector_Out(4));

end Behavioral;

