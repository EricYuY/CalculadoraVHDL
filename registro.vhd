library ieee;
use ieee.std_logic_1164.all;

entity registro is
	generic (width	: natural := 4);
		port(	reset_n		: in  std_logic;
				clk			: in  std_logic;
				en_div		: in 	std_logic;	
				en				: in  std_logic;
				entrada		: in  std_logic_vector(width-1 downto 0);
				sal			: out std_logic_vector(width-1 downto 0));
end registro;
	
architecture archi of registro is
signal q_next,q_reg : std_logic_vector(width-1 downto 0);

begin
	process(reset_n,clk)
		begin
			if(reset_n ='0') then q_reg<=(others => '0');
			elsif rising_edge(clk) then 
				if en_div = '1' then
					if en ='1' then
						q_reg<= q_next;	
						end if;
				end if;		
			end if;
	end process;
	q_next<= entrada;
	
	sal<=	q_reg;

end archi;