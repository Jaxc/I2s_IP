library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I2C_interface is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S_AXI
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 11
	);
	port (
		-- Signals from system
		clk 			: in 	std_logic;
		reset 			: in 	std_logic;

		direction		: in 	std_logic;
		send_new_frame	: in 	std_logic;

		slave_address 	: in 	std_logic_vector(7 downto 0);
		slave_register 	: in 	std_logic_vector(7 downto 0);
		slave_data_in	: in 	std_logic_vector(7 downto 0);
		slave_data_out	: out 	std_logic_vector(7 downto 0);

		done			: out 	std_logic;


		-- signals from IC
		SDA			: inout std_logic;	-- 2-Wire Control Interface Data Input/Output
		SCL			: out 	std_logic	-- 2-Wire Control Interface Clock Input. 

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S_AXI

	);
end I2C_interface;

architecture I2C_top of I2C_interface is

	type state_type is (	idle, start_I2C, send_slave_adress, receive_adress_ack,
						send_slave_register, receive_register_ack, send_slave_data,
						receive_data_ack, receive_slave_data, send_data_ack, end_I2C);

	type record_type is record
		state 		: state_type;
		data_out 	: std_logic_vector(8 downto 0);
		data_in 	: std_logic_vector(8 downto 0);
		SDA 		: std_logic;
		SCL 		: std_logic;

		end record;

	signal crnt,nxt : record_type;

	signal I2C_clk, I2C_2x_ena : std_logic;




	component CLK_DIV
	port (
		clk_in 		: in std_logic;
		reset 		: in std_logic;

		clk_out		: out std_logic;
		clk_2x_ena	: out std_logic
		

	);
end component;

begin


process(crnt)
nxt <= crnt;
begin
	case crnt.state is

	when idle => 
		if (send_new_frame = '1') then
			nxt.state <= start_I2C;
		end if;
		SCL <= '1';
		SDA <= '1';
		nxt.data_out <= "010000000";

	when start_I2C =>
		if (I2C_2x_ena = '1') then
			if crnt.data_out(8) = '1' then
				nxt.SDA <= '0';
			else 
				nxt.data_out <= crnt.data_out(7 downto 0) & '0';
				nxt.SDA <= '1';
			end if;
		


	when send_slave_adress => 

	when receive_adress_ack => 

	when send_slave_register => 

	when receive_register_ack =>

	when send_slave_data =>

	when receive_data_ack =>

	when receive_slave_data => 

	when send_data_ack =>

	when end_I2C =>

	end case;

end process;

process(clk,reset)
begin
	if reset = '0' then
		crnt.state <= idle;
	elsif rising_edge(clk) then
		crnt <= nxt;
	end if;
end process;



CLK_DIV_1 : CLK_DIV
	port map (
		clk_in 		=> clk,
		reset 		=> reset,

		clk_out		=> I2C_clk,
		clk_2x_ena	=> I2C_2x_ena
		

	);

end I2C_top;