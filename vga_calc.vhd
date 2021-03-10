library ieee;
use ieee.std_logic_1164.all;

entity vga_calc is
	port(signal clock_50MHz, reset_n				:  in std_logic;
		  signal sobrepaso_add, sobrepaso_mul  :	in std_logic;
		  signal negativo								: 	in std_logic;
		  signal	d4,d3,d2,d1,d0						: 	in std_logic_vector (3 downto 0);
		  signal VGA_HS, VGA_VS 					:	out std_logic;
		  signal VGA_R, VGA_G, VGA_B 				:  out std_logic_vector(3 downto 0));
end vga_calc;
		  
architecture behav of vga_calc is
		  
	signal enable_c, enable_25MHz,VGA_blank 					: std_logic;
	signal val1, val2, val3, val4, val5, val6 				: std_logic;
	signal clk_o_next 												: std_logic;
	signal VGA_ROJO, VGA_VERDE, VGA_AZUL						: std_logic;
	signal a_0,b_0,c_0,d_0,e_0,f_0,g_0						 	: std_logic;
	signal a_1,b_1,c_1,d_1,e_1,f_1,g_1						 	: std_logic;
	signal a_2,b_2,c_2,d_2,e_2,f_2,g_2						 	: std_logic;
	signal a_3,b_3,c_3,d_3,e_3,f_3,g_3						 	: std_logic;
	signal a_4,b_4,c_4,d_4,e_4,f_4,g_4						 	: std_logic;
	signal g_5 : std_logic;
	
	signal q_reg_0, q_next_0, q_next_sum 		: std_logic_vector(1 downto 0);
	signal q_reg_1, q_next_1, q_next_1_temp1, q_next_1_temp2, q_next_1_sum  : std_logic_vector (9 downto 0);
	signal q_reg_2, q_next_2, q_next_2_temp1, q_next_2_temp2, q_next_2_sum 	: std_logic_vector (9 downto 0);
	
	--------------NEGRO-------------
	signal line_h_1, line_h_2, line_h_3, line_h_4, line_h_5, line_h : std_logic;
	signal line_v_1, line_v_2, line_v_3, line_v_4, line_v_5, line_v : std_logic;
	
	--------------AZUL--------------
	signal bloq_1, bloq_2, bloq_3, bloq_4, bloq_5, bloq_6, bloq_7, bloq_8, bloq_9, bloq_0, azul : std_logic; 
	--------------ROJO---------------
	signal bloq_mas, bloq_menos, bloq_por, bloq_div, bloq_igual, bloq_vacio, rojo : std_logic;
	--------------AFUERA--------------
	signal exterior_h_1, exterior_h_2, exterior_v_1, exterior_v_2, exterior : std_logic;
	
	---------NUMEROS WHITE-------
	
	signal cero_h_1, cero_h_2, cero_v_1, cero_v_2, cero : std_logic;
	signal uno_h_1, uno_v_1, uno : std_logic;
	signal dos_h_1,dos_h_2,dos_h_3,dos_h_4,dos_h_5,dos_h_6,dos_h_7,dos : std_logic;
	signal tres_h_1, tres_h_2, tres_h_3, tres_v_1, tres_v_2, tres_v_3, tres_v_4, tres : std_logic;
	signal cuatro_h_1, cuatro_h_2, cuatro_h_3, cuatro_h_4, cuatro_v_1, cuatro : std_logic;
	signal cinco_h_1, cinco_h_2, cinco_h_3, cinco_v_1, cinco_v_2, cinco : std_logic;
	signal seis_h_1, seis_h_2, seis_h_3, seis_v_1, seis_v_2, seis_v_3, seis : std_logic;
	signal siete_h_1, siete_v_1, siete_v_2, siete_v_3, siete : std_logic;
	signal ocho_h_1, ocho_h_2, ocho_h_3, ocho_v_1, ocho_v_2, ocho_v_3, ocho_v_4, ocho : std_logic;
	signal nueve_h_1, nueve_h_2, nueve_h_3, nueve_v_1, nueve_v_2, nueve_v_3, nueve : std_logic;
	signal mas_h, mas_v, mas : std_logic;
	signal menos: std_logic;
	signal por_h_1, por_h_2, por_h_3, por_h_4, por_h_5, por_h_6, por_h_7, por_h_8, por_h_9, por : std_logic;
	signal entre_h_1, entre_h_2, entre_h_3, entre : std_logic;
	signal igual_h_1, igual_h_2, igual: std_logic;
	signal signos : std_logic; 
	
	--------marco del resultado-----
	signal marco :std_logic;
	
	---------VGABLANK----DISPLAY---------
	
	signal VGA_blank_0 ,VGA_blank_1 ,VGA_blank_2 ,VGA_blank_3 ,VGA_blank_4, VGA_blank_5, VGA_blank_temp, n : std_logic;
	
	---------------componente-----------
	component addsub is
			generic (width	: natural := 4);
			port( signal a: in std_logic_vector(width-1 downto 0);
					signal b: in std_logic_vector(width-1 downto 0);
					signal control : in std_logic;
					signal s: out std_logic_vector(width-1 downto 0));
	end component;
	
begin
	
	------------DIVISOR DE FRECUENCIA--------------------
	seq: process (clock_50MHz, reset_n)
	begin
		if (reset_n ='0') then
			enable_25MHz <= '0';
			q_reg_0 <= "00";
		elsif rising_edge(clock_50MHz) then
			enable_25MHz <= clk_o_next;
			q_reg_0 <= q_next_0;
		end if;
	end process seq;
	
	comb: addsub generic map (width => 2) port map ("01",q_reg_0,'0',q_next_sum);
	
	clk_o_next <= '1' when (q_reg_0 = "01") else
					  '0';
	q_next_0 <= (others => '0') when (q_reg_0 = "01") else
					q_next_sum;
	
	------------ CONTADOR COL-----------------
	seq1: process (clock_50MHz, reset_n)
	
	begin
		if (reset_n ='0') then
			q_reg_1 <= (others => '0');
		elsif rising_edge(clock_50MHz) then
			q_reg_1 <= q_next_1;
		end if;
	end process seq1;
	
	
	comb1: addsub generic map(width => 10) port map (q_reg_1,"0000000001",'0',q_next_1_sum);

	q_next_1 <= q_next_1_temp1 when (enable_25MHz = '1') else
					q_reg_1;
					
	q_next_1_temp1 <= (others => '0') when (val3 = '1') else
							q_next_1_temp2;
	q_next_1_temp2 <= (others => '0') when (q_reg_1 = "1100011111") else
							q_next_1_sum;
							
------------ CONTADOR FILAS-----------------------

	enable_c <= enable_25MHz and val3;
	
	seq2: process (clock_50MHz, reset_n)
	begin
		if (reset_n ='0') then
			q_reg_2 <= (others => '0');
		elsif rising_edge(clock_50MHz) then
			q_reg_2 <= q_next_2;
		end if;
	end process seq2;
	
	comb2: addsub generic map (width => 10) port map (q_reg_2,"0000000001",'0',q_next_2_sum);
	q_next_2 <= q_next_2_temp1 when (enable_c = '1') else
					q_reg_2;
					
	q_next_2_temp1 <= (others => '0') when (val6 = '1') else
							q_next_2_temp2;
							
	q_next_2_temp2 <= (others => '0') when (q_reg_1 = "1000000111") else
							q_next_2_sum;

--COMPARADORES
	val1 <= '1' when (q_reg_1 > "1010001111" and q_reg_1 < "1011110000") else 
			  '0';

	val2 <= '1' when (q_reg_1	> "1001111111") else
			  '0';
			  
	val3 <= '1' when (q_reg_1 = "1100011111") else
			  '0';
	
	val4 <= '1' when ((q_reg_2 > "0111101000" ) and (q_reg_2 < "0111101011")) else
			  '0';
			  
	val5 <= '1' when (q_reg_2 > "0111011111") else
			  '0';
			  
	val6 <= '1' when (q_reg_2 = "1000000111") else
			  '0';
	--------------------COLOREADO--------------
	line_h_1 <= '1' when (q_reg_1 > "0011001100") and q_reg_1 < "0110110011" and (q_reg_2 > "0001111100") and (Q_reg_2 < "0010000111") else
					'0';
	line_h_2 <= '1' when (q_reg_1 > "0011001100") and (q_reg_1 < "0110110011") and (q_reg_2 >"0010110011") and (q_reg_2 < "0010111110") else
					'0';
	line_h_3 <= '1' when (q_reg_1 > "0011001100") and (q_reg_1 < "0110110011") and (q_reg_2 >"0011101010") and (q_reg_2 < "0011110101") else
					'0';
	line_h_4 <= '1' when (q_reg_1 > "0011001100") and (q_reg_1 < "0110110011") and (q_reg_2 >"0100100001") and (q_reg_2 < "0100101100") else
					'0';
	line_h_5 <= '1' when (q_reg_1 > "0011001100") and (q_reg_1 < "0110110011") and (q_reg_2 >"0101011000") and (q_reg_2 < "0101100011") else
					'0';
	
	line_h <= line_h_1 or line_h_2 or line_h_3 or line_h_4 or line_h_5;				
	
	line_v_1 <= '1' when (q_reg_2 > "0001111100") and (q_reg_2 < "0101100011") and (q_reg_1 > "0011001100") and (q_reg_1 < "0011010111") else
					'0';
					line_v_2 <= '1' when (q_reg_2 > "0001111100") and (q_reg_2 < "0101100011") and (q_reg_1 > "0100000011") and (q_reg_1 < "0100001110") else
					'0';
					line_v_3 <= '1' when (q_reg_2 > "0001111100") and (q_reg_2 < "0101100011") and (q_reg_1 > "0100111010") and (q_reg_1 < "0101000101") else
					'0';
					line_v_4 <= '1' when (q_reg_2 > "0001111100") and (q_reg_2 < "0101100011") and (q_reg_1 > "0101110001") and (q_reg_1 < "0101111100") else
					'0';
					line_v_5 <= '1' when (q_reg_2 > "0001111100") and (q_reg_2 < "0101100011") and (q_reg_1 > "0110101000") and (q_reg_1 < "0110110011") else
					'0';
					
	line_v <= line_v_1 or line_v_2 or line_v_3 or line_v_4 or line_v_5;			

	-------------NUM 0------------
	cero_h_1 <= '1' when (q_reg_1 > "0100011100") and (q_reg_1 < "0100101100") and (q_reg_2 > "0100110000") and (q_reg_2 < "0100110110") else
					'0';
	cero_h_2 <= '1' when (q_reg_1 > "0100011100") and (q_reg_1 < "0100101100") and (q_reg_2 > "0101001110") and (q_reg_2 < "0101010100") else
					'0';
					
	cero_v_1 <= '1' when (q_reg_1 > "0100010111") and (q_reg_1 < "0100011101") and (q_reg_2 > "0100110101") and (q_reg_2 < "0101001111") else
					'0';
					
	cero_v_2 <= '1' when (q_reg_1 > "0100101011") and (q_reg_1 < "0100110001") and (q_reg_2 > "0100110101") and (q_reg_2 < "0101001111") else
					'0';
					
	cero <= cero_h_1 or cero_h_2 or cero_v_1 or cero_v_2;
	-------------NUM 1-----------
	
	uno_h_1 <= '1' when (q_reg_1 > "0011100000") and (q_reg_1 < "0011101011") and (q_reg_2 > "0010010000") and (q_reg_2 < "0010010110") else 
				  '0';
	uno_v_1 <= '1' when (q_reg_1 > "0011101010") and (q_reg_1 < "0011110000") and (q_reg_2 > "0010001011") and (q_reg_2 < "0010101111") else 
				  '0';
	uno <= uno_h_1 or uno_v_1;
	
	------------NUM 2--------------
	dos_h_1 <= '1' when (q_reg_1 > "0100011100") and (q_reg_1 < "0100101011") and (q_reg_2 > "0010001011") and (q_reg_2 <"0010010001") else
				  '0';
	dos_h_2 <= '1' when (((q_reg_1 > "0100010111") and (q_reg_1 < "0100011101") and (q_reg_2 > "0010010000") and (q_reg_2 < "0010010110")) or ((q_reg_1 > "0100101011") and (q_reg_1 < "0100110001") and (q_reg_2 > "0010010000") and (q_reg_2 < "0010010110"))) else
				  '0';
	dos_h_3 <= '1' when (q_reg_1 > "0100100110") and (q_reg_1 <"0100101100") and (q_reg_2 > "0010010101") and (q_reg_2 <"0010011011") else
				  '0';
	dos_h_4 <= '1' when (q_reg_1 > "0100100001") and (q_reg_1 < "0100100111") and (q_reg_2 >"0010011010") and (q_reg_2 <"0010100000") else
				  '0';
	dos_h_5 <= '1' when (q_reg_1 > "0100011100") and (q_reg_1 <"0100100010") and (q_reg_2 >"0010011111") and (q_reg_2 <"0010100101") else
				  '0';
	dos_h_6 <= '1' when (q_reg_1 > "0100010111") and (q_reg_1 <"0100011101") and (q_reg_2 >"0010100100") and (q_reg_2 <"0010101010") else
				  '0';
	dos_h_7 <= '1' when (q_reg_1 > "0100010111") and (q_reg_1 < "0100110001") and (q_reg_2 >"0010101001") and (q_reg_2 <"0010101111") else
				  '0';
	
	dos <= dos_h_1 or dos_h_2 or dos_h_3 or dos_h_4 or dos_h_5 or dos_h_6 or dos_h_7;
				  
	-------------NUM3--------------
	tres_h_1 <= '1' when (q_reg_1 > "0101010011") and (q_reg_1 < "0101100011") and (q_reg_2 > "0010001011") and (q_reg_2 < "0010010001") else
					'0';	
	tres_h_2 <= '1' when (q_reg_1 > "0101011000") and (q_reg_1 < "0101100011") and (q_reg_2 > "0010011010") and (q_reg_2 < "0010100000") else
					'0';	
	tres_h_3 <= '1' when (q_reg_1 > "0101010011") and (q_reg_1 < "0101100011") and (q_reg_2 > "0010101001") and (q_reg_2 < "0010101111") else
					'0';	
	tres_v_1 <= '1' when (q_reg_1 > "0101001110") and (q_reg_1 < "0101010100") and (q_reg_2 > "0010010000") and (q_reg_2 < "0010010110") else
					'0';	
	tres_v_2 <= '1' when (q_reg_1 > "0101001110") and (q_reg_1 < "0101010100") and (q_reg_2 > "0010100100") and (q_reg_2 < "0010101010") else
					'0';	
	tres_v_3 <= '1' when (q_reg_1 > "0101100010") and (q_reg_1 < "0101101000") and (q_reg_2 > "0010010000") and (q_reg_2 < "0010011011") else
					'0';
	tres_v_4 <= '1' when (q_reg_1 > "0101100010") and (q_reg_1 < "0101101000") and (q_reg_2 > "0010011111") and (q_reg_2 < "0010101010") else
					'0';	
	tres <= tres_h_1 or tres_h_2 or tres_h_3 or tres_v_1 or tres_v_2 or tres_v_3 or tres_v_4;
	
	------------NUM4-----------------
	cuatro_h_1 <= '1' when (q_reg_1 > "0011100000") and (q_reg_1 < "0011111010") and (q_reg_2 > "0011010110") and (q_reg_2 < "0011011100") else
					  '0';
	cuatro_h_2 <= '1' when (q_reg_1 > "0011100000") and (q_reg_1 < "0011100110") and (q_reg_2 > "0011010001") and (q_reg_2 <"0011010111") else
					  '0';
	cuatro_h_3 <= '1' when (q_reg_1 > "0011100101") and (q_reg_1 < "0011101011") and (q_reg_2 > "0011001100") and (q_reg_2 < "0011010010") else
					  '0';
	cuatro_h_4 <= '1' when (q_reg_1 > "0011101010") and (q_reg_1 < "0011110000") and (q_reg_2 > "0011000111") and (q_reg_2 < "0011001101") else
					  '0';
	cuatro_v_1 <= '1' when (q_reg_1 > "0011101111") and (q_reg_1 < "0011110101") and (q_reg_2 > "0011000010") and (q_reg_2 < "0011100110") else
					  '0';
	cuatro <= cuatro_h_1 or cuatro_h_2 or cuatro_h_3 or cuatro_h_4 or cuatro_v_1;
	
	------------NuM5---------------
	cinco_h_1 <= '1' when (q_reg_1 >"0100010111") and (q_reg_1 <"0100110001") and (q_reg_2 >"0011000010") and (q_reg_2 <"0011001000") else
					 '0';
	cinco_h_2 <= '1' when (q_reg_1 >"0100010111") and (q_reg_1 <"0100101100") and (q_reg_2 >"0011010001") and (q_reg_2 <"0011010111") else
					 '0';
	cinco_h_3 <= '1' when (q_reg_1 >"0100010111") and (q_reg_1 <"0100101100") and (q_reg_2 >"0011100000") and (q_reg_2 <"0011100110") else
					 '0';
	cinco_v_1 <= '1' when (q_reg_1 >"0100010111") and (q_reg_1 <"0100011101") and (q_reg_2 >"0011000010") and (q_reg_2 <"0011010111") else
					 '0';
	cinco_v_2 <= '1' when (q_reg_1 >"0100101011") and (q_reg_1 <"0100110001") and (q_reg_2 >"0011010110") and (q_reg_2 <"0011100001") else
					 '0';
	cinco <= cinco_h_1 or cinco_h_2 or cinco_h_3 or cinco_v_1 or cinco_v_2;
	

	------------NUM6---------------
	
	seis_h_1 <= '1' when (q_reg_1 > "0101010011") and (q_reg_1 < "0101100011") and (q_reg_2 > "0011000010") and (q_reg_2 < "0011001000") else
					 '0';
	seis_h_2 <= '1' when (q_reg_1 > "0101010011") and (q_reg_1 < "0101100011") and (q_reg_2 > "0011010001") and (q_reg_2 < "0011010111") else
					 '0';
	seis_h_3 <= '1' when (q_reg_1 > "0101010011") and (q_reg_1 < "0101100011") and (q_reg_2 > "0011100000") and (q_reg_2 < "0011100110") else
					 '0';
	seis_v_1 <= '1' when (q_reg_1 > "0101001110") and (q_reg_1 < "0101010100") and (q_reg_2 > "0011000111") and (q_reg_2 < "0011100001") else
					 '0';
	seis_v_2 <= '1' when (q_reg_1 > "0101100010") and (q_reg_1 < "0101101000") and (q_reg_2 > "0011000111") and (q_reg_2 < "0011001101") else
					 '0';
	seis_v_3 <= '1' when (q_reg_1 > "0101100010") and (q_reg_1 < "0101101000") and (q_reg_2 > "0011010110") and (q_reg_2 < "0011100001") else
					 '0';
	seis <= seis_h_1 or seis_h_2 or seis_h_3 or seis_v_1 or seis_v_2 or seis_v_3;
	------------NUM7---------------
	
	siete_h_1 <= '1' when (q_reg_1 > "0011100000") and (q_reg_1 < "0011111010") and (q_reg_2 > "0011111001") and (q_reg_2 < "0011111111") else
					 '0';
	siete_v_1 <= '1' when (q_reg_1 > "0011110100") and (q_reg_1 < "0011111010") and (q_reg_2 > "0011111110") and (q_reg_2 < "0100000100") else
					 '0';
	siete_v_2 <= '1' when (q_reg_1 > "0011101111") and (q_reg_1 < "0011110101") and (q_reg_2 > "0100000011") and (q_reg_2 < "0100001001") else
					 '0';
	siete_v_3 <= '1' when (q_reg_1 > "0011101010") and (q_reg_1 < "0011110000") and (q_reg_2 > "0100001000") and (q_reg_2 < "0100011101") else
					 '0';
	siete <= siete_h_1 or siete_v_1 or siete_v_2 or siete_v_3;
	------------NUM8-----------------
	
	ocho_h_1 <= '1' when (q_reg_1 > "0100011100") and (q_reg_1 < "0100101100") and (q_reg_2 > "0011111001") and (q_reg_2 < "0011111111")  else
					'0';
	ocho_h_2 <= '1' when (q_reg_1 > "0100011100") and (q_reg_1 < "0100101100") and (q_reg_2 > "0100001000") and (q_reg_2 < "0100001110")  else
					'0';
	ocho_h_3 <= '1' when (q_reg_1 > "0100011100") and (q_reg_1 < "0100101100") and (q_reg_2 > "0100010111") and (q_reg_2 < "0100011101")	 else
					'0';
	ocho_v_1 <= '1' when (q_reg_1 > "0100010111") and (q_reg_1 < "0100011101") and (q_reg_2 > "0011111110") and (q_reg_2 < "0100001001")  else
					'0';
	ocho_v_2 <= '1' when (q_reg_1 > "0100010111") and (q_reg_1 < "0100011101") and (q_reg_2 > "0100001101") and (q_reg_2 < "0100011000")  else
					'0';
	ocho_v_3 <= '1' when (q_reg_1 > "0100101011") and (q_reg_1 < "0100110001") and (q_reg_2 > "0011111110") and (q_reg_2 < "0100001001")  else
					'0';
	ocho_v_4 <= '1' when (q_reg_1 > "0100101011") and (q_reg_1 < "0100110001") and (q_reg_2 > "0100001101") and (q_reg_2 < "0100011000")  else
					'0';
	
	ocho <= ocho_h_1 or ocho_h_2 or ocho_h_3 or ocho_v_1 or ocho_v_2 or ocho_v_3 or ocho_v_4;
	------------NUM9-------------------
	
	
	nueve_h_1 <= '1' when (q_reg_1 > "0101010011") and (q_reg_1 < "0101100011") and (q_reg_2 > "0011111001") and (q_reg_2 < "0011111111") else
					 '0';
	nueve_h_2 <= '1' when (q_reg_1 > "0101010011") and (q_reg_1 < "0101100011") and (q_reg_2 > "0100001000") and (q_reg_2 < "0100001110") else
					 '0';
	nueve_h_3 <= '1' when (q_reg_1 > "0101010011") and (q_reg_1 < "0101100011") and (q_reg_2 > "0100010111") and (q_reg_2 < "0100011101") else
					 '0';
	nueve_v_1 <= '1' when (q_reg_1 > "0101001110") and (q_reg_1 < "0101010100") and (q_reg_2 > "0011111110") and (q_reg_2 < "0100001001") else
					 '0';
	nueve_v_2 <= '1' when (q_reg_1 > "0101001110") and (q_reg_1 < "0101010100") and (q_reg_2 > "0100010010") and (q_reg_2 < "0100011000") else
					 '0';
	nueve_v_3 <= '1' when (q_reg_1 > "0101100010") and (q_reg_1 < "0101101000") and (q_reg_2 > "0011111110") and (q_reg_2 < "0100011000") else
					 '0';
	
	nueve <= nueve_h_1 or nueve_h_2 or nueve_h_3 or nueve_v_1 or nueve_v_2 or nueve_v_3;

	----------SIGNO +----------------
	mas_h <= '1' when (q_reg_1 > "0110000101") and (q_reg_1 < "0110011111") and (q_reg_2 > "0010011010") and (q_reg_2 < "0010100000") else
				  '0';
	mas_v <= '1' when (q_reg_1 > "0110001111") and (q_reg_1 < "0110010101") and (q_reg_2 > "0010010000") and (q_reg_2 < "0010101010") else
				  '0';
	
	mas <= mas_h or mas_v;
	
	----------SIGNO - -----------------
	
	menos <= '1' when (q_reg_1 > "0110000101") and (q_reg_1 < "0110011111") and (q_reg_2 > "0011010001") and (q_reg_2 < "0011010111") else
				'0';
		
	----------SIGNO X-------------
	por_h_1 <= '1' when (q_reg_1 > "0110000101") and (q_reg_1 < "0110001011") and (q_reg_2 > "0011111110") and (q_reg_2 < "0100000100") else
				  '0';
	por_h_2 <= '1' when (q_reg_1 > "0110011001") and (q_reg_1 < "0110011111") and (q_reg_2 > "0011111110") and (q_reg_2 < "0100000100") else
				  '0';
	por_h_3 <= '1' when (q_reg_1 > "0110001010") and (q_reg_1 < "0110010000") and (q_reg_2 > "0100000011") and (q_reg_2 < "0100001001") else
				  '0';
	por_h_4 <= '1' when (q_reg_1 > "0110010100") and (q_reg_1 < "0110011010") and (q_reg_2 > "0100000011") and (q_reg_2 < "0100001001") else
				  '0';
	por_h_5 <= '1' when (q_reg_1 > "0110001111") and (q_reg_1 < "0110010101") and (q_reg_2 > "0100001000") and (q_reg_2 < "0100001110") else
				  '0';
	por_h_6 <= '1' when (q_reg_1 > "0110001010") and (q_reg_1 < "0110010000") and (q_reg_2 > "0100001101") and (q_reg_2 < "0100010011") else
				  '0';
	por_h_7 <= '1' when (q_reg_1 > "0110010100") and (q_reg_1 < "0110011010") and (q_reg_2 > "0100001101") and (q_reg_2 < "0100010011") else
				  '0';
	por_h_8 <= '1' when (q_reg_1 > "0110000101") and (q_reg_1 < "0110001011") and (q_reg_2 > "0100010010") and (q_reg_2 < "0100011000") else
				  '0';
	por_h_9 <= '1' when (q_reg_1 > "0110011001") and (q_reg_1 < "0110011111") and (q_reg_2 > "0100010010") and (q_reg_2 < "0100011000") else
				  '0';	
	
	por <= por_h_1 or por_h_2 or por_h_3 or por_h_4 or por_h_5 or por_h_6 or por_h_7 or por_h_8 or por_h_9;
	
	----------SIGNO %-------------
	
	
	entre_h_1 <= '1' when (q_reg_1 > "0110001111") and (q_reg_1 < "0110010101") and (q_reg_2 > "0100110101") and (q_reg_2 < "0100111011") else
				    '0';
	entre_h_2 <= '1' when (q_reg_1 > "0110000101") and (q_reg_1 < "0110011111") and (q_reg_2 > "0100111111") and (q_reg_2 < "0101000101") else
				    '0';
	entre_h_3 <= '1' when (q_reg_1 > "0110001111") and (q_reg_1 < "0110010101") and (q_reg_2 > "0101001001") and (q_reg_2 < "0101001111") else
				    '0';
	entre <= entre_h_1 or entre_h_2 or entre_h_3;
	
	---------SIGNO IGUAL------------
	
	
	igual_h_1 <= '1' when (q_reg_1 > "0101001110") and (q_reg_1 < "0101101000") and (q_reg_2 > "0100111010") and (q_reg_2 < "0101000000") else
				    '0';
	igual_h_2 <= '1' when (q_reg_1 > "0101001110") and (q_reg_1 < "0101101000") and (q_reg_2 > "0101000100") and (q_reg_2 < "0101001010") else
				    '0';
	igual <= igual_h_1 or igual_h_2;
			
	---------Bloque 1---------------
	bloq_1 <= '1' when (q_reg_1 > "0011010110") and (q_reg_1 < "0100000100") and (q_reg_2 > "0010000110") and (q_reg_2 < "0010110100")else
				 '0';
	---------Bloque 2---------------
	bloq_2 <= '1' when (q_reg_1 > "0100001101") and (q_reg_1 < "0100111011") and (q_reg_2 > "0010000110") and (q_reg_2 < "0010110100")else
					'0';
	---------Bloque 3---------------
	bloq_3 <= '1' when (q_reg_1 > "0101000100") and (q_reg_1 < "0101110010") and (q_reg_2 > "0010000110") and (q_reg_2 < "0010110100")else
					'0';
	---------Bloque +---------------
	bloq_mas <= '1' when (q_reg_1 > "0101111011") and (q_reg_1 < "0110101001") and (q_reg_2 > "0010000110") and (q_reg_2 < "0010110100")else
				 '0';
	---------Bloque 4---------------
	bloq_4 <= '1' when (q_reg_1 > "0011010110") and (q_reg_1 < "0100000100") and (q_reg_2 > "0010111101") and (q_reg_2 < "0011101011")else
				 '0';
	---------Bloque 5---------------
	bloq_5 <= '1' when (q_reg_1 > "0100001101") and (q_reg_1 < "0100111011") and (q_reg_2 > "0010111101") and (q_reg_2 < "0011101011")else
				 '0';
	---------Bloque 6---------------
	bloq_6 <= '1' when (q_reg_1 > "0101000100") and (q_reg_1 < "0101110010") and (q_reg_2 > "0010111101") and (q_reg_2 < "0011101011")else
				 '0';
	---------Bloque - ---------------
	bloq_menos <= '1' when (q_reg_1 > "0101111011") and (q_reg_1 < "0110101001") and (q_reg_2 > "0010111101") and (q_reg_2 < "0011101011")else
				 '0';
	---------Bloque 7---------------
	bloq_7 <= '1' when (q_reg_1 > "0011010110") and (q_reg_1 < "0100000100") and (q_reg_2 > "0011110100") and (q_reg_2 < "0100100010")else
			    '0';
	---------Bloque 8---------------
	bloq_8 <= '1' when (q_reg_1 > "0100001101") and (q_reg_1 < "0100111011") and (q_reg_2 > "0011110100") and (q_reg_2 < "0100100010")else
					'0';
	---------Bloque 9---------------
	bloq_9 <= '1' when (q_reg_1 > "0101000100") and (q_reg_1 < "0101110010") and (q_reg_2 > "0011110100") and (q_reg_2 < "0100100010")else
				 '0';
	---------Bloque *---------------
	bloq_por <= '1' when (q_reg_1 > "0101111011") and (q_reg_1 < "0110101001") and (q_reg_2 > "0011110100") and (q_reg_2 < "0100100010")else
				   '0';
	---------Bloque _---------------
	bloq_vacio <= '1' when (q_reg_1 > "0011010110") and (q_reg_1 < "0100000100") and (q_reg_2 > "0100101011") and (q_reg_2 < "0101011001")else
					'0';
	---------Bloque 0---------------
	bloq_0 <= '1' when (q_reg_1 > "0100001101") and (q_reg_1 < "0100111011") and (q_reg_2 > "0100101011") and (q_reg_2 < "0101011001")else
					'0';
	---------Bloque =---------------
	bloq_igual <= '1' when (q_reg_1 > "0101000100") and (q_reg_1 < "0101110010") and (q_reg_2 > "0100101011") and (q_reg_2 < "0101011001")else
				     '0';
	---------Bloque %---------------
	bloq_div <= '1' when (q_reg_1 > "0101111011") and (q_reg_1 < "0110101001") and (q_reg_2 > "0100101011") and (q_reg_2 < "0101011001")else
					'0';
					
	---------EXTERIOR-------------------
	exterior_h_1 <= '1' when (q_reg_1 > "0011001100") and (q_reg_1 < "0110110011") and (q_reg_2 >= "0000000000") and (q_reg_2 < "0000111100" ) else
						 '0';
	exterior_h_2 <= '1' when (q_reg_1 > "0011001100") and (q_reg_1 < "0110110011") and (q_reg_2 > "0101100010") and (q_reg_2 < "0111100000") else
						 '0';
	exterior_v_1 <= '1' when (q_reg_1 >= "0000000000") and (q_reg_1 < "0011001101") and (q_reg_2 >= "0000000000") and (q_reg_2 < "0111100000") else
						 '0';
	exterior_v_2 <= '1' when (q_reg_1 > "0110110010") and (q_reg_1 < "1010000000") and (q_reg_2 >= "0000000000") and (q_reg_2 < "0111100000") else
						 '0';
	exterior <= exterior_h_1 or exterior_h_2 or exterior_v_1 or exterior_v_2;
	
	---------MARCO------------------
	
	marco <= '1' when (q_reg_1 > "0011001100") and (q_reg_1 < "0110110011") and (q_reg_2 > "0000111011") and (q_reg_2 < "0001111101") else
				'0';
	
	-----------------	
	
	signos <= uno or dos or tres or cuatro or cinco or seis or siete or ocho or nueve or cero or mas or menos or por or entre or igual;
					
	rojo <= bloq_0 or bloq_1 or bloq_2 or bloq_3 or bloq_4 or bloq_5 or bloq_6 or bloq_7 or bloq_8 or bloq_9;
	
	azul <= bloq_mas or bloq_menos or bloq_por or bloq_div or bloq_vacio or bloq_igual; 				
	
	
	-----------RESULTADOS			
					
	a_0<= '1' when (q_reg_1 > "0110010100") and (q_reg_1 < "0110011111") and (q_reg_2 > "0001001010") and ( q_reg_2< "0001010000") else
			'0';
	b_0<= '1' when (q_reg_1 > "0110011110") and (q_reg_1 < "0110100100") and (q_reg_2 > "0001001111") and ( q_reg_2< "0001011010")else
			'0';
	c_0<= '1' when (q_reg_1 > "0110011110") and (q_reg_1 < "0110100100") and (q_reg_2 > "0001011110") and ( q_reg_2< "0001101001")else
			'0';
	d_0<= '1' when (q_reg_1 > "0110010100") and (q_reg_1 < "0110011111") and (q_reg_2 > "0001101000") and ( q_reg_2 < "0001101110")else
			'0';
	e_0<= '1' when (q_reg_1 > "0110001111") and (q_reg_1 < "0110010101") and (q_reg_2 > "0001011110") and ( q_reg_2< "0001101001")else
			'0';
	f_0<= '1' when (q_reg_1 > "0110001111") and (q_reg_1 < "0110010101") and (q_reg_2 > "0001001111") and ( q_reg_2< "0001011010")else
			'0';
	g_0<= '1' when (q_reg_1 > "0110010100") and (q_reg_1 < "0110011111") and (q_reg_2 > "0001011001") and ( q_reg_2< "0001011111")else
			'0';
	----------SE RESTAN 25 PIXELES PARA LLEGAR AL OTRO DIGITO A MOSTRAR
	a_1<= '1' when (q_reg_1 > "0101111011") and (q_reg_1 < "0110000110") and (q_reg_2 > "0001001010") and ( q_reg_2< "0001010000") else
			'0';
	b_1<= '1' when (q_reg_1 > "0110000101") and (q_reg_1 < "0110001011") and (q_reg_2 > "0001001111") and ( q_reg_2< "0001011010")else
			'0';
	c_1<= '1' when (q_reg_1 > "0110000101") and (q_reg_1 < "0110001011") and (q_reg_2 > "0001011110") and ( q_reg_2< "0001101001")else
			'0';
	d_1<= '1' when (q_reg_1 > "0101111011") and (q_reg_1 < "0110000110") and (q_reg_2 > "0001101000") and ( q_reg_2 < "0001101110")else
			'0';
	e_1<= '1' when (q_reg_1 > "0101110110") and (q_reg_1 < "0101111100") and (q_reg_2 > "0001011110") and ( q_reg_2< "0001101001")else
			'0';
	f_1<= '1' when (q_reg_1 > "0101110110") and (q_reg_1 < "0101111100") and (q_reg_2 > "0001001111") and ( q_reg_2< "0001011010")else
			'0';
	g_1<= '1' when (q_reg_1 > "0101111011") and (q_reg_1 < "0110000110") and (q_reg_2 > "0001011001") and ( q_reg_2< "0001011111")else
			'0';
	----------SE RESTAN 25 PIXELES PARA LLEGAR AL OTRO DIGITO A MOSTRAR
	a_2<= '1' when (q_reg_1 > "0101100010") and (q_reg_1 < "0101101101") and (q_reg_2 > "0001001010") and ( q_reg_2< "0001010000") else
			'0';
	b_2<= '1' when (q_reg_1 > "0101101100") and (q_reg_1 < "0101110010") and (q_reg_2 > "0001001111") and ( q_reg_2< "0001011010")else
			'0';
	c_2<= '1' when (q_reg_1 > "0101101100") and (q_reg_1 < "0101110010") and (q_reg_2 > "0001011110") and ( q_reg_2< "0001101001")else
			'0';
	d_2<= '1' when (q_reg_1 > "0101100010") and (q_reg_1 < "0101101101") and (q_reg_2 > "0001101000") and ( q_reg_2 < "0001101110")else
			'0';
	e_2<= '1' when (q_reg_1 > "0101011101") and (q_reg_1 < "0101100011") and (q_reg_2 > "0001011110") and ( q_reg_2< "0001101001")else
			'0';
	f_2<= '1' when (q_reg_1 > "0101011101") and (q_reg_1 < "0101100011") and (q_reg_2 > "0001001111") and ( q_reg_2< "0001011010")else
			'0';
	g_2<= '1' when (q_reg_1 > "0101100010") and (q_reg_1 < "0101101101") and (q_reg_2 > "0001011001") and ( q_reg_2< "0001011111")else
			'0';
			  
	----------SE RESTAN 25 PIXELES PARA LLEGAR AL OTRO DIGITO A MOSTRAR
	a_3<= '1' when (q_reg_1 > "0101001001") and (q_reg_1 < "0101010100") and (q_reg_2 > "0001001010") and ( q_reg_2< "0001010000") else
			'0';
	b_3<= '1' when (q_reg_1 > "0101010011") and (q_reg_1 < "0101011001") and (q_reg_2 > "0001001111") and ( q_reg_2< "0001011010")else
			'0';
	c_3<= '1' when (q_reg_1 > "0101010011") and (q_reg_1 < "0101011001") and (q_reg_2 > "0001011110") and ( q_reg_2< "0001101001")else
			'0';
	d_3<= '1' when (q_reg_1 > "0101001001") and (q_reg_1 < "0101010100") and (q_reg_2 > "0001101000") and ( q_reg_2 < "0001101110")else
			'0';
	e_3<= '1' when (q_reg_1 > "0101000100") and (q_reg_1 < "0101001010") and (q_reg_2 > "0001011110") and ( q_reg_2< "0001101001")else
			'0';
	f_3<= '1' when (q_reg_1 > "0101000100") and (q_reg_1 < "0101001010") and (q_reg_2 > "0001001111") and ( q_reg_2< "0001011010")else
			'0';
	g_3<= '1' when (q_reg_1 > "0101001001") and (q_reg_1 < "0101010100") and (q_reg_2 > "0001011001") and ( q_reg_2< "0001011111")else
			'0';
	----------SE RESTAN 25 PIXELES PARA LLEGAR AL OTRO DIGITO A MOSTRAR
	a_4<= '1' when (q_reg_1 > "0100110000") and (q_reg_1 < "0100111011") and (q_reg_2 > "0001001010") and ( q_reg_2< "0001010000") else
			'0';
	b_4<= '1' when (q_reg_1 > "0100111010") and (q_reg_1 < "0101000000") and (q_reg_2 > "0001001111") and ( q_reg_2< "0001011010")else
			'0';
	c_4<= '1' when (q_reg_1 > "0100111010") and (q_reg_1 < "0101000000") and (q_reg_2 > "0001011110") and ( q_reg_2< "0001101001")else
			'0';
	d_4<= '1' when (q_reg_1 > "0100110000") and (q_reg_1 < "0100111011") and (q_reg_2 > "0001101000") and ( q_reg_2< "0001101110")else
			'0';
	e_4<= '1' when (q_reg_1 > "0100101011") and (q_reg_1 < "0100110001") and (q_reg_2 > "0001011110") and ( q_reg_2< "0001101001")else
			'0';
	f_4<= '1' when (q_reg_1 > "0100101011") and (q_reg_1 < "0100110001") and (q_reg_2 > "0001001111") and ( q_reg_2< "0001011010")else
			'0';
	g_4<= '1' when (q_reg_1 > "0100110000") and (q_reg_1 < "0100111011") and (q_reg_2 > "0001011001") and ( q_reg_2< "0001011111")else
			'0';
	-----------------------SIGNO NEGATIVO
	g_5<= '1' when (q_reg_1 > "0100010111") and (q_reg_1 < "0100100010") and (q_reg_2 > "0001011001") and ( q_reg_2< "0001011111")else
			'0';
			  
			  
-------------------Logica salida----------------------

	VGA_HS 		<= not (val1);
	--VGA_blank	<= (not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v));------BLANK de los pixeles que no están dentro del VGA VISIBLE
	VGA_VS 		<= not (val4);
	
	VGA_ROJO <= ((not(rojo)) and (not(exterior)) and (not(signos))) or (not VGA_blank);
	VGA_VERDE <= ((not(exterior)) and (not(marco)) and (not(signos))) or (not VGA_blank); -----------para un tono oscuro colocar and (VGA_blank)----
	VGA_AZUL <= ((not(azul)) and (not(exterior)) and (not(signos)) and (not(marco))) or (not VGA_blank);
	
--------------------RGB---------------------
	
	VGA_R <= "1111" when (VGA_ROJO = '0') else
				"0000";
	VGA_G <= "1111" when (VGA_VERDE = '0') else
				"0000";
	VGA_B <= "1111" when (VGA_AZUL = '0') else
				"0000";
				
--------------------numeros mostrados en display-------------
	with d0 select
 VGA_blank_0 <= ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(b_0) and not(c_0) and not(d_0) and not(e_0) and not(f_0))    when "0000",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_0)and not(c_0))															  			  when "0001",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(b_0)and not(d_0)and not(e_0)and not(g_0)) 					  	  when "0010",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(b_0)and not(c_0)and not(d_0)and not(g_0)) 					  	  when "0011",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_0)and not(c_0)and not(f_0)and not(g_0)) 									  	  when "0100",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(c_0)and not(d_0)and not(f_0)and not(g_0)) 						  when "0101",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(c_0)and not(d_0)and not(e_0)and not(f_0)and not(g_0)) 		  when "0110",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(b_0)and not(c_0)) 												  		  when "0111",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(b_0)and not(c_0)and not(d_0)and not(e_0)and not(f_0)and not(g_0)) when "1000",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(b_0)and not(c_0)and not(d_0)and not(f_0)and not(g_0)) 		  when "1001",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v))) when others;

	with d1 select
	VGA_blank_1 <= ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_1)and not(b_1) and not(c_1) and not(d_1) and not(e_1) and not(f_1))    when "0000",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_1)and not(c_1))															  			  when "0001",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_1)and not(b_1)and not(d_1)and not(e_1)and not(g_1)) 					  	  when "0010",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_1)and not(b_1)and not(c_1)and not(d_1)and not(g_1)) 					  	  when "0011",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_1)and not(c_1)and not(f_1)and not(g_1)) 									  	  when "0100",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_1)and not(c_1)and not(d_1)and not(f_1)and not(g_1)) 						  when "0101",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_1)and not(c_1)and not(d_1)and not(e_1)and not(f_1)and not(g_1)) 		  when "0110",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_1)and not(b_1)and not(c_1)) 												  		  when "0111",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_1)and not(b_1)and not(c_1)and not(d_1)and not(e_1)and not(f_1)and not(g_1)) when "1000",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_1)and not(b_1)and not(c_1)and not(d_1)and not(f_1)and not(g_1)) 		  when "1001",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v))) when others;

	with d2 select
	VGA_blank_2 <= ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_2)and not(b_2) and not(c_2) and not(d_2) and not(e_2) and not(f_2))    when "0000",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_2)and not(c_2))															  			  when "0001",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_2)and not(b_2)and not(d_2)and not(e_2)and not(g_2)) 					  	  when "0010",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_2)and not(b_2)and not(c_2)and not(d_2)and not(g_2)) 					  	  when "0011",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_2)and not(c_2)and not(f_2)and not(g_2)) 									  	  when "0100",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_2)and not(c_2)and not(d_2)and not(f_2)and not(g_2)) 						  when "0101",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_2)and not(c_2)and not(d_2)and not(e_2)and not(f_2)and not(g_2)) 		  when "0110",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_2)and not(b_2)and not(c_2)) 												  		  when "0111",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_2)and not(b_2)and not(c_2)and not(d_2)and not(e_2)and not(f_2)and not(g_2)) when "1000",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_2)and not(b_2)and not(c_2)and not(d_2)and not(f_2)and not(g_2)) 		  when "1001",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v))) when others;

	with d3 select
	VGA_blank_3 <= ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_3)and not(b_3) and not(c_3) and not(d_3) and not(e_3) and not(f_3))    when "0000",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_3)and not(c_3))															  			  when "0001",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_3)and not(b_3)and not(d_3)and not(e_3)and not(g_3)) 					  	  when "0010",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_3)and not(b_3)and not(c_3)and not(d_3)and not(g_3)) 					  	  when "0011",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_3)and not(c_3)and not(f_3)and not(g_3)) 									  	  when "0100",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_3)and not(c_3)and not(d_3)and not(f_3)and not(g_3)) 						  when "0101",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_3)and not(c_3)and not(d_3)and not(e_3)and not(f_3)and not(g_3)) 		  when "0110",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_3)and not(b_3)and not(c_3)) 												  		  when "0111",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_3)and not(b_3)and not(c_3)and not(d_3)and not(e_3)and not(f_3)and not(g_3)) when "1000",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_3)and not(b_3)and not(c_3)and not(d_3)and not(f_3)and not(g_3)) 		  when "1001",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v))) when others;

	with d4 select
	VGA_blank_4 <= ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_4)and not(b_4) and not(c_4) and not(d_4) and not(e_4) and not(f_4))    when "0000",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_4)and not(c_4))															  			  when "0001",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_4)and not(b_4)and not(d_4)and not(e_4)and not(g_4)) 					  	  when "0010",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_4)and not(b_4)and not(c_4)and not(d_4)and not(g_4)) 					  	  when "0011",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_4)and not(c_4)and not(f_4)and not(g_4)) 									  	  when "0100",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_4)and not(c_4)and not(d_4)and not(f_4)and not(g_4)) 						  when "0101",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_4)and not(c_4)and not(d_4)and not(e_4)and not(f_4)and not(g_4)) 		  when "0110",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_4)and not(b_4)and not(c_4)) 												  		  when "0111",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_4)and not(b_4)and not(c_4)and not(d_4)and not(e_4)and not(f_4)and not(g_4)) when "1000",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_4)and not(b_4)and not(c_4)and not(d_4)and not(f_4)and not(g_4)) 		  when "1001",
					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v))) when others;

	
	with negativo select
	VGA_blank_5 <= (not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(g_5)    when '1',
					   ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v))) when others;
						
	n <= (not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(c_0) and not(e_0) and not(g_0) and not(c_1) and not(e_1) and not(g_1) and not(c_2) and not(e_2) and not(g_2) and not(c_3) and not(e_3) and not(g_3) and not(c_4) and not(e_4) and not(g_4);
	
	VGA_blank_temp <= VGA_blank_0 and VGA_blank_1 and VGA_blank_2 and VGA_blank_3 and VGA_blank_4 and VGA_blank_5;
	
	VGA_blank <= VGA_blank_temp when (sobrepaso_mul or sobrepaso_add) ='0' else
					 n;
					 
					 
					 
	------- PLANTILLA	
--	with sw select
--	VGA_blank <= ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(b_0) and not(c_0) and not(d_0) and not(e_0) and not(f_0))    when "0000",
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_0)and not(c_0))															  			  when "0001",
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(b_0)and not(d_0)and not(e_0)and not(g_0)) 					  	  when "0010",
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(b_0)and not(c_0)and not(d_0)and not(g_0)) 					  	  when "0011",
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_0)and not(c_0)and not(f_0)and not(g_0)) 									  	  when "0100",
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(c_0)and not(d_0)and not(f_0)and not(g_0)) 						  when "0101",
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(c_0)and not(d_0)and not(e_0)and not(f_0)and not(g_0)) 		  when "0110",
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(b_0)and not(c_0)) 												  		  when "0111",
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(b_0)and not(c_0)and not(d_0)and not(e_0)and not(f_0)and not(g_0)) when "1000",
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(a_0)and not(b_0)and not(c_0)and not(d_0)and not(f_0)and not(g_0)) 		  when "1001",
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_1)and not(c_1)and not(a_0)and not(b_0) and not(c_0) and not(d_0) and not(e_0) and not(f_0))		  when "1010",--A
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_1)and not(c_1)and not(b_0)and not(c_0))			  	  when "1011",--B
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_1)and not(c_1)and not(a_0)and not(b_0)and not(d_0)and not(e_0)and not(g_0))							 		  when "1100",--C
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_1)and not(c_1)and not(a_0)and not(b_0)and not(c_0)and not(d_0)and not(g_0)) 						  when "1101",--D
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_1)and not(c_1)and not(b_0)and not(c_0)and not(f_0)and not(g_0))				  when "1110",--E
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v)) and not(b_1)and not(c_1)and not(a_0)and not(c_0)and not(d_0)and not(f_0)and not(g_0))									  when "1111",--F
--					 ((not (val2)) and (not (val5)) and (not(line_h)) and (not(line_v))) when others;
	
end behav;