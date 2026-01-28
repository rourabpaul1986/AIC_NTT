
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity NTTCore is
    generic (
        ENABLE_NTT      : integer := 1;
        Q_WIDTH         : integer := 32;
        N_LOG           : integer := 11;
        PE_COUNT        : integer := 8;
        TRANSFORM_MODE  : string  := "";
        RADIX_BITS      : integer := 12;
        ADD_DELAY       : integer := 1;
        MUL_DELAY       : integer := 2;
        RED_DELAY       : integer := 1;
        POLY_MEMS       : integer := 1;
        ROM_ADDR_W      : integer := 32
    );
    port (
        clk_i     : in  std_logic;
        rst_i     : in  std_logic;
        start_i   : in  std_logic;

        m_i       : in  std_logic_vector(Q_WIDTH-1 downto 0);
        e_i       : in  std_logic_vector(Q_WIDTH-1 downto 0);
        n_i       : in  std_logic_vector(Q_WIDTH-1 downto 0);

        done_o    : out std_logic
    );
end entity NTTCore;

architecture rtl of NTTCore is

    signal busy_r : std_logic := '0';
    signal done_r : std_logic := '0';

begin

    process(clk_i)
    begin
        if rising_edge(clk_i) then
            if rst_i = '1' then
                busy_r <= '0';
                done_r <= '0';
            else
                done_r <= '0';
                if start_i = '1' and busy_r = '0' then
                    busy_r <= '1';
                elsif busy_r = '1' then
                    busy_r <= '0';
                    done_r <= '1';
                end if;
            end if;
        end if;
    end process;

    done_o <= done_r;

end architecture rtl;
