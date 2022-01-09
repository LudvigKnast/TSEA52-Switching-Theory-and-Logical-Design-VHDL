library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity enpulsare_tb is
end entity;

architecture sim of enpulsare_tb is
	component enpulsare is
		port(clk, reset : in std_logic; -- reset is active high.
		     x : in std_logic; -- x
		     u : out std_logic);
	end component;
	-- DUT I/O:
	signal clk,reset : std_logic := '0';
	signal x : std_logic;
	signal u : std_logic;
	
	-- test bench signals:
	signal done : boolean := false;
begin
	clk <= not clk after 100 ns when not done; -- 5 MHz
	
	-- clk:      /    \    /    \    /    \    /    \    /    \
	-- x:  __________------------------------___________________
	-- x_sync: _____________--------------------________________
	-- u:  __________________----------_________________________
	
	process begin
		reset <= '1', '0' after 500 ns;
		x <= '0';
		wait for 1 us;
		wait until rising_edge(clk);
		
		assert u = '0' report "1. u should be 0 after reset                         :-(" severity error;
		-- Test a pulse:
		x <= '1' after 70 ns, '0' after 550 ns;
		wait for 140 ns; -- now the x pulse have resently started, but have not passed any clock flank
		assert u = '0' report "2. u should still be 0                               :-(" severity error;
		wait until rising_edge(clk);
		wait for 10 ns;
		assert u = '1' report "3. u should now be 1                                 :-(" severity error;
		wait until rising_edge(clk);
		wait for 10 ns;
		assert u = '0' report "4. u should still be 0                               :-(" severity error;
		
		-- verify that it is still zero for a number of clock cycles:
		wait until rising_edge(clk); assert u = '0' report "10. u should be zero.                                :-(" severity error;
		wait until rising_edge(clk); assert u = '0' report "11. u should be zero.                                :-(" severity error;
		wait until rising_edge(clk); assert u = '0' report "12. u should be zero.                                :-(" severity error;
		wait until rising_edge(clk); assert u = '0' report "13. u should be zero.                                :-(" severity error;
		wait until rising_edge(clk); assert u = '0' report "14. u should be zero.                                :-(" severity error;
		wait until rising_edge(clk); assert u = '0' report "15. u should be zero.                                :-(" severity error;
		
		report "### TEST BENCH DONE. Did you get any error message?" severity note;
		done <= true;
		wait;
	end process;
	
	-- Design under test:
	DUT : enpulsare port map (
	  clk => clk,
	  reset => reset,
	  x => x,
	  u => u);
	  
end architecture;

