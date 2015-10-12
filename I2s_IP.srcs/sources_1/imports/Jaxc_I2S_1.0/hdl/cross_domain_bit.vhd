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

entity cross_domain_bit is
	generic (
		fast : natural;
		tra_edge : natural;
		rec_edge : natural
		);
	Port ( 
			async_rst : in std_logic;

			clk_a : in std_logic;
			data_in : in std_logic;

			clk_b : in std_logic;
			data_out : out std_logic

		   );
end cross_domain_bit;

architecture Behavioral of cross_domain_bit is

	signal clk_a_buffer : std_logic;

	signal clk_b_i_buffer : std_logic;
	signal clk_b_o_buffer : std_logic;

begin

process(async_rst,clk_a)
begin
	if tra_edge = 0 then 
		if fast = 0 then
			if async_rst = '0' then
				clk_a_buffer <=  '0';
			elsif falling_edge(clk_a) then
				clk_a_buffer <= data_in;
			end if;
		end if;
	else 
		if fast = 0 then
			if async_rst = '0' then
				clk_a_buffer <=  '0';
			elsif rising_edge(clk_a) then
				clk_a_buffer <= data_in;
			end if;
		end if;		
	end if;
end process;

process(async_rst,clk_b)
begin
	if rec_edge = 0 then
		if async_rst ='0' then
			clk_b_i_buffer <= '0';
			clk_b_o_buffer <= '0';
		elsif falling_edge(clk_b) then
			if fast = 0 then
				clk_b_i_buffer <= clk_a_buffer;
			else
				clk_b_i_buffer <= data_in;
			end if;

			clk_b_o_buffer <= clk_b_i_buffer;

		end if;	
	else 
		if async_rst ='0' then
			clk_b_i_buffer <= '0';
			clk_b_o_buffer <= '0';
		elsif rising_edge(clk_b) then
			if fast = 0 then
				clk_b_i_buffer <= clk_a_buffer;
			else
				clk_b_i_buffer <= data_in;
			end if;

			clk_b_o_buffer <= clk_b_i_buffer;

		end if;	
	end if;	
end process;

data_out <= clk_b_o_buffer;

end Behavioral;
