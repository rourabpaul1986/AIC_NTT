-- btf_modmul.vhd
-- Parametric modular multiply (butterfly) wrapper
-- e = shift(a)
-- o = b * w (mod q)  (performed by modular reduction unit)
-- Note: This is a structural wrapper. Implement or map the
--       `shiftreg`, `intmul`, and `modred` entities separately.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity btf_modmul is
  generic (
    LOGQ                 : integer := 0;
    Q_VALUE              : std_logic_vector(LOGQ-1 downto 0) := (others => '0'); -- constant q (optional)
    WORD_SIZE            : integer := 0; -- Last WORD_SIZE digit of q will be 00...001
    -- integer multiplier parameters
    INTMUL_LAT           : integer := 0; -- should be >= 1 (valid only if INTMUL_TYPE = "")
    INTMUL_TYPE          : string  := ""; -- options: "", "fpga_auto", "fpga_lut", "fpga_dsp", "custom"
    -- modular reduction parameters
    MODRED_LAT           : integer := 0;
    MODRED_TYPE          : string  := "default"; -- "default" (WL Montgomery), "custom", "" (sim)
    MODRED_L             : integer := 4;        -- montgomery loop count (ceil(LOGQ/WORD_SIZE))
    MODRED_COREMUL_LAT   : integer := 1;        -- latency of multiply/add in WL Montgomery
    -- butterfly related parameters
    SHIFT_A              : integer := 0         -- 1: shift input a by MODRED_LAT + INTMUL_LAT
  );
  port (
    clk : in  std_logic;
    q   : in  std_logic_vector(LOGQ-1 downto 0);
    a   : in  std_logic_vector(LOGQ-1 downto 0);
    b   : in  std_logic_vector(LOGQ-1 downto 0);
    w   : in  std_logic_vector(LOGQ-1 downto 0);
    e   : out std_logic_vector(LOGQ-1 downto 0);
    o   : out std_logic_vector(LOGQ-1 downto 0)
  );
end entity btf_modmul;

architecture structural of btf_modmul is

  -- internal wide product: 2*LOGQ bits
  signal imul : std_logic_vector(2*LOGQ-1 downto 0);

  ----------------------------------------------------------------------------
  -- Component declarations
  -- NOTE: Adapt these declarations to match your actual module/entity names,
  --       generic names/types, and port directions if they differ.
  ----------------------------------------------------------------------------

  component shiftreg
    generic (
      DEPTH : integer := 0;
      WIDTH : integer := 0
    );
    port (
      clk  : in  std_logic;
      din  : in  std_logic_vector(WIDTH-1 downto 0);
      dout : out std_logic_vector(WIDTH-1 downto 0)
    );
  end component;

  component intmul
    generic (
      A_WIDTH : integer := 0;
      B_WIDTH : integer := 0;
      LATENCY : integer := 0;
      TYPE_STR: string  := ""
    );
    port (
      clk     : in  std_logic;
      a       : in  std_logic_vector(A_WIDTH-1 downto 0);
      b       : in  std_logic_vector(B_WIDTH-1 downto 0);
      product : out std_logic_vector(A_WIDTH+B_WIDTH-1 downto 0)
    );
  end component;

  component modred
    generic (
      QW       : integer := 0;
      QVAL     : std_logic_vector(QW-1 downto 0) := (others => '0');
      WSIZE    : integer := 0;
      LATENCY  : integer := 0;
      TYPE_STR : string  := "default";
      L_LOOP   : integer := 4;
      CORE_LAT : integer := 1
    );
    port (
      clk    : in  std_logic;
      in_val : in  std_logic_vector(2*QW-1 downto 0);
      q      : in  std_logic_vector(QW-1 downto 0);
      out_val: out std_logic_vector(QW-1 downto 0)
    );
  end component;

begin

  ----------------------------------------------------------------------------
  -- shift: e <= delayed(a) by SHIFT_A * (INTMUL_LAT + MODRED_LAT)
  -- mapped to shiftreg generic DEPTH = SHIFT_A * (INTMUL_LAT + MODRED_LAT)
  ----------------------------------------------------------------------------
  shiftreg_i : shiftreg
    generic map (
      DEPTH => SHIFT_A * (INTMUL_LAT + MODRED_LAT),
      WIDTH => LOGQ
    )
    port map (
      clk  => clk,
      din  => a,
      dout => e
    );

  ----------------------------------------------------------------------------
  -- integer multiply: imul <= b * w
  ----------------------------------------------------------------------------
  intmul_i : intmul
    generic map (
      A_WIDTH => LOGQ,
      B_WIDTH => LOGQ,
      LATENCY => INTMUL_LAT,
      TYPE_STR=> INTMUL_TYPE
    )
    port map (
      clk     => clk,
      a       => b,
      b       => w,
      product => imul
    );

  ----------------------------------------------------------------------------
  -- modular reduction: o <= imul mod q
  ----------------------------------------------------------------------------
  modred_i : modred
    generic map (
      QW       => LOGQ,
      QVAL     => Q_VALUE,
      WSIZE    => WORD_SIZE,
      LATENCY  => MODRED_LAT,
      TYPE_STR => MODRED_TYPE,
      L_LOOP   => MODRED_L,
      CORE_LAT => MODRED_COREMUL_LAT
    )
    port map (
      clk     => clk,
      in_val  => imul,
      q       => q,
      out_val => o
    );

end architecture structural;
