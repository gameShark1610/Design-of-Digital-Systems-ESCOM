library ieee;
use ieee.std_logic_1164.all;
entity rom is
Port(clk:in std_logic;
rst:in std_logic;
count:out std_logic_vector(0 to 6));
end rom;

architecture arq_seguidor of rom is
signal counter:integer range 0 to 15:=0;
signal counter5hz:integer range 0 to 8640000:=0; 
signal clk5hz:std_logic:='0';
begin
--CLK a 25Hz
process(clk, rst)
begin
    if rst='0' then
    counter5hz <= 0;
    clk5hz <= '0';
    elsif rising_edge(clk) then
    if counter5hz = 8640000 then 
    counter5hz <= 0;
    clk5hz <= not clk5hz;
    else
    counter5hz <= counter5hz + 1;
    end if;
    end if;
end process;
--Lógica display 1
process(clk5hz, rst)
begin
    if rst='0' then
    counter <= 0;
    elsif rising_edge(clk5hz) then
        if counter = 7 then
        counter <= 0;
        else
        counter <= counter + 1;
        end if;
    end if;
end process;

with counter select
count <= "0110111" when 0, -- H
"1111110" when 1, -- O
"0001110" when 2, --L
"1110111" when 3, -- A
"0000101" when 4, -- r
"1110111" when 5, -- A
"0111110" when 6, -- U
"0001110" when 7, -- L
"0000000" when others;


end arq_seguidor;