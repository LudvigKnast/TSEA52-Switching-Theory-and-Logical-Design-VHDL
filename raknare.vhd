library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stopwatch is
	port(clk, reset : in std_logic; -- clk is "fast enough". reset is active high.
	     hundradelspuls : in std_logic;
	     muxfrekvens   : in std_logic; -- tic for multiplexing the display.
	     start_stopp : in std_logic;
	     nollstallning : in std_logic; -- restart from 00:00:00
	     visningslage : in std_logic; -- 1:show min/sec. 0: show sec/centisec
	     display : out unsigned(1 downto 0); -- 0=rightmost
	     digit : out std_logic_vector(0 to 7); -- 0=top, 6=middle, 7=DP
	     raknar : out std_logic); -- Connected to a LED
end entity;

architecture rtl of stopwatch is
signal start_stopp_sync, start_stopp_plus : std_logic;
signal nollstallning_sync, nollstallning_plus : std_logic;
signal visningslage_sync, visningslage_plus : std_logic;
signal raknar_local : std_logic;
signal counter_100: unsigned(6 downto 0);
signal counter_sec, counter_min : unsigned(5 downto 0);
signal rco_100, rco_sec: std_logic;

begin

------------------------------------------------
-- Vippor 
process(clk)
begin
  if rising_edge (clk) then
    start_stopp_sync <= start_stopp_plus;
    nollstallning_sync <= nollstallning_plus;
    visningslage_sync <= visningslage_plus;
  end if;
end process;

-- Tillståndsuppdatering
  start_stopp_plus <= start_stopp;
  nollstallning_plus <= nollstallning;
  visningslage_plus <= visningslage;
  
------------------------------------------------
-- Kontroll
process(clk, reset)
begin
  if reset = '1' then           -- Asykron reset
    raknar_local <= '0';
  elsif rising_edge (clk) then
    raknar_local <= start_stopp_sync;
  end if;
end process;

------------------------------------------------
-- Räknare

-- 100_Räknare
process(hundradelspuls, nollstallning_sync, reset)
begin
  if reset = '1' or nollstallning_sync = '1' then       
    counter_100 <= 0;
  elsif rising_edge (hundradelspuls) then
    if (raknar_local = '1') then
      if(counter_100 = 99) then
        counter_100 <= 0;
      end if;
    else  
      counter_100 <= counter_100 + 1;
    end if;  
  end if;
end process;
rco_100 <= '1' when ((raknar_local = '1') and (counter_100 = 99)) else '0'; 


-- Sec_Räknare
process(rco_100, nollstallning_sync, reset) -- *behövs enable?
begin
  if reset = '1' or nollstallning_sync = '1' then       
    counter_sec <= 0;
  elsif rising_edge (rco_100) then
    if(counter_sec = 59) then
      counter_sec <= 0;
    else  
      counter_sec <= counter_sec + 1;
    end if;  
  end if;
end process;
rco_sec <= '1' when ((raknar_local = '1') and (counter_sec = 59)) else '0';  


-- Min_Räknare
process(rco_sec, nollstallning_sync, reset) -- *behövs enable?
begin
  if reset = '1' or nollstallning_sync = '1' then       
    counter_min <= 0;
  elsif rising_edge (rco_sec) then
    if(counter_min = 59) then
      counter_min <= 0;
    else  
      counter_sec <= counter_sec + 1;
    end if;  
  end if;
end process;

------------------------------------------------
-- Utsignaler
raknar <= raknar_local;

------------------------------------------------
end architecture;

