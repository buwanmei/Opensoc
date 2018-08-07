// *********************************************************************************
// Project Name : OSXXXX
// Author       : dengkanwen
// Email        : dengkanwen@163.com
// Website      : http://www.opensoc.cn/
// Create Time  : 2017/4/16 22:42:20
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
// 2017/4/16    Kevin           1.0                     Original
//  
// *********************************************************************************
`timescale      1ns/1ns

module  auto_write_read(
        // system signals
        input                   s_rst_n                 ,       
        // wfifo
        input                   wfifo_wclk              ,
        input                   wfifo_wr_en             ,       
        input           [15:0]  wfifo_wr_data           ,
        input                   wfifo_rclk              ,
        input                   wfifo_rd_en             ,       
        output  wire    [15:0]  wfifo_rd_data           ,
        output  reg             wr_trig
);

//========================================================================\
// =========== Define Parameter and Internal signals =========== 
//========================================================================/
localparam      WFIFO_RD_CNT    =       256                     ;

wire    [ 8:0]                  wfifo_rside_usedw               ;
wire    [ 8:0]                  wfifo_wside_usedw               ;


//=============================================================================
//**************    Main Code   **************
//=============================================================================
always  @(posedge wfifo_rclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                wr_trig <=      1'b0;
        else if(wfifo_rside_usedw >= WFIFO_RD_CNT)
                wr_trig <=      1'b1;
        else
                wr_trig <=      1'b0;
end


wfifo_512x16    wfifo_512x16_inst(
        .rst                    (~s_rst_n               ),      // input rst
        .wr_clk                 (wfifo_wclk             ),      // input wr_clk
        .rd_clk                 (wfifo_rclk             ),      // input rd_clk
        .din                    (wfifo_wr_data          ),      // input [15 : 0] din
        .wr_en                  (wfifo_wr_en            ),      // input wr_en
        .rd_en                  (wfifo_rd_en            ),      // input rd_en
        .dout                   (wfifo_rd_data          ),      // output [15 : 0] dout
        .full                   (                       ),      // output full
        .almost_full            (                       ),      // output almost_full
        .empty                  (                       ),      // output empty
        .almost_empty           (                       ),      // output almost_empty
        .rd_data_count          (wfifo_rside_usedw      ),      // output [8 : 0] rd_data_count
        .wr_data_count          (wfifo_wside_usedw      )       // output [8 : 0] wr_data_count
);


endmodule
