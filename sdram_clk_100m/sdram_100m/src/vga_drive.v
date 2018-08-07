// *********************************************************************************
// Project Name : OSXXXX
// Author       : dengkanwen
// Email        : dengkanwen@163.com
// Website      : http://www.opensoc.cn/
// Create Time  : 2017/4/12 21:52:17
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

module  vga_drive(
        // system signals
        input                   sclk                    ,       
        input                   s_rst_n                 ,       
        // VGA
        output  wire            vga_hsync               ,       
        output  wire            vga_vsync               ,       
        output  reg     [15:0]  vga_rgb
);

//========================================================================\
// =========== Define Parameter and Internal signals =========== 
//========================================================================/
localparam      H_TOTAL_TIME    =       1056                    ;
localparam      H_ADDR_TIME     =       800                     ;
localparam      H_SYNC_TIME     =       128                     ;
localparam      H_BACK_PORCH    =       88                      ;

localparam      V_TOTAL_TIME    =       628                     ;
localparam      V_ADDR_TIME     =       600                     ;
localparam      V_SYNC_TIME     =       4                       ;
localparam      V_BACK_PORCH    =       23                      ;

reg     [10:0]                  cnt_h                           ;       
reg     [ 9:0]                  cnt_v                           ;       

//=============================================================================
//**************    Main Code   **************
//=============================================================================
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                cnt_h   <=      'd0;
        else if(cnt_h >= H_TOTAL_TIME)
                cnt_h   <=      'd0;
        else
                cnt_h   <=      cnt_h + 1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                cnt_v   <=      'd0;
        else if(cnt_v >= V_TOTAL_TIME && cnt_h >= H_TOTAL_TIME)
                cnt_v   <=      'd0;
        else if(cnt_h >= H_TOTAL_TIME)
                cnt_v   <=      cnt_v + 1'b1;
end

always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                vga_rgb <=      'd0;
        else if(cnt_v >= (V_SYNC_TIME + V_BACK_PORCH) && cnt_v < (V_SYNC_TIME + V_BACK_PORCH + V_ADDR_TIME)) begin
                if(cnt_h >= (H_SYNC_TIME + H_BACK_PORCH - 1) && cnt_h < (H_SYNC_TIME + H_BACK_PORCH - 1 + 200))
                        vga_rgb <=      16'h0fff;
                else if(cnt_h >= (H_SYNC_TIME + H_BACK_PORCH - 1 + 200) && cnt_h < (H_SYNC_TIME + H_BACK_PORCH - 1 + 400))
                        vga_rgb <=      16'hf0ff;
                else if(cnt_h >= (H_SYNC_TIME + H_BACK_PORCH - 1 + 400) && cnt_h < (H_SYNC_TIME + H_BACK_PORCH - 1 + 600))
                        vga_rgb <=      16'hff0f;
                else if(cnt_h >= (H_SYNC_TIME + H_BACK_PORCH - 1 + 600) && cnt_h < (H_SYNC_TIME + H_BACK_PORCH - 1 + H_ADDR_TIME))
                        vga_rgb <=      16'hfff0;
                else
                        vga_rgb <=      16'h0000;
        end
        else
                vga_rgb <=      16'h000;
end

assign  vga_hsync       =       (cnt_h < H_SYNC_TIME) ? 1'b1 : 1'b0;
assign  vga_vsync       =       (cnt_v < V_SYNC_TIME) ? 1'b1 : 1'b0;

endmodule



