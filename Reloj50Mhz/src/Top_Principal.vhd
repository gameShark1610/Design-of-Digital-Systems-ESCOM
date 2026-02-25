library ieee;
use ieee.std_logic_1164.all;

entity Top_Principal is
    port(
        clk_27mhz : in std_logic; -- Pin fisico del cristal
        reset_n   : in std_logic; -- Pin del boton de reset
        s1, s2, s3, s4, s5 : out std_logic
    );
end Top_Principal;

architecture structural of Top_Principal is

    -- Señal interna para el reloj de 50MHz
    signal clk_50mhz : std_logic;

    -- 1. Declaramos el componente del PLL (generado por el IP Core)
    component gowin_rpll
        port (
            clkout: out std_logic;
            clkin: in std_logic
        );
    end component;

    -- 2. Declaramos tu entidad Reloj (el divisor)
    component Reloj50Mhz
        port(
            clk   : in std_logic;
            reset : in std_logic;
            s1, s2, s3, s4, s5 : out std_logic
        );
    end component;

begin

    -- Instancia del PLL: Convierte 27MHz -> 50MHz
    Instancia_PLL: gowin_rpll
        port map (
            clkin  => clk_27mhz,
            clkout => clk_50mhz
        );

    -- Instancia de tu Divisor: Trabaja ya con los 50MHz
    Instancia_Reloj: Reloj50Mhz
        port map (
            clk   => clk_50mhz,
            reset => reset_n,
            s1 => s1, s2 => s2, s3 => s3, s4 => s4, s5 => s5
        );

end structural;