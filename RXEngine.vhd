
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.pcie_constants.ALL;

entity RXEngine is
port(
        --INTERFAZ PCIe
    clk: in std_logic;
    reset : in std_logic;
    m_axis_rx_tlast: in std_logic;
	m_axis_rx_tdata: in std_logic_vector(31 downto 0);
	rerr_fw : in std_logic;--Marca el paquete actual como invalido
	m_axis_rx_tvalid : in std_logic;
	m_axis_rx_tready: out std_logic;
	rx_np_ok : out std_logic;
	bar_hit : in std_logic_vector(6 downto 0);
    --Para la comunicacion con el modulo de transmision
    read_request: out std_logic;
    read_request_done: in std_logic;
    --Datos que se han leido del ultimo paquete
    DW0 : out std_logic_vector(31 downto 0);
    DW1 : out std_logic_vector(31 downto 0);
    ADDR_FIRST : out std_logic_vector(31 downto 0);
    ADDR_SECOND : out std_logic_vector(31 downto 0);
    DATA: out std_logic_vector(31 downto 0);
    --senales de depuracion
    estadoActual_dbg : out std_logic_vector(2 downto 0)
);
end RXEngine;

architecture Behavioral of RXEngine is

 type ReceptionState is (
    READING_DW_0,
    READING_DW_1,
    READING_ADDR_FIRST,
    READING_ADDR_SECOND,
    READING_DATA,
    WAITING_RESPONSE_COMPLETION,
    IGNORING_PACKAGE
  );

signal estado : ReceptionState := READING_DW_0;
signal nextState, previousState :  ReceptionState;

signal DW0_VALUE : std_logic_vector(31 downto 0) := (others => '0');
signal DW1_VALUE : std_logic_vector(31 downto 0) := (others => '0');
signal ADDR_FIRST_VALUE : std_logic_vector(31 downto 0) := (others => '0');
signal ADDR_SECOND_VALUE : std_logic_vector(31 downto 0) := (others => '0');
signal DATA_VALUE: std_logic_vector(31 downto 0) := (others => '0');

signal DW0_SIGNAL : std_logic_vector(31 downto 0) := (others => '0');
signal DW1_SIGNAL : std_logic_vector(31 downto 0) := (others => '0');
signal ADDR_FIRST_SIGNAL : std_logic_vector(31 downto 0) := (others => '0');
signal ADDR_SECOND_SIGNAL : std_logic_vector(31 downto 0) := (others => '0');
signal DATA_SIGNAL : std_logic_vector(31 downto 0) := (others => '0');


signal Packet_Fmt : std_logic_vector(1 downto 0);
signal Packet_IS_4_WORD_ADDR_Q: std_logic;
signal Packet_HAVE_DATA_Q: std_logic;
signal Packet_Type: std_logic_vector(4 downto 0);
signal Packet_Length: std_logic_vector(9 downto 0);

begin

process (estado) begin
    case estado is
        when READING_DW_0                                                           => estadoActual_dbg<= "000";
        when READING_DW_1                                                           => estadoActual_dbg<= "001";
        when READING_ADDR_FIRST                                               => estadoActual_dbg<= "010";
        when READING_ADDR_SECOND                                          => estadoActual_dbg<= "011";
        when READING_DATA                                                             => estadoActual_dbg<= "100";
        when WAITING_RESPONSE_COMPLETION                          => estadoActual_dbg<= "101";
        when IGNORING_PACKAGE                                                     => estadoActual_dbg<= "110";
    end case;    
end process;

DW0 <= DW0_VALUE;
DW1 <= DW1_VALUE;
ADDR_FIRST <= ADDR_FIRST_VALUE;
ADDR_SECOND <= ADDR_SECOND_VALUE;
DATA <= DATA_VALUE;

 DW0_VALUE <= DW0_SIGNAL;
DW1_VALUE <= DW1_SIGNAL;
ADDR_FIRST_VALUE <= ADDR_FIRST_SIGNAL;
ADDR_SECOND_VALUE <= ADDR_SECOND_SIGNAL;
DATA_VALUE <= DATA_SIGNAL;

Packet_Fmt <= DW0_VALUE( 30 downto 29 );
Packet_IS_4_WORD_ADDR_Q <= Packet_Fmt( 1 );
Packet_HAVE_DATA_Q <= DW0_VALUE( 30 );
Packet_Type <= DW0_VALUE( 28 downto 24 );
Packet_Length <= DW0_VALUE( 9 downto 0 );

stateChange: process(clk, estado, nextState,m_axis_rx_tlast, m_axis_rx_tvalid , rerr_fw, read_request_done) begin
        if( rising_edge(clk)) then
           

            if (reset = '1') then
                    estado <= READING_DW_0;
                    previousState <= READING_DW_0;
                    m_axis_rx_tready <= '1';
                    read_request <= '0';
            else -- Evolucion de la maquina de estados
                previousState <= estado;
                
                if( bar_hit(0) = '1' ) then
                         case estado is
                       
                                 when  READING_DW_0 => -- Se esta esperando al primera palabra
                                         if(m_axis_rx_tvalid='1') then
                                            if( rerr_fw  = '1' ) then
                                                estado <= IGNORING_PACKAGE;
                                            else 
                                                estado <= READING_DW_1;
                                                DW0_SIGNAL <= m_axis_rx_tdata;
                                            end if;
                                        end if;
                                       
                                       
                                when READING_DW_1 =>
                                    if(m_axis_rx_tvalid='1') then
                                        DW1_SIGNAL <= m_axis_rx_tdata;
                                        estado <= READING_ADDR_FIRST;
                                    end if;
                                        
                                        
                                when READING_ADDR_FIRST =>
                                        if(m_axis_rx_tvalid='1') then
                                                ADDR_FIRST_SIGNAL <= m_axis_rx_tdata;
                                                if( Packet_IS_4_WORD_ADDR_Q= '1' ) then --direccion de 64 bits
                                                        estado <= READING_ADDR_SECOND;
                                                else
                                                        estado <= READING_DATA;
                                                end if;
                                            
                                        end if;
                                
                                
                                when READING_ADDR_SECOND =>
                                    if(m_axis_rx_tvalid='1') then
                                        ADDR_SECOND_SIGNAL <= m_axis_rx_tdata;
                                        estado <= READING_DATA;
                                    end if;
                                    
                                    
                                when READING_DATA =>
                                    if(m_axis_rx_tvalid='1') then
                                        DATA_SIGNAL <= m_axis_rx_tdata;
                                        if( (Packet_HAVE_DATA_Q = '0') and (Packet_Type = PCIeType_MRd)  ) then
                                                read_request <= '1';
                                                estado <= WAITING_RESPONSE_COMPLETION;-- se reinicia la maquina de estado
                                        else
                                                estado <= READING_DW_0;-- se reinicia la maquina de estado
                                        end if;
                                    end if;
                                    
                                when WAITING_RESPONSE_COMPLETION =>
                                    if( read_request_done = '1' ) then
                                        estado <= READING_DW_0;
                                        read_request<= '0';
                                    end if;
                                    
                                when IGNORING_PACKAGE =>
                                    if( (m_axis_rx_tlast = '1') and (m_axis_rx_tvalid='1')) then
                                        estado <= READING_DW_0;
                                    end if;
                                    
                                    
                            end case;
                    end if;--barhit
                    
                    
            end if;
                
               
                 
        end if;
        
end process;

--process () begin
--
--    
--    
--end process;

end Behavioral;

