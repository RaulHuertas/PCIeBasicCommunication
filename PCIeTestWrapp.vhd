

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity PCIeTestWrapp is 
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
    tx_buf_av :  out std_logic_vector(5 downto 0);
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
end PCIeTestWrapp;
  
architecture Behavioral of PCIeTestWrapp is
component PCIeTestCore 
 generic (
    TL_TX_RAM_RADDR_LATENCY           : integer    := 0;
    TL_TX_RAM_RDATA_LATENCY           : integer    := 2;
    TL_RX_RAM_RADDR_LATENCY           : integer    := 0;
    TL_RX_RAM_RDATA_LATENCY           : integer    := 2;
    TL_RX_RAM_WRITE_LATENCY           : integer    := 0;
    VC0_TX_LASTPACKET                 : integer    := 14;
    VC0_RX_RAM_LIMIT                  : bit_vector := x"7FF";
    VC0_TOTAL_CREDITS_PH              : integer    := 32;
    VC0_TOTAL_CREDITS_PD              : integer    := 211;
    VC0_TOTAL_CREDITS_NPH             : integer    := 8;
    VC0_TOTAL_CREDITS_CH              : integer    := 40;
    VC0_TOTAL_CREDITS_CD              : integer    := 211;
    VC0_CPL_INFINITE                  : boolean    := TRUE;
    BAR0                              : bit_vector := x"FFFFFF84";
    BAR1                              : bit_vector := x"FFFFFFFF";
    BAR2                              : bit_vector := x"00000000";
    BAR3                              : bit_vector := x"00000000";
    BAR4                              : bit_vector := x"00000000";
    BAR5                              : bit_vector := x"00000000";
    EXPANSION_ROM                     : bit_vector := "0000000000000000000000";
    DISABLE_BAR_FILTERING             : boolean    := FALSE;
    DISABLE_ID_CHECK                  : boolean    := FALSE;
    TL_TFC_DISABLE                    : boolean    := FALSE;
    TL_TX_CHECKS_DISABLE              : boolean    := FALSE;
    USR_CFG                           : boolean    := FALSE;
    USR_EXT_CFG                       : boolean    := FALSE;
    DEV_CAP_MAX_PAYLOAD_SUPPORTED     : integer    := 2;
    CLASS_CODE                        : bit_vector := x"050000";
    CARDBUS_CIS_POINTER               : bit_vector := x"00000000";
    PCIE_CAP_CAPABILITY_VERSION       : bit_vector := x"1";
    PCIE_CAP_DEVICE_PORT_TYPE         : bit_vector := x"0";
    PCIE_CAP_SLOT_IMPLEMENTED         : boolean    := FALSE;
    PCIE_CAP_INT_MSG_NUM              : bit_vector := "00000";
    DEV_CAP_PHANTOM_FUNCTIONS_SUPPORT : integer    := 0;
    DEV_CAP_EXT_TAG_SUPPORTED         : boolean    := FALSE;
    DEV_CAP_ENDPOINT_L0S_LATENCY      : integer    := 7;
    DEV_CAP_ENDPOINT_L1_LATENCY       : integer    := 7;
    SLOT_CAP_ATT_BUTTON_PRESENT       : boolean    := FALSE;
    SLOT_CAP_ATT_INDICATOR_PRESENT    : boolean    := FALSE;
    SLOT_CAP_POWER_INDICATOR_PRESENT  : boolean    := FALSE;
    DEV_CAP_ROLE_BASED_ERROR          : boolean    := TRUE;
    LINK_CAP_ASPM_SUPPORT             : integer    := 1;
    LINK_CAP_L0S_EXIT_LATENCY         : integer    := 7;
    LINK_CAP_L1_EXIT_LATENCY          : integer    := 7;
    LL_ACK_TIMEOUT                    : bit_vector := x"00B7";
    LL_ACK_TIMEOUT_EN                 : boolean    := FALSE;
    LL_REPLAY_TIMEOUT                 : bit_vector := x"00FF";
    LL_REPLAY_TIMEOUT_EN              : boolean    := TRUE;
    MSI_CAP_MULTIMSGCAP               : integer    := 0;
    MSI_CAP_MULTIMSG_EXTENSION        : integer    := 0;
    LINK_STATUS_SLOT_CLOCK_CONFIG     : boolean    := FALSE;
    PLM_AUTO_CONFIG                   : boolean    := FALSE;
    FAST_TRAIN                        : boolean    := FALSE;
    ENABLE_RX_TD_ECRC_TRIM            : boolean    := TRUE;
    DISABLE_SCRAMBLING                : boolean    := FALSE;
    PM_CAP_VERSION                    : integer    := 3;
    PM_CAP_PME_CLOCK                  : boolean    := FALSE;
    PM_CAP_DSI                        : boolean    := FALSE;
    PM_CAP_AUXCURRENT                 : integer    := 0;
    PM_CAP_D1SUPPORT                  : boolean    := FALSE;
    PM_CAP_D2SUPPORT                  : boolean    := FALSE;
    PM_CAP_PMESUPPORT                 : bit_vector := x"0E";
    PM_DATA0                          : bit_vector := x"00";
    PM_DATA_SCALE0                    : bit_vector := x"0";
    PM_DATA1                          : bit_vector := x"00";
    PM_DATA_SCALE1                    : bit_vector := x"0";
    PM_DATA2                          : bit_vector := x"00";
    PM_DATA_SCALE2                    : bit_vector := x"0";
    PM_DATA3                          : bit_vector := x"00";
    PM_DATA_SCALE3                    : bit_vector := x"0";
    PM_DATA4                          : bit_vector := x"00";
    PM_DATA_SCALE4                    : bit_vector := x"0";
    PM_DATA5                          : bit_vector := x"00";
    PM_DATA_SCALE5                    : bit_vector := x"0";
    PM_DATA6                          : bit_vector := x"00";
    PM_DATA_SCALE6                    : bit_vector := x"0";
    PM_DATA7                          : bit_vector := x"00";
    PM_DATA_SCALE7                    : bit_vector := x"0";
    PCIE_GENERIC                      : bit_vector := "000000101111";
    GTP_SEL                           : integer    := 0;
    CFG_VEN_ID                        : std_logic_vector(15 downto 0) := x"10EE";
    CFG_DEV_ID                        : std_logic_vector(15 downto 0) := x"0007";
    CFG_REV_ID                        : std_logic_vector(7 downto 0)  := x"00";
    CFG_SUBSYS_VEN_ID                 : std_logic_vector(15 downto 0) := x"10EE";
    CFG_SUBSYS_ID                     : std_logic_vector(15 downto 0) := x"0007";
    REF_CLK_FREQ                      : integer    := 1
);
port (
    -- PCI Express Fabric Interface
    pci_exp_txp             : out std_logic;
    pci_exp_txn             : out std_logic;
    pci_exp_rxp             : in  std_logic;
    pci_exp_rxn             : in  std_logic;

    user_lnk_up             : out std_logic;

    -- Tx
    s_axis_tx_tdata         : in  std_logic_vector(31 downto 0);
    s_axis_tx_tlast         : in  std_logic;
    s_axis_tx_tvalid        : in  std_logic;
    s_axis_tx_tready        : out std_logic;
    s_axis_tx_tkeep         : in  std_logic_vector(3 downto 0);
    s_axis_tx_tuser         : in  std_logic_vector(3 downto 0);
    tx_err_drop             : out std_logic;
    tx_buf_av               : out std_logic_vector(5 downto 0);
    tx_cfg_req              : out std_logic;
    tx_cfg_gnt              : in  std_logic;

    -- Rx
    m_axis_rx_tdata         : out std_logic_vector(31 downto 0);
    m_axis_rx_tlast         : out std_logic;
    m_axis_rx_tvalid        : out std_logic;
    m_axis_rx_tkeep         : out std_logic_vector(3 downto 0);
    m_axis_rx_tready        : in  std_logic;
    m_axis_rx_tuser         : out std_logic_vector(21 downto 0);
    rx_np_ok                : in  std_logic;

    fc_sel                  : in  std_logic_vector(2 downto 0);
    fc_nph                  : out std_logic_vector(7 downto 0);
    fc_npd                  : out std_logic_vector(11 downto 0);
    fc_ph                   : out std_logic_vector(7 downto 0);
    fc_pd                   : out std_logic_vector(11 downto 0);
    fc_cplh                 : out std_logic_vector(7 downto 0);
    fc_cpld                 : out std_logic_vector(11 downto 0);

    -- Host (CFG) Interface
    cfg_do                  : out std_logic_vector(31 downto 0);
    cfg_rd_wr_done          : out std_logic;
    cfg_dwaddr              : in  std_logic_vector(9 downto 0);
    cfg_rd_en               : in  std_logic;
    cfg_err_ur              : in  std_logic;
    cfg_err_cor             : in  std_logic;
    cfg_err_ecrc            : in  std_logic;
    cfg_err_cpl_timeout     : in  std_logic;
    cfg_err_cpl_abort       : in  std_logic;
    cfg_err_posted          : in  std_logic;
    cfg_err_locked          : in  std_logic;
    cfg_err_tlp_cpl_header  : in  std_logic_vector(47 downto 0);
    cfg_err_cpl_rdy         : out std_logic;
    cfg_interrupt           : in  std_logic;
    cfg_interrupt_rdy       : out std_logic;
    cfg_interrupt_assert    : in  std_logic;
    cfg_interrupt_do        : out std_logic_vector(7 downto 0);
    cfg_interrupt_di        : in  std_logic_vector(7 downto 0);
    cfg_interrupt_mmenable  : out std_logic_vector(2 downto 0);
    cfg_interrupt_msienable : out std_logic;
    cfg_turnoff_ok          : in  std_logic;
    cfg_to_turnoff          : out std_logic;
    cfg_pm_wake             : in  std_logic;
    cfg_pcie_link_state     : out std_logic_vector(2 downto 0);
    cfg_trn_pending         : in  std_logic;
    cfg_dsn                 : in  std_logic_vector(63 downto 0);
    cfg_bus_number          : out std_logic_vector(7 downto 0);
    cfg_device_number       : out std_logic_vector(4 downto 0);
    cfg_function_number     : out std_logic_vector(2 downto 0);
    cfg_status              : out std_logic_vector(15 downto 0);
    cfg_command             : out std_logic_vector(15 downto 0);
    cfg_dstatus             : out std_logic_vector(15 downto 0);
    cfg_dcommand            : out std_logic_vector(15 downto 0);
    cfg_lstatus             : out std_logic_vector(15 downto 0);
    cfg_lcommand            : out std_logic_vector(15 downto 0);

    -- System Interface
    sys_clk                 : in  std_logic;
    sys_reset               : in  std_logic;
    user_clk_out            : out std_logic;
    user_reset_out          : out std_logic;
    received_hot_reset      : out std_logic
  );
end component PCIeTestCore;
  
  signal pcie_s_axis_tx_tuser : std_logic_vector(3 downto 0);
  signal pcie_m_axis_rx_tuser : std_logic_vector(21 downto 0);
  
begin

 PCIeController : PCIeTestCore  generic map
  (
    FAST_TRAIN                        => FALSE
  )
  port map (
    -- PCI Express (PCI_EXP) Fabric Interface
    pci_exp_txp                         => pci_exp_txp0,
    pci_exp_txn                         => pci_exp_txn0,
    pci_exp_rxp                         => pci_exp_rxp0,
    pci_exp_rxn                         => pci_exp_rxn0,

    -- Transaction (TRN) Interface
    -- Common clock & reset
    user_lnk_up                         => user_lnk_up,
    user_clk_out                        => user_clk_out,
    user_reset_out                      => user_reset_out,
    -- Common flow control
    fc_sel                              => "000",
    fc_nph                              => open,
    fc_npd                              => open,
    fc_ph                               => open,
    fc_pd                               => open,
    fc_cplh                             => open,
    fc_cpld                             => open,
    -- Transaction Tx
    s_axis_tx_tready                    => s_axis_tx_tready,
    s_axis_tx_tdata                     => s_axis_tx_tdata,
    s_axis_tx_tkeep                     => "1111",
    s_axis_tx_tuser                     => pcie_s_axis_tx_tuser,
    s_axis_tx_tlast                     => s_axis_tx_tlast,
    s_axis_tx_tvalid                    => s_axis_tx_tvalid,
    tx_err_drop                         => tx_terr_drop,
    tx_buf_av                           => tx_buf_av,
    tx_cfg_req                          => open,
    tx_cfg_gnt                          => '1',
    -- Transaction Rx
    m_axis_rx_tdata                     => m_axis_rx_tdata,
    m_axis_rx_tkeep                     => open,
    m_axis_rx_tlast                     => m_axis_rx_tlast,
    m_axis_rx_tvalid                    => m_axis_rx_tvalid,
    m_axis_rx_tready                    => m_axis_rx_tready,
    m_axis_rx_tuser                     => pcie_m_axis_rx_tuser,
    rx_np_ok                            => rx_np_ok,
    -- Configuration (CFG) Interface
    -- Configuration space access
    cfg_do                             => cfg_do,
    cfg_rd_wr_done                     => cfg_rd_wr_done,
    cfg_dwaddr                         => cfg_dwaddr,
    cfg_rd_en                          => cfg_rd_en,
    -- Error reporting
    cfg_err_ur                         => '0',
    cfg_err_cor                        => '0',
    cfg_err_ecrc                       => '0',
    cfg_err_cpl_timeout                => '0',
    cfg_err_cpl_abort                  => '0',
    cfg_err_posted                     => '0',
    cfg_err_locked                     => '0',
    cfg_err_tlp_cpl_header             => (others=>'0'),
    cfg_err_cpl_rdy                    => open,
    -- Interrupt generation
    cfg_interrupt                      => cfg_interrupt,
    cfg_interrupt_rdy                  => cfg_interrupt_rdy,
    cfg_interrupt_assert               => '0',
    cfg_interrupt_do                   => open,
    cfg_interrupt_di                   => (others=>'0'),
    cfg_interrupt_mmenable             => open,
    cfg_interrupt_msienable            => cfg_interrupt_msienable,
    -- Power management signaling
    cfg_turnoff_ok                     => cfg_turnoff_ok ,
    cfg_to_turnoff                     => cfg_to_turnoff,
    cfg_pm_wake                        => '0',
    cfg_pcie_link_state                => open,
    cfg_trn_pending                    => cfg_trn_pending,
    -- System configuration and status
    cfg_dsn                            => (others=>'0'),
    cfg_bus_number                     => cfg_bus_number,
    cfg_device_number                  => cfg_device_number,
    cfg_function_number                => cfg_function_number,
    cfg_status                         => open,
    cfg_command                        => open,
    cfg_dstatus                        => open,
    cfg_dcommand                       => open,
    cfg_lstatus                        => open,
    cfg_lcommand                       => open,

    -- System (SYS) Interface
    sys_clk                            => sys_clk_125MHz,
    sys_reset                          => sys_reset,
    received_hot_reset                 => OPEN
  );



end Behavioral;

