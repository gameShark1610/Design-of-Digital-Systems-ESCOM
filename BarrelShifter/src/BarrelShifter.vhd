
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
 
entity Shifter_Final is
port(
    w:in unsigned(7 downto 0);
    sel:in unsigned(2 downto 0);
    y:out unsigned(7 downto 0));
end entity Shifter_Final;
 
architecture Shift of Shifter_Final is
begin
 
process(w,sel)
begin
        case sel is
            when "000"=> y<=w;
            when "001"=> y<=w(0)&w(7 downto 1);
            when "010"=> y<=w(1 downto 0)&w(7 downto 2); 
            when "011"=> y<=w(2 downto 0)&w(7 downto 3);
            when "100"=> y<=w(3 downto 0)&w(7 downto 4);
            when "101"=> y<=w(4 downto 0)&w(7 downto 5);
            when "110"=> y<=w(5 downto 0)&w(7 downto 6);
            when others=> y<=w(6 downto 0)&w(7);
        end case;  
end process;
 
end architecture Shift;
