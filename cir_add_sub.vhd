library ieee;
use ieee.std_logic_1164.all;

entity cir_add_sub is
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
end cir_add_sub;
architecture arch of cir_add_sub is 
	type state is( st0,st1,st2,st3);
	signal state_next, state_reg :state;
	attribute syn_encoding: string;
	attribute syn_encoding of state : type is "safe";
	
	signal b_in: std_logic_vector (17 downto 0);
	signal c: std_logic_vector (18 downto 0);
	signal s,pout_next,pout_reg : std_logic_vector(17 downto 0);
	signal s_int : std_logic_vector(17 downto 0);
	signal a_ok,b_ok : std_logic_vector(17 downto 0);
	signal en_pout,sel_pout : std_logic;
	signal en_ack,sel_ack : std_logic;
	signal ack_reg, ack_next : std_logic;
	signal en_div: std_logic;
	signal p_out		:	 std_logic_vector(17 downto 0);
	signal en,sal,pout		:	std_logic_vector(16 downto 0);
	
	component fulladder is 
			port (	a,b,cin : in std_logic;
						s,cout : out std_logic);
	end component;
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
stageen: divisor500mil port map(reset_n, clk, en_div);
a_ok <= '0'&a;
b_ok <= '0'&b;
--datapath--
	gen: for i in 0 to 17 generate
	begin
		b_in(i)<= b_ok(i) xor control;
	end generate gen;
	c(0)<= control;
	gen1: for i in 0 to 17 generate
	begin
	
	U: fulladder port map (a_ok(i),b_in(i),c(i),s_int(i),c(i+1));
	
	end generate gen1;

	s<= s_int;
	--registro pout
	process(reset_n,clk)
		begin
			if(reset_n ='0') then pout_reg<=(others => '0');
			elsif rising_edge(clk) then 
				if en_div = '1' then
					if en_pout ='1' then
						pout_reg<= pout_next;	
						end if;
				end if;		
			end if;
	end process;
	pout_next<= s when sel_pout='1' else (others=>'0');
	
	p_out<=	pout_reg; 
	--registro ack--
	process(reset_n,clk)
		begin
			if(reset_n ='0') then ack_reg<='0';
			elsif rising_edge(clk) then 
				if en_div = '1' then
					if en_ack ='1' then
						ack_reg<= ack_next;	
						end if;
				end if;		
			end if;
	end process;
	ack_next<= '1' when sel_ack='1' else '0';
	
	ack<=	ack_reg; 
	
	
	---
	
seq: process(reset_n, clk)
	begin
		if(reset_n = '0') then state_reg <= st0;
		elsif rising_edge(clk) then 
			if en_div = '1' then 
				state_reg <= state_next;
			end if;
		end if;
end process seq;
comb: process(state_reg,req)
	begin
		sel_pout<= '0';
		sel_ack<= '0';
		en_ack <= '0';
		en_pout<= '0';
		case(state_reg) is
			when(st0)=> 
				en_ack <= '1';
				en_pout<= '1';
				if(req='0') then state_next<= st0;
				else state_next <= st1;
				end if;
			when(st1)=>
				sel_pout <= '1';
				en_pout <='1';
				state_next<= st2;
			when(st2)=>
				if(req='1') then state_next<= st2;
				else state_next <= st3;
				end if;
			when(st3)=>
				sel_ack<= '1';
				en_ack<='1';
				state_next<= st0;
		end case;
		end process comb;
		 n<= p_out(17);
		 en<=not( p_out(16 downto 0));
		 
		y: addsub 
			generic map(width=>17)
			port map(en,"00000000000000001",'0',sal);
		
		 pout <= sal when (p_out(17)='1')  else p_out(16 downto 0);
	
		 v <= '1' when  p_out >"011000011010011111" else '0';
		 salida <= pout;
						
		
		
		
		
		end arch;

