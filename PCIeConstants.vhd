----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:30:37 10/30/2011 
-- Design Name: 
-- Module Name:    PCIeConstants - Behavioral 
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

package pcie_constants is
        --Formatos
        constant  PCIeFMT_3DW : std_logic_vector(1 downto 0) := "00";
        constant  PCIeFMT_4DW : std_logic_vector(1 downto 0) := "01";
        constant  PCIeFMT_3DWD: std_logic_vector(1 downto 0) := "10";
        constant  PCIeFMT_4DWD : std_logic_vector(1 downto 0) := "11";
        --Tipos
        constant  PCIeType_MRd : std_logic_vector(4 downto 0) := "00000";
        constant  PCIeType_MWr : std_logic_vector(4 downto 0) := "00000";
        constant  PCIeType_Cpl : std_logic_vector(4 downto 0) := "01010";
        constant  PCIeType_CplD : std_logic_vector(4 downto 0) := "01010";

end pcie_constants;
