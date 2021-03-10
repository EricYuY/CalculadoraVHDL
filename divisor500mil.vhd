library ieee;
use ieee.std_logic_1164.all;

entity divisor500mil is
	port( reset_n, clk					: in std_logic;
			salida							: out std_logic);
	end divisor500mil;


architecture arch of divisor500mil is 
component addsub 
	generic (width	: natural := 4);
	port( signal a: in std_logic_vector(width-1 downto 0);
			signal b: in std_logic_vector(width-1 downto 0);
			signal control : in std_logic;
			signal s: out std_logic_vector(width-1 downto 0));
	end component;
signal q_reg,q_next,q_ok : std_logic_vector(18 downto 0);
begin
	process(reset_n, clk)
		begin 
			if reset_n = '0' then
				q_reg <= (others => '0');
			elsif rising_edge(clk) then
				q_reg<= q_next;
		end if;
	end process;
	stage0: addsub
			generic map(width => 19)
			port map(q_reg,"0000000000000000001",'0',q_ok); 
	q_next <= (others=>'0') when (q_reg="1111010000100011111") else q_ok;--cambiar por 1111010000100011111
	salida <= '1' when (q_reg="1111010000100011111") else '0'; --cambiar por 1111010000100011111
end arch;

