library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CLK_DIV_TB is

end CLK_DIV_TB;



architecture Testbench of CLK_DIV_TB is
	signal clk,reset,new_clk, clk_2x_ena : std_logic := '0';

	component CLK_DIV
	port (
		clk_in 		: in std_logic;
		reset 		: in std_logic;

		clk_out		: out std_logic;
		clk_2x_ena	: out std_logic
		

	);
end component;

begin

clk <= not clk after 5 ns;
reset <= '1' after 100 ns;

process
begin
	if (reset = '0') then
		wait for 1 ns;
	else 
		assert (new_clk = '0') report "clock error" severity error;
		assert (clk_2x_ena = '1') report "enable error" severity error;
		wait for 1 us;
		assert (new_clk = '1') report "clock error" severity error;
		assert (clk_2x_ena = '1') report "enable error" severity error;
		wait for 1 us;
	end if;
end process;

CLK_DIV_1 : CLK_DIV
	port map (
		clk_in 		=> clk,
		reset 		=> reset,

		clk_out		=> new_clk,
		clk_2x_ena	=> clk_2x_ena
		

	);

end Testbench;
