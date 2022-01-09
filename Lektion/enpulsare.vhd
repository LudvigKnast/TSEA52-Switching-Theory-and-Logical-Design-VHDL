library ieee;
use ieee.std_logic_1164.all;

entity enpulsare is
port (clk , reset : in std_logic;
       x : in std_logic;
       u : out std_logic);
end entity;

architecture behav of enpulsare is
  signal x_sync : std_logic;
  signal x_sync_old : std_logic;
begin
-- The two D- flip flops
process (clk , reset) begin
  if reset = '1' then
    x_sync <= '0';
    x_sync_old <= '0';
  elsif rising_edge (clk) then
    x_sync <= x;
    x_sync_old <= x_sync;
  end if;
end process;

u <= x_sync and not x_sync_old;

end architecture ;
