transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vcom -93 -work work {C:/temp/Calculadora/operaciones.vhd}
vcom -93 -work work {C:/temp/Calculadora/teclado_calc.vhd}
vcom -93 -work work {C:/temp/Calculadora/fulladder.vhd}
vcom -93 -work work {C:/temp/Calculadora/addsub.vhd}
vcom -93 -work work {C:/temp/Calculadora/fsm_calc.vhd}
vcom -93 -work work {C:/temp/Calculadora/fsm_calc_slave.vhd}
vcom -93 -work work {C:/temp/Calculadora/registro.vhd}
vcom -93 -work work {C:/temp/Calculadora/reg_des.vhd}
vcom -93 -work work {C:/temp/Calculadora/multiplicador.vhd}
vcom -93 -work work {C:/temp/Calculadora/ffd.vhd}
vcom -93 -work work {C:/temp/Calculadora/cir_add_sub.vhd}
vcom -93 -work work {C:/temp/Calculadora/divider.vhd}
vcom -93 -work work {C:/temp/Calculadora/controlador_op.vhd}
vcom -93 -work work {C:/temp/Calculadora/datapath.vhd}
vcom -93 -work work {C:/temp/Calculadora/bin_bcd.vhd}
vcom -93 -work work {C:/temp/Calculadora/hexa.vhd}
vcom -93 -work work {C:/temp/Calculadora/divisor500mil.vhd}
vcom -93 -work work {C:/temp/Calculadora/bcd_binary.vhd}
vcom -93 -work work {C:/temp/Calculadora/calculadora.vhd}

vcom -93 -work work {C:/temp/Calculadora/simulation/modelsim/calculadora.vht}

vsim -t 1ps -L altera -L lpm -L sgate -L altera_mf -L altera_lnsim -L fiftyfivenm -L rtl_work -L work -voptargs="+acc"  calculadora_vhd_tst

add wave *
view structure
view signals
run 200 us
