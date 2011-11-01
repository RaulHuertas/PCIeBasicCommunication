
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 use work.pcie_constants.ALL;
 
ENTITY RXEngineTestBench1 IS
END RXEngineTestBench1;
 
ARCHITECTURE behavior OF RXEngineTestBench1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RXEngineSynthetized
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         m_axis_rx_tlast : IN  std_logic;
         m_axis_rx_tdata : IN  std_logic_vector(31 downto 0);
         rerr_fw : IN  std_logic;
         m_axis_rx_tvalid : IN  std_logic;
         m_axis_rx_tready : OUT  std_logic;
         rx_np_ok : OUT  std_logic;
         bar_hit : IN  std_logic_vector(6 downto 0);
         read_request : OUT  std_logic;
         read_request_done : IN  std_logic;
         DW0 : OUT  std_logic_vector(31 downto 0);
         DW1 : OUT  std_logic_vector(31 downto 0);
         ADDR_FIRST : OUT  std_logic_vector(31 downto 0);
         ADDR_SECOND : OUT  std_logic_vector(31 downto 0);
         DATA : OUT  std_logic_vector(31 downto 0);
         
         estadoActual_dbg : out std_logic_vector(2 downto 0)
         
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal m_axis_rx_tlast : std_logic := '0';
   signal m_axis_rx_tdata : std_logic_vector(31 downto 0) := (others => '0');
   signal rerr_fw : std_logic := '0';
   signal m_axis_rx_tvalid : std_logic := '0';
   signal bar_hit : std_logic_vector(6 downto 0) := (others => '0');
   signal read_request_done : std_logic := '0';
   signal estadoActual_dbg : std_logic_vector(2 downto 0) ;

 	--Outputs
   signal m_axis_rx_tready : std_logic;
   signal rx_np_ok : std_logic;
   signal read_request : std_logic;
   signal DW0 : std_logic_vector(31 downto 0);
   signal DW1 : std_logic_vector(31 downto 0);
   signal ADDR_FIRST : std_logic_vector(31 downto 0);
   signal ADDR_SECOND : std_logic_vector(31 downto 0);
   signal DATA : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RXEngineSynthetized PORT MAP (
          clk => clk,
          reset => reset,
          m_axis_rx_tlast => m_axis_rx_tlast,
          m_axis_rx_tdata => m_axis_rx_tdata,
          rerr_fw => rerr_fw,
          m_axis_rx_tvalid => m_axis_rx_tvalid,
          m_axis_rx_tready => m_axis_rx_tready,
          rx_np_ok => rx_np_ok,
          bar_hit => bar_hit,
          read_request => read_request,
          read_request_done => read_request_done,
          DW0 => DW0,
          DW1 => DW1,
          ADDR_FIRST => ADDR_FIRST,
          ADDR_SECOND => ADDR_SECOND,
          DATA => DATA,
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
          wait for clk_period*10;

      -- insert stimulus here 
      --Reinicio del sistema
      
      bar_hit(0) <= '1';
      m_axis_rx_tlast <= '0';
      reset <= '1';
      wait for clk_period*10;
      reset <= '0';
      wait for clk_period*10;
     
     --Se recibe un paquete de escritura de forma continua
     m_axis_rx_tvalid <= '1';
     
     m_axis_rx_tdata <= "0"&"11"&"00000"&"0"&"000"&"0000"&"0"&"0"&"00"&"00"&"0000000001";--DW0
     wait for clk_period ;
     m_axis_rx_tdata <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"1111"&"1111";--DW1
     wait for clk_period ;
     m_axis_rx_tdata <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";--ADDR_FIRST
     wait for clk_period ;
     m_axis_rx_tdata <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0100";--ADDR_SECOND
     wait for clk_period ;
     m_axis_rx_tlast <= '1';
     m_axis_rx_tdata <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0111";--DATA
     wait for clk_period ;
     m_axis_rx_tlast <= '0';
     m_axis_rx_tvalid <= '0';


     --Se recibe un paquete de escritura pero hay esperas entre palabra y palabra
     m_axis_rx_tvalid <= '1';
     m_axis_rx_tdata <= "0"&"11"&"00000"&"0"&"000"&"0000"&"0"&"0"&"00"&"00"&"0000000001";--DW0
     wait for clk_period ;
     
     m_axis_rx_tvalid <= '0';
     wait for clk_period ;
     
     m_axis_rx_tvalid <= '1';
     m_axis_rx_tdata <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"1111"&"1111";--DW1
     wait for clk_period ;
     
     m_axis_rx_tdata <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";--ADDR_FIRST
     wait for clk_period ;
     
     m_axis_rx_tvalid <= '0';
     wait for clk_period ;
     
     m_axis_rx_tvalid <= '1';
     m_axis_rx_tdata <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0100";--ADDR_SECOND
     wait for clk_period ;
     
     m_axis_rx_tlast <= '1';
     m_axis_rx_tdata <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0111";--DATA
     wait for clk_period ;
     m_axis_rx_tlast <= '0';
     m_axis_rx_tvalid <= '0';
     wait for clk_period*4;

     --Se recibe un paquete de lectura
     m_axis_rx_tvalid <= '1';
     m_axis_rx_tdata <= "0"&PCIeFMT_4DW&PCIeType_MRd&"0"&"000"&"0000"&"0"&"0"&"00"&"00"&"0000000001";--DW0
     wait for clk_period ;
     m_axis_rx_tdata <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"1111"&"1111";--DW1
     wait for clk_period ;
     m_axis_rx_tdata <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";--ADDR_FIRST
     wait for clk_period ;
     m_axis_rx_tlast <= '1';
     m_axis_rx_tdata <= "0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000"&"0000";--ADDR_SECOND
     wait for clk_period ;
     m_axis_rx_tvalid <= '0';
     m_axis_rx_tlast <= '0';
     wait for 10*clk_period ;--En este tiempo se envia larespeusta por el modulo de transmision
     read_request_done <= '1';
     wait for clk_period ;
     read_request_done <= '0';
     

      wait;
   end process;

END;
