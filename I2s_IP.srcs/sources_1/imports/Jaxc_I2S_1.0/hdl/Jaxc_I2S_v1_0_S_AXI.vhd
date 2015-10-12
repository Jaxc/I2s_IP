library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Jaxc_I2S_v1_0_S_AXI is
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
end Jaxc_I2S_v1_0_S_AXI;

architecture arch_imp of Jaxc_I2S_v1_0_S_AXI is

	-- AXI4LITE signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rdata	: std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 8;
	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------
	---- Number of Slave Registers 512

	--type array_type is array (0 to 255) of std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg_in, slv_reg_out : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

	signal write_ram : std_logic_vector(0 to 0);

	signal Sample_in_right, Sample_in_left : STD_LOGIC_VECTOR(31 downto 0);
	signal Sample_in_right_buf, Sample_in_left_buf : STD_LOGIC_VECTOR(31 downto 0);
	signal new_sample_r,new_sample_l : STD_LOGIC_VECTOR(2 downto 0);
	
	signal cnt_l, cnt_r	: natural range 0 to 511;

	signal slv_reg_rden	: std_logic;
	signal slv_reg_wren	: std_logic;
	signal reg_data_out	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index	: integer;

	signal read_channel : std_logic;

	signal loc_addr :std_logic_vector(OPT_MEM_ADDR_BITS-1 downto 0); 
	signal read_addr : std_logic_vector(OPT_MEM_ADDR_BITS-1 downto 0);
	
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

	COMPONENT blk_mem_gen_0
	  PORT (
	    clka : IN STD_LOGIC;
	    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
	    addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	    dina : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	    clkb : IN STD_LOGIC;
	    addrb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	    doutb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	  );
	END COMPONENT;

	component cross_domain_bus 
	generic (
		bus_width : natural;
		fast : natural;
		tra_edge : natural;
		rec_edge : natural
		);
	Port ( 
			async_rst : in std_logic;

			clk_a : in std_logic;
			data_in : in std_logic_vector(bus_width-1 downto 0);

			clk_b : in std_logic;
			data_out : out std_logic_vector(bus_width-1 downto 0)

		   );
	end component;

component cross_domain_bit
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
end component;


begin
	-- I/O Connections assignments

	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP	<= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
	S_AXI_RDATA	<= axi_rdata;
	S_AXI_RRESP	<= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;
	-- Implement axi_awready generation
	-- axi_awready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_awready is
	-- de-asserted when reset is low.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awready <= '0';
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
	        -- slave is ready to accept write address when
	        -- there is a valid write address and write data
	        -- on the write address and data bus. This design 
	        -- expects no outstanding transactions. 
	        axi_awready <= '1';
	      else
	        axi_awready <= '0';
	      end if;
	    end if;
	  end if;
	end process;

	-- Implement axi_awaddr latching
	-- This process is used to latch the address when both 
	-- S_AXI_AWVALID and S_AXI_WVALID are valid. 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_awaddr <= (others => '0');
	    else
	      if (axi_awready = '0' and S_AXI_AWVALID = '1' and S_AXI_WVALID = '1') then
	        -- Write Address latching
	        axi_awaddr <= S_AXI_AWADDR;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_wready generation
	-- axi_wready is asserted for one S_AXI_ACLK clock cycle when both
	-- S_AXI_AWVALID and S_AXI_WVALID are asserted. axi_wready is 
	-- de-asserted when reset is low. 

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_wready <= '0';
	    else
	      if (axi_wready = '0' and S_AXI_WVALID = '1' and S_AXI_AWVALID = '1') then
	          -- slave is ready to accept write data when 
	          -- there is a valid write address and write data
	          -- on the write address and data bus. This design 
	          -- expects no outstanding transactions.           
	          axi_wready <= '1';
	      else
	        axi_wready <= '0';
	      end if;
	    end if;
	  end if;
	end process; 

	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	slv_reg_wren <= axi_wready and S_AXI_WVALID and axi_awready and S_AXI_AWVALID ;

	process (S_AXI_ACLK)
	
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      slv_reg_in <= (others => '0');
	      write_ram <= "0";
	      loc_addr <= (others => '1');
	    else
	      --loc_addr <= axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS-1 downto ADDR_LSB);
	      if (slv_reg_wren = '1') then
	      		slv_reg_in <= S_AXI_WDATA;
	      	write_ram <= "0";
	      else 
	      	write_ram <= "0";	        
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement write response logic generation
	-- The write response and response valid signals are asserted by the slave 
	-- when axi_wready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted.  
	-- This marks the acceptance of address and indicates the status of 
	-- write transaction.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_bvalid  <= '0';
	      axi_bresp   <= "00"; --need to work more on the responses
	    else
	      if (axi_awready = '1' and S_AXI_AWVALID = '1' and axi_wready = '1' and S_AXI_WVALID = '1' and axi_bvalid = '0'  ) then
	        axi_bvalid <= '1';
	        axi_bresp  <= "00"; 
	      elsif (S_AXI_BREADY = '1' and axi_bvalid = '1') then   --check if bready is asserted while bvalid is high)
	        axi_bvalid <= '0';                                 -- (there is a possibility that bready is always asserted high)
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arready generation
	-- axi_arready is asserted for one S_AXI_ACLK clock cycle when
	-- S_AXI_ARVALID is asserted. axi_awready is 
	-- de-asserted when reset (active low) is asserted. 
	-- The read address is also latched when S_AXI_ARVALID is 
	-- asserted. axi_araddr is reset to zero on reset assertion.

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      axi_arready <= '0';
	      axi_araddr  <= (others => '1');
	    else
	      if (axi_arready = '0' and S_AXI_ARVALID = '1') then
	        -- indicates that the slave has acceped the valid read address
	        axi_arready <= '1';
	        -- Read Address latching 
	        axi_araddr  <= S_AXI_ARADDR;           
	      else
	        axi_arready <= '0';
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement axi_arvalid generation
	-- axi_rvalid is asserted for one S_AXI_ACLK clock cycle when both 
	-- S_AXI_ARVALID and axi_arready are asserted. The slave registers 
	-- data are available on the axi_rdata bus at this instance. The 
	-- assertion of axi_rvalid marks the validity of read data on the 
	-- bus and axi_rresp indicates the status of read transaction.axi_rvalid 
	-- is deasserted on reset (active low). axi_rresp and axi_rdata are 
	-- cleared to zero on reset (active low).  
	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then
	    if S_AXI_ARESETN = '0' then
	      axi_rvalid <= '0';
	      axi_rresp  <= "00";
	    else
	      if (axi_arready = '1' and S_AXI_ARVALID = '1' and axi_rvalid = '0') then
	        -- Valid read data is available at the read data bus
	        axi_rvalid <= '1';
	        axi_rresp  <= "00"; -- 'OKAY' response
	      elsif (axi_rvalid = '1' and S_AXI_RREADY = '1') then
	        -- Read data is accepted by the master
	        axi_rvalid <= '0';
	      end if;            
	    end if;
	  end if;
	end process;

	-- Implement memory mapped register select and read logic generation
	-- Slave register read enable is asserted when valid address is available
	-- and the slave is ready to accept the read address.
	slv_reg_rden <= axi_arready and S_AXI_ARVALID and (not axi_rvalid) ;

	process (axi_araddr, S_AXI_ARESETN, slv_reg_rden)
	begin
	    -- Address decoding for reading registers
--	    loc_addr := axi_araddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);

--	    reg_data_out <= slv_reg(to_integer(unsigned(loc_addr)));
	end process; 

	-- Output register or memory read data
	process( S_AXI_ACLK ) is
	begin
	  if (rising_edge (S_AXI_ACLK)) then
	    if ( S_AXI_ARESETN = '0' ) then
	      axi_rdata  <= (others => '0');
	    else
	      if (slv_reg_rden = '1') then
	        -- When there is a valid read address (S_AXI_ARVALID) with 
	        -- acceptance of read address by the slave (axi_arready), 
	        -- output the read dada 
	        -- Read address mux
	          axi_rdata <= reg_data_out;     -- register read data
	      end if;   
	    end if;
	  end if;
	end process;


	process(S_AXI_ACLK)
	begin
		if rising_edge(S_AXI_ACLK) then
			if S_AXI_ARESETN = '0' then
				new_sample_r(0) <= '0';
				new_sample_l(0) <= '0';
				cnt_r <= 0;
				cnt_l <= 0;
				Sample_in_right_buf <= (others => '0');
				Sample_in_left_buf <= (Others => '0');
				read_channel <= '0';
			else
				new_sample_r(0) <= new_sample_r(1);
				new_sample_l(0) <= new_sample_l(1);


				if (new_sample_r(0) = '0') AND (new_sample_r(1) = '1') then
					if cnt_r >=255 then
						cnt_r <= 0;
						null; -- activate interupt to request new values;
					else 
						cnt_r <= cnt_r + 1;
					end if;
					read_channel <= '1';
				end if;

				if (new_sample_l(0) = '0' ) AND (new_sample_l(1) = '1') then
					if cnt_l >=255 then
						cnt_l <= 0;
						null; -- activate interupt to request new values;
					else 
						cnt_l <= cnt_l + 1;
					end if;
					read_channel <= '0';
				end if;

				if (read_channel = '1') then
					read_addr <= STD_LOGIC_VECTOR(to_unsigned(cnt_r*2,OPT_MEM_ADDR_BITS));
					Sample_in_right_buf <= slv_reg_out;
				else
					read_addr <= STD_LOGIC_VECTOR(to_unsigned(cnt_l*2+1,OPT_MEM_ADDR_BITS));
					Sample_in_left_buf <= slv_reg_out;
				end if;
			end if;
		end if;
	end process;

	--process(BCLK)
	--begin
	--	if falling_edge(BCLK) then
	--		Sample_in_right <= Sample_in_right_buf;
	--		Sample_in_left <= Sample_in_left_buf;

	--	end if;
	--end process;

left_sample :  cross_domain_bus
	generic map(
		bus_width => 32,
		fast => 0,
		tra_edge => 1,
		rec_edge => 0
		)
	Port map ( 
			async_rst => S_AXI_ARESETN,

			clk_a => S_AXI_ACLK,
			data_in => Sample_in_left_buf,

			clk_b => BCLK,
			data_out => Sample_in_left
		   );

right_sample :  cross_domain_bus
	generic map(
		bus_width => 32,
		fast => 0,
		tra_edge => 1,
		rec_edge => 0
		)
	Port map ( 
			async_rst => S_AXI_ARESETN,

			clk_a => S_AXI_ACLK,
			data_in => Sample_in_right_buf,

			clk_b => BCLK,
			data_out => Sample_in_right
		   );

new_right_sample : cross_domain_bit
	generic map(
		fast => 1,
		tra_edge => 0,
		rec_edge => 1
		)
	Port map( 
			async_rst => S_AXI_ARESETN,

			clk_a => BCLK,
			data_in => new_sample_r(2),

			clk_b => S_AXI_ACLK,
			data_out => new_sample_r(1)

		   );


new_left_sample : cross_domain_bit
	generic map(
		fast => 1,
		tra_edge => 0,
		rec_edge => 1
		)
	Port map( 
			async_rst => S_AXI_ARESETN,

			clk_a => BCLK,
			data_in => new_sample_l(2),

			clk_b => S_AXI_ACLK,
			data_out => new_sample_l(1)

		   );
	-- Add user logic here

RAM : blk_mem_gen_0
  PORT MAP (
    clka => S_AXI_ACLK,
    wea => write_ram,
    addra => loc_addr,
    dina => slv_reg_in,
    clkb => S_AXI_ACLK,
    addrb => read_addr,
    doutb => slv_reg_out
  );

I2S : I2S_controller 
	Port map ( 
		   reset	=> S_AXI_ARESETN,
           BCLK		=> BCLK,
           PBDAT	=> PBDAT,
           PBLRC	=> PBLRC,
           MUTE		=> MUTE,
           Sample_in_right 	=> Sample_in_right,
		   Sample_in_left	=> Sample_in_left,
		   new_sample_r => new_sample_r(2),
		   new_sample_l => new_sample_l(2));

end arch_imp;
