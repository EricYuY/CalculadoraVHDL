library ieee;
use ieee.std_logic_1164.all;

entity fsm_calc_slave is
	port(  signal reset_n	: in std_logic;
			 signal clock_50	: in std_logic;
			 signal en			: in std_logic;
			 signal eq_op		: in std_logic;
			 signal eq_result	: in std_logic;
			 signal fs_valido	: in std_logic;
			 signal ack			: in std_logic;
			 signal req			: out std_logic;
			 signal en_A		: out std_logic;
			 signal en_B		: out std_logic;
			 signal en_Op		: out std_logic);
end fsm_calc_slave;

architecture behav of fsm_calc_slave is

	type state is (st_idle, st_a, st_w_a, st_op, st_w_op, st_b, st_w_b, st_eop, st_wait);
	signal st_next, st_reg : state;
	attribute syn_encoding : string;
	attribute syn_encoding of state: type is "safe";

begin
	
	seq: process (clock_50, reset_n)
	begin
		if (reset_n ='0') then
			st_reg <= st_idle; 
		elsif rising_edge(clock_50) then
			if (en = '1') then
				st_reg <= st_next;
			end if;
		end if;
	end process seq;
	
	comb: process(eq_op, eq_result, fs_valido, ack,st_reg)
	begin
		en_A <= '0';
		en_B <= '0';
		en_Op <= '0';
		req <= '0';
		case (st_reg) is
			when (st_idle) =>
				if (fs_valido = '0') then
					st_next <= st_idle;
				elsif (eq_op = '0') then
					st_next <= st_a;
				else
					st_next <= st_idle;
				end if;
			when (st_a) =>
				en_A <= '1';
				st_next <= st_w_a;
			when (st_w_a) =>
				if (fs_valido = '0') then
					st_next <= st_w_a;
				elsif (eq_op = '0') then
					st_next <= st_a;
				else
					st_next <= st_op;
				end if;
			when (st_op) =>
				en_Op <= '1';
				st_next <= st_w_op;
			when (st_w_op) =>
				if (fs_valido = '0') then
					st_next <= st_w_op;
				elsif (eq_op = '0') then
					st_next <= st_b;
				else
					st_next <= st_op;
				end if;
			when (st_b) =>
				en_b <= '1';
				st_next <= st_w_b;
			when (st_w_b) =>
				if (fs_valido = '1') then 
					if (eq_result = '1') then 
						st_next <= st_eop;
					elsif (eq_op = '0') then
						st_next <= st_b;
					else
						st_next <= st_w_b;
					end if;
				else
					st_next <= st_w_b;
				end if;
			when (st_eop) =>
				req <= '1';
				if (ack = '0') then
					st_next <= st_eop;
				else 
					st_next <= st_wait;
				end if;
			when (st_wait) =>
				if (ack = '1') then
					st_next <= st_wait;
				else 
					st_next <= st_idle;
				end if;
			when others =>
				st_next <= st_idle;
		end case;
	end process comb;
									
end behav;
			 