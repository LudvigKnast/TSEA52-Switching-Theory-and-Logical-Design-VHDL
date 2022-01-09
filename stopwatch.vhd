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
signal start_stopp_enpuls, old_start_stopp: std_logic;
signal nollstallning_enpuls, old_nollstallning : std_logic;
signal visningslage_sync, visningslage_plus : std_logic;
signal raknar_local : std_logic;
signal counter_100_high, counter_100_low: integer;
signal counter_sec_high, counter_sec_low, counter_min_high, counter_min_low : integer;
signal rco_100, rco_sec: std_logic;
signal display_local: unsigned(1 downto 0);
signal hundradelspuls_enpuls, old_hundradelspuls : std_logic;
signal muxfrekvens_enpuls, old_muxfrekvens : std_logic;
signal digit_adress : std_logic_vector(0 to 7);

-- Adress-rom
type ROM is array(0 to 9) of std_logic_vector(0 to 7);
constant ROM_content : ROM := (0 => "11111100",
                               1 => "01100000",
                               2 => "11011010",
                               3 => "11110010",
                               4 => "01100110",                              
                               5 => "10110110",                               
                               6 => "10111110",
                               7 => "11100000",                               
                               8 => "11111110",                               
                               9 => "11110110");                                                               

begin

------------------------------------------------
-- Vippor 
process(clk)
begin
  if rising_edge(clk) then
    visningslage_sync <= visningslage_plus;
    nollstallning_enpuls <= old_nollstallning;
  end if;
end process;

-- Tillståndsuppdatering
  visningslage_plus <= visningslage;
  old_nollstallning <= nollstallning;
  
------------------------------------------------
-- Kontroll
process(clk, reset)
begin
  if reset = '1' then           -- Asykron reset
    raknar_local <= '0';
  elsif rising_edge(clk) then    
    if (start_stopp_enpuls = '1') then
      raknar_local <= not raknar_local;
    end if;  
  end if;
end process;

------------------------------------------------
-- Start_stop_enpuls
process(clk)
begin
  if rising_edge(clk) then
    old_start_stopp <= start_stopp;
    if ((old_start_stopp = '0') and (start_stopp = '1')) then 
      start_stopp_enpuls <= '1';
    else
      start_stopp_enpuls <= '0';  
    end if;  
  end if;
end process;
   
------------------------------------------------
-- Hundradelspuls_enpuls
process(clk)
begin
  if rising_edge(clk) then
    old_hundradelspuls <= hundradelspuls;
    if ((old_hundradelspuls = '0') and (hundradelspuls = '1')) then 
      hundradelspuls_enpuls <= '1';
    else
      hundradelspuls_enpuls <= '0';  
    end if;  
  end if;
end process;

------------------------------------------------
-- Räknare

-- 100_Räknare
process(clk, reset, nollstallning_enpuls)
begin
  if ((reset = '1') or (nollstallning_enpuls = '1')) then       
    counter_100_high <= 0;
    counter_100_low <= 0;
  elsif ((rising_edge(clk)) and (hundradelspuls_enpuls = '1')) then
    if (raknar_local = '1') then
      if(counter_100_high = 9 and counter_100_low = 9) then
        counter_100_high <= 0;
        counter_100_low <= 0;
      elsif counter_100_low = 9 then  
        counter_100_high <= counter_100_high + 1;
        counter_100_low <= 0;
      else
        counter_100_low <= counter_100_low + 1;  
      end if;  
    end if;  
  end if;
end process;
rco_100 <= '1' when ((raknar_local = '1') and (counter_100_low = 9) and (counter_100_high = 9)) else '0'; 


-- Sec_Räknare
process(rco_100, reset, nollstallning_enpuls) -- *behövs enable?
begin
  if ((reset = '1') or (nollstallning_enpuls = '1')) then       
    counter_sec_high <= 0;
    counter_sec_low <= 0;
  elsif falling_edge(rco_100) then
    if(counter_sec_high = 5 and counter_sec_low = 9) then
      counter_sec_high <= 0;
      counter_sec_low <= 0;
    elsif counter_sec_low = 9 then  
      counter_sec_high <= counter_sec_high + 1;
      counter_sec_low <= 0;
    else
      counter_sec_low <= counter_sec_low + 1; 
    end if;  
  end if;
end process;
rco_sec <= '1' when ((raknar_local = '1') and (counter_sec_high = 5) and (counter_sec_low = 9)) else '0';  


-- Min_Räknare
process(rco_sec, reset, nollstallning_enpuls) -- *behövs enable?
begin
  if ((reset = '1') or (nollstallning_enpuls = '1')) then       
    counter_min_high <= 0;
    counter_min_low <= 0;
  elsif falling_edge(rco_sec) then
    if(counter_min_high = 5 and counter_min_low = 9) then
      counter_min_high <= 0;
      counter_min_low <= 0;
    elsif (counter_min_low = 9) then  
      counter_min_high <= counter_min_high + 1;
      counter_min_low <= 0;
    else
      counter_min_low <= counter_min_low + 1;
    end if;  
  end if;
end process;

------------------------------------------------
-- Muxfrekevens_enpuls
process(clk)
begin
  if rising_edge(clk) then
    old_muxfrekvens <= muxfrekvens;
    if ((old_muxfrekvens = '0') and (muxfrekvens = '1')) then 
      muxfrekvens_enpuls <= '1';
    else
      muxfrekvens_enpuls <= '0';  
    end if;  
  end if;
end process;
     
------------------------------------------------
-- Sifferäknare
process(clk, reset, muxfrekvens_enpuls) 
begin
  if (reset = '1') then
    display_local <= "00";
  elsif ((rising_edge(clk)) and (muxfrekvens_enpuls = '1')) then 
    if (display_local = 3) then
      display_local <= "00";
    else
      display_local <= display_local + 1;
    end if;
  end if;    
end process;

------------------------------------------------
-- Digit
process(clk)
begin
if rising_edge(clk) and muxfrekvens_enpuls = '1' then
  if visningslage_sync = '0' then    -- visningläge sek/100
    if display_local = "11" then
      digit_adress <= ROM_content(counter_100_low);
    elsif display_local = "0" then
      digit_adress <= ROM_content(counter_100_high);   -- blir alltid heltal
    elsif display_local = "01" then
     digit_adress <= ROM_content(counter_sec_low);
    else
      digit_adress <= ROM_content(counter_sec_high);  
    end if;
  else                               -- visningläge min/sek
    if display_local = "11" then
      digit_adress <= ROM_content(counter_sec_low);
    elsif display_local = "00" then
      digit_adress <= ROM_content(counter_sec_high);
    elsif display_local = "01" then
      digit_adress <= ROM_content(counter_min_low);
    else
      digit_adress <= ROM_content(counter_min_high);  
    end if;
   end if;
end if;
end process;

------------------------------------------------
-- Utsignaler
raknar <= raknar_local;
display <= display_local;
digit <= digit_adress;

------------------------------------------------
end architecture;

