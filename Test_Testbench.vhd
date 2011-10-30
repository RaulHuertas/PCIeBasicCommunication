--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:11:13 09/28/2011
-- Design Name:   
-- Module Name:   /home/rhuertas/FPGAProjects/PCIeTest/Test_Testbench.vhd
-- Project Name:  PCIeTest
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Test
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY Test_Testbench IS
END Test_Testbench;
 
ARCHITECTURE behavior OF Test_Testbench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Test
    PORT(
         A : IN  std_logic;
         B : OUT  std_logic;
         Clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal A : std_logic := '0';
   signal Clk : std_logic := '0';

 	--Outputs
   signal B : std_logic;

   -- Clock period definitions
   constant Clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Test PORT MAP (
          A => A,
          B => B,
          Clk => Clk
        );

   -- Clock process definitions
   Clk_process :process
   begin
		Clk <= '0';
		wait for Clk_period/2;
		Clk <= '1';
		wait for Clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for Clk_period*10;

      -- insert stimulus here ';
		A<='1';
		wait for Clk_period;
		A<='0';
		wait for Clk_period;
		A<='1';
		wait for Clk_period;
		A<='0';
		wait for Clk_period;
		wait for Clk_period;
		wait for Clk_period;
      wait;
   end process;

END;
