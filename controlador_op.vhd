library ieee;
use ieee.std_logic_1164.all;

entity  controlador_op is
 port(	 reset_n		   		: in	std_logic;
			 clock_50				: in	std_logic;
			 req						: in	std_logic;
			 ack_add_sub			: in	std_logic;
			 result_add_sub		: in	std_logic_vector(16 downto 0);
			 ack_mult				: in	std_logic;
			 result_mult			: in	std_logic_vector(16 downto 0);
			 ack_div					: in	std_logic;
			 result_div				: in	std_logic_vector(16 downto 0);
			 Op_reg					: in	std_logic_vector(3 downto 0);
			 control_add_sub		: out std_logic;
			 req_add_sub			: out std_logic;
			 req_mult				: out std_logic;
			 req_div					: out std_logic;
			 result_bin				: out std_logic_vector(16 downto 0);
			 ack						: out std_logic);
end controlador_op;

architecture arch of controlador_op is

type state is (st0,st1,st2,st3,st4,st5,st6,st7,st8,st9,st10,st11,st12,st13,st14,st15,st16,st17);
signal state_next,state_reg: state;
attribute syn_encoding : string;
attribute syn_encoding of state: type is "safe";
---señales--
signal sel_result_add_sub,en_result_add_sub: std_logic;
signal sel_result_mult,en_result_mult: std_logic;
signal sel_result_div,en_result_div: std_logic;
signal sel_ack, en_ack : std_logic; 
signal en, en_rst: std_logic;
---datapath--
component datapath
 port(	 reset_n		   													: in	std_logic;
			 clock_50															: in	std_logic;
			 result_add_sub													: in	std_logic_vector(16 downto 0);
			 result_mult														: in	std_logic_vector(16 downto 0);
			 result_div															: in	std_logic_vector(16 downto 0);
			 sel_result_add_sub,en_result_add_sub						: in	std_logic;
			 sel_result_mult,en_result_mult	 							: in	std_logic;
			 sel_result_div,en_result_div 								: in	std_logic;
			 sel_ack, en_ack													: in	std_logic;
			 result_bin															: out std_logic_vector(16 downto 0);
			 ack																	: out std_logic;
			 en																	: in 	std_logic;
			 en_rst         													:in std_logic);
			 
end component;
----- div f
	component divisor500mil 
		port( reset_n, clk					: in std_logic;
				salida							: out std_logic);
		end component;
----- 
			
begin
stage0: divisor500mil port map(reset_n,clock_50,en);
stage1: datapath port map(reset_n,clock_50,result_add_sub,result_mult,result_div,sel_result_add_sub,en_result_add_sub,sel_result_mult,en_result_mult,sel_result_div,en_result_div,sel_ack, en_ack,result_bin,ack,en,en_rst);

 
 
 seq: process(reset_n,clock_50)
	begin
		if reset_n = '0' then state_reg<= st0;
			elsif rising_edge(clock_50) then
				if (en = '1') then
					state_reg <= state_next;
				end if;
		end if;
 end process seq;
 comb: process(state_reg,ack_add_sub,ack_mult,ack_div,req,Op_reg)
	begin
		sel_result_add_sub <= '0';
		en_result_add_sub <= '0';
		sel_result_mult <= '0';
		en_result_mult <= '0';
		sel_result_div <= '0';
		en_result_div <= '0';
		sel_ack <= '0';
		en_ack <= '0';
		control_add_sub	<= '0';
		req_add_sub			<= '0';
		req_mult				<= '0';
		req_div				<= '0';
		en_rst <= '0';
		
	case(state_reg) is	
	when(st0) =>
		en_result_add_sub <= '1';
		en_result_mult <= '1';
		en_result_div <= '1';
		en_ack <= '1';
		if(req='0') then state_next<= st0;
		else state_next <= st1;
		end if;
	when(st1) =>
		if(Op_reg= "1010") then state_next<=st2;
		elsif(Op_reg= "1011") then state_next<=st3;
		elsif(Op_reg= "1100") then state_next<=st4;
		elsif(Op_reg= "1101") then state_next<=st5;
		else state_next <= st0;
		end if;
	when(st2) =>
			req_add_sub <= '1';
			state_next <= st6;
	when(st3) =>
			req_add_sub <= '1';
			control_add_sub <= '1';
			state_next <= st7;
	when(st4) =>
			req_mult <= '1';
			state_next <= st8;
	when(st5) =>
			req_div <= '1';
			state_next <= st9;
	when(st6) => 
	
			if ack_add_sub ='0' then 
			state_next <= st6;
			else 
			sel_result_add_sub <= '1';
			en_result_add_sub <= '1';
			state_next <= st10;
			end if;
	when(st7) => 
			control_add_sub <= '1';
			if ack_add_sub ='0' then state_next <= st7;
			else 
			sel_result_add_sub <= '1';
			en_result_add_sub <= '1';
			state_next <= st11;
			end if;
	when(st8) => 
			if ack_mult ='0' then state_next <= st8;
			else 
			sel_result_mult <= '1';
			en_result_mult <= '1';
			state_next <= st12;
			end if;
	when(st9) => 
			if ack_div ='0' then state_next <= st9;
			else 
			sel_result_div <= '1';
			en_result_div <= '1';
			state_next <= st13;
			end if;
	when(st10) =>
			en_rst <= '1';
			state_next <= st14;
	when(st11) =>
			en_rst <= '1';
			state_next <= st14;
	when(st12) =>
			en_rst <= '1';			
			state_next <= st14;	
	when(st13) =>
			en_rst <= '1';
			state_next <= st14;
	when (st17) =>
	state_next <= st14;
	when(st14) =>
			sel_ack <= '1';
			en_ack <= '1';
			state_next <= st15;
	when(st15) =>
			if(req='1') then state_next<= st15;
			else state_next <= st16;
			end if;
	when(st16) =>
			en_ack <= '1';
			state_next <= st0;
	end case;
end process comb;

end arch;	
			

 
