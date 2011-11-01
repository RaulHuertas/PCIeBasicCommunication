
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 

ENTITY TxEngineTestBench1 IS
END TxEngineTestBench1;
use work.pcie_constants.ALL;


ARCHITECTURE behavior OF TxEngineTestBench1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TXEngine
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         s_axis_tx_last : OUT  std_logic;
         s_axis_tx_data : OUT  std_logic_vector(31 downto 0);
         s_axis_tx_tvalid : OUT  std_logic;
         s_axis_tx_tready : IN  std_logic;
         tx_src_dsc : OUT  std_logic;
         tx_buf_av : IN  std_logic;
         tx_terr_drop : IN  std_logic;
         tx_str : OUT  std_logic;
         tx_cfg_req : IN  std_logic;
         tx_cfg_gnt : OUT  std_logic;
         terr_fwd : OUT  std_logic;
         read_request : IN  std_logic;
         read_request_done : OUT  std_logic;
         RQST_HEADER_DW0 : IN  std_logic_vector(31 downto 0);
         RQST_HEADER_DW1 : IN  std_logic_vector(31 downto 0);
         RQST_HEADER_ADDR_FIRST : IN  std_logic_vector(31 downto 0);
         RQST_HEADER_ADDR_SECOND : IN  std_logic_vector(31 downto 0);
         DATA_TO_RESPOND : IN  std_logic_vector(31 downto 0);
         ResponseID : IN  std_logic_vector(15 downto 0);
         estadoActual_dbg : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal s_axis_tx_tready : std_logic := '0';
   signal tx_buf_av : std_logic := '0';
   signal tx_terr_drop : std_logic := '0';
   signal tx_cfg_req : std_logic := '0';
   signal read_request : std_logic := '0';
   signal RQST_HEADER_DW0 : std_logic_vector(31 downto 0) := (others => '0');
   signal RQST_HEADER_DW1 : std_logic_vector(31 downto 0) := (others => '0');
   signal RQST_HEADER_ADDR_FIRST : std_logic_vector(31 downto 0) := (others => '0');
   signal RQST_HEADER_ADDR_SECOND : std_logic_vector(31 downto 0) := (others => '0');
   signal DATA_TO_RESPOND : std_logic_vector(31 downto 0) := (others => '0');
   signal ResponseID : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal s_axis_tx_last : std_logic;
   signal s_axis_tx_data : std_logic_vector(31 downto 0);
   signal s_axis_tx_tvalid : std_logic;
   signal tx_src_dsc : std_logic;
   signal tx_str : std_logic;
   signal tx_cfg_gnt : std_logic;
   signal terr_fwd : std_logic;
   signal read_request_done : std_logic;
   signal estadoActual_dbg : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TXEngine PORT MAP (
          clk => clk,
          reset => reset,
          s_axis_tx_last => s_axis_tx_last,
          s_axis_tx_data => s_axis_tx_data,
          s_axis_tx_tvalid => s_axis_tx_tvalid,
          s_axis_tx_tready => s_axis_tx_tready,
          tx_src_dsc => tx_src_dsc,
          tx_buf_av => tx_buf_av,
          tx_terr_drop => tx_terr_drop,
          tx_str => tx_str,
          tx_cfg_req => tx_cfg_req,
          tx_cfg_gnt => tx_cfg_gnt,
          terr_fwd => terr_fwd,
          read_request => read_request,
          read_request_done => read_request_done,
          RQST_HEADER_DW0 => RQST_HEADER_DW0,
          RQST_HEADER_DW1 => RQST_HEADER_DW1,
          RQST_HEADER_ADDR_FIRST => RQST_HEADER_ADDR_FIRST,
          RQST_HEADER_ADDR_SECOND => RQST_HEADER_ADDR_SECOND,
          DATA_TO_RESPOND => DATA_TO_RESPOND,
          ResponseID => ResponseID,
          estadoActual_dbg => estadoActual_dbg
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
    
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      RQST_HEADER_DW0 <= "0"&PCIeFMT_4DW&PCIeType_MRd&"0"&"000"&"0000"&"0"&"0"&"00"&"00"&"0000000001";
      RQST_HEADER_DW1 <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"1111"&"1111";
      RQST_HEADER_ADDR_FIRST <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";
       RQST_HEADER_ADDR_SECOND <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";
       DATA_TO_RESPOND <= (others => '0');
       s_axis_tx_tready <= '0';
       read_request <= '0';
      wait for clk_period*10;

      -- insert stimulus here 
      --Se recibe la orden de responder consulta
      read_request <= '1';
      wait for clk_period;
      wait for clk_period;
      wait for clk_period;--Aqui debe de estar esperando a que se pueda tansmitir informacion
      s_axis_tx_tready <= '1';
      wait for clk_period;
      
      while(  true ) loop
                if(read_request_done='1') then
                        read_request <= '0';
                        wait for clk_period;
                        exit;
                else
                        
                end if;
                wait for clk_period;
      end loop;
      
      wait;
   end process;

END;
