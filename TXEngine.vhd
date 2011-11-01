
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.pcie_constants.ALL;

entity TXEngine is

    port(
            --INTERFAZ PCIe
            clk: in std_logic;
            reset : in std_logic;
            s_axis_tx_last : out std_logic;
            s_axis_tx_data : out std_logic_vector(31 downto 0);
            s_axis_tx_tvalid : out std_logic;
            s_axis_tx_tready : in std_logic;
            tx_src_dsc : out std_logic;
            tx_buf_av : in std_logic;
            tx_terr_drop : in std_logic;
            tx_str : out std_logic;
            tx_cfg_req : in std_logic;
            tx_cfg_gnt : out std_logic;
            terr_fwd : out std_logic;
            --Senales que indican cuando y que transmitir
            read_request: in std_logic;
            read_request_done: out std_logic; 
            RQST_HEADER_DW0 : in std_logic_vector(31 downto 0);
            RQST_HEADER_DW1 : in std_logic_vector(31 downto 0);
            RQST_HEADER_ADDR_FIRST : in std_logic_vector(31 downto 0);
            RQST_HEADER_ADDR_SECOND : in std_logic_vector(31 downto 0);
            DATA_TO_RESPOND: in std_logic_vector(31 downto 0);
            --Informacion de la configuracion en el bus PCI
            ResponseID : in std_logic_vector(15 downto 0);
            --senales de depuracion
            estadoActual_dbg : out std_logic_vector(2 downto 0)
            
    );


end TXEngine;

architecture Behavioral of TXEngine is
    
     type TransmisorState is (
        WAITING,
        SENDING_DW0,
        SENDING_DW1,
        SENDING_DW2,
        SENDING_DATA
    );

    signal estado : TransmisorState := WAITING;
    signal nextState, previousState :  TransmisorState; 
    
    signal DW0, DW1, DW2, DATA:  std_logic_vector(31 downto 0); 
    
begin

DW0 <= "0"&PCIeCplFMT_WITHD&PCIeType_CplD&"0"&RQST_HEADER_DW0(22 downto 20)&"0000"&"0"&"0"&RQST_HEADER_DW0(13 downto 12)&"00"&RQST_HEADER_DW0(9 downto 0);
DW1 <= ResponseID&"000"&"0"&"000000000100";
DW2 <= RQST_HEADER_DW1(31 downto 16)&RQST_HEADER_DW1(15 downto 8)&"1111"&"1111";

depurarEstadoActual: process (estado) begin
    case estado is
        when WAITING                                                           => estadoActual_dbg<= "000";
        when SENDING_DW0                                               => estadoActual_dbg<= "001";
        when SENDING_DW1                                               => estadoActual_dbg<= "010";
        when SENDING_DW2                                               => estadoActual_dbg<= "011";
        when SENDING_DATA                                              => estadoActual_dbg<= "100";
    end case;    
end process;



stateChange: process(   
        clk, estado, nextState,s_axis_tx_tready, 
        tx_buf_av , tx_terr_drop, tx_cfg_req
) begin

tx_src_dsc <= '0';-- Nunca vamos a detener una transmision
tx_str <= '0';-- Nunca transmitimos en modo streaming
tx_cfg_gnt <= '1';--Que el modulo de PCIe pueda pueda enviar respeustas de configuracion cada vez que es necesario
terr_fwd <= '0'; --no transmitimos datos invalidos


clocking : if (rising_edge(clk)) then

        if (reset='1') then -- Reiniciar la maquina de estados
            estado <= WAITING;
            previousState <= estado;
            s_axis_tx_last <= '0';
            s_axis_tx_tvalid <= '0';
            read_request_done <= '0';
        else 
             previousState <= estado;
             case estado is
                    when WAITING               =>-- Esperando a que se necesite envair un paquete
                        if ( read_request = '1' ) then
                            estado <= SENDING_DW0;
                            s_axis_tx_data <= DW0;
                            s_axis_tx_tvalid <= '1';
                            read_request_done  <= '0';
                        end if;
                    when SENDING_DW0    => -- Enviando la primera palabra  de la cabecera de respuesta
                        if( s_axis_tx_tready = '1' ) then 
                            estado <= SENDING_DW1;
                            s_axis_tx_data <= DW1;
                        end if;
                    when SENDING_DW1    => --Enviando al segunda palbra de la cabecer a de respuesta
                        if( s_axis_tx_tready = '1' ) then 
                            estado <= SENDING_DW2;
                            s_axis_tx_data <= DW2;
                        end if;
                    when SENDING_DW2    =>
                        if( s_axis_tx_tready = '1' ) then 
                            estado <= SENDING_DATA;
                            s_axis_tx_data <= DATA_TO_RESPOND;
                            s_axis_tx_last <= '1';
                        end if;
                    when SENDING_DATA   =>
                        if( s_axis_tx_tready = '1' ) then 
                            estado <= WAITING;
                            s_axis_tx_last <= '0';
                            s_axis_tx_tvalid <= '0';
                            read_request_done  <= '1';
                        end if;
             end case;--case(estado)
        end if;--reset

end if; -- rising_edge(clk)

end process;



end Behavioral;

