library ieee;
use ieee.std_logic_1164.all;

entity multiplicador is
	port( signal clk 	:	in std_logic;
			signal reset_n 	:	in std_logic;
			signal req 	:	in std_logic;
			signal a		:	in std_logic_vector(16 downto 0);
			signal b		:	in std_logic_vector(16 downto 0);
			signal salida:	out std_logic_vector(16 downto 0);
			signal v		:  out std_logic;
			signal ack	:	out std_logic);
end multiplicador;

architecture arch of multiplicador is

type state is( st0,st1,st2,st3,st4,st5,st6,st7);
signal state_next, state_reg :state;
attribute syn_encoding: string;
attribute syn_encoding of state : type is "safe";
-------
signal en,en_a, en_p,en_pout, en_ack, en_n, cond_if, cond_n : std_logic;
signal sel_n, sel_p, sel_pout, sel_ack : std_logic;
signal p_out:	std_logic_vector(33 downto 0);

	component divisor500mil 
	port( reset_n, clk					: in std_logic;
			salida							: out std_logic);
	end component;
	
	component registro
			generic (width	: natural := 4);
			port(	reset_n		: in  std_logic;
					clk			: in  std_logic;
					en_div		: in 	std_logic;	
					en			: in  std_logic;
					entrada		: in  std_logic_vector(width-1 downto 0);
					sal			: out std_logic_vector(width-1 downto 0));
	end component;
	
	component ffd
			port(	reset_n		: in  std_logic;
				clk			: in  std_logic;
				en_div		: in 	std_logic;	
				en			: in  std_logic;
				entrada		: in  std_logic;
				sal			: out std_logic);
	end component;
	component addsub 
	generic (width	: natural := 4);
	port( signal a: in std_logic_vector(width-1 downto 0);
			signal b: in std_logic_vector(width-1 downto 0);
			signal control : in std_logic;
			signal s: out std_logic_vector(width-1 downto 0));
	end component;

	
	signal a_next,a_reg, b_next,b_reg,n_next, n_reg : std_logic_vector(16 downto 0); 
	signal n_menos : std_logic_vector(16 downto 0);--n_menos_1
	signal a_comp,b_comp,ack_next, ack_reg : std_logic; 
	signal p_next, p_reg,pout_next, pout_reg : std_logic_vector(33 downto 0); 
	signal p_mas_a, a_ok  : std_logic_vector(33 downto 0); 

begin
		stageen: divisor500mil port map(reset_n, clk, en);
		---datapath---
	stagea: registro 
			generic map(width => 17)
			port map(reset_n, clk,en,en_a, a, a_reg);
	a_comp<= '1' when (a="00000000000000000") else '0';
	b_comp<= '1' when ( b="00000000000000000") else '0';
	cond_if <= a_comp or b_comp;
	a_ok <= "00000000000000000"&a_reg;
	stageb: addsub 
			generic map(width => 34)
			port map(p_reg,a_ok,'0',p_mas_a);
	p_next <= (others=> '0') when sel_p = '0' else p_mas_a;
	stagec: registro 
			generic map(width => 34)
			port map(reset_n, clk,en, en_p, p_next, p_reg);
	staged: addsub 
			generic map(width => 17)
			port map(n_reg,"00000000000000001",'1',n_menos);
	
	n_next <= b when sel_n='0' else n_menos;
	stagee: registro 
			generic map(width => 17)
			port map(reset_n, clk,en, en_n, n_next, n_reg);
	cond_n <= '0' when (n_reg="00000000000000000") else '1';
	
	pout_next <= (others=> '0') when sel_pout ='0' else p_reg;
	stagef: registro
			generic map(width => 34)
			port map(reset_n, clk, en,en_pout, pout_next, pout_reg);
	
	ack_next <= '0' when sel_ack ='0' else '1';
	stageg: ffd port map(reset_n, clk,en, en_ack, ack_next, ack_reg);
	
	
	p_out <= pout_reg;
	ack <= ack_reg;
		----

seq: process(reset_n, clk)
	begin
		if(reset_n = '0') then state_reg <= st0;
		elsif rising_edge(clk) then 
			if en = '1' then 
				state_reg <= state_next;
			end if;
		end if;
end process seq;

comb: process(state_reg,a,b, req, cond_if, cond_n)
	begin
		en_a <= '0';
		en_p<= '0';
		en_pout <= '0';
		en_ack<= '0';
		en_n<= '0';
		sel_n <= '0';
		sel_p<= '0';
		sel_pout<= '0';
		sel_ack<= '0';
		case(state_reg) is
			when(st0)=> 
				en_a <= '1';
				en_p<= '1';
				if(req='0') then state_next<= st0;
				else state_next <= st1;
				end if;
			when(st1)=>
				if(cond_if='1') then state_next<= st5;
				else state_next<= st2;
				end if;
			when(st2) =>
				en_n<= '1';
				state_next<= st3;
			when(st3) =>
				if(cond_n='1') then state_next <= st4;
				else state_next <= st5;
				end if;
			when(st4) =>
				sel_p<='1';
				en_p <= '1';
				sel_n<='1';
				en_n <= '1';
				state_next<= st3;
			when(st5) =>
				en_pout<='1';
				sel_pout <= '1';
				en_ack<='1';
				sel_ack <= '1';
				state_next <= st6;
			when(st6)=>
				if(req='1') then state_next<= st6;
				else state_next <= st7;
				end if;
			when(st7)=>
				en_ack<='1';
				state_next<= st0;
			end case;
		end process comb;
		v<= '1' when (p_out > "0000000000000000011000011010011111") else '0';
		salida <= p_out(16 downto 0);
end arch;
				
			