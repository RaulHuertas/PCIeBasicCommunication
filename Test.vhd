----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:46:43 09/26/2011 
-- Design Name: 
-- Module Name:    Test - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Test is
    Port ( A : in  STD_LOGIC;
           B : out  STD_LOGIC;
           Clk : in  STD_LOGIC);
end Test;

architecture Behavioral of Test is

begin
	clocking: process(Clk, A) begin
		if( rising_edge(Clk)) then
			B <= A;
		end if;
	end process;

end Behavioral;

