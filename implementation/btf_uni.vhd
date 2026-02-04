library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity btf_uni is
  generic (
    LOGQ                 : integer := 0;
    Q_VALUE              : natural := 0; -- constant q (if used as integer)
    WORD_SIZE            : integer := 0;
    MODADD_LAT           : integer := 0;
    INTMUL_LAT           : integer := 0;
    INTMUL_TYPE          : string  := ""; -- "", "fpga_auto", ...
    MODRED_LAT           : integer := 0;
    MODRED_TYPE          : string  := "default";
    MODRED_L             : integer := 4;
    MODRED_COREMUL_LAT   : integer := 1;
    BTF_TYPE             : string  := "unified"; -- "unified", "ct", "gs"
    SHIFT_AE             : integer := 0;
    DIV_BY_2             : integer := 1
  );
  port (
    clk      : in  std_logic;
    dif_dit  : in  std_logic;  -- 0: dif, 1: dit
    div_by_2 : in  std_logic;  -- perform final div_by_2 when high (for butterfly opcode)
    opcode   : in  std_logic_vector(1 downto 0); -- 00: butterfly, 01: multiply, 10: modadd, 11: modsub
    q        : in  std_logic_vector(LOGQ-1 downto 0);
    a        : in  std_logic_vector(LOGQ-1 downto 0);
    b        : in  std_logic_vector(LOGQ-1 downto 0);
    w        : in  std_logic_vector(LOGQ-1 downto 0);
    e        : out std_logic_vector(LOGQ-1 downto 0);
    o        : out std_logic_vector(LOGQ-1 downto 0);
    add_out  : out std_logic_vector(LOGQ-1 downto 0);
    sub_out  : out std_logic_vector(LOGQ-1 downto 0);
    mult_out : out std_logic_vector(LOGQ-1 downto 0)
  );
end entity btf_uni;

architecture rtl of btf_uni is

  -- Component declarations (stubs). Replace with actual implementations.
  component btf_addsub
    generic (
      LOGQ      : integer;
      Q_VALUE   : natural;
      WORD_SIZE : integer;
      MODADD_LAT: integer
    );
    port (
      clk     : in  std_logic;
      qH      : in  std_logic_vector((LOGQ-WORD_SIZE)-1 downto 0);
      i0      : in  std_logic_vector(LOGQ-1 downto 0);
      i1      : in  std_logic_vector(LOGQ-1 downto 0);
      o0      : out std_logic_vector(LOGQ-1 downto 0);
      o1      : out std_logic_vector(LOGQ-1 downto 0)
    );
  end component;

  component btf_modmul
    generic (
      LOGQ                 : integer;
      Q_VALUE              : natural;
      WORD_SIZE            : integer;
      INTMUL_LAT           : integer;
      INTMUL_TYPE          : string;
      MODRED_LAT           : integer;
      MODRED_TYPE          : string;
      MODRED_L             : integer;
      MODRED_COREMUL_LAT   : integer;
      SHIFT_AE             : integer
    );
    port (
      clk  : in  std_logic;
      q    : in  std_logic_vector(LOGQ-1 downto 0);
      i0   : in  std_logic_vector(LOGQ-1 downto 0);
      i1   : in  std_logic_vector(LOGQ-1 downto 0);
      w    : in  std_logic_vector(LOGQ-1 downto 0);
      o0   : out std_logic_vector(LOGQ-1 downto 0);
      o1   : out std_logic_vector(LOGQ-1 downto 0)
    );
  end component;

  component divby2
    generic (
      LOGQ      : integer;
      Q_VALUE   : natural;
      WORD_SIZE : integer;
      LATENCY   : integer
    );
    port (
      clk : in std_logic;
      i   : in std_logic_vector(LOGQ-1 downto 0);
      qH  : in std_logic_vector((LOGQ-WORD_SIZE)-1 downto 0);
      o   : out std_logic_vector(LOGQ-1 downto 0)
    );
  end component;

  -- Internal signals
  signal dif_dit_internal : std_logic;
  signal dif_by_2_DP      : std_logic := '0';

  signal addsub_i0, addsub_i1 : std_logic_vector(LOGQ-1 downto 0);
  signal addsub_o0, addsub_o1 : std_logic_vector(LOGQ-1 downto 0);

  signal modmul_i0, modmul_i1 : std_logic_vector(LOGQ-1 downto 0);
  signal modmul_o0, modmul_o1 : std_logic_vector(LOGQ-1 downto 0);

  signal dif_dit_d0, dif_dit_d1 : std_logic;

  signal e_bf, o_bf : std_logic_vector(LOGQ-1 downto 0);
  signal e_bf_1DP, o_bf_1DP : std_logic_vector(LOGQ-1 downto 0);
  signal e_div, o_div : std_logic_vector(LOGQ-1 downto 0);

  -- qH slice (high bits of q)
  signal qH : std_logic_vector((LOGQ-WORD_SIZE)-1 downto 0);

  -- shift pipelines for dif_dit:
  -- pipeline1 length = INTMUL_LAT + MODRED_LAT to produce dif_dit_d0
  -- pipeline2 length = MODADD_LAT to produce dif_dit_d1
begin

  -- compute qH (if WORD_SIZE equals LOGQ, this will generate a zero-length range;
  -- ensure generics make sense)
  qH <= q(LOGQ-1 downto WORD_SIZE) when LOGQ > WORD_SIZE else (others => '0');

  -- dif_dit_internal selection (based on BTF_TYPE generic)
  dif_dit_sel_proc: process(dif_dit, opcode)
  begin
    if BTF_TYPE = "unified" then
      if opcode = "00" then
        dif_dit_internal <= dif_dit;
      else
        dif_dit_internal <= '1';
      end if;
    elsif BTF_TYPE = "ct" then
      dif_dit_internal <= '1';
    else
      -- assume "gs" or anything else => dif (0)
      dif_dit_internal <= '0';
    end if;
  end process;

  -- dif_by_2 pipeline register (sampled on clock; butterfly opcode only)
  dif_by_2_reg: process(clk)
  begin
    if rising_edge(clk) then
      if opcode = "00" then
        dif_by_2_DP <= div_by_2;
      else
        dif_by_2_DP <= '0';
      end if;
    end if;
  end process;

  -- Pipeline stage 1: shift dif_dit_internal by (INTMUL_LAT + MODRED_LAT) to produce dif_dit_d0
  gen_dif_pipeline1: if (INTMUL_LAT + MODRED_LAT) > 0 generate
    signal dif_pipe1 : std_logic_vector(INTMUL_LAT + MODRED_LAT - 1 downto 0);
  begin
    process(clk)
    begin
      if rising_edge(clk) then
        if (INTMUL_LAT + MODRED_LAT) > 1 then
          dif_pipe1(INTMUL_LAT + MODRED_LAT - 1 downto 1) <= dif_pipe1(INTMUL_LAT + MODRED_LAT - 2 downto 0);
        end if;
        dif_pipe1(0) <= dif_dit_internal;
      end if;
    end process;
    dif_dit_d0 <= dif_pipe1(INTMUL_LAT + MODRED_LAT - 1);
  end generate;

  gen_dif_pipeline1_zero: if (INTMUL_LAT + MODRED_LAT) = 0 generate
  begin
    dif_dit_d0 <= dif_dit_internal;
  end generate;

  -- Pipeline stage 2: shift dif_dit_d0 by MODADD_LAT to produce dif_dit_d1
  gen_dif_pipeline2: if MODADD_LAT > 0 generate
    signal dif_pipe2 : std_logic_vector(MODADD_LAT-1 downto 0);
  begin
    process(clk)
    begin
      if rising_edge(clk) then
        if MODADD_LAT > 1 then
          dif_pipe2(MODADD_LAT-1 downto 1) <= dif_pipe2(MODADD_LAT-2 downto 0);
        end if;
        dif_pipe2(0) <= dif_dit_d0;
      end if;
    end process;
    dif_dit_d1 <= dif_pipe2(MODADD_LAT-1);
  end generate;

  gen_dif_pipeline2_zero: if MODADD_LAT = 0 generate
  begin
    dif_dit_d1 <= dif_dit_d0;
  end generate;

  -- Instantiate units (component stubs)
  addsub_inst: btf_addsub
    generic map (
      LOGQ       => LOGQ,
      Q_VALUE    => Q_VALUE,
      WORD_SIZE  => WORD_SIZE,
      MODADD_LAT => MODADD_LAT
    )
    port map (
      clk => clk,
      qH  => qH,
      i0  => addsub_i0,
      i1  => addsub_i1,
      o0  => addsub_o0,
      o1  => addsub_o1
    );

  modmul_inst: btf_modmul
    generic map (
      LOGQ               => LOGQ,
      Q_VALUE            => Q_VALUE,
      WORD_SIZE          => WORD_SIZE,
      INTMUL_LAT         => INTMUL_LAT,
      INTMUL_TYPE        => INTMUL_TYPE,
      MODRED_LAT         => MODRED_LAT,
      MODRED_TYPE        => MODRED_TYPE,
      MODRED_L           => MODRED_L,
      MODRED_COREMUL_LAT => MODRED_COREMUL_LAT,
      SHIFT_AE           => SHIFT_AE
    )
    port map (
      clk => clk,
      q   => q,
      i0  => modmul_i0,
      i1  => modmul_i1,
      w   => w,
      o0  => modmul_o0,
      o1  => modmul_o1
    );

  -- MUXes: connect modmul inputs either directly from a/b or from addsub outputs depending on dif_dit_internal
  modmul_i0 <= a when dif_dit_internal = '1' else addsub_o0;
  modmul_i1 <= b when dif_dit_internal = '1' else addsub_o1;

  -- MUXes: connect addsub inputs either from modmul outputs (pipelined) or from original a/b depending on dif_dit_d0
  addsub_i0 <= modmul_o0 when dif_dit_d0 = '1' else a;
  addsub_i1 <= modmul_o1 when dif_dit_d0 = '1' else b;

  -- BF output MUXes: choose between addsub outputs and modmul outputs based on dif_dit_d1
  e_bf <= addsub_o0 when dif_dit_d1 = '1' else modmul_o0;
  o_bf <= addsub_o1 when dif_dit_d1 = '1' else modmul_o1;

  -- Division-by-2 path (generate only if DIV_BY_2 generic set)
  gen_divby2: if DIV_BY_2 = 1 generate
    divby2_e: divby2
      generic map (
        LOGQ      => LOGQ,
        Q_VALUE   => Q_VALUE,
        WORD_SIZE => WORD_SIZE,
        LATENCY   => 1
      )
      port map (
        clk => clk,
        i   => e_bf,
        qH  => qH,
        o   => e_div
      );

    divby2_o: divby2
      generic map (
        LOGQ      => LOGQ,
        Q_VALUE   => Q_VALUE,
        WORD_SIZE => WORD_SIZE,
        LATENCY   => 1
      )
      port map (
        clk => clk,
        i   => o_bf,
        qH  => qH,
        o   => o_div
      );

    -- register one-cycle delayed bf outputs for non-div case
    process(clk)
    begin
      if rising_edge(clk) then
        e_bf_1DP <= e_bf;
        o_bf_1DP <= o_bf;
      end if;
    end process;

    -- Output selection depends on dif_by_2_DP (registered)
    e <= e_div when dif_by_2_DP = '1' else e_bf_1DP;
    o <= o_div when dif_by_2_DP = '1' else o_bf_1DP;

  end generate;

  gen_no_divby2: if DIV_BY_2 /= 1 generate
  begin
    e <= e_bf;
    o <= o_bf;
  end generate;

  -- add / sub / mult out:
  add_out  <= addsub_o0;
  sub_out  <= addsub_o1;
  mult_out <= modmul_o1;

  -- Localparam-like constants (for reference; may be synthesized as constants if needed)
  -- Example references:
  -- ADD_SUB_LAT     := if BTF_TYPE = "gs" then MODADD_LAT else MODADD_LAT + INTMUL_LAT + MODRED_LAT
  -- MULT_LAT        := if BTF_TYPE = "unified" or "ct" then INTMUL_LAT + MODRED_LAT else MODADD_LAT + INTMUL_LAT + MODRED_LAT
  -- BTF_LAT         := MODADD_LAT + INTMUL_LAT + MODRED_LAT + (if DIV_BY_2=1 then 1 else 0)
  -- These calculations are left for the user or testbench if required.

end architecture rtl;
