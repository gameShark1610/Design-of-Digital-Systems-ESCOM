-- estacionamiento.vhd
-- Tang Nano 9K (GW1NR-LV9) | Gowin EDA | DSD
-- Contador 0-F con debounce, LEDs de estado y display 7 segmentos

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity estacionamiento is
    port (
        clk            : in  std_logic;                    -- 27 MHz onboard
        rst_n          : in  std_logic;                    -- reset activo en bajo (BTN1)
        sensor_entrada : in  std_logic;                    -- switch límite entrada
        sensor_salida  : in  std_logic;                    -- switch límite salida
        led_verde      : out std_logic;                    -- espacio disponible
        led_rojo       : out std_logic;                    -- estacionamiento lleno
        seg7           : out std_logic_vector(6 downto 0)  -- display 7 segmentos
    );
end entity estacionamiento;

architecture rtl of estacionamiento is

    constant MAX          : integer := 15;
    constant DEBOUNCE_CNT : integer := 27_000;  -- 1 ms @ 27 MHz

    signal contador : unsigned(3 downto 0) := (others => '0');

    -- Debounce sensor entrada
    signal db_ent_cnt : integer range 0 to DEBOUNCE_CNT := 0;
    signal ent_db     : std_logic := '1';  -- reposo en '1' (pull-up)
    signal ent_prev   : std_logic := '1';

    -- Debounce sensor salida
    signal db_sal_cnt : integer range 0 to DEBOUNCE_CNT := 0;
    signal sal_db     : std_logic := '1';  -- reposo en '1' (pull-up)
    signal sal_prev   : std_logic := '1';

    signal pulso_entrada : std_logic;
    signal pulso_salida  : std_logic;

begin

    -- Flanco de bajada (pull-up: reposo='1', presionado='0')
    pulso_entrada <= ent_prev and (not ent_db);
    pulso_salida  <= sal_prev and (not sal_db);

    -- ─── Debounce sensor entrada ──────────────────────────
    debounce_entrada : process(clk, rst_n)
    begin
        if rst_n = '0' then
            db_ent_cnt <= 0;
            ent_db     <= '1';
        elsif rising_edge(clk) then
            if sensor_entrada /= ent_db then
                if db_ent_cnt = DEBOUNCE_CNT - 1 then
                    ent_db     <= sensor_entrada;
                    db_ent_cnt <= 0;
                else
                    db_ent_cnt <= db_ent_cnt + 1;
                end if;
            else
                db_ent_cnt <= 0;
            end if;
        end if;
    end process;

    -- ─── Debounce sensor salida ───────────────────────────
    debounce_salida : process(clk, rst_n)
    begin
        if rst_n = '0' then
            db_sal_cnt <= 0;
            sal_db     <= '1';
        elsif rising_edge(clk) then
            if sensor_salida /= sal_db then
                if db_sal_cnt = DEBOUNCE_CNT - 1 then
                    sal_db     <= sensor_salida;
                    db_sal_cnt <= 0;
                else
                    db_sal_cnt <= db_sal_cnt + 1;
                end if;
            else
                db_sal_cnt <= 0;
            end if;
        end if;
    end process;

    -- ─── Registros prev (proceso separado) ───────────────
    prev_proc : process(clk, rst_n)
    begin
        if rst_n = '0' then
            ent_prev <= '1';
            sal_prev <= '1';
        elsif rising_edge(clk) then
            ent_prev <= ent_db;
            sal_prev <= sal_db;
        end if;
    end process;

    -- ─── Lógica del contador ──────────────────────────────
    contador_proc : process(clk, rst_n)
    begin
        if rst_n = '0' then
            contador <= (others => '0');
        elsif rising_edge(clk) then
            if pulso_entrada = '1' and contador < MAX then
                contador <= contador + 1;
            elsif pulso_salida = '1' and contador > 0 then
                contador <= contador - 1;
            end if;
        end if;
    end process;

    -- ─── LEDs ─────────────────────────────────────────────
    led_verde <= '1' when contador = 0 else '0';
    led_rojo  <= '1' when contador = MAX else '0';

    -- ─── Decodificador 7 segmentos (ánodo común 5161BS)
    -- Orden: seg7(6)=G  seg7(5)=F  seg7(4)=E  seg7(3)=D
    --        seg7(2)=C  seg7(1)=B  seg7(0)=A
    -- Ánodo común: '0' = encendido, '1' = apagado
    seg7_proc : process(contador)
    begin
        case contador is
          --                      GFEDCBA
            when x"0"   => seg7 <= "1000000";  -- 0
            when x"1"   => seg7 <= "1111001";  -- 1
            when x"2"   => seg7 <= "0100100";  -- 2
            when x"3"   => seg7 <= "0110000";  -- 3
            when x"4"   => seg7 <= "0011001";  -- 4
            when x"5"   => seg7 <= "0010010";  -- 5
            when x"6"   => seg7 <= "0000010";  -- 6
            when x"7"   => seg7 <= "1111000";  -- 7
            when x"8"   => seg7 <= "0000000";  -- 8
            when x"9"   => seg7 <= "0010000";  -- 9
            when x"A"   => seg7 <= "0001000";  -- A
            when x"B"   => seg7 <= "0000011";  -- b
            when x"C"   => seg7 <= "1000110";  -- C
            when x"D"   => seg7 <= "0100001";  -- d
            when x"E"   => seg7 <= "0000110";  -- E
            when x"F"   => seg7 <= "0001110";  -- F
            when others => seg7 <= "1111111";  -- apagado
        end case;
    end process;

end architecture rtl;