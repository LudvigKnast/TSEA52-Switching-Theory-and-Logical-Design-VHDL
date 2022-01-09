library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
	port(clk, reset : in std_logic; -- clk is 1 Hz. reset is active high.
	     startknapp : in std_logic; -- aktiv hÃ¶g
	     alarm : out std_logic;
	     tidkvar : out unsigned(3 downto 0));
end entity;

architecture behav of timer is
  signal q_int : unsigned(3 downto 0);  -- Typ för att räkna
  signal s, s_plus, u : std_logic;
begin
-- tillståndsuppdatering
process (clk, reset) begin
  if (reset = '1') then                              -- Asynkron reset
    q_int <= to_unsigned (0, 4);
  elsif rising_edge (clk) then
    s <= s_plus;
    if ((u = '1') and (q_int = 0)) then              -- Count enable
        q_int <= "1000";
    elsif (q_int /= 0) then
        q_int <= q_int - 1;                          -- Aritmetisk operation
    end if;
  end if;
end process;

u <= (not s) and startknapp;
s_plus <= startknapp;

-- utsignaler
alarm <= '1' when (q_int = 0)
  else '0';
tidkvar <= q_int;
end behav;

