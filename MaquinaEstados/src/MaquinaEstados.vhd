library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity diagrama is
    Port(
        clk     : in  std_logic; 
        X       : in  std_logic; 
        Z       : out std_logic; 
        y       : in  std_logic; -- PIN 4 changed from 'out' to 'in' to act as RESET
        monitor : out std_logic  
    );
end diagrama;

architecture arq_diagrama of diagrama is

    -- Clock at 10 Hz (0.1 seconds)
    constant MAX_CUENTA : integer := 1350000; 
    signal contador     : integer range 0 to MAX_CUENTA := 0;
    signal clk_muestreo : std_logic := '0';

    -- States for detecting 4 pulses
    type estados is (inicio, p1, p2, p3, p4);
    signal edo_presente : estados := inicio;

    -- Signal to detect the edge
    signal X_ant : std_logic := '1';
    
    -- Timeout timer
    signal timer_error : integer range 0 to 30 := 0;

begin

    -- 10 Hz Clock Generator
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

    monitor <= clk_muestreo; 

    -- State Machine Logic with Synchronous Reset
    process(clk_muestreo)
    begin
        if rising_edge(clk_muestreo) then
            -- RESET LOGIC: If 'y' is high, the system returns to the start
            if y = '0' then 
                edo_presente <= inicio;
                timer_error <= 0;
                X_ant <= '1';
            else
                -- Save the previous value of X
                X_ant <= X;

                -- TIMEOUT LOGIC
                if edo_presente /= inicio and edo_presente /= p4 then
                    if timer_error = 5 then
                        edo_presente <= inicio; 
                        timer_error <= 0;
                    else
                        timer_error <= timer_error + 1;
                    end if;
                else
                    timer_error <= 0;
                end if;

                -- TRANSITION LOGIC (Detecting 4 pulses)
                if (X_ant = '1' and X = '0') then
                    timer_error <= 0; 
                    case edo_presente is
                        when inicio => edo_presente <= p1;
                        when p1     => edo_presente <= p2;
                        when p2     => edo_presente <= p3;
                        when p3     => edo_presente <= p4;
                        when p4     => edo_presente <= p4; 
                        when others => edo_presente <= inicio;
                    end case;
                end if;
            end if;
        end if;
    end process;

    -- Output Logic (Active Low LED)
    Z <= '0' when edo_presente = p4 else '1';

end arq_diagrama;