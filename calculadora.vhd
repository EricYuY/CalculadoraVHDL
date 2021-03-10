library ieee;
use ieee.std_logic_1164.all;
use work.operaciones.all;

entity calculadora is
 port (  clock_50 , reset_n   : in std_logic;
			fila 						: in std_logic_vector(3 downto 0);
			columna 					: out std_logic_vector(3 downto 0);
			display5 				: out std_logic_vector(6 downto 0);
			display4 				: out std_logic_vector(6 downto 0);
			display3 				: out std_logic_vector(6 downto 0);
			display2 				: out std_logic_vector(6 downto 0);
			display1					: out std_logic_vector(6 downto 0);
			display0 				: out std_logic_vector(6 downto 0);		  
			VGA_HS, VGA_VS 		:	out std_logic;
		   VGA_R, VGA_G, VGA_B 	:  out std_logic_vector(3 downto 0));
end calculadora;

architecture arch of calculadora is 
---operaciones--
component multiplicador is
	port( signal clk 	:	in std_logic;
			signal reset_n 	:	in std_logic;
			signal req 	:	in std_logic;
			signal a		:	in std_logic_vector(16 downto 0);
			signal b		:	in std_logic_vector(16 downto 0);
			signal salida:	out std_logic_vector(16 downto 0);
			signal v		:  out std_logic;
			signal ack	:	out std_logic);
end component;
	
component cir_add_sub is
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
end component;	


component divider is
	generic (width: natural := 4);
	port (clk, rst_n, req 	: in std_logic;
			A_in, B_in			: in std_logic_vector(width-1 downto 0);
			ack 					: out std_logic;
			cociente 			: out std_logic_vector (width -1 downto 0);
			residuo	         : out std_logic_vector (width -1 downto 0));	
end component;
--
component teclado_calc 
	port ( signal	clock_50, reset_n : in std_logic;
						fila		: in 	std_logic_vector(3 downto 0);
						value_in	: out std_logic_vector(3 downto 0);
						columna	: out std_logic_vector(3 downto 0);
						z	      : out std_logic);
end component;

component fsm_calc is
	port( signal reset_n	: in std_logic;
			signal valido	: in std_logic;
			signal clock_50: in std_logic;
			signal valor	: in std_logic_vector(3 downto 0);
			signal A_reg	: out std_logic_vector(3 downto 0);
			signal Op_reg	: out std_logic_vector(3 downto 0);
			signal B_reg	: out std_logic_vector(3 downto 0);
			signal req		: out std_logic;
			signal ack		: in std_logic;
			signal enableA,enableB : out std_logic);
end component;

component reg_des is
 port  (signal reset_n 		:  in  std_logic;
        signal clk     		:  in  std_logic;
        signal data    		:  in  std_logic_vector(3 downto 0);
		  signal z 				: 	in	 std_logic;
        signal d4       	: 	out std_logic_vector(3 downto 0);
		  signal d3       	: 	out std_logic_vector(3 downto 0);
		  signal d2       	: 	out std_logic_vector(3 downto 0);
		  signal d1       	: 	out std_logic_vector(3 downto 0);
		  signal d0       	: 	out std_logic_vector(3 downto 0));
end component;

component bcd_binary is
	port( signal d0			: in 	std_logic_vector(3 downto 0);
			signal d1			: in 	std_logic_vector(3 downto 0);
			signal d2			: in 	std_logic_vector(3 downto 0);
			signal d3			: in 	std_logic_vector(3 downto 0);
			signal d4			: in 	std_logic_vector(3 downto 0);
			signal binary		: out	std_logic_vector(16 downto 0));
end component;

component  controlador_op is
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
end component;

component bin_bcd is--------CONVERTIDOR BIN A BCD DE 5DIGITOS 99999
	port( clk, rst_n: in std_logic;
			binario : in std_logic_vector(16 downto 0);
			d4 : out std_logic_vector(3 downto 0);
			d3 : out std_logic_vector(3 downto 0);
			d2 : out std_logic_vector(3 downto 0);
			d1 : out std_logic_vector(3 downto 0);
			d0 : out std_logic_vector(3 downto 0); --REALIZAR EL CALCULO RESPECTIVO PARA EL NUMERO DE DÍGITOS
			en_controlador : in std_logic);
end component;

component hexa is 
port(	entrada	: in std_logic_vector(3 downto 0);
		salida	: out std_logic_vector(6 downto 0));
end component;

component ffd is
		port(	reset_n		: in  std_logic;
				clk			: in  std_logic;
				en_div		: in 	std_logic;	
				en				: in  std_logic;
				entrada		: in  std_logic;
				sal			: out std_logic);
end component;

component registro is
	generic (width	: natural := 4);
		port(	reset_n		: in  std_logic;
				clk			: in  std_logic;
				en_div		: in 	std_logic;	
				en				: in  std_logic;
				entrada		: in  std_logic_vector(width-1 downto 0);
				sal			: out std_logic_vector(width-1 downto 0));
end component;

component vga_calc is
	port(signal clock_50MHz, reset_n				:  in std_logic;
		  signal sobrepaso_add, sobrepaso_mul  :	in std_logic;
		  signal negativo								: 	in std_logic;
		  signal	d4,d3,d2,d1,d0						: 	in std_logic_vector (3 downto 0);
		  signal VGA_HS, VGA_VS 					:	out std_logic;
		  signal VGA_R, VGA_G, VGA_B 				:  out std_logic_vector(3 downto 0));
end component;


signal valido 	: std_logic;
signal valor	: std_logic_vector(3 downto 0);
signal A_reg	: std_logic_vector(3 downto 0);
signal Op_reg	: std_logic_vector(3 downto 0);
signal B_reg	: std_logic_vector(3 downto 0);
signal req_fsm_calc, ack_fsm_calc : std_logic;
signal a4,a3,a2,a1,a0 : std_logic_vector(3 downto 0);
signal b4,b3,b2,b1,b0 : std_logic_vector(3 downto 0);
signal a_in,b_in : std_logic_vector(16 downto 0);


signal ack_add_sub			: 	std_logic;
signal result_add_sub		: 	std_logic_vector(16 downto 0);
signal ack_mult				: 	std_logic;
signal result_mult			: 	std_logic_vector(16 downto 0);
signal ack_div					: 	std_logic;
signal result_div				: 	std_logic_vector(16 downto 0);
signal control_add_sub		:  std_logic;
signal req_add_sub			:  std_logic;
signal req_mult				:  std_logic;
signal req_div					:  std_logic;
signal result_bin				:  std_logic_vector(16 downto 0);

signal z : std_logic;
signal sobrepaso_mul,sobrepaso_mul_enganche,sobrepaso_mul_next,sobrepaso_add,sobrepaso_add_enganche,sobrepaso_add_next, negativo, negativo_next, negativo_enganche		:  std_logic;
signal residuo : std_logic_vector(16 downto 0);
signal en_reg_des_A ,en_reg_des_B : std_logic;

signal diezmil,mil,centena,decena,unidad : std_logic_vector(3 downto 0);
signal display_4,display_3,display_2,display_1,display_0 : std_logic_vector(6 downto 0);

signal enableA,enableB :std_logic;
signal en_controlador, en_controlador_next : std_logic;


signal d4,d3,d2,d1,d0 : std_logic_vector (3 downto 0);
signal enable_HEXB, enable_HEXB_next: std_logic; 


begin

tec_calc:  teclado_calc port map(clock_50, reset_n,fila,valor,columna,z);

--hexa_tecl: hexa port map (valor,display5);

fsm_calcu: fsm_calc port map(reset_n, z, clock_50, valor, A_reg, Op_reg, B_reg, req_fsm_calc, ack_fsm_calc,enableA,enableB);
en_reg_des_A <= enableA;
en_reg_des_B <= enableB;

enganche_display_B: ffd port map (reset_n,clock_50,'1','1',enable_HEXB_next,enable_HEXB);
enable_HEXB_next <= '1' when (enableB = '1') else
					     enable_HEXB;

reg_desp_A : reg_des port map(reset_n,clock_50,A_reg,en_reg_des_A,a4,a3,a2,a1,a0);
reg_desp_B : reg_des port map(reset_n,clock_50,B_reg,en_reg_des_B,b4,b3,b2,b1,b0);

bcd_A			: bcd_binary port map(a0,a1,a2,a3,a4,a_in);
bcd_B			: bcd_binary port map(b0,b1,b2,b3,b4,b_in);

controlador : controlador_op port map(reset_n,clock_50,req_fsm_calc,ack_add_sub,result_add_sub,ack_mult,result_mult,ack_div,result_div,Op_reg,control_add_sub,req_add_sub,req_mult,req_div,result_bin,ack_fsm_calc);

enganche: ffd port map (reset_n,clock_50,'1','1',en_controlador_next,en_controlador);
en_controlador_next <= '1' when (ack_fsm_calc = '1') else
							  en_controlador;

multiplicacion : multiplicador port map(clock_50,reset_n,req_mult,a_in,b_in,result_mult,sobrepaso_mul_enganche,ack_mult);
add_sub : cir_add_sub port map(clock_50,reset_n,req_add_sub,control_add_sub,a_in,b_in,result_add_sub,sobrepaso_add_enganche,negativo_enganche,ack_add_sub);
divisor : divider generic map(width => 17) port map(clock_50,reset_n,req_div,a_in,b_in,ack_div,result_div,residuo);
bintobcd: bin_bcd port map(clock_50,reset_n, result_bin, diezmil,mil,centena,decena,unidad,en_controlador);

---------
d4 <= a4 when (en_controlador = '0') and (enable_HEXB = '0') else
		b4 when (en_controlador = '0') and (enable_HEXB = '1') else
		diezmil;
		
d3 <= a3 when (en_controlador = '0') and (enable_HEXB = '0') else
		b3 when (en_controlador = '0') and (enable_HEXB = '1') else
		mil;
		
d2 <= a2 when (en_controlador = '0') and (enable_HEXB = '0') else
		b2 when (en_controlador = '0') and (enable_HEXB = '1') else
		centena;
		
d1 <= a1 when (en_controlador = '0') and (enable_HEXB = '0') else
		b1 when (en_controlador = '0') and (enable_HEXB = '1') else
		decena;
		
d0 <= a0 when (en_controlador = '0') and (enable_HEXB = '0') else
		b0 when (en_controlador = '0') and (enable_HEXB = '1') else
		unidad;
------------

display_4s : hexa port map (d4, display_4);
display_3s : hexa port map (d3, display_3);
display_2s : hexa port map (d2, display_2);
display_1s : hexa port map (d1, display_1);
display_0s : hexa port map (d0, display_0);


display4 <= display_4 when (sobrepaso_mul or sobrepaso_add) ='0' else "0101011";
display3 <= display_3 when (sobrepaso_mul or sobrepaso_add) ='0' else "0101011";
display2 <= display_2 when (sobrepaso_mul or sobrepaso_add) ='0' else "0101011";
display1 <= display_1 when (sobrepaso_mul or sobrepaso_add) ='0' else "0101011";
display0 <= display_0 when (sobrepaso_mul or sobrepaso_add) ='0' else "0101011";

display5 <= "1111111" when negativo='0' else "0111111" ;

-------enganche negativo---

enganche_n: ffd port map (reset_n,clock_50,'1','1',negativo_next,negativo);
negativo_next <= '1' when (negativo_enganche = '1') else
					  negativo;
--- enganche sobrepaso---
enganche_mult: ffd port map (reset_n,clock_50,'1','1',sobrepaso_mul_next,sobrepaso_mul);
sobrepaso_mul_next <= '1' when (sobrepaso_mul_enganche = '1') else
					  sobrepaso_mul;
enganche_add: ffd port map (reset_n,clock_50,'1','1',sobrepaso_add_next,sobrepaso_add);
sobrepaso_add_next <= '1' when (sobrepaso_add_enganche = '1') else
					  sobrepaso_add;


-------------VGA-----------


Pantalla: vga_calc port map (clock_50, reset_n,sobrepaso_add, sobrepaso_mul, negativo, d4,d3,d2,d1,d0, VGA_HS, VGA_VS, VGA_R, VGA_G, VGA_B);


end arch;



-----SOLO PUEDE RESTAR, SI Y SOLO SI, LA SUMA DEL MINUENDO Y SUTRAENDO ES 131071, ESTE NUMERO OCUPA LOS 17 BITS





