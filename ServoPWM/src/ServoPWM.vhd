library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_garra is
    Port (
        clk      : in  STD_LOGIC; -- Pin 52 (27MHz)
        rst      : in  STD_LOGIC; -- Pin 3 (Reset)
        enc_clk  : in  STD_LOGIC; -- Pin 33 (Encoder Clock)
        enc_dt   : in  STD_LOGIC; -- Pin 34 (Encoder Data)
        cerrar   : in  STD_LOGIC; -- Pin 32 (Encoder Switch)
        pwm_out  : out STD_LOGIC  -- Pin 31 (Señal al Servo MG995)
    );
end control_garra;

architecture Behavioral of control_garra is

    -- Señales para leer el estado del encoder
    signal enc_clk_last : STD_LOGIC := '1';
    
    -- Contador de posición del servo (De 0 a 100)
    -- 0 = 1ms (Aprox 0°), 100 = 2ms (Aprox 180°)
    signal pos_contador : integer range 0 to 100 := 0; 

    -- Señales para el generador de PWM
    signal pwm_counter : integer range 0 to 540000 := 0; -- Para los 20ms (50Hz)
    signal duty_cycle  : integer := 27000; -- Empieza en 1ms (Posición base)

begin

    -- BLOQUE 1: Lectura del Encoder y Lógica de Posición
    process(clk, rst)
    begin
        -- Reset asíncrono (si lo conectaste a un botón a GND)
        if rst = '0' then  
            pos_contador <= 0;
            enc_clk_last <= '1';
            
        -- Lógica síncrona evaluada cada ciclo de reloj
        elsif rising_edge(clk) then
            
            -- Prioridad al botón del encoder: si se presiona, regresa a 0
            if cerrar = '0' then
                pos_contador <= 0;
            else
                -- Detectar el giro: cuando 'enc_clk' pasa de '1' a '0'
                if (enc_clk_last = '1' and enc_clk = '0') then
                    
                    if enc_dt = '1' then
                        -- Sentido 1: Sumar (Avanza 2 pasos para no girar tanto la perilla)
                        if pos_contador <= 98 then 
                            pos_contador <= pos_contador + 2;
                        end if;
                    else
                        -- Sentido 2: Restar
                        if pos_contador >= 2 then
                            pos_contador <= pos_contador - 2;
                        end if;
                    end if;
                    
                end if;
            end if;
            
            -- Guardar el estado actual para la siguiente comparación
            enc_clk_last <= enc_clk;
            
        end if;
    end process;

    -- BLOQUE 2: Generación Física de la Señal PWM
    process(clk)
    begin
        if rising_edge(clk) then
            
            -- Mapear la posición al tiempo del pulso
            -- Base: 27,000 ticks (1ms). Máximo: 27,000 + (100 * 270) = 54,000 ticks (2ms)
            duty_cycle <= 27000 + (pos_contador * 270);

            -- Contador principal para la frecuencia de 50Hz (20ms total)
            if pwm_counter < 540000 then
                pwm_counter <= pwm_counter + 1;
            else
                pwm_counter <= 0;
            end if;

            -- Generar el pulso alto (Lógica directa)
            if pwm_counter < duty_cycle then
                pwm_out <= '1';
            else
                pwm_out <= '0';
            end if;
            
        end if;
    end process;

end Behavioral;