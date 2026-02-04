-- btf_addsub.vhd
-- Parametric add/sub unit for butterfly
-- e = (a + b)
-- o = (a - b)
-- Mirrors the Verilog module:
-- module btf_addsub #( ... ) ( input clk, input qH, input a,b, output e,o );

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity btf_addsub is
  generic (
    LOGQ       : integer := 0;   -- bit-width of a, b, e, o, and Q_VALUE (when represented as vector)
    Q_VALUE    : integer := 0;   -- numeric representation of Q (0 => non-constant q)
    WORD_SIZE  : integer := 0;   -- last WORD_SIZE digits of q will be 00...001
    MODADD_LAT : integer := 0    -- latency for modular ADD/SUB, options: 0,1,2
  );
  port (
    clk : in  std_logic;
    -- qH width = LOGQ - WORD_SIZE (must be >= 0)
    qH  : in  std_logic_vector((LOGQ - WORD_SIZE) - 1 downto 0);
    a   : in  std_logic_vector(LOGQ - 1 downto 0);
    b   : in  std_logic_vector(LOGQ - 1 downto 0);
    e   : out std_logic_vector(LOGQ - 1 downto 0);
    o   : out std_logic_vector(LOGQ - 1 downto 0)
  );
end entity btf_addsub;

architecture rtl of btf_addsub is

  -- Component declaration for modadd
  component modadd
    generic (
      LOGQ       : integer := 0;
      Q_VALUE    : integer := 0;
      WORD_SIZE  : integer := 0;
      MODADD_LAT : integer := 0
    );
    port (
      clk : in  std_logic;
      qH  : in  std_logic_vector((LOGQ - WORD_SIZE) - 1 downto 0);
      a   : in  std_logic_vector(LOGQ - 1 downto 0);
      b   : in  std_logic_vector(LOGQ - 1 downto 0);
      e   : out std_logic_vector(LOGQ - 1 downto 0)
    );
  end component;

  -- Component declaration for modsub
  component modsub
    generic (
      LOGQ       : integer := 0;
      Q_VALUE    : integer := 0;
      WORD_SIZE  : integer := 0;
      MODADD_LAT : integer := 0
    );
    port (
      clk : in  std_logic;
      qH  : in  std_logic_vector((LOGQ - WORD_SIZE) - 1 downto 0);
      a   : in  std_logic_vector(LOGQ - 1 downto 0);
      b   : in  std_logic_vector(LOGQ - 1 downto 0);
      o   : out std_logic_vector(LOGQ - 1 downto 0)
    );
  end component;

begin

  -- Instantiate modadd
  u_modadd : modadd
    generic map (
      LOGQ       => LOGQ,
      Q_VALUE    => Q_VALUE,
      WORD_SIZE  => WORD_SIZE,
      MODADD_LAT => MODADD_LAT
    )
    port map (
      clk => clk,
      qH  => qH,
      a   => a,
      b   => b,
      e   => e
    );

  -- Instantiate modsub
  u_modsub : modsub
    generic map (
      LOGQ       => LOGQ,
      Q_VALUE    => Q_VALUE,
      WORD_SIZE  => WORD_SIZE,
      MODADD_LAT => MODADD_LAT
    )
    port map (
      clk => clk,
      qH  => qH,
      a   => a,
      b   => b,
      o   => o
    );

end architecture rtl;
