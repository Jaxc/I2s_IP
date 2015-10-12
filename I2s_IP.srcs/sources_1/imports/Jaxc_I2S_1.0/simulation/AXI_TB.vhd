library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AXI_I2S_TB is

end AXI_I2S_TB;



architecture Testbench of AXI_I2S_TB is
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

component Jaxc_I2S_v1_0_S_AXI
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 11
	);
	port (
		-- Users to add ports here

		PBDAT 		: out 	std_logic;	-- Audio data out
		BCLK		: in 	std_logic;	-- Bit clock
		PBLRC		: in 	std_logic;	-- Playback sample clock (44100 Hz)

		MUTE 		: out 	std_logic;	-- Mute audio output



		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK	: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	: in std_logic;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	: out std_logic;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID	: out std_logic;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	: out std_logic;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	: in std_logic
	);
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

I2S : Jaxc_I2S_v1_0_S_AXI

	port map (
		-- Users to add ports here

		PBDAT 		=> PBDAT,
		BCLK		=> BCLK,
		PBLRC		=> PBLRC,

		MUTE 		=> MUTE,



		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK	=> sys_clk,
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	=> reset,
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	=> (others => '0'),
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	=> (others => '0'),
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	=> '0',
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	=> open,
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	=> (others => '0'),
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	=> (others => '0'),
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	=>  '0',
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	=> open,
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	=> open,
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID 	=> open,
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	=> '0',
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	=> (others => '0'),
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	=> (others => '0'),
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	=> '0',
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	=> open,
		-- Read data (issued by slave)
		S_AXI_RDATA	=> open,
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	=> open,
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	=> open,
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	=>  '0');

end Testbench;
