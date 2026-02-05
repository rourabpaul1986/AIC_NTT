library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity error_emulator is
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        fifo_rd_en    : in  std_logic;
        no_fault  : in  std_logic_vector(2 downto 0);
        fifo_out  : in  std_logic_vector(31 downto 0);
        data_in  : in  std_logic_vector(15 downto 0); --original output form mul/adder/sub
        data_out : out std_logic_vector(15 downto 0) --fault injected dummy output
    );
end entity error_emulator;

architecture rtl of error_emulator is
    --signal data_reg : std_logic_vector(15 downto 0);
    signal data_reg : std_logic_vector(15 downto 0):=(others => '1');
begin


       gen_chunks : for i in 0 to 7 generate
        begin
            data_reg(to_integer(unsigned(fifo_out(i*4+3 downto i*4)))) <= '0';
        end generate;

        --data_reg <= temp;
 

    selective_and : for i in 0 to data_in'length-1 generate
    begin
    data_out(i) <= not data_in(i) when data_reg(i) = '0'
                   else data_in(i);
    end generate;


end architecture rtl;
