library ieee;
use ieee.std_logic_1164.all;

entity seguidorpwm is
    Port(
        clk     : in  std_logic;
        M       : out std_logic_vector(3 downto 0);
        S       : in  std_logic_vector(1 downto 0);
        pwm_out : out std_logic
    );
end seguidorpwm;

architecture arq_seguidor of seguidorpwm is


    type estados is (a, d, i, st_giro_izq, st_op_garra, st_giro_der);
    signal edo_presente : estados := a;
    signal cerrar : std_logic := '0';
    signal M_int : std_logic_vector(3 downto 0) := "0000";
    signal timer : integer range 0 to 53999999 := 0;


    constant PERIOD_20MS   : integer := 540000;
    constant DUTY_MIN      : integer := 27000;
    constant DUTY_MAX      : integer := 54000;

    signal contador      : integer range 0 to PERIOD_20MS - 1 := 0;
    signal current_duty  : integer range 0 to PERIOD_20MS - 1 := DUTY_MIN;

    constant SPEED_DIVIDER : integer := 2;
    signal speed_counter   : integer range 0 to SPEED_DIVIDER := 0;

begin

    M <= M_int;

    principal: process(clk)
    begin
        if rising_edge(clk) then
            case edo_presente is

                when a =>
                    M_int <= "1010"; -- avanza
                    if    S = "11" then
                        edo_presente <= st_giro_izq;
                        timer        <= 53999999;
                    elsif S = "01" then
                        edo_presente <= d;
                    elsif S = "10" then
                        edo_presente <= i;
                    end if;

                when d =>
                    M_int <= "1000"; -- gira derecha
                    if    S = "00" then
                        edo_presente <= a;
                    elsif S = "10" then
                        edo_presente <= i;
                    elsif S = "11" then
                        edo_presente <= st_giro_izq;
                        timer        <= 53999999;
                    end if;

                when i =>
                    M_int <= "0010"; -- gira izquierda
                    if    S = "00" then
                        edo_presente <= a;
                    elsif S = "01" then
                        edo_presente <= d;
                    elsif S = "11" then
                        edo_presente <= st_giro_izq;
                        timer <= 53999999;
                    end if;

                when st_giro_izq =>
                    M_int <= "0010"; -- giro izquierda
                    if timer > 0 then
                        timer <= timer - 1;
                    else
                        M_int        <= "0000";
                        cerrar       <= not cerrar;
                        edo_presente <= st_op_garra;
                        timer        <= 53999999; -- espera a que el servo termine
                    end if;

                when st_op_garra =>
                    M_int <= "0000";
                    if timer > 0 then
                        timer <= timer - 1;
                    else
                        edo_presente <= st_giro_der;
                        timer        <= 53999999;
                    end if;

                when st_giro_der =>
                    M_int <= "1000"; --giro derecha
                    if timer > 0 then
                        timer <= timer - 1;
                    else
                        M_int        <= "0000";
                        edo_presente <= a; -- regresa al seguidor de línea
                    end if;

            end case;
        end if;
    end process principal;

    PWM: process(clk)
    begin
        if rising_edge(clk) then
            if contador < PERIOD_20MS - 1 then
                contador <= contador + 1;
            else
                contador <= 0; -- reinicio del período de 20 ms

                if speed_counter < SPEED_DIVIDER then
                    speed_counter <= speed_counter + 1;
                else
                    speed_counter <= 0;

                    if cerrar = '1' then
                        if current_duty < DUTY_MAX then
                            current_duty <= current_duty + 400; -- cierra la garra
                        end if;
                    else
                        if current_duty > DUTY_MIN then
                            current_duty <= current_duty - 400; -- abre la garra
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process PWM;

    --el transisor invierte la entrada
    pwm_out <= '0' when contador < current_duty else '1';

end arq_seguidor;