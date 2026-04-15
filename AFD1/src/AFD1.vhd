library ieee;
use ieee.std_logic_1164.all;

entity AFD1 is 
port(
    clk,x: in std_logic;
    z: out std_logic
);
end AFD1;

architecture a_afd1 of AFD1 is
type estados is (q0, q1, q2, q3, q4);

signal edo_presente, edo_futuro: estados;

begin
    Proceso1: process(edo_presente, x)
    begin
        case edo_presente is
        when q0 => z <= '0'; -- estado q0
            if x = '1' then
                edo_futuro <= q1;
            else
                edo_futuro <=q4;
            end if;
        when q1  => z <= '0'; -- estado q1
            if x = '1' then
                edo_futuro <= q2;
            else
                edo_futuro <=q4;
            end if;   
        when q2  => z <= '0'; -- estado q2
            if x = '1' then
                edo_futuro <= q3;
            else
                edo_futuro <=q4;
            end if;
        when q3  => z <= '0'; -- estado q3
            if x = '1' then
                edo_futuro <= q3;
            else
                edo_futuro <= q3;
            end if;              
        when q4  => z <= '0'; -- estado q4
            if x = '1' then
                edo_futuro <= q1;
            else
                edo_futuro <= q4;
            end if;
        end case;

    end process proceso1;
        
    Proceso2 : process(clk)
    begin
    if(clk'event and clk='1') then
        edo_presente <= edo_futuro;
        end if;
        
        end process proceso2;
    end a_afd1;