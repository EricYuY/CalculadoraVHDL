library ieee;
use ieee.std_logic_1164.all;

entity bcd_binary is
	port( signal d0			: in 	std_logic_vector(3 downto 0);
			signal d1			: in 	std_logic_vector(3 downto 0);
			signal d2			: in 	std_logic_vector(3 downto 0);
			signal d3			: in 	std_logic_vector(3 downto 0);
			signal d4			: in 	std_logic_vector(3 downto 0);
			signal binary		: out	std_logic_vector(16 downto 0));
end bcd_binary;

architecture arch of bcd_binary is 
component addsub
	generic (width	: natural := 4);
	port( signal a: in std_logic_vector(width-1 downto 0);
			signal b: in std_logic_vector(width-1 downto 0);
			signal control : in std_logic;
			signal s: out std_logic_vector(width-1 downto 0));
end component;

signal suma_0,en1,en2 : std_logic_vector(6 downto 0);
signal suma_1,en3,en4 : std_logic_vector(8 downto 0);
signal suma_2,en5,en6 : std_logic_vector(9 downto 0);
signal suma_3,en7,en8 : std_logic_vector(11 downto 0);
signal suma_4 ,en9,en10: std_logic_vector(12 downto 0);
signal suma_5,en11,en12: std_logic_vector(14 downto 0);
signal suma_6,en13,en14: std_logic_vector(15 downto 0);
signal suma_7,en15,en16 : std_logic_vector(17 downto 0);
signal suma_8,en17,en18 : std_logic_vector(18 downto 0);

begin



en1<="0000000";
en2<="000"&d4;

	stage1: addsub
			generic map(width => 7)
			port map(en1,en2,'0',suma_0);
en3<=suma_0&"00";
en4<="00"&suma_0;
	stage2: addsub
			generic map(width => 9)
			port map(en3,en4,'0',suma_1);
en5<=suma_1&'0';
en6<="000000"&d3;	
	stage3: addsub
			generic map(width => 10)
			port map(en5,en6,'0',suma_2);
en7<=suma_2&"00";
en8<="00"&suma_2;
	stage4: addsub
			generic map(width => 12)
			port map(en7,en8,'0',suma_3);
en9<=suma_3&'0';
en10<="000000000"&d2;
	stage5: addsub
			generic map(width => 13)
			port map(en9,en10,'0',suma_4);
en11<=suma_4&"00";
en12<="00"&suma_4;
	stage6: addsub
			generic map(width => 15)
			port map(en11,en12,'0',suma_5);
en13<=suma_5&'0';
en14<="000000000000"&d1;
	stage7: addsub
			generic map(width => 16)
			port map(en13,en14,'0',suma_6);
en15<=suma_6&"00";
en16<="00"&suma_6;
	stage8: addsub
			generic map(width => 18)
			port map(en15,en16,'0',suma_7);
en17<=suma_7&'0';
en18<="000000000000000"&d0;
	stage9: addsub
			generic map(width => 19)
			port map(en17,en18,'0',suma_8);
	
	binary <= suma_8(16 downto 0);

end arch;			