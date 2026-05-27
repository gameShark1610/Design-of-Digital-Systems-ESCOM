-- ============================================================
--  Debounce - Anti-rebote para botones mecanicos
--  Espera DEBOUNCE_LIMIT ciclos estables antes de cambiar salida
--  A 24 MHz, 240_000 ciclos = 10 ms (suficiente para rebote)
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    generic (
        DEBOUNCE_LIMIT : integer := 240_000  -- 10 ms a 24 MHz
    );
    Port (
        CLK     : in  std_logic;
        BTN_IN  : in  std_logic;   -- Entrada cruda del boton (activo bajo)
        BTN_OUT : out std_logic    -- Salida limpia
    );
end debounce;

architecture Behavioral of debounce is
    signal counter    : integer range 0 to DEBOUNCE_LIMIT := 0;
    signal btn_sync   : std_logic_vector(1 downto 0) := (others => '1');
    signal btn_stable : std_logic := '1';
begin

    process(CLK)
    begin
        if rising_edge(CLK) then
            -- Sincronizar con el reloj (2 flip-flops)
            btn_sync(0) <= BTN_IN;
            btn_sync(1) <= btn_sync(0);

            if btn_sync(1) /= btn_stable then
                -- La entrada cambio, comenzar a contar
                counter <= counter + 1;
                if counter >= DEBOUNCE_LIMIT - 1 then
                    btn_stable <= btn_sync(1);
                    counter    <= 0;
                end if;
            else
                counter <= 0;
            end if;
        end if;
    end process;

    BTN_OUT <= btn_stable;

end Behavioral;