module  sdram_top(
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
        // User Signals
        input                   wfifo_wclk              ,
        input                   wfifo_wr_en             ,
        input           [15:0]  wfifo_wr_data           ,

        input                   rfifo_rclk              ,
        input                   rfifo_rd_en             ,
        output  wire    [15:0]  rfifo_rd_data           ,
        output  wire            rfifo_rd_ready
);

//===================================================================\
// ********* Define Parameter and Internal Signals *********
//===================================================================/
localparam      IDLE            =       5'b0_0001               ;
localparam      ARBIT           =       5'b0_0010               ;
localparam      AREF            =       5'b0_0100               ;
localparam      WRITE           =       5'b0_1000               ;
localparam      READ            =       5'b1_0000               ;


wire                            wfifo_rd_en                     ;
wire    [15:0]                  wfifo_rd_data                   ;
wire    [15:0]                  rfifo_wr_data                   ;
wire                            rfifo_wr_en                     ;           

reg     [ 3:0]                  sd_cmd                          ;
wire                            wr_trig                         ;       
wire                            rd_trig                         ;       
//init module
wire                            flag_init_end                   ;
wire    [ 3:0]                  init_cmd                        ;
wire    [12:0]                  init_addr                       ;
// 
reg     [ 4:0]                  state                           ;

// refresh module
wire                            ref_req                         ;
wire                            flag_ref_end                    ;
reg                             ref_en                          ;        
wire    [ 3:0]                  ref_cmd                         ;
wire    [12:0]                  ref_addr                        ;     

// write module
 reg                            wr_en                           ;   
 wire                           wr_req                          ;
 wire                           flag_wr_end                     ;
 wire   [ 3:0]                  wr_cmd                          ;
 wire   [12:0]                  wr_addr                         ;
 wire   [ 1:0]                  wr_bank_addr                    ;
 wire   [15:0]                  wr_data                         ;

// read module
reg                             rd_en                           ;     
wire                            rd_req                          ;
wire                            flag_rd_end                     ;  
wire    [ 3:0]                  rd_cmd                          ;    
wire    [12:0]                  rd_addr                         ;    
wire    [ 1:0]                  rd_bank_addr                    ;    
 
//==========================================================================
// ****************     Main    Code    **************
//==========================================================================
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                state   <=      IDLE;
        else case(state)
                IDLE:
                        if(flag_init_end == 1'b1)
                                state   <=      ARBIT;
                        else
                                state   <=      IDLE;
                ARBIT:
                        if(ref_en == 1'b1)
                                state   <=      AREF;
                        else if(wr_en == 1'b1)
                                state   <=      WRITE;
                        else if(rd_en == 1'b1)
                                state   <=      READ;
                        else
                                state   <=      ARBIT;
                AREF:
                        if(flag_ref_end == 1'b1)
                                state   <=      ARBIT;
                        else
                                state   <=      AREF; 
                WRITE:
                        if(flag_wr_end == 1'b1)
                                state   <=      ARBIT;
                        else
                                state   <=      WRITE;
                READ:
                        if(flag_rd_end == 1'b1)
                                state   <=      ARBIT;
                        else
                                state   <=      READ;
                default:
                        state   <=      IDLE;
        endcase
end

// ref_en
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                ref_en  <=      1'b0;
        else if(state == ARBIT && ref_req == 1'b1)
                ref_en  <=      1'b1;
        else
                ref_en  <=      1'b0;
end

// wr_en
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                wr_en   <=      1'b0;
        else if(state == ARBIT && ref_req == 1'b0 && wr_req == 1'b1)
                wr_en   <=      1'b1;
        else
                wr_en   <=      1'b0;
end

// rd_en
always  @(posedge sclk or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
                rd_en   <=      1'b0;
        else if(state == ARBIT && ref_req == 1'b0 && wr_req == 1'b0 && rd_req == 1'b1)
                rd_en   <=      1'b1;
        else 
                rd_en   <=      1'b0;        
end


always  @(*) begin
        case(state) 
                IDLE: begin
                        sd_cmd          <=      init_cmd;
                        sdram_addr      <=      init_addr;
                end
                AREF: begin
                        sd_cmd          <=      ref_cmd;
                        sdram_addr      <=      ref_addr;
                end
                WRITE: begin
                        sd_cmd          <=      wr_cmd;
                        sdram_addr      <=      wr_addr;
                end
                READ: begin
                        sd_cmd          <=      rd_cmd;
                        sdram_addr      <=      rd_addr;
                end
                default: begin
                        sd_cmd          <=      4'b0111;        // NOP Command
                        sdram_addr      <=      'd0;
                end
        endcase
end
assign  sdram_cke       =       1'b1;
//assign  sdram_addr      =       (state == IDLE) ? init_addr : ref_addr;
//assign  {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n}      =       (state == IDLE) ? init_cmd : ref_cmd;
assign  {sdram_cs_n, sdram_ras_n, sdram_cas_n, sdram_we_n}      =       sd_cmd;
assign  sdram_dqm       =       2'b00;
assign  sdram_clk       =       ~sclk;
assign  sdram_dq        =       (state == WRITE) ? wr_data : {16{1'bz}};
assign  sdram_bank      =       (state == WRITE) ? wr_bank_addr : rd_bank_addr;

sdram_init      sdram_init_inst(
        // system signals
        .sclk                    (sclk                  ),
        .s_rst_n                 (s_rst_n               ),
        // others                
        .cmd_reg                 (init_cmd              ),
        .sdram_addr              (init_addr             ),
        .flag_init_end           (flag_init_end         )
);

sdram_aref      sdram_aref_inst(
        // system signals
        .sclk                    (sclk                  ),
        .s_rst_n                 (s_rst_n               ),
        // communicate with ARBIT
        .ref_en                  (ref_en                ),
        .ref_req                 (ref_req               ),
        .flag_ref_end            (flag_ref_end          ),
        // others                
        .aref_cmd                (ref_cmd               ),
        .sdram_addr              (ref_addr              ),
        .flag_init_end           (flag_init_end         )
);

sdram_write     sdram_write_inst(
        // system signals
        .sclk                    (sclk                  ),
        .s_rst_n                 (s_rst_n               ),
        // Communicate with TOP  
        .wr_en                   (wr_en                 ),
        .wr_req                  (wr_req                ),
        .flag_wr_end             (flag_wr_end           ),
        // Others                
        .ref_req                 (ref_req               ),
        .wr_trig                 (wr_trig               ),
        // write interfaces      
        .wr_cmd                  (wr_cmd                ),
        .wr_addr                 (wr_addr               ),
        .bank_addr               (wr_bank_addr          ),
        .wr_data                 (wr_data               ),
        // WFIFO Interfaces
        .wfifo_rd_en             (wfifo_rd_en           ),
        .wfifo_rd_data           (wfifo_rd_data         )
);

sdram_read      sdram_read_inst(
        // system signals
        .sclk                    (sclk                  ),
        .s_rst_n                 (s_rst_n               ),
        // Communicate with TOP
        .rd_en                   (rd_en                 ),
        .rd_req                  (rd_req                ),
        .flag_rd_end             (flag_rd_end           ),
        // Others
        .ref_req                 (ref_req               ),
        .rd_trig                 (rd_trig               ),
        .sdram_dq                (sdram_dq              ),
        // write interfaces      
        .rd_cmd                  (rd_cmd                ),
        .rd_addr                 (rd_addr               ),
        .bank_addr               (rd_bank_addr          ),
        // RFIFO
        .rfifo_wr_en             (rfifo_wr_en           ),
        .rfifo_wr_data           (rfifo_wr_data         )
);

auto_write_read auto_write_read_inst(
        // system signals
        .s_rst_n                (s_rst_n                ),
        // wfifo
        .wfifo_wclk             (wfifo_wclk             ),
        .wfifo_wr_en            (wfifo_wr_en            ),
        .wfifo_wr_data          (wfifo_wr_data          ),
        .wfifo_rclk             (sclk                   ),
        .wfifo_rd_en            (wfifo_rd_en            ),
        .wfifo_rd_data          (wfifo_rd_data          ),
        .wr_trig                (wr_trig                ),
        // rfifo
        .rfifo_wclk             (sclk                   ),       // 100MHz
        .rfifo_wr_en            (rfifo_wr_en            ),       
        .rfifo_wr_data          (rfifo_wr_data          ),
        .rfifo_rclk             (rfifo_rclk             ),
        .rfifo_rd_en            (rfifo_rd_en            ),       
        .rfifo_rd_data          (rfifo_rd_data          ),
        .rd_trig                (rd_trig                ),
        .rfifo_rd_ready         (rfifo_rd_ready         )
);

endmodule
