// *********************************************************************************
// Project Name : OSXXXX
// Author       : dengkanwen
// Email        : dengkanwen@163.com
// Website      : http://www.opensoc.cn/
// Create Time  : 2017/4/12 22:18:11
// File Name    : .v
// Module Name  : 
// Called By    :
// Abstract     :
//
// CopyRight(c) 2016, OpenSoc Studio.. 
// All Rights Reserved
//
// *********************************************************************************
// Modification History:
// Date         By              Version                 Change Description
// -----------------------------------------------------------------------
// 2017/4/12    Kevin           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns

module  top(
        // system signals
        input                   sclk                    ,       
        input                   s_rst_n                 ,       
        // VGA
        output  wire            vga_hsync               ,       
        output  wire            vga_vsync               ,       
        output  wire    [15:0]  vga_rgb
);

//========================================================================\
// =========== Define Parameter and Internal signals =========== 
//========================================================================/
wire                            clk_sys40m                      ;       


//=============================================================================
//**************    Main Code   **************
//=============================================================================
vga_drive       vga_drive_inst(
        // system signals
        .sclk                   (clk_sys40m             ),
        .s_rst_n                (s_rst_n                ),
        // VGA
        .vga_hsync              (vga_hsync              ),
        .vga_vsync              (vga_vsync              ),
        .vga_rgb                (vga_rgb                )
);

sdram_top       sdram_top_inst(
        // system signals
        input                   sclk                    ,       //      100MHz
        input                   s_rst_n                 ,
        // SDRAM Interfaces
        output  wire            sdram_clk               ,
        output  wire            sdram_cke               ,
        output  wire            sdram_cs_n              ,
        output  wire            sdram_cas_n             ,
        output  wire            sdram_ras_n             ,
        output  wire            sdram_we_n              ,
        output  wire    [ 1:0]  sdram_bank              ,
        output  reg     [12:0]  sdram_addr              ,
        output  wire    [ 1:0]  sdram_dqm               ,
        inout           [15:0]  sdram_dq                ,
        // FIFO Signals
        input                   wfifo_wclk              ,
        input                   wfifo_wr_en             ,
        input           [15:0]  wfifo_wr_data           ,
        output  wire    [ 7:0]  rfifo_wr_data           ,
        output  wire            rfifo_wr_en             
);

/* clk_wiz_v3_6    clk_wiz_v3_6_inst(
        // Clock in ports
        .CLK_IN1                (sclk                   ),      // IN
        // Clock out ports
        .CLK_OUT1               (clk_sys40m             ),     // OUT
        // Status and control signals
        .RESET                  (1'b0                   ),// IN
        .LOCKED                 (                       )// OUT
); */

endmodule
