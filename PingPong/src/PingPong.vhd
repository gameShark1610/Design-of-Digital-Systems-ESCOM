library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ping_pong_top is
    Port (
        CLK         : in  std_logic;
        BTN_P1      : in  std_logic;
        BTN_P2      : in  std_logic;
        BTN_RESET   : in  std_logic;
        LEDS        : out std_logic_vector(7 downto 0);
        SEG_P1      : out std_logic_vector(6 downto 0);
        SEG_P2      : out std_logic_vector(6 downto 0)
    );
end ping_pong_top;

architecture Behavioral of ping_pong_top is

    constant SPEED_0       : integer := 24_000_000;
    constant SPEED_1       : integer := 12_000_000;
    constant SPEED_2       : integer :=  6_000_000;

    type state_t is (ST_IDLE, ST_MOVING, ST_WAIT_HIT, ST_POINT, ST_WIN);

    signal state        : state_t := ST_IDLE;
    signal ball_pos     : integer range 0 to 7 := 0;
    signal ball_dir     : std_logic := '1';
    signal score_p1     : integer range 0 to 9 := 0;
    signal score_p2     : integer range 0 to 9 := 0;
    signal rally_cnt    : integer range 0 to 15 := 0;
    signal speed_level  : integer range 0 to 2 := 0;
    signal move_cnt     : integer := 0;
    signal wait_cnt     : integer := 0;
    signal pause_cnt    : integer := 0;
    signal current_speed: integer := SPEED_0;
    signal leds_reg     : std_logic_vector(7 downto 0) := (others => '0');

    signal btn1_db      : std_logic := '1';
    signal btn2_db      : std_logic := '1';
    signal rst_db       : std_logic := '1';
    signal btn1_prev    : std_logic := '1';
    signal btn2_prev    : std_logic := '1';
    signal btn1_press   : std_logic := '0';
    signal btn2_press   : std_logic := '0';

    component debounce is
        generic (DEBOUNCE_LIMIT : integer := 240_000);
        Port (CLK : in std_logic; BTN_IN : in std_logic; BTN_OUT : out std_logic);
    end component;

    component seg7_decoder is
        Port (digit : in integer range 0 to 9; seg : out std_logic_vector(6 downto 0));
    end component;

begin

    db_p1  : debounce port map (CLK => CLK, BTN_IN => BTN_P1,   BTN_OUT => btn1_db);
    db_p2  : debounce port map (CLK => CLK, BTN_IN => BTN_P2,   BTN_OUT => btn2_db);
    db_rst : debounce port map (CLK => CLK, BTN_IN => BTN_RESET, BTN_OUT => rst_db);

    -- Displays intercambiados segun conexion fisica real
    seg1 : seg7_decoder port map (digit => score_p1, seg => SEG_P2);
    seg2 : seg7_decoder port map (digit => score_p2, seg => SEG_P1);

    process(CLK)
    begin
        if rising_edge(CLK) then
            btn1_prev  <= btn1_db;
            btn2_prev  <= btn2_db;
            btn1_press <= btn1_prev and (not btn1_db);
            btn2_press <= btn2_prev and (not btn2_db);
        end if;
    end process;

    process(speed_level)
    begin
        case speed_level is
            when 0      => current_speed <= SPEED_0;
            when 1      => current_speed <= SPEED_1;
            when 2      => current_speed <= SPEED_2;
            when others => current_speed <= SPEED_0;
        end case;
    end process;

    process(CLK)
    begin
        if rising_edge(CLK) then

            if rst_db = '0' then
                state       <= ST_IDLE;
                score_p1    <= 0;
                score_p2    <= 0;
                rally_cnt   <= 0;
                speed_level <= 0;
                move_cnt    <= 0;
                wait_cnt    <= 0;
                pause_cnt   <= 0;
                leds_reg    <= (others => '0');

            else
                case state is

                    -- ----------------------------------------
                    -- IDLE: solo tras reset
                    -- ----------------------------------------
                    when ST_IDLE =>
                        pause_cnt <= pause_cnt + 1;
                        if pause_cnt mod 12_000_000 < 6_000_000 then
                            leds_reg <= "10000001";
                        else
                            leds_reg <= (others => '0');
                        end if;

                        if btn1_press = '1' then
                            ball_pos  <= 0;
                            ball_dir  <= '1';
                            move_cnt  <= 0;
                            pause_cnt <= 0;
                            state     <= ST_MOVING;
                        elsif btn2_press = '1' then
                            ball_pos  <= 7;
                            ball_dir  <= '0';
                            move_cnt  <= 0;
                            pause_cnt <= 0;
                            state     <= ST_MOVING;
                        end if;

                    -- ----------------------------------------
                    -- MOVING
                    -- ----------------------------------------
                    when ST_MOVING =>
                        leds_reg           <= (others => '0');
                        leds_reg(ball_pos) <= '1';

                        if move_cnt >= current_speed - 1 then
                            move_cnt <= 0;
                            if ball_dir = '1' then
                                if ball_pos >= 6 then
                                    ball_pos <= 7;
                                    wait_cnt <= 0;
                                    state    <= ST_WAIT_HIT;
                                else
                                    ball_pos <= ball_pos + 1;
                                end if;
                            else
                                if ball_pos <= 1 then
                                    ball_pos <= 0;
                                    wait_cnt <= 0;
                                    state    <= ST_WAIT_HIT;
                                else
                                    ball_pos <= ball_pos - 1;
                                end if;
                            end if;
                        else
                            move_cnt <= move_cnt + 1;
                        end if;

                        -- Penalizacion por presionar antes de tiempo:
                        -- J1 controla LED 0 (izquierda). Si presiona mientras
                        -- la pelota va HACIA el (ball_dir='0'), es demasiado pronto.
                        if btn1_press = '1' and ball_dir = '0' then
                            score_p2    <= score_p2 + 1;
                            pause_cnt   <= 0;
                            rally_cnt   <= 0;
                            speed_level <= 0;
                            state       <= ST_POINT;
                        end if;
                        -- J2 controla LED 7 (derecha). Si presiona mientras
                        -- la pelota va HACIA el (ball_dir='1'), es demasiado pronto.
                        if btn2_press = '1' and ball_dir = '1' then
                            score_p1    <= score_p1 + 1;
                            pause_cnt   <= 0;
                            rally_cnt   <= 0;
                            speed_level <= 0;
                            state       <= ST_POINT;
                        end if;

                    -- ----------------------------------------
                    -- WAIT_HIT: ventana = current_speed (mismo
                    -- tiempo que tarda un paso de la pelota)
                    -- ----------------------------------------
                    when ST_WAIT_HIT =>
                        -- Parpadeo rapido para avisar al jugador
                        if wait_cnt mod (current_speed / 4) < (current_speed / 8) then
                            leds_reg(ball_pos) <= '1';
                        else
                            leds_reg(ball_pos) <= '0';
                        end if;
                        wait_cnt <= wait_cnt + 1;

                        -- J1 golpea en extremo izquierdo (pos = 0)
                        if btn1_press = '1' then
                            if ball_pos = 0 then
                                ball_dir  <= '1';
                                ball_pos  <= 1;
                                move_cnt  <= 0;
                                rally_cnt <= rally_cnt + 1;
                                if (rally_cnt + 1) mod 3 = 0 and speed_level < 2 then
                                    speed_level <= speed_level + 1;
                                end if;
                                state <= ST_MOVING;
                            else
                                -- Presiono en el lado equivocado
                                score_p2    <= score_p2 + 1;
                                pause_cnt   <= 0;
                                rally_cnt   <= 0;
                                speed_level <= 0;
                                state       <= ST_POINT;
                            end if;
                        end if;

                        -- J2 golpea en extremo derecho (pos = 7)
                        if btn2_press = '1' then
                            if ball_pos = 7 then
                                ball_dir  <= '0';
                                ball_pos  <= 6;
                                move_cnt  <= 0;
                                rally_cnt <= rally_cnt + 1;
                                if (rally_cnt + 1) mod 3 = 0 and speed_level < 2 then
                                    speed_level <= speed_level + 1;
                                end if;
                                state <= ST_MOVING;
                            else
                                score_p1    <= score_p1 + 1;
                                pause_cnt   <= 0;
                                rally_cnt   <= 0;
                                speed_level <= 0;
                                state       <= ST_POINT;
                            end if;
                        end if;

                        -- Timeout = mismo tiempo que un paso de la pelota
                        if wait_cnt >= current_speed then
                            if ball_pos = 0 then
                                score_p2 <= score_p2 + 1;
                            else
                                score_p1 <= score_p1 + 1;
                            end if;
                            pause_cnt   <= 0;
                            rally_cnt   <= 0;
                            speed_level <= 0;
                            state       <= ST_POINT;
                        end if;

                    -- ----------------------------------------
                    -- POINT: pausa 2s, luego ST_MOVING desde centro
                    -- ----------------------------------------
                    when ST_POINT =>
                        leds_reg  <= (others => '1');
                        pause_cnt <= pause_cnt + 1;
                        if pause_cnt >= 48_000_000 then
                            pause_cnt <= 0;
                            if score_p1 >= 9 or score_p2 >= 9 then
                                state <= ST_WIN;
                            else
                                ball_pos <= 3;
                                ball_dir <= '1';
                                move_cnt <= 0;
                                state    <= ST_MOVING;
                            end if;
                        end if;

                    -- ----------------------------------------
                    -- WIN: parpadeo alternado hasta reset
                    -- ----------------------------------------
                    when ST_WIN =>
                        pause_cnt <= pause_cnt + 1;
                        if pause_cnt mod 12_000_000 < 6_000_000 then
                            leds_reg <= "10101010";
                        else
                            leds_reg <= "01010101";
                        end if;

                    when others =>
                        state <= ST_IDLE;

                end case;
            end if;
        end if;
    end process;

    LEDS <= leds_reg;

end Behavioral;
