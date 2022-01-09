library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comb_lock is
	port(clk, reset : in std_logic; -- clk is "fast enough". reset is active high.
	     x1 : in std_logic; -- x1 is left
	     x0 : in std_logic; -- x0 is right
	     u  : out std_logic);
end comb_lock;

architecture arch of comb_lock is

-- Definition av ROM - minnet :

  signal q1, q1_plus : std_logic;
  signal q0, q0_plus : std_logic;

  type ROM_mem is array (0 to 15) of std_logic_vector (2 downto 0);
  constant ROM_content : ROM_mem := (0 => "010",
                                     1 to 3 => "000",
                                     4 => "010",
                                     5 => "100",
                                     6 to 7  => "000",
                                     8 => "010",
                                     9 => "100",
                                     10 => "000",
                                     11 => "110",
                                     12 => "011",
                                     13 to 14 => "111",
                                     15 => "111");
  
  -- Övriga signaler
  signal address : std_logic_vector (3 downto 0);
  signal data : std_logic_vector (2 downto 0);
  
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

  -- Tilldela bitarna in till address - vektorn
  address(3) <= q1;
  address(2) <= q0;
  address(1) <= x1;
  address(0) <= x0;

  -- Läs ut data
  data <= ROM_content(to_integer(unsigned(address)));

  -- Utbitar
  q1_plus <= data(2);
  q0_plus <= data(1);
  u <= data(0);

end architecture;

