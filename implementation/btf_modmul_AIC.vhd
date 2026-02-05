library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity btf_modmul is
    generic (
        LOGQ                    : integer := 0;
        Q_VALUE                 : std_logic_vector := (others => '0'); -- interpreted as std_logic_vector, width must match LOGQ
        WORD_SIZE               : integer := 0;
        INTMUL_LAT              : integer := 0;
        INTMUL_TYPE             : string  := "";
        MODRED_LAT              : integer := 0;
        MODRED_TYPE             : string  := "default";
        MODRED_L                : integer := 4;
        MODRED_COREMUL_LAT      : integer := 1;
        SHIFT_A                 : integer := 0
    );
    port (
        clk     : in  std_logic;
        q       : in  std_logic_vector(LOGQ - 1 downto 0);
        a       : in  std_logic_vector(LOGQ - 1 downto 0);
        b       : in  std_logic_vector(LOGQ - 1 downto 0);
        w       : in  std_logic_vector(LOGQ - 1 downto 0);
        e       : out std_logic_vector(LOGQ - 1 downto 0);
        o       : out std_logic_vector(LOGQ - 1 downto 0);
        o_fault : out std_logic_vector(LOGQ - 1 downto 0)
    );
end entity;

architecture behavioral of btf_modmul is

    -- Assuming generic components exist with these port interfaces.
    component shiftreg
        generic (
            DEPTH : integer;
            WIDTH : integer
        );
        port (
            clk   : in  std_logic;
            din   : in  std_logic_vector(WIDTH - 1 downto 0);
            q     : out std_logic_vector(WIDTH - 1 downto 0)
        );
    end component;

    component intmul
        generic (
            A_WIDTH        : integer;
            B_WIDTH        : integer;
            LATENCY        : integer;
            IMPLEMENTATION : string
        );
        port (
            clk : in  std_logic;
            a   : in  std_logic_vector(A_WIDTH - 1 downto 0);
            b   : in  std_logic_vector(B_WIDTH - 1 downto 0);
            p   : out std_logic_vector(A_WIDTH + B_WIDTH - 1 downto 0)
        );
    end component;

    component modred
        generic (
            WIDTH            : integer;
            Q_CONST          : std_logic_vector;
            WORD_SIZE        : integer;
            LATENCY          : integer;
            IMPLEMENTATION   : string;
            MONT_LOOP        : integer;
            CORE_MUL_LAT     : integer
        );
        port (
            clk : in  std_logic;
            din : in  std_logic_vector(2 * WIDTH - 1 downto 0);
            q   : in  std_logic_vector(WIDTH - 1 downto 0);
            dout: out std_logic_vector(WIDTH - 1 downto 0)
        );
    end component;

    signal imul       : std_logic_vector(2 * LOGQ - 1 downto 0);
    signal imul_fault : std_logic_vector(2 * LOGQ - 1 downto 0);

begin

    -- shift a through shift register
    shift_inst : shiftreg
        generic map (
            DEPTH => SHIFT_A * (INTMUL_LAT + MODRED_LAT),
            WIDTH => LOGQ
        )
        port map (
            clk => clk,
            din => a,
            q   => e
        );

    -- main multiplication
    intmul_inst : intmul
        generic map (
            A_WIDTH        => LOGQ,
            B_WIDTH        => LOGQ,
            LATENCY        => INTMUL_LAT,
            IMPLEMENTATION => INTMUL_TYPE
        )
        port map (
            clk => clk,
            a   => b,
            b   => w,
            p   => imul
        );

    -- fault-free multiplier
    intmul_fault_inst : intmul
        generic map (
            A_WIDTH        => LOGQ,
            B_WIDTH        => LOGQ,
            LATENCY        => INTMUL_LAT,
            IMPLEMENTATION => INTMUL_TYPE
        )
        port map (
            clk => clk,
            a   => b,
            b   => w,
            p   => imul_fault
        );

    -- Montgomery modular reduction
    modred_inst : modred
        generic map (
            WIDTH          => LOGQ,
            Q_CONST        => Q_VALUE,
            WORD_SIZE      => WORD_SIZE,
            LATENCY        => MODRED_LAT,
            IMPLEMENTATION => MODRED_TYPE,
            MONT_LOOP      => MODRED_L,
            CORE_MUL_LAT   => MODRED_COREMUL_LAT
        )
        port map (
            clk => clk,
            din => imul,
            q   => q,
            dout=> o
        );

    -- Fault injection path reduction
    modred_fault_inst : modred
        generic map (
            WIDTH          => LOGQ,
            Q_CONST        => Q_VALUE,
            WORD_SIZE      => WORD_SIZE,
            LATENCY        => MODRED_LAT,
            IMPLEMENTATION => MODRED_TYPE,
            MONT_LOOP      => MODRED_L,
            CORE_MUL_LAT   => MODRED_COREMUL_LAT
        )
        port map (
            clk => clk,
            din => imul_fault,
            q   => q,
            dout=> o_fault
        );

end architecture;
