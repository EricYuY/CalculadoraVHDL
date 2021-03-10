library ieee;
use ieee.std_logic_1164.all;


entity teclado_calc is
	port ( signal	clock_50, reset_n : in std_logic;
						fila		: in 	std_logic_vector(3 downto 0);
						value_in	: out std_logic_vector(3 downto 0);
						columna	: out std_logic_vector(3 downto 0);
						z	      : out std_logic);
end teclado_calc;

architecture behav of teclado_calc is 

component addsub 
	generic (width	: natural := 4);
	port( signal a: in std_logic_vector(width-1 downto 0);
			signal b: in std_logic_vector(width-1 downto 0);
			signal control : in std_logic;
			signal s: out std_logic_vector(width-1 downto 0));
end component;

	signal value_reg, value_next : std_logic_vector (3 downto 0);
	signal q_reg_DF, q_next_DF	: std_logic_vector(22 downto 0);
	signal q_reg_mas_uno	: std_logic_vector(22 downto 0);
	signal clk_o, clk_o_next: std_logic;
	signal z_in : std_logic;

	signal en_df : std_logic;
	
	signal data, data_nosync, data_sync : std_logic_vector (3 downto 0);
	
	signal fila_sync : std_logic_vector (3 downto 0);
	
	signal q_next_c, q_reg_c : std_logic_vector (1 downto 0);
	signal q_reg_c_mas_uno : std_logic_vector (1 downto 0);
	
	
	signal colum_bin			: std_logic_vector(1 downto 0);
	signal fila_bin			: std_logic_vector(1 downto 0);
	signal retraso : std_logic_vector (1 downto 0);
	signal selector : std_logic_vector (3 downto 0);
	
	
begin
	
	u: addsub 
		generic map(width => 23)
		port map (q_reg_DF,"00000000000000000000001",'0',q_reg_mas_uno);
		
	y: addsub 
		generic map(width => 2)
		port map (q_reg_c,"01",'0',q_reg_c_mas_uno);
		
		
		
	-------------------Registro-------------------------
	registro:process (clock_50, reset_n)
	begin
		if (reset_n ='0') then
			value_reg <= (others => '0');
		elsif rising_edge(clock_50) then
			if	(z_in = '1') then
				value_reg <= value_next;
			end if;
		end if;
	end process registro;
	
	-----------------------Divisor 5m---------------------
   seq_DF: process (clock_50, reset_n)
	begin
		if (reset_n ='0') then
			clk_o <= '0';
			q_reg_DF <= (others => '0');
		elsif rising_edge(clock_50) then
			clk_o <= clk_o_next;
			q_reg_DF <= q_next_DF;
			end if;
	end process seq_DF;
	
	comb_DF: process(q_reg_DF,q_reg_mas_uno)
	begin
		if (q_reg_DF = "10011000100101100111111") then ----"10011000100101100111111" 
			clk_o_next <= '1';														 
			q_next_DF <= (others => '0');
		else
			clk_o_next <= '0';
			q_next_DF <= q_reg_mas_uno;
		end if;
	end process comb_DF;
	
	en_df <= clk_o;
	
	
	---------------Sincronizador------------------
	data <= not (fila);
	
	
	seq_sinc: process (clock_50, reset_n)
		begin 
		if (reset_n = '0') then 
			data_nosync <= (others => '0');
			data_sync <= (others => '0');
		elsif(rising_edge(clock_50)) then
			if (en_df='1') then
				data_nosync <= data;
				data_sync <= data_nosync;
			end if;
		end if;
	end process seq_sinc;
	
	
	fila_sync <= data_sync;
	
	----------------CONTADOR-------------------------
	
		
	seq_c: process (clock_50, reset_n)
	begin
		if (reset_n ='0') then
			q_reg_c <= (others => '0');
		elsif rising_edge(clock_50) then
			q_reg_c <= q_next_c;
			end if;
	end process seq_c;
	
	comb_c: process(en_df, q_reg_c,q_reg_c_mas_uno)
	begin
		if(en_df = '1') then
			if (q_reg_c = "11") then
				q_next_c <= "00";
			else
				q_next_c <= q_reg_c_mas_uno;
			end if;
		else 
			q_next_c <= q_reg_c;
		end if;
	end process comb_c;
	
	
	colum_bin <= q_reg_c;
	
	------------------CODIFICADOR---------------------
	fila_bin	<= "11" when fila_sync ="1000" else
					"10" when fila_sync ="0100" else 
					"01" when fila_sync ="0010" else
					"00" when fila_sync ="0001" else
					"--"; 
	z_in <= 	(fila_sync(3) or fila_sync(2) or fila_sync(1) or fila_sync(0));
	
	z<= z_in;

	------------------restador-------------
	r: addsub 
		generic map(width => 2)
		port map (colum_bin,"10",'1',retraso); -- si le resto 2, se malogra el circuito
	
	selector <= fila_bin & retraso;
	--------------------MUX-----------------
	with selector select 
	value_next <=  x"D" when "0000",
						x"C" when "0100",
						x"B" when "1000",
						x"A" when "1100",
						x"F" when "0001",
						x"9" when "0101",
						x"6" when "1001",
						x"3" when "1101",
						x"0" when "0010",
						x"8" when "0110",
						x"5" when "1010",
						x"2" when "1110",
						x"E" when "0011",
						x"7" when "0111",
						x"4" when "1011",
						x"1" when "1111",
						value_reg when others;
	value_in <=  value_reg;------------
	--------------------DECODIFICADOR------------------
	columna	<= "1110" when colum_bin = "00" else 
					"1101" when colum_bin = "01" else
					"1011" when colum_bin = "10" else
					"0111" when colum_bin = "11" else
					"----";
	
	
end behav;