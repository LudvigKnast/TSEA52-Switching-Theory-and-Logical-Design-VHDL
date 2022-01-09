library ieee;
use ieee.std_logic_1164.all;

entity comb_lock is
	port(clk, reset : in std_logic; -- clk is "fast enough". reset is active high.
	     x1 : in std_logic; -- x1 is left
	     x0 : in std_logic; -- x0 is right
	     u : out std_logic);
end entity;

architecture behav of comb_lock is

  signal q1, q1_plus : std_logic;
  signal q0, q0_plus : std_logic;
  
begin

  -- Vippor
  process (clk ,reset) begin
    if reset = '1' then
      q1 <= '0'; -- Asynkron reset
      q0 <= '0'; -- av alla D- vippor
    elsif rising_edge (clk) then
      q1 <= q1_plus; -- Skapar en D- vippa
      q0 <= q0_plus; -- Skapar en D- vippa
    end if;
  end process ;

  -- Tillst å ndsuppdatering
  q1_plus <= not ((not (q1 and q0 and x1)) and  (not (q0 and (not x1) and x0)) and (not (q1 and x0)));
  q0_plus <= not ((not ((not x1) and (not x0))) and (not (q0 and q1)) and (not (q1 and x0 and x1)));

  -- Utsignaler
  u <= q1 and q0;


end architecture;

