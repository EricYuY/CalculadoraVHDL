library ieee;
use ieee.std_logic_1164.all;
entity reg_des is
 port (signal reset_n 		:  in  std_logic;
        signal clk     		:  in  std_logic;
        signal data    		:  in  std_logic_vector(3 downto 0);
		  signal z 				: 	in	 std_logic;
        signal d4       	: 	out std_logic_vector(3 downto 0);
		  signal d3       	: 	out std_logic_vector(3 downto 0);
		  signal d2       	: 	out std_logic_vector(3 downto 0);
		  signal d1       	: 	out std_logic_vector(3 downto 0);
		  signal d0       	: 	out std_logic_vector(3 downto 0));
end reg_des;

architecture arch of reg_des is 
component registro is
	generic (width	: natural := 4);
		port(	reset_n		: in  std_logic;
				clk			: in  std_logic;
				en_div		: in 	std_logic;	
				en				: in  std_logic;
				entrada		: in  std_logic_vector(width-1 downto 0);
				sal			: out std_logic_vector(width-1 downto 0));
	end component;
component divisor500mil is
	port( reset_n, clk					: in std_logic;
			salida							: out std_logic);
	end component;
	

	
signal e4,e3,e2,e1,e0 : std_logic_vector(3 downto 0);
signal en, en_reg, en_df				 : std_logic;

begin

u: divisor500mil port map(reset_n, clk, en_df);


en_reg <= '1' when e0 = "0000" else '0';--- si se quiere poner un divisor de frencuencia usar en and en_df
en <= en_reg and en_df;

stage4: registro
				generic map(width => 4)
				port map(reset_n,clk,en,z,data,e4);
stage3: registro
				generic map(width => 4)
				port map(reset_n,clk,en,z,e4,e3);
stage2: registro
				generic map(width => 4)
				port map(reset_n,clk,en,z,e3,e2);
stage1: registro
				generic map(width => 4)
				port map(reset_n,clk,en,z,e2,e1);
stage0: registro
				generic map(width => 4)
				port map(reset_n,clk,en,z,e1,e0);

d0 <= e4;
d1 <= e3;
d2 <= e2;
d3 <= e1;
d4 <= e0;


end arch;