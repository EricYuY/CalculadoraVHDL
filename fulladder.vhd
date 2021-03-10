library ieee;
use ieee.std_logic_1164.all;

entity fulladder is
	port( a, b, cin: in std_logic;
			s, cout: out std_logic);
end fulladder;

architecture structural of fulladder is
begin
	cout <= ((a xor b) and cin) or (a and b);
	s <= a xor b xor cin;
end structural;
