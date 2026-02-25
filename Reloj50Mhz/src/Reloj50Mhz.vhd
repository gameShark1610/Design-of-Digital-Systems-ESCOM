library ieee;
use ieee.std_logic_1164.all;

entity Reloj50Mhz is
port(
    clk: in std_logic;   -- Aquí entran los 50MHz del PLL
    reset: in std_logic;
    s1, s2, s3, s4, s5: out std_logic
);	
end Reloj50Mhz;

architecture divisor of Reloj50Mhz is
    -- Arreglo para 50MHz: 25MHz, 10MHz, 65KHz, 25Hz, 5Hz
    type arreglo_frecuencias is array (1 to 5) of integer;
    constant LIMITES : arreglo_frecuencias := (0, 1, 383, 999999, 4999999);

    signal cont1, cont2, cont3, cont4, cont5: integer range 0 to 50000000 := 0;
    signal r1, r2, r3, r4, r5 : std_logic := '0';
begin
    -- Proceso para S1 (25 MHz)
    process(clk, reset) begin
        if reset='0' then cont1<=0; r1<='0';
        elsif rising_edge(clk) then
            if cont1 >= LIMITES(1) then cont1<=0; r1<=not r1;
            else cont1<=cont1+1; end if;
        end if;
    end process;

    -- Proceso para S2 (10 MHz aprox)
    process(clk, reset) begin
        if reset='0' then cont2<=0; r2<='0';
        elsif rising_edge(clk) then
            if cont2 >= LIMITES(2) then cont2<=0; r2<=not r2;
            else cont2<=cont2+1; end if;
        end if;
    end process;

    -- Proceso para S3 (65 KHz)
    process(clk, reset) begin
        if reset='0' then cont3<=0; r3<='0';
        elsif rising_edge(clk) then
            if cont3 >= LIMITES(3) then cont3<=0; r3<=not r3;
            else cont3<=cont3+1; end if;
        end if;
    end process;

    -- Proceso para S4 (5 Hz)
    process(clk, reset) begin
        if reset='0' then cont4<=0; r4<='0';
        elsif rising_edge(clk) then
            if cont4 >= LIMITES(4) then cont4<=0; r4<=not r4;
            else cont4<=cont4+1; end if;
        end if;
    end process;

    -- Proceso para S5 (5 Hz)
    process(clk, reset) begin
        if reset='0' then cont5<=0; r5<='0';
        elsif rising_edge(clk) then
            if cont5 >= LIMITES(5) then cont5<=0; r5<=not r5;
            else cont5<=cont5+1; end if;
        end if;
    end process;

    s1<=r1; s2<=r2; s3<=r3; s4<=r4; s5<=r5;
end divisor;