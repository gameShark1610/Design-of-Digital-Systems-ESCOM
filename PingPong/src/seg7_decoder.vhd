-- ============================================================
--  Decodificador 7 Segmentos (Display Catodo Comun, activo bajo)
--
--  Segmentos:
--       _
--      |_|
--      |_|
--
--   seg(6) = a (segmento superior)
--   seg(5) = b (superior derecho)
--   seg(4) = c (inferior derecho)
--   seg(3) = d (inferior)
--   seg(2) = e (inferior izquierdo)
--   seg(1) = f (superior izquierdo)
--   seg(0) = g (medio)
--
--  ACTIVO BAJO: '0' enciende el segmento
--
--  Digitos 0-9 soportados
-- ============================================================

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seg7_decoder is
    Port (
        digit  : in  integer range 0 to 9;
        seg    : out std_logic_vector(6 downto 0)   -- abcdefg activo bajo
    );
end seg7_decoder;

architecture Behavioral of seg7_decoder is
begin

    process(digit)
    begin
        case digit is
            --                  abcdefg
            when 0 => seg <= "0000001";  -- 0: todos excepto g
            when 1 => seg <= "1001111";  -- 1: b, c
            when 2 => seg <= "0010010";  -- 2: a, b, d, e, g
            when 3 => seg <= "0000110";  -- 3: a, b, c, d, g
            when 4 => seg <= "1001100";  -- 4: b, c, f, g
            when 5 => seg <= "0100100";  -- 5: a, c, d, f, g
            when 6 => seg <= "0100000";  -- 6: a, c, d, e, f, g
            when 7 => seg <= "0001111";  -- 7: a, b, c
            when 8 => seg <= "0000000";  -- 8: todos
            when 9 => seg <= "0000100";  -- 9: a, b, c, d, f, g
            when others => seg <= "1111111";  -- apagado
        end case;
    end process;

end Behavioral;
