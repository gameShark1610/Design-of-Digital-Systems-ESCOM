library ieee;
use ieee.std_logic_1164.all;

entity DivisorFrecuencia is
    port(
        clk_in  : in  std_logic;
        reset   : in  std_logic;
        clk_out : out std_logic
    );
end DivisorFrecuencia;

architecture comportamiento of DivisorFrecuencia is
    -- Constante para 5Hz: 27,000,000 / (2 * 5) = 2,700,000
    signal contador : integer range 0 to 2700000 := 0;
    signal estado   : std_logic := '0';
begin
    process(clk_in, reset)
    begin
        if reset = '0' then
            contador <= 0;
            estado   <= '0';
        elsif rising_edge(clk_in) then
            if contador = 2699999 then
                estado <= not estado;
                contador <= 0;
            else
                contador <= contador + 1;
            end if;
        end if;
    end process;
    clk_out <= estado;
end comportamiento;