library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CountOnes is
  port(clk : in std_logic;
       reset : in std_logic;     -- active high
       startknapp : in std_logic;    -- active high
       cs1,cs2 : out std_logic; -- active low
       addr : out unsigned(3 downto 0); -- this is a number, and should be unsigned
       data : in std_logic_vector(3 downto 0); -- this is just a vector of bits
       LED : out std_logic;
       BCD2,BCD1,BCD0 : out unsigned(3 downto 0)); -- these are also numbers, BCD0 is least significant digit.
end entity;

architecture behav of CountOnes is

  signal counting : std_logic;
  signal startknapp_plus : std_logic;
  signal cs_counter : integer;
  signal round : integer;
  signal BCD2_ref, BCD1_ref, BCD0_ref : unsigned(3 downto 0);

  -- data-rom
  type ROM is array(0 to 15) of integer;
  constant ROM_content : ROM := (0 => 0,
                               1 => 1,
                               2 => 1,
                               3 => 2,
                               4 => 1,                              
                               5 => 2,                               
                               6 => 2,
                               7 => 3,                               
                               8 => 1,                               
                               9 => 2,
                               10 => 2,
                               11 => 3,
                               12 => 2,                              
                               13 => 3,                               
                               14 => 3,
                               15 => 4); 
begin

------------------------------------------------
-- Vippor 
process(clk, reset, round)
begin
  if reset = '1' or round = 2 then         -- Asykron reset
    counting <= '0';
  elsif rising_edge(clk) then
    if counting = '0' then
      counting <= startknapp_plus;
    end if;  
  end if;
end process;

-- Tillståndsuppdatering
  startknapp_plus <= startknapp;
    
-- LED
  LED <= counting;
   
------------------------------------------------
-- Cs-counter and adress-counter
process(clk, reset, round, counting)
begin
  if reset = '1' or round = 2 then           -- Asykron reset
    cs_counter <= 0;
    round <= 0;
  elsif rising_edge(clk) and counting = '1' then  
    if cs_counter = 15 then
      round <= round + 1;
      cs_counter <= 0;
    else  
      cs_counter <= cs_counter + 1;
    end if;
  end if;
end process;

cs1 <= '0' when cs_counter < 16 and round = 0 else '1';
cs2 <= '0' when cs_counter < 16 and round = 1 else '1';
addr <= to_unsigned(cs_counter, 4);

------------------------------------------------
-- Sum stämmer med testbänk, fixa sum => BCD sen är uppg klar
process(clk, reset)
begin
  if reset = '1' then         -- Asykron reset
    BCD2_ref <= "0000";
    BCD1_ref <= "0000";
    BCD0_ref <= "0000";
  elsif rising_edge(clk) then
    if cs_counter = 0 and counting = '1' and round = 0 then
      BCD0_ref <= to_unsigned(ROM_content(to_integer(unsigned(data))), 4);
      BCD2_ref <= "0000";
      BCD1_ref <= "0000";
    elsif counting = '1' then
      if BCD0_ref + to_unsigned(ROM_content(to_integer(unsigned(data))), 4) > 9 and BCD1_ref = 9 then
        BCD2_ref <= BCD2_ref + 1;
        BCD1_ref <= "0000";
        BCD0_ref <= BCD0_ref + to_unsigned(ROM_content(to_integer(unsigned(data))), 4) - 10;
      elsif  BCD0_ref + to_unsigned(ROM_content(to_integer(unsigned(data))), 4) > 9 then
        BCD1_ref <= BCD1_ref + 1;
        BCD0_ref <= BCD0_ref + to_unsigned(ROM_content(to_integer(unsigned(data))), 4) - 10;
      else
        BCD0_ref <= BCD0_ref + to_unsigned(ROM_content(to_integer(unsigned(data))), 4);
      end if;
    end if;  
  end if;
end process;

BCD2 <= BCD2_ref;
BCD1 <= BCD1_ref;
BCD0 <= BCD0_ref;

------------------------------------------------

end architecture;

