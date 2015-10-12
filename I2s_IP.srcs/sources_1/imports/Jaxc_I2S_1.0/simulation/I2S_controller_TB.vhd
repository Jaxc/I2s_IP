library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2S_controller_TB is

end I2S_controller_TB;



architecture Testbench of I2S_controller_TB is
	signal sys_clk,reset,MCLK, BCLK, PBDAT, PBLRC,MUTE, new_sample_r, new_sample_l : std_logic := '0';
	type array_type is array (0 to 10) of STD_LOGIC_VECTOR(31 downto 0);
	signal Sample_in_right,Sample_in_left : array_type
		:= (1 => (others => '1'),
			3 => (others => '1'),
			5 => (others => '1'),
			7 => (others => '1'),
			9 => (others => '1'),
			others => (others => '0'));

	signal counter, cnt: natural;

component I2S_controller 
	Port ( 
		   reset   : in STD_LOGIC;
           BCLK : in STD_LOGIC;
           PBDAT : out STD_LOGIC;
           PBLRC : in STD_LOGIC;
           MUTE : out STD_LOGIC;
           Sample_in_right : in STD_LOGIC_VECTOR(31 downto 0);
		   Sample_in_left : in STD_LOGIC_VECTOR(31 downto 0);
		   new_sample_r : out STD_LOGIC;
		   new_sample_l : out STD_LOGIC);
end component;

begin

sys_clk <= not sys_clk after 5 ns;
reset <= '1' after 100 ns;

MCLK <= not MCLK after 40690.104166667 ps;

process(MCLK)
begin
	if rising_edge(MCLK) then
		if counter = 1 then
			BCLK <= not BCLK;
			counter <= 0;
		else
			counter <= counter +1;
		end if;

		if cnt = 127 then
			PBLRC <= not PBLRC;
			cnt <= 0;
		else 
			cnt <= cnt +1;
		end if;
	end if;
end process;

process(new_sample_r)
begin
	if rising_edge(new_sample_r) then
		Sample_in_right(0 to 9) <= Sample_in_right(1 to 10);
		Sample_in_right(10) <= (others => '0');
	end if;
end process;

process(new_sample_l)
begin
	if rising_edge(new_sample_l) then
		Sample_in_left(0 to 9) <= Sample_in_left(1 to 10);
		Sample_in_left(10) <= (others => '0');
	end if;
end process;

AXI_I2S : I2S_controller 
	Port map ( 
		   reset	=> reset,
           BCLK		=> BCLK,
           PBDAT	=> PBDAT,
           PBLRC	=> PBLRC,
           MUTE		=> MUTE,
           Sample_in_right 	=> Sample_in_right(0),
		   Sample_in_left	=> Sample_in_left(0),
		   new_sample_r => new_sample_r,
		   new_sample_l => new_sample_l);

end Testbench;
