library ieee;
use ieee.std_logic_1164.all;

entity Reloj is
port(
    clk: in std_logic;   -- 27MHz
    reset: in std_logic; -- Pin 3
    s1: out std_logic;   -- Pin 10
    s2: out std_logic;   -- Pin 11
    s3: out std_logic;   -- Pin 13
    s4: out std_logic;   -- Pin 14
    s5: out std_logic    -- Pin 15
);	
end Reloj;

architecture divisor of Reloj is

    -- Definimos un tipo de arreglo para los 5 limites
    type arreglo_frecuencias is array (1 to 5) of integer;

    -- ARREGLO 1: Valores originales
    --constant LIMITES : arreglo_frecuencias := (0, 1, 12, 134, 2699999); -- 20Mhz, 15Mhz, 1Mhz, 100Khz, 5Hz 

    -- ARREGLO 2: Frecuencias Originales
    constant LIMITES : arreglo_frecuencias := (0, 0, 12, 134, 2699999); -- 20Mhz, 15Mhz, 1Mhz, 100Khz, 5Hz  Daria (13.5 MHz, 13.5 MHz, 1Mhz, 100Khz, 5Hz)

    -- ARREGLO 3: Frecuencias con formula sin x2
    -- constant LIMITES : arreglo_frecuencias := (0, 1, 26, 269, 5399999); -- 20Mhz, 15Mhz, 1Mhz, 100Khz, 5Hz Daria (13.5 MHz, 6.75 MHz, 500Khz, 50Khz, 2.5Hz)

    -- ARREGLO 4: Pruebas individuales
    --constant LIMITES : arreglo_frecuencias := (674999, 2699999, 6749999, 13499999, 26999999); -- 20Hz, 5Hz, 2hz, 1hz, 0.5Hz

    -- Señales para los contadores (Wires)
    signal contador1: integer range 0 to 30000000 := 0;
    signal contador2: integer range 0 to 30000000 := 0;
    signal contador3: integer range 0 to 30000000 := 0;
    signal contador4: integer range 0 to 30000000 := 0;
    signal contador5: integer range 0 to 30000000 := 0;

    -- Señales medias (Wires)
    signal salida_media1, salida_media2, salida_media3, salida_media4, salida_media5: std_logic := '0';

begin

    -- Divisor 1 (Incluyendo s1 con contador en cero al iniciar)
    Divisor_frecuencia1: process (clk, reset)
    begin
        if reset = '0' then
            salida_media1 <= '0';
            contador1 <= 0;
        elsif rising_edge(clk) then
            if contador1 >= LIMITES(1) then
                contador1 <= 0;
                salida_media1 <= not salida_media1;
            else
                contador1 <= contador1 + 1;
            end if;
        end if;
    end process;
    s1 <= salida_media1;

    -- Divisor 2
    Divisor_frecuencia2: process (clk, reset)
    begin
        if reset = '0' then
            salida_media2 <= '0';
            contador2 <= 0;
        elsif rising_edge(clk) then
            if contador2 >= LIMITES(2) then
                contador2 <= 0;
                salida_media2 <= not salida_media2;
            else
                contador2 <= contador2 + 1;
            end if;
        end if;
    end process;
    s2 <= salida_media2;

    -- Divisor 3
    Divisor_frecuencia3: process (clk, reset)
    begin
        if reset = '0' then
            salida_media3 <= '0';
            contador3 <= 0;
        elsif rising_edge(clk) then
            if contador3 >= LIMITES(3) then
                contador3 <= 0;
                salida_media3 <= not salida_media3;
            else
                contador3 <= contador3 + 1;
            end if;
        end if;
    end process;
    s3 <= salida_media3;

    -- Divisor 4
    Divisor_frecuencia4: process (clk, reset)
    begin
        if reset = '0' then
            salida_media4 <= '0';
            contador4 <= 0;
        elsif rising_edge(clk) then
            if contador4 >= LIMITES(4) then
                contador4 <= 0;
                salida_media4 <= not salida_media4;
            else
                contador4 <= contador4 + 1;
            end if;
        end if;
    end process;
    s4 <= salida_media4;

    -- Divisor 5
    Divisor_frecuencia5: process (clk, reset)
    begin
        if reset = '0' then
            salida_media5 <= '0';
            contador5 <= 0;
        elsif rising_edge(clk) then
            if contador5 >= LIMITES(5) then
                contador5 <= 0;
                salida_media5 <= not salida_media5;
            else
                contador5 <= contador5 + 1;
            end if;
        end if;
    end process;
    s5 <= salida_media5;

end divisor;