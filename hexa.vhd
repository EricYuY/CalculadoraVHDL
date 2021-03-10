library ieee;
use ieee.std_logic_1164.all;


entity hexa is 
port(	entrada	: in std_logic_vector(3 downto 0);
		salida	: out std_logic_vector(6 downto 0));
end hexa;
architecture arch2 of hexa is
begin
 with entrada select
salida <= "0100001" when x"D" ,
				"1000110" when x"C" ,
				"0000011" when x"B" ,
				"0001000" when x"A" ,
				"0001110" when x"F" ,
				"0010000" when x"9" ,
				"0000010" when x"6" ,
				"0110000" when x"3" ,
				"1000000" when x"0" ,
				"0000000" when x"8" ,
				"0010010" when x"5" ,
				"0100100" when x"2" ,
				"0000110" when x"E" ,
				"1111000" when x"7" ,
				"0011001" when x"4" ,
				"1111001" when x"1" ,
				"-------" when others;
				
		
end arch2;