
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
	m_axis_rx_ready: out std_logic;
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
    estadoActual_dbg : out std_logic_vector(2 downto 0);
    potEstadoActual_dbg : out std_logic_vector(2 downto 0);
    rxDataBeat_dbg: out std_logic;
    rxData_dbg: out std_logic_vector(31 downto 0)
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

signal state : ReceptionState := READING_DW_0;
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
signal Packet_IS_64_WORD_ADDR_Q: std_logic;
signal Packet_HAVE_DATA_Q: std_logic;
signal Packet_Type: std_logic_vector(4 downto 0);
signal Packet_Length: std_logic_vector(9 downto 0);

signal m_axis_rx_tready : std_logic;

signal dataStrobe: std_logic;

begin

--GENERAMOS LAS SENALES DE DEPURACION
--Senales del estado actual de la maquina de estados
process (state) begin
    case state is
        when READING_DW_0                                                           => estadoActual_dbg<= "000";
        when READING_DW_1                                                           => estadoActual_dbg<= "001";
        when READING_ADDR_FIRST                                               => estadoActual_dbg<= "010";
        when READING_ADDR_SECOND                                          => estadoActual_dbg<= "011";
        when READING_DATA                                                             => estadoActual_dbg<= "100";
        when WAITING_RESPONSE_COMPLETION                          => estadoActual_dbg<= "101";
        when IGNORING_PACKAGE                                                     => estadoActual_dbg<= "110";
    end case;    
end process;


process (nextState) begin
    case nextState is
        when READING_DW_0                                                           => potEstadoActual_dbg<= "000";
        when READING_DW_1                                                           => potEstadoActual_dbg<= "001";
        when READING_ADDR_FIRST                                               => potEstadoActual_dbg<= "010";
        when READING_ADDR_SECOND                                          => potEstadoActual_dbg<= "011";
        when READING_DATA                                                             => potEstadoActual_dbg<= "100";
        when WAITING_RESPONSE_COMPLETION                          => potEstadoActual_dbg<= "101";
        when IGNORING_PACKAGE                                                     => potEstadoActual_dbg<= "110";
    end case;    
end process;


--Senales para capturar el paquete recibido
m_axis_rx_ready <= m_axis_rx_tready;
m_axis_rx_tready <= '1';
dataStrobe <= (m_axis_rx_tready and m_axis_rx_tvalid and bar_hit(0)  );
rxDataBeat_dbg <=  dataStrobe;
rxData_dbg <= m_axis_rx_tdata;

rx_np_ok <= '1';

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
Packet_IS_64_WORD_ADDR_Q <= Packet_Fmt( 1 );
Packet_HAVE_DATA_Q <= DW0_VALUE( 30 );
Packet_Type <= DW0_VALUE( 28 downto 24 );
Packet_Length <= DW0_VALUE( 9 downto 0 );

stateTransition: process (reset, clk, nextState) begin
    if( rising_edge(clk) ) then
        if(reset = '1') then
            state <= READING_DW_0;
        else
            state <= nextState;
        end if;
    end if;
end process stateTransition;

stateMachineDefinition: process(
        state,
        bar_hit,
        m_axis_rx_tlast, 
        m_axis_rx_tvalid , 
        rerr_fw, 
        read_request_done,
        Packet_IS_64_WORD_ADDR_Q,
        Packet_HAVE_DATA_Q, 
        Packet_Type,
        dataStrobe
) begin
    
            case state is
                when READING_DW_0 =>
                    if(    (dataStrobe='1')    ) then
                            nextState <= READING_DW_1;
                    else
                            nextState <= READING_DW_0;
                    end if;
                when READING_DW_1 =>
                    if(   (dataStrobe='1')     ) then
                             if( rerr_fw  = '1' ) then
                                nextState<= IGNORING_PACKAGE;
                            else 
                                nextState <= READING_ADDR_FIRST;
                            end if;
                     else
                            nextState <= READING_DW_1;
                    end if;
                when READING_ADDR_FIRST =>
                    if (    (dataStrobe='1')    )  then
                    
                                    if(  Packet_IS_64_WORD_ADDR_Q = '0' ) then
                                    
                                                if( Packet_HAVE_DATA_Q = '1' ) then
                                                    nextState <= READING_DATA;
                                                else
                                                    if (   Packet_Type = PCIeType_MRd ) then
                                                        nextState <= WAITING_RESPONSE_COMPLETION;
                                                    else
                                                        nextState <= READING_DW_0;--Esperar el siguiente paquete
                                                    end if;
                                                end if;
                                                
                                    else
                                                nextState <= READING_ADDR_SECOND;
                                    end if;
                    else
                            nextState <= READING_ADDR_FIRST;                
                    end if;
                when READING_ADDR_SECOND =>
                    if(     dataStrobe='1'   ) then
                        if( Packet_HAVE_DATA_Q = '1' ) then
                            nextState <= READING_DATA;
                        else
                            if (   Packet_Type = PCIeType_MRd ) then
                                nextState <= WAITING_RESPONSE_COMPLETION;
                            else
                                nextState <= READING_DW_0;--Esperar el siguiente paquete
                            end if;
                        end if;
                    else
                        nextState <= READING_ADDR_SECOND;--Esperar el siguiente paquete
                    end if;
                when READING_DATA =>
                    if(     dataStrobe='1'   ) then
                       nextState <= READING_DW_0;--Esperar el siguiente paquete
                    else
                        nextState <= READING_DATA;--Esperar el siguiente paquete
                    end if;
                 when WAITING_RESPONSE_COMPLETION =>
                    if( read_request_done = '1'  ) then
                        nextState <= READING_DW_0;
                    else
                        nextState <= WAITING_RESPONSE_COMPLETION;
                    end if;  
                 when IGNORING_PACKAGE =>
                    if(    (dataStrobe='1') and (m_axis_rx_tlast = '1')) then
                        nextState <= READING_DW_0;
                    else
                        nextState <= IGNORING_PACKAGE;
                    end if;  
            end case;
end process stateMachineDefinition;





updatingRegisters: process(
        state, 
        clk, 
        dataStrobe, 
        m_axis_rx_tdata,
        Packet_Type
  ) begin

    if( rising_edge(clk) ) then
    
        if (    (state=READING_DW_0) and (dataStrobe='1')  ) then
                DW0_SIGNAL <= m_axis_rx_tdata;
         end if;
        if (    (state=READING_DW_1) and (dataStrobe='1')  ) then
                DW1_SIGNAL <= m_axis_rx_tdata;
         end if;
        if (    (state=READING_ADDR_FIRST) and (dataStrobe='1')  ) then
                ADDR_FIRST_SIGNAL <= m_axis_rx_tdata;
        end if;
        if (    (state=READING_ADDR_SECOND) and (dataStrobe='1')  ) then
                ADDR_SECOND_SIGNAL <= m_axis_rx_tdata;
        end if;
        if (    (state=READING_DATA) and (dataStrobe='1')  ) then
                DATA_SIGNAL <= m_axis_rx_tdata;
        end if;
        if(     (state=READING_ADDR_FIRST) and (Packet_Type = PCIeType_MRd)  ) then
                read_request <= '1';
        else
                read_request <= '0';
        end if;
        
        
    end if;

end process updatingRegisters;


end Behavioral;

