library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity diagrama is
    Port(
        clk     : in  std_logic; 
        X       : in  std_logic; 
        Z       : out std_logic; 
        monitor : out std_logic  
    );
end diagrama;

architecture arq_diagrama of diagrama is

    -- Reloj de 10 Hz (0.1 segundos) para mayor sensibilidad
    constant MAX_CUENTA : integer := 1350000; 
    signal contador     : integer range 0 to MAX_CUENTA := 0;
    signal clk_muestreo : std_logic := '0';

    -- Estados para detectar 4 pulsos
    type estados is (inicio, p1, p2, p3, p4);
    signal edo_presente, edo_futuro : estados := inicio;

    -- Señales para detectar el "clic" (flanco de bajada si es active low)
    signal X_ant : std_logic := '1';
    
    -- Temporizador para el margen de error (Timeout)
    -- Si pasan 30 ciclos de clk_muestreo (3 segundos) sin clics, resetea.
    signal timer_error : integer range 0 to 30 := 0;

begin

    -- Generador de Reloj de 10 Hz
    process(clk)
    begin
        if rising_edge(clk) then
            if contador = MAX_CUENTA then
                contador <= 0;
                clk_muestreo <= not clk_muestreo;
            else
                contador <= contador + 1;
            end if;
        end if;
    end process;

    monitor <= clk_muestreo; -- Parpadea rápido (10 veces por seg)

    -- Lógica de la Máquina de Estados
    process(clk_muestreo)
    begin
        if rising_edge(clk_muestreo) then
            -- Guardamos el valor anterior de X para detectar el flanco
            X_ant <= X;

            -- LÓGICA DE TIEMPO (Margen de error)
            if edo_presente /= inicio and edo_presente/=p4 then
                if timer_error = 5 then
                    edo_presente <= inicio; -- Timeout: Regresa al inicio por tardado
                    timer_error <= 0;
                else
                    timer_error <= timer_error + 1;
                end if;
            else
                timer_error <= 0;
            end if;

            -- LÓGICA DE TRANSICIÓN (Detectar 4 pulsos)
            -- Detectamos cuando X cambia de 1 a 0 (presionar botón en lógica negativa)
            if (X_ant = '1' and X = '0') then
                timer_error <= 0; -- Reset del timer porque el usuario sí picó el botón
                case edo_presente is
                    when inicio => edo_presente <= p1;
                    when p1     => edo_presente <= p2;
                    when p2     => edo_presente <= p3;
                    when p3     => edo_presente <= p4;
                    when p4     => edo_presente <= p4; -- Reinicia el ciclo si sigue picando --Si queremos que se reinicia ponemos p1 aqui en lugar de p4
                    when others => edo_presente <= inicio;
                end case;
            end if;
        end if;
    end process;

    -- Lógica de Salida (Combinacional)
    -- Mantengo tu lógica de Z='1' en reposo y Z='0' al detectar (Active Low LED)
    Z <= '0' when edo_presente = p4 else '1';

end arq_diagrama;