`timescale      1ns/1ns

module  tb_sdram_top;

//use IEEE.STD_LOGIC_ARITH.ALL;
//use IEEE.STD_LOGIC_UNSIGNED.ALL;


reg             sclk;
reg             s_rst_n;

//----------------------------------------------------------
wire            sdram_clk;
wire            sdram_cke;
wire            sdram_cs_n;
wire            sdram_cas_n;
wire            sdram_ras_n;
wire            sdram_we_n;
wire    [ 1:0]  sdram_bank;
wire    [12:0]  sdram_addr;
wire    [ 1:0]  sdram_dqm;
wire    [15:0]  sdram_dq;

reg wr_trig;
reg rd_trig;

//------------------------------------------------------- 
//    wfifo
reg                             wfifo_wclk                      ;       
reg                             wfifo_wr_en                     ;       
reg  [15:0]                     wfifo_wr_data                    ;       
//rfifo
reg                             rfifo_rclk                      ;       
reg                             rfifo_rd_en                     ;       
wire [15:0]                     rfifo_rd_data                   ;       
wire                            rfifo_rd_ready                  ;    
//----------------------------------------------------------

initial begin
        sclk    =       1;
        s_rst_n <=      0;
        rd_trig <= 0;
        #100
        s_rst_n <=      1;
        #210000;
    
end

initial begin
   wfifo_wclk = 1;
   wfifo_wr_en = 0;
   #220000;
   wfifo_wr_en = 1;
   #5120;
   wfifo_wr_en = 0;
end

initial begin
   rfifo_rclk = 1;
end


//------------------------------------------------------- 
//    wfifo_wr_data
always  @(posedge wfifo_wclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
            wfifo_wr_data = 'd0;
        else if(wfifo_wr_data >= 255)
            wfifo_wr_data = 'd0;
        else if(wfifo_wr_en == 1'b1)
            wfifo_wr_data = wfifo_wr_data + 1'b1;
end

always @(posedge wfifo_wclk or negedge s_rst_n) begin
    if(s_rst_n == 1'b0)
        rfifo_rd_en <= 'd0;
    else if(rfifo_rd_ready == 1'b1)
        rfifo_rd_en <= 1'b1;
end



always  begin
    #5;     
    sclk    =       ~sclk; //100M
end

always begin
    #10;
    wfifo_wclk = ~wfifo_wclk; //50M
end

always begin
    #10;
    rfifo_rclk = ~rfifo_rclk; //50M
end


defparam        sdram_model_plus_inst.addr_bits =       13;
defparam        sdram_model_plus_inst.data_bits =       16;
defparam        sdram_model_plus_inst.col_bits  =       9;
defparam        sdram_model_plus_inst.mem_sizes =       2*1024*1024;            // 2M






sdram_top	sdram_top_inst(
        // system signals
        .sclk                   (sclk                   ),
        .s_rst_n                (s_rst_n                ),
        // SDRAM Interfaces
        .sdram_clk              (sdram_clk              ),
        .sdram_cke              (sdram_cke              ),
        .sdram_cs_n             (sdram_cs_n             ),
        .sdram_cas_n            (sdram_cas_n            ),
        .sdram_ras_n            (sdram_ras_n            ),
        .sdram_we_n             (sdram_we_n             ),
        .sdram_bank             (sdram_bank             ),
        .sdram_addr             (sdram_addr             ),
        .sdram_dqm              (sdram_dqm              ),
        .sdram_dq               (sdram_dq               ),
    
            // FIFO Signals
        .wfifo_wclk             (wfifo_wclk             ),
        .wfifo_wr_en            (wfifo_wr_en            ),
        .wfifo_wr_data          (wfifo_wr_data          ),

        .rfifo_rclk             (rfifo_rclk          ),
        .rfifo_rd_en            (rfifo_rd_en            ),
        .rfifo_rd_data          (rfifo_rd_data          ),
        .rfifo_rd_ready         (rfifo_rd_ready         )
);


sdram_model_plus sdram_model_plus_inst(
        .Dq                     (sdram_dq               ), 
        .Addr                   (sdram_addr             ), 
        .Ba                     (sdram_bank             ), 
        .Clk                    (sdram_clk              ), 
        .Cke                    (sdram_cke              ), 
        .Cs_n                   (sdram_cs_n             ), 
        .Ras_n                  (sdram_ras_n            ), 
        .Cas_n                  (sdram_cas_n            ), 
        .We_n                   (sdram_we_n             ), 
        .Dqm                    (sdram_dqm              ),
        .Debug                  (1'b1                   )
);


endmodule
