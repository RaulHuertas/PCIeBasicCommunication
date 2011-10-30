----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:20:41 10/08/2011 
-- Design Name: 
-- Module Name:    PCIeBasicRX - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;

entity PCIeBasicRX is
port(
        --INTERFAZ PCIe
     pci_exp_clk_p : in std_logic;
     pci_exp_clk_n : in std_logic;
	pci_exp_txp0: out std_logic;
	pci_exp_txn0: out std_logic;
	pci_exp_rxp0: in std_logic;
	pci_exp_rxn0: in std_logic;
    pci_exp_perst_b: in std_logic;
    --Salidas para la depuracion
    leds : out std_logic_vector(3 downto 0);
    button : in std_logic
);
end PCIeBasicRX;

architecture Behavioral of PCIeBasicRX is

component PCIeTestWrapp  
port(
	--INTERFAZ DEL SISTEMA
	sys_reset : in std_logic;
	sys_clk_125MHz: in std_logic;
	received_hot_reset: out std_logic;
	--INTERFAZ PCIe
	pci_exp_txp0: out std_logic;
	pci_exp_txn0: out std_logic;
	pci_exp_rxp0: in std_logic;
	pci_exp_rxn0: in std_logic;
	--INTERFAZ DE USUARIO
	user_clk_out : out std_logic;
	user_reset_out : out std_logic;
	user_lnk_up : out std_logic;
	--INTERFAZ DE TRANSMISION
	s_axis_tx_tlast : in std_logic;
	s_axis_tx_tdata : in std_logic_vector(31 downto 0);
	s_axis_tx_tvalid : in std_logic;
	s_axis_tx_tready : out std_logic;
	src_dsc : in std_logic;
	tx_terr_drop: out std_logic;
	str : in std_logic;
	tx_cfg_req: out std_logic;
	tx_cfg_gnt: in std_logic;
	terr_fwd: in std_logic;
	--INTERFAZ DE RECEPCION
	m_axis_rx_tlast: out std_logic;
	m_axis_rx_tdata: out std_logic_vector(31 downto 0);
	rerr_fw : out std_logic;
	m_axis_rx_tvalid : out std_logic;
	m_axis_rx_tready: in std_logic;
	rx_np_ok : in std_logic;
	bar_hit : out std_logic_vector(6 downto 0);
	--INTERFAZ DE CONFIGURACION
	cfg_do: out std_logic_vector(31 downto 0);
	cfg_rd_wr_done : out std_logic;
	cfg_dwaddr: in std_logic_vector(9 downto 0);
	cfg_rd_en: in std_logic;
	cfg_interrupt : in std_logic;
	cfg_interrupt_rdy : out std_logic;
	cfg_interrupt_msienable : out std_logic;
    cfg_turnoff_ok          : in  std_logic;
    cfg_to_turnoff          : out std_logic;
	cfg_trn_pending : in std_logic;
    cfg_bus_number : out std_logic_vector(7 downto 0);
    cfg_device_number: out std_logic_vector(4 downto 0);
    cfg_function_number : out std_logic_vector(2 downto 0)
	--SENALES DE REPORTE DE ERRORES
	
);
end component PCIeTestWrapp;

    signal clk125MHzInSP605Board: std_logic ;
    signal pcie_sys_reset_n : std_logic;
    signal pcie_sys_reset :  std_logic;
    signal user_clk:  std_logic;
    signal cfg_to_turnoff :std_logic :='0';
    signal cfg_turnoff_ok :std_logic :='0';
    signal cfg_interrupt_msienable: std_logic :='0';
    signal m_axis_rx_tvalid :std_logic :='0';
    signal user_lnk_up :std_logic :='0';
    signal button_reg:std_logic :='0';
    signal user_reset_out:std_logic :='0';
    signal s_axis_tx_tready:std_logic :='0';
  
    
begin

--LEDs para depurar el diseno
leds(0) <= m_axis_rx_tvalid;
leds(1) <= pcie_sys_reset;
leds(2) <= user_lnk_up;
leds(3) <= s_axis_tx_tready;

--Convertir la entrada diferencia ldel reloj en una senal no diferencial
refclk_ibuf : IBUFDS
  port map
  (
    O  => clk125MHzInSP605Board,
    I  => pci_exp_clk_p,
    IB => pci_exp_clk_n
  );
  
  --obtener la senal de reset del sistema
  sys_reset_n_ibuf : IBUF
  port map
  (
    O  => pcie_sys_reset_n,
    I  => pci_exp_perst_b
  );
  
  pcie_turn_off_response: process(user_clk, cfg_to_turnoff) begin
  
  if (rising_edge(user_clk)) then 
      if(  (cfg_to_turnoff or cfg_turnoff_ok ) = '1' )then
            cfg_turnoff_ok <= '1';
       else
            cfg_turnoff_ok <= '0';
       end if;
  end if;
--    cfg_turnoff_ok          : in  std_logic;
--    cfg_to_turnoff          : out std_logic;
  end process;
  
  
 pcie_sys_reset <= not pcie_sys_reset_n;
  
 clocking_test : process (button, user_clk) begin
    if( rising_edge(user_clk)) then
        button_reg<= button;
    end if;
 end process;
  
 
  
pcieController : PCIeTestWrapp 
    port map(
        --INTERFAZ DEL SISTEMA
	sys_reset  =>pcie_sys_reset,
	sys_clk_125MHz=>clk125MHzInSP605Board,
	received_hot_reset=>open,
	--INTERFAZ PCIe
	pci_exp_txp0 => pci_exp_txp0,
	pci_exp_txn0 => pci_exp_txn0,
	pci_exp_rxp0 => pci_exp_rxp0,
	pci_exp_rxn0 => pci_exp_rxn0,
	--INTERFAZ DE USUARIO
	user_clk_out => user_clk,
	user_reset_out  => user_reset_out,
	user_lnk_up =>user_lnk_up,
	--INTERFAZ DE TRANSMISION
	s_axis_tx_tlast => '0',
	s_axis_tx_tdata  => (others=>'0'),
	s_axis_tx_tvalid => '0',
	s_axis_tx_tready =>s_axis_tx_tready,
	src_dsc  => '0',
	tx_terr_drop => open,
	str  => '0',
	tx_cfg_req => open,
	tx_cfg_gnt => '1',
	terr_fwd=>'0',
	--INTERFAZ DE RECEPCION
	m_axis_rx_tlast  => open,
	m_axis_rx_tdata => open,
	rerr_fw => open,
    m_axis_rx_tvalid  => m_axis_rx_tvalid,
	m_axis_rx_tready => '0',
	rx_np_ok  => '1',
	bar_hit  => open,
	--INTERFAZ DE CONFIGURACION
	cfg_do => open,
	cfg_rd_wr_done => open,
	cfg_dwaddr => (others=>'0'),
	cfg_rd_en => '0',
	cfg_interrupt  => '0',
	cfg_interrupt_rdy  => open,
	cfg_interrupt_msienable  => cfg_interrupt_msienable,
    cfg_turnoff_ok  => cfg_turnoff_ok,
    cfg_to_turnoff   => cfg_to_turnoff,
	cfg_trn_pending  => '0',
    cfg_bus_number => open,
    cfg_device_number => open,
    cfg_function_number => open
	
        
    );
     

end Behavioral;


