library ieee;
use ieee.std_logic_1164.all;

entity RegistrosCorrimiento is
    port(
        clk_fpga : in  std_logic; -- El reloj físico de 27MHz (Pin 52)
        reset    : in  std_logic;
        load     : in  std_logic;
        d_in     : in  std_logic_vector(7 downto 0);
        --s_in     : in  std_logic;
        modo     : in  std_logic_vector(2 downto 0);
        q_out    : out std_logic_vector(7 downto 0)
        --s_out    : out std_logic
    );
end RegistrosCorrimiento;

architecture comportamiento of RegistrosCorrimiento is

    -- 1. Declaramos que vamos a usar el Divisor
    component DivisorFrecuencia is
        port(
            clk_in  : in  std_logic;
            reset   : in  std_logic;
            clk_out : out std_logic
        );
    end component;

    -- 2. Creamos una señal interna para el reloj lento
    signal clk_5hz : std_logic;
    signal reg       : std_logic_vector(7 downto 0) := (others => '0');

begin

    -- 3. Hacemos el PORT MAP para conectar el divisor
    Reloj_5Hz: DivisorFrecuencia 
        port map(
            clk_in  => clk_fpga,  -- Conectamos el reloj rápido de la placa
            reset   => reset,
            clk_out => clk_5hz  -- La salida va a nuestra señal interna
        );

    -- 4. Tu lógica de siempre, pero usando 'clk_5hz'
    process(clk_5hz, reset)
    begin
        if reset = '0' then
            reg <= (others => '0');
        elsif rising_edge(clk_5hz) then
            case modo is
                when "000" => reg <= '0' & reg(7 downto 1); --SISO derecha
                when "001" => reg <= reg(6 downto 0) & '0'; --SISO izquierda
                when "010" =>                               --PISO
                    if load = '1' then reg <= d_in;
                    else reg <= reg(6 downto 0) & '0';
                    end if;
                when "011" => reg <= reg(6 downto 0) & '0'; --SIPO
                when "100" => reg <= d_in;                  --PIPO
                when "101" => reg <= reg(0) & reg(7 downto 1); --Rotacion a la derecha
                when "110" => reg <= reg(6 downto 0) & reg(7); --Rotacion a la izquierda
                when others => reg <= reg;
            end case;
        end if;
    end process;

    q_out <= reg;
    --s_out <= reg(7);

end comportamiento;