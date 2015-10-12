library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CLK_DIV is
	port (
		clk_in 		: in std_logic;
		reset 		: in std_logic;

		clk_out		: out std_logic;
		clk_2x_ena	: out std_logic
		

	);
end CLK_DIV;



architecture DIVIDER of CLK_DIV is
	constant DIV_FACTOR : natural := 99;

	signal cnt : natural range 0 to DIV_FACTOR;
	signal new_clk : std_logic;
begin

	clk_out <= new_clk;

	process(reset, clk_in) is

	begin
		if (reset = '0') then
			cnt <= 0;
			new_clk <= '0';
			clk_2x_ena <= '0';
		elsif rising_edge(clk_in) then 
			if cnt = DIV_FACTOR then
				clk_2x_ena <= '1';
				new_clk <= not new_clk;
				cnt <= 0;
			else 
				clk_2x_ena <= '0';
				cnt <= cnt + 1;
				new_clk <= new_clk;
			end if;
		end if;
	end process;


end DIVIDER;