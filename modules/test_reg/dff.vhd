library ieee;
use ieee.std_logic_1164.all;

entity DFF is
port (
    i_clk : in  std_logic;
    i_d   : in  std_logic;
    o_q   : out std_logic
);
end entity DFF;
architecture DFF of DFF is
begin
  process(i_clk) is
  begin
    if (rising_edge(i_clk)) then
      o_q <= i_d;
    end if;
  end process;
end architecture;