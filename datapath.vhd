library ieee;
use ieee.std_logic_1164.all;

entity  datapath is
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
			 en_rst																: in std_logic);

end datapath;

architecture arch of datapath is

signal result_add_sub_next	, result_add_sub_reg		: std_logic_vector(16 downto 0);
signal result_mult_next		, result_mult_reg			: std_logic_vector(16 downto 0);
signal result_div_next		, result_div_reg			: std_logic_vector(16 downto 0);
signal ack_next												: std_logic;
signal result_bin_next,result_bin_reg :  std_logic_vector(16 downto 0);

begin

result_add_sub_next 	<= result_add_sub when sel_result_add_sub='1' else (others=>'0');
result_mult_next 		<= result_mult when sel_result_mult='1' else (others=>'0');
result_div_next 		<= result_div when sel_result_div = '1' else (others=>'0');
ack_next 				<= '1' when sel_ack='1' else '0';

process(reset_n,clock_50)
	begin
		if reset_n = '0' then 
				result_add_sub_reg 	<= (others=>'0');
				result_mult_reg 		<= (others=>'0');
				result_div_reg 		<= (others=>'0');
				result_bin_reg 		<= (others=>'0');
				
			elsif rising_edge(clock_50) then 
				if (en = '1') then
					if en_result_add_sub = '1' then result_add_sub_reg <= result_add_sub_next;
					end if;
					if en_result_mult ='1' then result_mult_reg <= result_mult_next;
					end if;
					if en_result_div ='1' then result_div_reg <= result_div_next;
					end if; 
					if en_ack ='1' then ack <= ack_next;
					end if;
				end if;
				if (en_rst = '1') then
					result_bin_reg <= result_bin_next;
				end if;
		end if;
	
 end process;

 result_bin_next <= result_mult_reg or result_div_reg or result_add_sub_reg;
 
 result_bin <= result_bin_reg;
 
 end arch;
 
