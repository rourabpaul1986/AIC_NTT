library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity error_emulator is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;

        fifo_in  : in  std_logic_vector(31 downto 0);
        data_in  : in  std_logic_vector(11 downto 0);
        data_out : out std_logic_vector(11 downto 0)
    );
end entity error_emulator;

architecture rtl of error_emulator is

    signal data_reg : std_logic_vector(11 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                data_reg <= (others => '0');
            else
                -- Default behavior: pass-through
                data_reg <= data_in;

                -- Placeholder for error / fault emulation logic
                -- Example (commented):
                -- if fifo_in(0) = '1' then
                --     data_reg <= data_in xor "000000000001";
                -- end if;
            end if;
        end if;
    end process;

    data_out <= data_reg;

end architecture rtl;
