-- Copyright (C) 1991-2015 Altera Corporation. All rights reserved.
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, the Altera Quartus Prime License Agreement,
-- the Altera MegaCore Function License Agreement, or other 
-- applicable license agreement, including, without limitation, 
-- that your use is for the sole purpose of programming logic 
-- devices manufactured by Altera and sold by Altera or its 
-- authorized distributors.  Please refer to the applicable 
-- agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "12/01/2018 20:47:16"
                                                            
-- Vhdl Test Bench template for design  :  calculadora
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY calculadora_vhd_tst IS
END calculadora_vhd_tst;
ARCHITECTURE calculadora_arch OF calculadora_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL clock_50 : STD_LOGIC:= '0';
SIGNAL columna : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL display0 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL display1 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL display2 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL display3 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL display4 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL display5 : STD_LOGIC_VECTOR(6 DOWNTO 0);
SIGNAL fila : STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL reset_n : STD_LOGIC;
COMPONENT calculadora
	PORT (
	clock_50 : IN STD_LOGIC;
	columna : BUFFER STD_LOGIC_VECTOR(3 DOWNTO 0);
	display0 : BUFFER STD_LOGIC_VECTOR(6 DOWNTO 0);
	display1 : BUFFER STD_LOGIC_VECTOR(6 DOWNTO 0);
	display2 : BUFFER STD_LOGIC_VECTOR(6 DOWNTO 0);
	display3 : BUFFER STD_LOGIC_VECTOR(6 DOWNTO 0);
	display4 : BUFFER STD_LOGIC_VECTOR(6 DOWNTO 0);
	display5 : BUFFER STD_LOGIC_VECTOR(6 DOWNTO 0);
	fila : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
	reset_n : IN STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : calculadora
	PORT MAP (
-- list connections between master ports and signals
	clock_50 => clock_50,
	columna => columna,
	display0 => display0,
	display1 => display1,
	display2 => display2,
	display3 => display3,
	display4 => display4,
	display5 => display5,
	fila => fila,
	reset_n => reset_n
	);
init : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
        -- code that executes only once                      
WAIT;                                                       
END PROCESS init;           

	clock_50 <= not (clock_50) after 10ns;   
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN                                                         
        -- code executes for every event on sensitivity list  
	reset_n <= '0';
	wait for 30 ns;
	reset_n <= '1';
	fila <= "1111";
	wait for 1020ns;
	fila <= "1101";--9
	wait for 1000 ns;
	fila <= "1111";
	wait for 3000 ns;
--	fila <= "1101";--9
	wait for 1000 ns;
	fila <= "1111";
	wait for 2000 ns;
	
	fila <= "0111";--+
	wait for 1000 ns;
	fila <= "1111";
	wait for 3000 ns;
--	fila <= "0111";--+
	wait for 1000 ns;
	fila <= "1111";
	wait for 2000 ns;
	fila <= "1011"; --4
	wait for 1000 ns;
	fila <= "1111";
	wait for 3000 ns;
--	fila <= "1011"; --4
	wait for 1000 ns;
	fila <= "1111";
	wait for 1000 ns;
	fila <= "1110"; --=
	wait for 1000 ns;
	fila <= "1111";
	
	
WAIT;                                                        
END PROCESS always;                                          
END calculadora_arch;
