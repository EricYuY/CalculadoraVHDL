library ieee;
use ieee.std_logic_1164.all;
package operaciones is 

component multiplicador is
	port( signal clk 	:	in std_logic;
			signal reset_n 	:	in std_logic;
			signal req 	:	in std_logic;
			signal a		:	in std_logic_vector(16 downto 0);
			signal b		:	in std_logic_vector(16 downto 0);
			signal salida:	out std_logic_vector(16 downto 0);
			signal v		:  out std_logic;
			signal ack	:	out std_logic);
end component;
	
component cir_add_sub is
	port( signal clk 			:	in std_logic;
			signal reset_n 	:	in std_logic;
			signal req 			:	in std_logic;
			signal control		: 	in std_logic;
			signal a				:	in std_logic_vector(16 downto 0);
			signal b				:	in std_logic_vector(16 downto 0);
			signal salida		:	out std_logic_vector(16 downto 0);
			signal v				:	out std_logic;
			signal n				:  out std_logic;
			signal ack			:	out std_logic);
end component;	


component divider is
	generic (width: natural := 4);
	port (clk, rst_n, req 	: in std_logic;
			A_in, B_in			: in std_logic_vector(width-1 downto 0);
			ack 					: out std_logic;
			cociente 			: out std_logic_vector (width -1 downto 0);
			residuo	         : out std_logic_vector (width -1 downto 0));	
end component;
	
end operaciones;