library ieee;
use ieee.std_logic_1164.all;

entity addsub is
	generic (width	: natural := 4);
	port( signal a: in std_logic_vector(width-1 downto 0);
			signal b: in std_logic_vector(width-1 downto 0);
			signal control : in std_logic;
			signal s: out std_logic_vector(width-1 downto 0));
end addsub;

architecture estructura of addsub is
	component fulladder
		port( a, b, cin: in std_logic;
				s, cout: out std_logic);
	end component;
	constant n : natural := width;
	signal c: std_logic_vector(width downto 0);
	signal b_ok: std_logic_vector(width-1 downto 0);
	begin
		gen0: for i in 0 to width-1 generate
			b_ok(i)<= b(i) xor control;
		end generate gen0;
		c(0)<=control;
		gen1: for i in 0 to width-1 generate
			stage0: fulladder port map(a(i),b_ok(i),c(i),s(i),c(i+1));
		end generate gen1;
	end estructura;