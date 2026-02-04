library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- divbytwo: divide-by-2 in (mod q)
-- Generics:
--   LOGQ      : integer >= 2
--   Q_VALUE   : std_logic_vector(LOGQ-1 downto 0) -- if all zeros, use qH + WORD_SIZE scheme
--   WORD_SIZE : integer >= 0
--   DIVBY2_LAT: integer (0 = combinational, 1 = registered)
entity divbytwo is
  generic (
    LOGQ       : integer := 8;
    Q_VALUE    : std_logic_vector(LOGQ-1 downto 0) := (others => '0');
    WORD_SIZE  : integer := 1;
    DIVBY2_LAT : integer := 0
  );
  port (
    clk : in  std_logic;
    x   : in  std_logic_vector(LOGQ-1 downto 0);
    qH  : in  std_logic_vector(LOGQ-WORD_SIZE-1 downto 0);
    y   : out std_logic_vector(LOGQ-1 downto 0)
  );
end entity divbytwo;

architecture rtl of divbytwo is
  -- x0and has width LOGQ-1 (equivalent to Verilog [LOGQ-2:0])
  signal x0and_u : unsigned(LOGQ-2 downto 0) := (others => '0');
  signal sum_u   : unsigned(LOGQ-1 downto 0);
begin

  -- Build x0and depending on Q_VALUE and WORD_SIZE and LSB of x
  gen_qvalue_zero: if Q_VALUE = (others => '0') generate
    -- When Q_VALUE == 0, we use qH and WORD_SIZE to form the adjustor.
    -- If WORD_SIZE <= 2 there are no middle zeros; else insert (WORD_SIZE-2) zeros.
    gen_ws_le_2: if WORD_SIZE <= 2 generate
      proc_x0and: process(x, qH)
      begin
        if x(0) = '1' then
          -- concats: qH & '1'  (total bits: LOGQ - WORD_SIZE + 1 = LOGQ-1)
          x0and_u <= unsigned(qH & '1');
        else
          x0and_u <= (others => '0');
        end if;
      end process proc_x0and;
    end generate gen_ws_le_2;

    gen_ws_gt_2: if WORD_SIZE > 2 generate
      -- create middle zeros of length (WORD_SIZE-2)
      constant middle_zeros : std_logic_vector(WORD_SIZE-3 downto 0) := (others => '0'); -- length = WORD_SIZE-2
      proc_x0and_ws: process(x, qH)
      begin
        if x(0) = '1' then
          -- qH & middle_zeros & '1' -> total LOGQ-1 bits
          x0and_u <= unsigned(qH & middle_zeros & '1');
        else
          x0and_u <= (others => '0');
        end if;
      end process proc_x0and_ws;
    end generate gen_ws_gt_2;

  end generate gen_qvalue_zero;

  gen_qvalue_nonzero: if Q_VALUE /= (others => '0') generate
    -- When Q_VALUE != 0, construct x0and from Q_VALUE[LOGQ-1:2] & 1
    proc_x0and_qval: process(x)
    begin
      if x(0) = '1' then
        x0and_u <= unsigned(Q_VALUE(LOGQ-1 downto 2) & '1');
      else
        x0and_u <= (others => '0');
      end if;
    end process proc_x0and_qval;
  end generate gen_qvalue_nonzero;

  -- Compute sum_u = resize(x[LOGQ-1:1], LOGQ) + resize(x0and, LOGQ)
  sum_u <= resize(unsigned(x(LOGQ-1 downto 1)), LOGQ) + resize(x0and_u, LOGQ);

  -- Output either combinational or registered depending on DIVBY2_LAT
  gen_latency_comb: if DIVBY2_LAT = 0 generate
    -- combinational
    y <= std_logic_vector(sum_u);
  end generate gen_latency_comb;

  gen_latency_reg: if DIVBY2_LAT /= 0 generate
    process(clk)
    begin
      if rising_edge(clk) then
        y <= std_logic_vector(sum_u);
      end if;
    end process;
  end generate gen_latency_reg;

end architecture rtl;
