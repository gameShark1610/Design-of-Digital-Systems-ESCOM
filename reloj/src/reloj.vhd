library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Reloj is
	port (
	clk: in  std_logic; -- 27MHz (Pin 52)
        reset: in  std_logic; --(Pin 3)
        s1: out std_logic;--Pin10
        s2: out std_logic;--11
        s3: out std_logic;--13
        s4: out std_logic;--14
        s5: out std_logic);--15
end Reloj;

architecture divisor of Reloj is
    signal contador1: integer range 0 to 1;--Divisor a 15MHz (Redondeado a 13.5Hz)
	signal salida_media1: std_logic := '0';
	
    signal contador2: integer range 0 to 1;--Divisor a 15MHz (Redondeado a 13.5Hz)
	signal salida_media2: std_logic := '0';

	signal contador3: integer range 0 to 12; --Divisor a 1Mhz(Redondeado a  1.04Mhz)
	signal salida_media3: std_logic := '0';

	signal contador4: integer range 0 to 134;--Divisor a 100KHz
	signal salida_media4: std_logic := '0';

	signal contador5: integer range 0 to 2699999:= 0;--Divisor a 5Hz
	signal salida_media5: std_logic := '0';
begin

	s1 <= clk;

--******************************************************
	Divisor_frecuencia15MHz: process (clk, reset)
	begin
		if reset= '0' then
		salida_media2 <= '0';
		contador2 <= 0;

		elsif rising_edge (clk) then
			if contador2 = 1 then
			contador2 <= 0;
			salida_media2 <= NOT salida_media2;
			
			else
			contador2 <= contador2 + 1;
			end if;
		end if;
	end process;
	s2 <= salida_media2;
--****************************************************
	Divisor_frecuencia1MHz: process (clk, reset)
	begin
		if reset= '0' then
		salida_media3 <= '0';
		contador3 <= 0;

		elsif rising_edge (clk) then
			if contador3 = 12 then
			contador3 <= 0;
			salida_media3 <= NOT salida_media3;
			
			else
			contador3 <= contador3 + 1;
			end if;
		end if;
	end process;
	s3 <= salida_media3;
--***************************************************
	Divisor_frecuencia100KHz: process (clk, reset)
	begin
		if reset= '0' then
		salida_media4 <= '0';
		contador4 <= 0;

		elsif rising_edge (clk) then
			if contador4 = 134 then
			contador4 <= 0;
			salida_media4 <= NOT salida_media4;
			
			else
			contador4 <= contador4 + 1;
			end if;
		end if;
	end process;
	s4 <= salida_media4;
--***************************************************
	Divisor_frecuencia5KHz: process (clk, reset)
	begin
		if reset= '0' then
		salida_media5 <= '0';
		contador5 <= 0;

		elsif rising_edge (clk) then
			if contador5 = 2699999 then
			contador5 <= 0;
			salida_media5 <= NOT salida_media5;
			
			else
			contador5 <= contador5 + 1;
			end if;
		end if;
	end process;
	s5 <= salida_media5;

	end divisor;
		