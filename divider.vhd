library ieee;
use ieee.std_logic_1164.all;



entity divider is
	generic (width: natural := 4);
	port (clk, rst_n, req 	: in std_logic;
			A_in, B_in			: in std_logic_vector(width-1 downto 0);
			ack 					: out std_logic;
			cociente 			: out std_logic_vector (width -1 downto 0);
			residuo	         : out std_logic_vector (width -1 downto 0));
			
end divider;

architecture behav of divider is
	---------------Registro----
	signal Q, Q_next1, Q_next2				: std_logic_vector (width -1 downto 0); 
	signal R, R_next1, R_next2, R_next3 : std_logic_vector (width -1 downto 0);
	signal ack_next 							: std_logic;
	signal en_Q, en_R, en_ack				: std_logic;
	signal en_st								: STD_LOGIC;
	
	---------------selectores y condiciones
	signal sel_0, sel_1, sel_2, sel_ack : std_logic;
	signal cond_1, cond_2		: std_logic;
	
	--------------fsm---------
	type state is (st0,st1, st2, st3, st4, st5);
	signal st_next, st_reg : state;
	attribute syn_encoding : string;
	attribute syn_encoding of state: type is "safe";
	
	--------------signals
	signal temp1						  : std_logic_vector (width-1 downto 0);
	signal temp2						 : std_logic_vector (width-1 downto 0);
	
	--------------constantes-----
	constant zeros		: std_logic_vector(width-1 downto 0) := (others => '0');
	
	-------------COMPONENTES-------
		component divisor500mil 
		port( reset_n, clk					: in std_logic;
				salida							: out std_logic);
		end component;
	
	
	component addsub 
		generic (width	: natural := 4);
		port( signal a: in std_logic_vector(width-1 downto 0);
				signal b: in std_logic_vector(width-1 downto 0);
				signal control : in std_logic;
				signal s: out std_logic_vector(width-1 downto 0));
		end component;

begin
	-------------DIV F---------
	DF: divisor500mil port map(rst_n,clk,en_st);   ----------------------- para la simulación cambiar el 499999 a 1 -------------
	
	----------------Registros
	seq_r: process (clk, rst_n)
	begin
		if (rst_n = '0') then
			Q <= (others => '0');
			R <= (others => '0');
			ack <= '0';
			st_reg <= st0;
		elsif rising_edge (clk) then
			if (en_st = '1') then
				if (en_Q ='1') then
					Q <= Q_next1;
				end if;
				if (en_R ='1') then
					R <= R_next1;
				end if;
				if (en_ack ='1') then
					ack <= ack_next;
				end if;
				st_reg <= st_next;
			end if;
		end if;
	end process;
	
	---------------Logica combinacional-------------
	R_next1 <= zeros when (sel_0 = '1') else
				  R_next2;
	R_next2 <= A_in when (sel_1 = '1') else 
				  R_next3;
	R_next3 <= temp1 when (sel_2 = '1') else
				  R;
				  
	U_temp1: addsub generic map (width=> width) port map (R,B_in,'1',temp1);
	
	U_temp2: addsub generic map (width=> width) port map (Q,"00000000000000001",'0',temp2);
	
	
	Q_next1 <= zeros when (sel_0 = '1') else
				  Q_next2;
	
	Q_next2 <= temp2 when (sel_2 = '1') else
				  Q;
				 
	
	ack_next <= '1' when (sel_ack = '1') else
					'0';
					
	---------------comparadores-------------
	cond_1 <= '1' when (A_in = "0000") else
				 '0';
	cond_2 <= '1' when (R >= B_in) else
				 '0';
				 	
	----------------fsm--------------------
	comb_fsm: process (st_reg, req, cond_1, cond_2)
	begin
		en_Q <= '0';
		en_R <= '0';
		en_ack <= '0';
		sel_0 <= '0';
		sel_1 <= '0';
		sel_2 <= '0';
		sel_ack <= '0';
		
		case st_reg is
			when st0 =>
				sel_0 <= '1';
				en_R <= '1';
				en_Q <= '1';
				if (req = '0') then
					st_next <= st0;
				else
					st_next <= st1;
				end if;
			when st1 =>
				if (cond_1 = '1') then
					st_next <= st4;
				else
					st_next <= st2;
				end if;
			when st2 =>
				sel_1 <= '1';
				en_R <= '1';
				st_next <= st3;
			when st3 =>
				en_R <= '1';
				en_Q <= '1';
				sel_2<= '1';
				if (cond_2 = '1') then
					st_next <= st3;
				else
					en_R <= '0';
					en_Q <= '0';
					st_next <= st4;
				end if;
			when st4 =>
				en_ack <= '1';
				sel_ack <= '1';
				if (req = '1') then
					st_next <= st4;
				else
					st_next <= st5;
				end if;
				
			when st5 =>
			
				en_ack <= '1';
				st_next<= st0;
				
			when others =>
				st_next <= st0;
				
		end case;			
	end process comb_fsm;
			
cociente <= Q;
residuo <= R;
	
end behav;