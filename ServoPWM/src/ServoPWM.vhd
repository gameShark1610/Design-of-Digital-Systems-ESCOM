library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ServoPWM is
    port(
        clk     : in  std_logic; -- Pin 52 (27 MHz)
        rst     : in  std_logic; -- Pin 3 (Botón S1)
        cerrar  : in  std_logic; -- Pin 32
        pwm_out : out std_logic  -- Pin 31
    );
end ServoPWM;

architecture generador of ServoPWM is
    constant PERIOD_20MS : integer := 540000;
    signal contador      : integer range 0 to PERIOD_20MS - 1 := 0;
    
    constant DUTY_MIN : integer := 27000; -- 1ms
    constant DUTY_MAX : integer := 54000; -- 2ms
    
    signal current_duty : integer range 0 to PERIOD_20MS - 1 := DUTY_MIN;
    
    -- AJUSTE DE VELOCIDAD:
    -- Ahora que estamos sincronizados, 1 significa que se mueve cada 20ms.
    -- Prueba con valores entre 1 y 5.
    constant SPEED_DIVIDER : integer := 2; 
    signal speed_counter   : integer range 0 to SPEED_DIVIDER := 0;

begin

    process(clk, rst)
    begin
        if rst = '0' then 
            contador <= 0;
            current_duty <= DUTY_MIN;
            speed_counter <= 0;
        elsif rising_edge(clk) then
            
            -- 1. Generador del periodo de 20ms
            if contador < PERIOD_20MS - 1 then
                contador <= contador + 1;
            else
                contador <= 0; -- REINICIO DEL CICLO PWM

                -- 2. Lógica de rampa (Solo ocurre una vez cada 20ms)
                if speed_counter < SPEED_DIVIDER then
                    speed_counter <= speed_counter + 1;
                else
                    speed_counter <= 0;
                    
                    if cerrar = '1' then
                        if current_duty < DUTY_MAX then
                            -- Subimos de 400 en 400 para que se note el movimiento
                            current_duty <= current_duty + 400; 
                        end if;
                    else
                        if current_duty > DUTY_MIN then
                            current_duty <= current_duty - 400;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- LÓGICA PARA TRANSISTOR 2N2222 (INVERSOR)
    pwm_out <= '0' when contador < current_duty else '1';

end generador;