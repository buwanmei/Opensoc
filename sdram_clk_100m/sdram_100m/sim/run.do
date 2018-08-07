##create work library
vlib work


vlog	"../src/*.v"
vlog	"./*.v"


vsim	-voptargs=+acc work.tb_sdram_top

# Set the window types
view wave
view structure
view signals


add wave -divider {tb_sdram_top}
add wave tb_sdram_top/*
add wave -divider {sdram_top}
add wave tb_sdram_top/sdram_top_inst/*
add wave -divider {sdram_write}
add wave tb_sdram_top/sdram_top_inst/sdram_write_inst/*
add wave -divider {sdram_read}
add wave tb_sdram_top/sdram_top_inst/sdram_read_inst/*

.main clear

