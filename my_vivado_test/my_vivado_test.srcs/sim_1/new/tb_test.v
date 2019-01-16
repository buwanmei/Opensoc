`timescale 100ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: vtf_led_test
//////////////////////////////////////////////////////////////////////////////////
module vtf_led_test;
// Inputs
reg sys_clk_p;
wire sys_clk_n;
reg rst_n;
// Outputs
wire [3:0] led;
// Instantiate the Unit Under Test (UUT)
led_test uut (
.sys_clk_p(sys_clk_p),
.sys_clk_n(sys_clk_n),
.rst_n(rst_n),
.led(led)
);
initial begin
// Initialize Inputs
sys_clk_p = 0;
rst_n = 0;
// Wait 100 ns for global reset to finish
#1000;
rst_n = 1;
// Add stimulus here, stop simulation after 2ms
#20000;
$stop;
end
always #25 sys_clk_p = ~ sys_clk_p; //5ns 一个周期，产生 200MHz 时钟源
assign sys_clk_n=~sys_clk_p;
endmodule