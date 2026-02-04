library IEEE;
use IEEE.std_logic_1164.all;

entity BitReverse is
  generic (
    BITWIDTH : positive := 8  -- Set desired bit width (must be > 0)
  );
  port (
    data_in  : in  std_logic_vector(BITWIDTH-1 downto 0);
    data_out : out std_logic_vector(BITWIDTH-1 downto 0)
  );
end entity BitReverse;

architecture rtl of BitReverse is
begin
  gen_bitrev: for i in 0 to BITWIDTH-1 generate
  begin
    -- Reverse bit order: data_out(i) := data_in(BITWIDTH-1 - i)
    data_out(i) <= data_in(BITWIDTH-1 - i);
  end generate gen_bitrev;
end architecture rtl;
