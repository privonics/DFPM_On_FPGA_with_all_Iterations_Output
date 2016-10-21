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
use work.DFPM_ARRAY_25X32_BIT.all;
use IEEE.NUMERIC_STD.ALL;


entity Signed_SubtrAndMult_Ops_Module is
    Port ( Vector_A : in  DFPM_SIGNED_VECTOR_25X32_BIT;
           Vector_B : in  DFPM_SIGNED_VECTOR_5X32_BIT;
           Vector_X : in  DFPM_SIGNED_VECTOR_5X32_BIT;
           Scalar_Mu : in  SIGNED (32 downto 0);
           Vector_V : in  DFPM_SIGNED_VECTOR_5X32_BIT;
			  
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
			  NEW_ITERATION : in  STD_LOGIC := '0';
			  ITERATION_COMPLETE : out  STD_LOGIC:= '0';
			  
           B_Minus_AX : out  DFPM_SIGNED_VECTOR_5X32_BIT;
           B_Minus_Ax_Minus_muV : out  DFPM_SIGNED_VECTOR_5X32_BIT);
end Signed_SubtrAndMult_Ops_Module;

architecture Behavioral of Signed_SubtrAndMult_Ops_Module is

------------------------------------------------


	-- This component will be used to evaluate
	-- The vector multiplication A*X
	-- It takes two input of 5 by 1 vectors
	COMPONENT Signed_Vector_Vector_Mult_5By1
		 PORT(
				Vector_1 : IN  DFPM_SIGNED_VECTOR_5X32_BIT;
				Vector_2 : IN  DFPM_SIGNED_VECTOR_5X32_BIT;
				CLK : IN  std_logic;
				RST : IN  std_logic;
				Vector_Out : OUT  Signed(32 downto 0)
			  );
		 END COMPONENT;
	
	-- This component will be used top evaluate the subtraction in B - Ax
	COMPONENT Signed_Vector_Vector_5By1_Subtr
		 Port ( Vector_1 : in  DFPM_SIGNED_VECTOR_5X32_BIT;
				  vector_2 : in  DFPM_SIGNED_VECTOR_5X32_BIT;
				  CLK : in  STD_LOGIC;
				  RST : in  STD_LOGIC;
				  Vector_Out : out  DFPM_SIGNED_VECTOR_5X32_BIT);
		 END COMPONENT;
    
------------------------------------------------

		

------------------------------------------------
	-- Signals for storing the input values
	Signal Sig_Vector_A : DFPM_SIGNED_VECTOR_25X32_BIT := (	((Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'), (Others => '0')),
																				((Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'), (Others => '0')),
																				((Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'), (Others => '0')),
																				((Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'), (Others => '0')),
																				((Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'), (Others => '0')));
																				
   Signal Sig_Vector_B : DFPM_SIGNED_VECTOR_5X32_BIT := ((Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'));
   Signal Sig_Vector_X : DFPM_SIGNED_VECTOR_5X32_BIT := ((Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'));
   Signal Sig_Scalar_Mu: SIGNED (32 downto 0);
   Signal Sig_Vector_V : DFPM_SIGNED_VECTOR_5X32_BIT := ((Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'));
	
	
	-- The two signals below are used to connect the signals at the Vector_vector_Mult_Module
	-- To the the Corresponding Vector indexes.
	-- These were used to avoid assigning Dynamically changing signals directly to a static line
	Signal Sig_Vector_A_With_IndexPosition : DFPM_SIGNED_VECTOR_5X32_BIT := ((Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'));
	
	Signal Sig_Vector_A_Mult_X_With_IndexPosition : SIGNED (32 downto 0);
	
	-- These following two(2) signals will be used to store the products of the 
	-- Multiplication of Vectors A and X
	-- as well as Scalar mu and Vector V.
	Signal Sig_Vector_A_Mult_X : DFPM_SIGNED_VECTOR_5X32_BIT := ((Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'));
	Signal Sig_Vector_Mu_Mult_V : DFPM_SIGNED_VECTOR_5X32_BIT := ((Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'));
	
	-- These following tow signals will be used to store the result 
	-- of the subtraction operations
	Signal Sig_Vector_B_Minus_AX : DFPM_SIGNED_VECTOR_5X32_BIT := ((Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'));
	Signal Sig_Vector_B_Minus_AX_Minus_MuV : DFPM_SIGNED_VECTOR_5X32_BIT := ((Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'), (Others => '0'));
	
	-- This signal will only be raised for one clock cycle 
	-- when there is a new set of data for available computation
	Signal DFPMCompute : STD_LOGIC := '0';
	
	-- This signal is used to sommunicate with other modules "downstream" of this module
	-- when there the result of this module's computation is ready
	Signal Sig_ITERATION_COMPLETE : STD_LOGIC := '0';
	
	-- This Signal will be used to represent the index position that 
	-- that will be progressively incremented as a means of pipelining
	-- data for multiplication in this module as well as input for the
	-- Vector_Vector_Multiplication module
	Signal MultplicationStageArrayPosition : integer := 0;
	
	-- This signal will be used to signal when the index position 
	-- can be shifted and when data can be stored for output
	Signal Shift_Array_Position : STD_LOGIC := '0';
	
	-- This signal will be raised once when all the products of multiplication are ready.
	-- This is to enable the module to signal to other modules "downstream"
	-- that the result of the computation is ready
	Signal MultiplicationProductsReady : STD_LOGIC := '0';
	
	Signal ReadyFlag 			: STD_LOGIC := '0';
	
	-- This clock signal was created as a slowed down (half pace of CLK)
	-- And will be used for clocking the shifting of the index position
	Signal Sig_Clk_For_Index_Shifting : STD_LOGIC := '0';
	

begin
	-- For Vector - Vector multiplication
	Vector_Vector_Mult: Signed_Vector_Vector_Mult_5By1 PORT MAP (
          Vector_1 => Sig_Vector_A_With_IndexPosition,
          Vector_2 => Sig_Vector_X,
          CLK => CLK,
          RST => RST,
          Vector_Out => Sig_Vector_A_Mult_X_With_IndexPosition);
		  
	-- For Subtraction operations for B - AX
	Doing_B_Minus_AX : Signed_Vector_Vector_5By1_Subtr PORT MAP (
          Vector_1 => Sig_Vector_B,
          vector_2 => Sig_Vector_A_Mult_X,
          CLK => CLK,
          RST => RST,
          Vector_Out => Sig_Vector_B_Minus_AX);	
	
	-- For Subtraction operations for B - AX - muV
	Doing_B_Minus_AX_Minus_MuV : Signed_Vector_Vector_5By1_Subtr PORT MAP (
          Vector_1 => Sig_Vector_B_Minus_AX,
          vector_2 => Sig_Vector_Mu_Mult_V,
          CLK => CLK,
          RST => RST,
          Vector_Out => Sig_Vector_B_Minus_AX_Minus_MuV);
	
	-- This signal wiill be used to signal that the output of this module is ready to be read.
	ITERATION_COMPLETE <= Sig_ITERATION_COMPLETE;
	
	
	
	
	
	-- This process determines the when each iteration of the DFPM algorithm is to be started
	-- Computation will only be done if it's a new iteration and it has not been completed before
	-- Therefore this process sets DFPMCompute to '1' only on the rising edge of NEW_ITERATION
	-- And stored new Value into the Vectors only at the rising edge of NEW_ITERATION
	process(CLK, RST, Sig_ITERATION_COMPLETE, NEW_ITERATION)
		Variable NEW_ITERATION_Var : STD_LOGIC := '0';
		begin
			if rising_edge(CLK) then
				if (RST = '1') then
					DFPMCompute <= '0';
					NEW_ITERATION_Var := '0';
				elsif (Sig_ITERATION_COMPLETE = '1') then
					NEW_ITERATION_Var := '0';
					DFPMCompute <= '0';
				-- This more or less senses for the rising edge of NEW_ITERATION
				elsif (NEW_ITERATION = '1') and (NEW_ITERATION_Var = '0') then				
					--if rising_edge(NEW_ITERATION) then
					NEW_ITERATION_Var := '1';
					
					Sig_Vector_A <= Vector_A;
					Sig_Vector_B <= Vector_B;
					Sig_Vector_X <= Vector_X;
					Sig_Vector_V <= Vector_V;
					Sig_Scalar_Mu <= Scalar_Mu;
					
					DFPMCompute <= '1';
				elsif (NEW_ITERATION = '1') and (NEW_ITERATION_Var = '1') then
					NEW_ITERATION_Var := '0';
					DFPMCompute <= '0';
				elsif (NEW_ITERATION = '0') then
					NEW_ITERATION_Var := '0';
					DFPMCompute <= '0';
				end if;
			end if;
		end process;
	
	
	-- This process determies the array postions to be multiplied together for A*X
	process(RST, Sig_ITERATION_COMPLETE, DFPMCompute, Shift_Array_Position, NEW_ITERATION, CLK, Sig_Clk_For_Index_Shifting, MultplicationStageArrayPosition, Sig_Vector_A, Sig_Vector_A_Mult_X_With_IndexPosition, Sig_Scalar_Mu, Sig_Vector_V)
		Variable MultplicationStageArrayPosition_Var : integer := 0;
		
		begin
			if (RST = '1') then
				MultplicationStageArrayPosition <= 0;
				Shift_Array_Position <= '0';
				MultiplicationProductsReady <= '0';
				
			elsif (Sig_ITERATION_COMPLETE = '1') then
				MultplicationStageArrayPosition <= 0;
				Shift_Array_Position <= '0';
			
			elsif (DFPMCompute = '1') then -- Checking for the rising edge of NEW iteration here
				MultplicationStageArrayPosition <= 0;
				Shift_Array_Position <= '1';
				MultiplicationProductsReady <= '0';		

--				Sig_Vector_A_With_IndexPosition <= Sig_Vector_A(0);
--				Sig_Vector_A_Mult_X(0) <= Sig_Vector_A_Mult_X_With_IndexPosition;
--				productTempStore := Sig_Scalar_Mu * Sig_Vector_V(0);
--				Sig_Vector_Mu_Mult_V(MultplicationStageArrayPosition) <= productTempStore(48 downto 16);	
				
			elsif (Shift_Array_Position = '1') then
				if rising_edge(Sig_Clk_For_Index_Shifting) then				
					if (MultplicationStageArrayPosition = 5) then
						MultplicationStageArrayPosition <= 0;
						Shift_Array_Position <= '0';
						MultiplicationProductsReady <= '1';						
					else
						MultplicationStageArrayPosition_Var := MultplicationStageArrayPosition;
						MultplicationStageArrayPosition <= MultplicationStageArrayPosition_Var + 1;					
					end if;
				end if;
			end if;
		end process;
	
	process(CLK, DFPMCompute, Shift_Array_Position, MultplicationStageArrayPosition)
		Variable productTempStore : Signed(65 downto 0);
		begin
			if rising_edge(CLK) then
				if (Shift_Array_Position = '1')  and ( MultplicationStageArrayPosition < 5) then
					case MultplicationStageArrayPosition is 
						when 0 =>
							Sig_Vector_A_With_IndexPosition <= Sig_Vector_A(0);
							Sig_Vector_A_Mult_X(0) <= Sig_Vector_A_Mult_X_With_IndexPosition;
							productTempStore := Sig_Scalar_Mu * Sig_Vector_V(0);
						when 1 =>
							Sig_Vector_A_With_IndexPosition <= Sig_Vector_A(1);
							Sig_Vector_A_Mult_X(1) <= Sig_Vector_A_Mult_X_With_IndexPosition;
							productTempStore := Sig_Scalar_Mu * Sig_Vector_V(1);
						when 2 =>
							Sig_Vector_A_With_IndexPosition <= Sig_Vector_A(2);
							Sig_Vector_A_Mult_X(2) <= Sig_Vector_A_Mult_X_With_IndexPosition;
							productTempStore := Sig_Scalar_Mu * Sig_Vector_V(2);
						when 3 =>
							Sig_Vector_A_With_IndexPosition <= Sig_Vector_A(3);
							Sig_Vector_A_Mult_X(3) <= Sig_Vector_A_Mult_X_With_IndexPosition;
							productTempStore := Sig_Scalar_Mu * Sig_Vector_V(3);
						when 4 =>
							Sig_Vector_A_With_IndexPosition <= Sig_Vector_A(4);
							Sig_Vector_A_Mult_X(4) <= Sig_Vector_A_Mult_X_With_IndexPosition;
							productTempStore := Sig_Scalar_Mu * Sig_Vector_V(4);
						when Others =>
							NULL;
					end case;				
	--						-- Setting the correcponding Vector_A element as the input to the Vector_Vector_Mult_Module
	--						Sig_Vector_A_With_IndexPosition <= Sig_Vector_A(MultplicationStageArrayPosition);
	--						-- Connecting the output of the Vector_Vector_Mult module to tghe corresponding A_Mult_X index
	--						Sig_Vector_A_Mult_X(MultplicationStageArrayPosition) <= Sig_Vector_A_Mult_X_With_IndexPosition;
	--						-- Doing mu*V
	--						productTempStore := Sig_Scalar_Mu * Sig_Vector_V(MultplicationStageArrayPosition);
					Sig_Vector_Mu_Mult_V(MultplicationStageArrayPosition) <= productTempStore(48 downto 16);
				end if;
			end if;
		end process;
	
	
	-- This process clears ITERATION_COMPLETE and 
	-- only sets it to 1 when the MultiplicationProductsReady signal is high.
	-- At the rising_edge of MultiplicationProductsReady, the vectors
	-- B_Minus_AX and B_Minus_Ax_Minus_muV are assigned.
	process(CLK, RST, DFPMCompute, MultiplicationProductsReady, ReadyFlag)
		begin
			if rising_edge(clk) then
				if (RST = '1') then
					Sig_ITERATION_COMPLETE <= '0';
					ReadyFlag <= '0';
					
				elsif (DFPMCompute = '1') then
					Sig_ITERATION_COMPLETE <= '0';
					ReadyFlag <= '0';
				elsif (MultiplicationProductsReady = '1')  and (ReadyFlag = '0') then
					ReadyFlag <= '1';
					
					Sig_ITERATION_COMPLETE <= '1';
					B_Minus_AX <= Sig_Vector_B_Minus_AX;
					B_Minus_Ax_Minus_muV <= Sig_Vector_B_Minus_AX_Minus_MuV;
				else	
					Sig_ITERATION_COMPLETE <= '0';
--				end if;
				end if;
			end if;
		end process;
		
	-- The clock signal created in this process is a real afterthought
	-- It would not have been created if this module had behaved itself ;-))
	-- It was observed that the circuit computed an output that was wrong
	-- For as long as the shifting of the index position was based on the normal clock "CLK"
	-- Hence this clock that cuts the speed to half.
	process(CLK)
		begin
			if rising_edge(CLK) then
				Sig_Clk_For_Index_Shifting <= not(Sig_Clk_For_Index_Shifting);
			end if;		End process;

end Behavioral;

