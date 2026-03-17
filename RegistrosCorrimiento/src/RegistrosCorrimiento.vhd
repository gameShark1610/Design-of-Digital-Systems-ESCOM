library ieee;
use ieee.std_logic_1164.all;

entity RegistrosCorrimiento is
    port(
        clk_fpga : in  std_logic;
        reset    : in  std_logic;
        load     : in  std_logic;
        d_in     : in  std_logic_vector(7 downto 0);
        modo     : in  std_logic_vector(2 downto 0);
        q_out    : out std_logic_vector(7 downto 0)
    );
end RegistrosCorrimiento;

architecture comportamiento of RegistrosCorrimiento is

    component DivisorFrecuencia is
        port(
            clk_in  : in  std_logic;
            reset   : in  std_logic;
            clk_out : out std_logic
        );
    end component;

    signal clk_5hz   : std_logic;
    signal reg       : std_logic_vector(7 downto 0) := (others => '0');
    signal bit_index : integer range 0 to 8 := 0;

begin

    Reloj_5Hz: DivisorFrecuencia 
        port map(
            clk_in  => clk_fpga,
            reset   => reset,
            clk_out => clk_5hz
        );

    process(clk_5hz, reset)
    begin
        if reset = '0' then
            reg <= (others => '0');
            bit_index <= 0;
            
        elsif rising_edge(clk_5hz) then
            case modo is
                when "000" | "001" | "011" => 
                    if bit_index < 8 then
                        if modo = "000" then
                            -- Entra SIEMPRE d_in(0) por la izquierda (corrimiento a la derecha)
                            reg <= d_in(0) & reg(7 downto 1);
                        else
                            -- Entra SIEMPRE d_in(0) por la derecha (corrimiento a la izquierda)
                            reg <= reg(6 downto 0) & d_in(0);
                        end if;
                        
                        -- Usamos bit_index SOLO para contar los 8 ciclos
                        bit_index <= bit_index + 1;
                    else
                        -- Al llegar a 8, se congela. No entran más datos.
                        reg <= reg; 
                    end if;

                when "010" | "100" =>
                    bit_index <= 0; 
                    if modo = "100" or load = '1' then
                        reg <= d_in;
                    else
                        reg <= reg(6 downto 0) & '0';
                    end if;

                when "101" => 
                    reg <= reg(0) & reg(7 downto 1);
                when "110" => 
                    reg <= reg(6 downto 0) & reg(7);

                when others => 
                    bit_index <= 0;
            end case;
        end if;
    end process;

    q_out <= reg;

end comportamiento;