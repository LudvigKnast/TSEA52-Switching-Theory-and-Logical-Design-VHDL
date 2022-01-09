library ieee ;
use ieee.std_logic_1164.all;

entity boolfunc is
  port (x , y , z : in std_logic;
      a , b , c , d : out std_logic);
end boolfunc;

architecture equations1 of boolfunc is
begin
  a <= not z;                                 -- Inverterare
  b <= not (x and y);                         -- NAND - grind
  c <= ((not x) and y) or ((not y) and x);    -- XOR - grind
  d <= x xor z;                               -- XOR - grind
end equations1;
