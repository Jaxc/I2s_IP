----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/28/2015 06:40:14 AM
-- Design Name: 
-- Module Name: I2S_controller - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity I2S_controller is
	Port ( 
		   reset   : in STD_LOGIC;
           BCLK : in STD_LOGIC;
           PBDAT : out STD_LOGIC;
           PBLRC : in STD_LOGIC;
           MUTE : out STD_LOGIC;
           Sample_in_right : in STD_LOGIC_VECTOR (31 downto 0);
		   Sample_in_left : in STD_LOGIC_VECTOR (31 downto 0);
		   new_sample_r : out STD_LOGIC;
		   new_sample_l : out STD_LOGIC
		   );
end I2S_controller;

architecture Behavioral of I2S_controller is


type state_type is (idle, send_right,send_left);

type reg_type is record
	PBLRC : STD_LOGIC;
	sample : STD_LOGIC_VECTOR(31 downto 0);
	state : state_type;
end record;

signal crnt,nxt : reg_type;

begin

MUTE <= '1';

process(crnt,PBLRC,Sample_in_right,Sample_in_left,BCLK)

begin
	nxt <= crnt;
	nxt.PBLRC <=PBLRC;
	new_sample_r <= '0';
	new_sample_l <= '0';
	

	case crnt.state is

	when idle =>
		if (crnt.PBLRC = '0') AND (PBLRC = '1') then
			nxt.state <= send_right;
		end if;
		nxt.sample <= Sample_in_right;
		PBDAT <= '0';

	when send_right =>


		if (crnt.PBLRC = '1') AND (PBLRC = '0') then
			nxt.state <= send_left;
			nxt.sample <= Sample_in_left;
			new_sample_r <= '1';
			PBDAT <= crnt.sample(0);
		else 
			PBDAT <= crnt.sample(0);
			nxt.sample <= '0' & crnt.sample(31 downto 1);
		end if;
		


	when send_left =>



		if (crnt.PBLRC = '0') AND (PBLRC = '1') then
			nxt.state <= send_right;
			nxt.sample <= Sample_in_right;
			new_sample_l <= '1';
			PBDAT <= crnt.sample(0);
		else 
			PBDAT <= crnt.sample(0);
			nxt.sample <= '0' & crnt.sample(31 downto 1);
		end if;

	when others => 
		nxt.state <= idle;
		PBDAT <= '0';

	end case;


		

end process;




process(BCLK)
begin
	if falling_edge(BCLK) then
		if reset = '0' then
			crnt.state <= idle;
			crnt.PBLRC <= '0';
			crnt.sample <= (others => '0');
		else 
			crnt <= nxt;
		end if;
	end if;
end process;


end Behavioral;
