`include "sd_defines.v"
module sd_controller_wb(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=sdc/sd_controller_wb/sd_controller_wb.v:grp:port_section:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=3-36
         wb_clk_i, wb_rst_i, wb_dat_i, wb_dat_o,

         // WISHBONE slave
         wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, wb_stb_i, wb_ack_o,

         // WISHBONE master


         we_m_tx_bd, new_cmd,
         we_m_rx_bd,
         we_ack, int_ack, cmd_int_busy,
         Bd_isr_reset,
         normal_isr_reset,
         error_isr_reset,
         int_busy,
         dat_in_m_tx_bd,
         dat_in_m_rx_bd,
         write_req_s,
         cmd_set_s,
         cmd_arg_s,
         argument_reg,
         cmd_setting_reg,
         status_reg,
         cmd_resp_1,
         software_reset_reg,
         time_out_reg,
         normal_int_status_reg,
         error_int_status_reg,
         normal_int_signal_enable_reg,
         error_int_signal_enable_reg,
         clock_divider,
         Bd_Status_reg,
         Bd_isr_reg,
         Bd_isr_enable_reg
//__RB_CUT_GROUP_END__ type=port_section id=sdc/sd_controller_wb/sd_controller_wb.v:grp:port_section:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=3-36
       );

// WISHBONE common
input           wb_clk_i;     // WISHBONE clock
input           wb_rst_i;     // WISHBONE reset
input   [31:0]  wb_dat_i;     // WISHBONE data input
output reg [31:0]  wb_dat_o;     // WISHBONE data output
// WISHBONE error output

// WISHBONE slave
input   [7:0]  wb_adr_i;     // WISHBONE address input
input    [3:0]  wb_sel_i;     // WISHBONE byte select input
input           wb_we_i;      // WISHBONE write enable input
input           wb_cyc_i;     // WISHBONE cycle input
input           wb_stb_i;     // WISHBONE strobe input

output reg         wb_ack_o;     // WISHBONE acknowledge output



output reg we_m_tx_bd;
output reg we_m_rx_bd; //Write enable Master side Rx_bd

output reg new_cmd;
output reg we_ack; //CMD acces granted
output reg int_ack; //Internal Delayed Ack;
output reg cmd_int_busy;


//Read enable Master side Rx_bd
output reg int_busy;
input write_req_s;
input wire [15:0] cmd_set_s;
input wire [31:0] cmd_arg_s;


//
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=sdc/sd_controller_wb/sd_controller_wb.v:grp:param_decl:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=74-119
`define SUPPLY_VOLTAGE_3_3
`define SD_CARD_2_0

//Register Addreses
`define argument 8'h00
`define command 8'h04
`define status 8'h08
`define resp1 8'h0c
`define controller 8'h1c
`define block 8'h20
`define power 8'h24
`define software 8'h28
`define timeout 8'h2c
`define normal_isr 8'h30
`define error_isr 8'h34
`define normal_iser 8'h38
`define error_iser 8'h3c
`define capa 8'h48
`define clock_d 8'h4c
`define bd_status 8'h50
`define bd_isr 8'h54
`define bd_iser 8'h58
`define bd_rx 8'h60
`define bd_tx 8'h80



//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=101-108
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001:br:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=101-103
`ifdef SUPPLY_VOLTAGE_3_3
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=101-108
//__RB_CUT_BODY__ type=pp_ifdef_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001:br:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=101-103

parameter power_controll_reg  = 8'b0000_111_1;
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001:br:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=101-103
//__RB_CUT_END__ type=pp_ifdef_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001:br:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=101-103
//__RB_CUT_BEGIN__ type=pp_elsif_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001:br:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=104-105
`elsif SUPPLY_VOLTAGE_3_0
//__RB_CUT_BODY__ type=pp_elsif_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001:br:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=104-105
       parameter power_controll_reg  = 8'b0000_110_1;
//__RB_CUT_TAIL__ type=pp_elsif_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001:br:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=104-105
//__RB_CUT_END__ type=pp_elsif_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001:br:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=104-105
//__RB_CUT_BEGIN__ type=pp_elsif_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001:br:000003 file=sdc/sd_controller_wb/sd_controller_wb.v lines=106-107
`elsif SUPPLY_VOLTAGE_1_8
//__RB_CUT_BODY__ type=pp_elsif_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001:br:000003 file=sdc/sd_controller_wb/sd_controller_wb.v lines=106-107
       parameter power_controll_reg  = 8'b0000_101_1;
//__RB_CUT_TAIL__ type=pp_elsif_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001:br:000003 file=sdc/sd_controller_wb/sd_controller_wb.v lines=106-107
//__RB_CUT_END__ type=pp_elsif_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001:br:000003 file=sdc/sd_controller_wb/sd_controller_wb.v lines=106-107
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=101-108
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=101-108

parameter block_size_reg = `BLOCK_SIZE ; //512-Bytes

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=112-117
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000002:br:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=112-114
`ifdef SD_BUS_WIDTH_4
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=112-117
//__RB_CUT_BODY__ type=pp_ifdef_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000002:br:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=112-114

parameter controll_setting_reg =16'b0000_0000_0000_0010;
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000002:br:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=112-114
//__RB_CUT_END__ type=pp_ifdef_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000002:br:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=112-114
//__RB_CUT_BEGIN__ type=pp_else_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000002:br:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=115-116
`else
//__RB_CUT_BODY__ type=pp_else_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000002:br:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=115-116
parameter controll_setting_reg =16'b0000_0000_0000_0000;
//__RB_CUT_TAIL__ type=pp_else_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000002:br:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=115-116
//__RB_CUT_END__ type=pp_else_branch id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000002:br:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=115-116
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=112-117
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=112-117

parameter capabilies_reg =16'b0000_0000_0000_0000;
//__RB_CUT_GROUP_END__ type=param_decl id=sdc/sd_controller_wb/sd_controller_wb.v:grp:param_decl:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=74-119

//Buss accessible registers
output reg [31:0] argument_reg;
output reg [15:0] cmd_setting_reg;
input  wire [15:0] status_reg;
input wire [31:0] cmd_resp_1;
output reg [7:0] software_reset_reg;
output reg [15:0] time_out_reg;
input wire [15:0]normal_int_status_reg;
input wire [15:0]error_int_status_reg;
output reg [15:0]normal_int_signal_enable_reg;
output reg [15:0]error_int_signal_enable_reg;
output reg [7:0] clock_divider;
input  wire [15:0] Bd_Status_reg;
input  wire [7:0] Bd_isr_reg;
output reg [7:0] Bd_isr_enable_reg;

//Register Controll
output reg Bd_isr_reset;
output reg normal_isr_reset;
output reg error_isr_reset;
output reg [`RAM_MEM_WIDTH-1:0] dat_in_m_rx_bd; //Data in to Rx_bd from Master
output reg [`RAM_MEM_WIDTH-1:0] dat_in_m_tx_bd;


//internal reg
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_controller_wb/sd_controller_wb.v:grp:internal_signal:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=146-146
reg [1:0] we;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_controller_wb/sd_controller_wb.v:grp:internal_signal:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=146-146


//__RB_CUT_BEGIN__ type=always id=sdc/sd_controller_wb/sd_controller_wb.v:proc:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=149-309
always @(posedge wb_clk_i or posedge wb_rst_i)
//__RB_CUT_BODY__ type=always id=sdc/sd_controller_wb/sd_controller_wb.v:proc:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=149-309
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000016 file=sdc/sd_controller_wb/sd_controller_wb.v lines=150-309
  begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000016 file=sdc/sd_controller_wb/sd_controller_wb.v lines=150-309
    we_m_rx_bd <= 0;
    we_m_tx_bd <= 0;
    new_cmd<= 1'b0 ;
    we_ack <= 0;
    int_ack =  1;
    cmd_int_busy<=0;
    if ( wb_rst_i )
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=158-178
      begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=158-178
        argument_reg <=0;
        cmd_setting_reg <= 0;
        software_reset_reg <= 0;
        time_out_reg <= 0;
        normal_int_signal_enable_reg <= 0;
        error_int_signal_enable_reg <= 0;
        clock_divider <=`RESET_CLK_DIV;
        int_ack=1 ;
        we<=0;
        int_busy <=0;
        we_ack <=0;
        wb_ack_o=0;
        cmd_int_busy<=0;
        Bd_isr_reset<=0;
        dat_in_m_tx_bd<=0;
        dat_in_m_rx_bd<=0;
        Bd_isr_enable_reg<=0;
        normal_isr_reset<=0;
        error_isr_reset<=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=158-178
      end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=158-178
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000015 file=sdc/sd_controller_wb/sd_controller_wb.v lines=179-307
    else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000015 file=sdc/sd_controller_wb/sd_controller_wb.v lines=179-307
    if ((wb_stb_i  & wb_cyc_i) || wb_ack_o )
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000013 file=sdc/sd_controller_wb/sd_controller_wb.v lines=181-295
      begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000013 file=sdc/sd_controller_wb/sd_controller_wb.v lines=181-295
        Bd_isr_reset<=0;
        normal_isr_reset<=  0;
        error_isr_reset<=  0;
        if (wb_we_i)
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000012 file=sdc/sd_controller_wb/sd_controller_wb.v lines=186-293
          begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000012 file=sdc/sd_controller_wb/sd_controller_wb.v lines=186-293
//__RB_CUT_BEGIN__ type=case id=sdc/sd_controller_wb/sd_controller_wb.v:case:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=187-292
            case (wb_adr_i)
              `argument:
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=189-192
                begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=189-192
                  argument_reg  <=  wb_dat_i;
                  new_cmd <=  1'b1 ;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=189-192
                end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=189-192
              `command :
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000003 file=sdc/sd_controller_wb/sd_controller_wb.v lines=194-197
                begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000003 file=sdc/sd_controller_wb/sd_controller_wb.v lines=194-197
                  cmd_setting_reg  <=  wb_dat_i;
                  int_busy <= 1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000003 file=sdc/sd_controller_wb/sd_controller_wb.v lines=194-197
                end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000003 file=sdc/sd_controller_wb/sd_controller_wb.v lines=194-197
              `software :
                software_reset_reg <=  wb_dat_i;
              `timeout :
                time_out_reg  <=  wb_dat_i;
              `normal_iser :
                normal_int_signal_enable_reg <=  wb_dat_i;
              `error_iser :
                error_int_signal_enable_reg  <=  wb_dat_i;
              `normal_isr :
                normal_isr_reset<=  1;
              `error_isr:
                error_isr_reset<=  1;
              `clock_d:
                clock_divider  <=  wb_dat_i;
              `bd_isr:
                Bd_isr_reset<=  1;
              `bd_iser :
                Bd_isr_enable_reg <= wb_dat_i ;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000003 file=sdc/sd_controller_wb/sd_controller_wb.v lines=216-251
          `ifdef RAM_MEM_WIDTH_32
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000003 file=sdc/sd_controller_wb/sd_controller_wb.v lines=216-251

              `bd_rx:
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000005 file=sdc/sd_controller_wb/sd_controller_wb.v lines=219-234
                begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000005 file=sdc/sd_controller_wb/sd_controller_wb.v lines=219-234
                  we <= we+1;
                  we_m_rx_bd <= 1;
                  int_ack =  0;
                  if  (we[1:0]==2'b00)
                    we_m_rx_bd <= 0;
                  else if  (we[1:0]==2'b01)
                    dat_in_m_rx_bd <=  wb_dat_i;
                  else
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000004 file=sdc/sd_controller_wb/sd_controller_wb.v lines=228-232
                    begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000004 file=sdc/sd_controller_wb/sd_controller_wb.v lines=228-232
                      int_ack =  1;
                      we<= 0;
                      we_m_rx_bd <= 0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000004 file=sdc/sd_controller_wb/sd_controller_wb.v lines=228-232
                    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000004 file=sdc/sd_controller_wb/sd_controller_wb.v lines=228-232

//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000005 file=sdc/sd_controller_wb/sd_controller_wb.v lines=219-234
                end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000005 file=sdc/sd_controller_wb/sd_controller_wb.v lines=219-234
              `bd_tx:
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000007 file=sdc/sd_controller_wb/sd_controller_wb.v lines=236-250
                begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000007 file=sdc/sd_controller_wb/sd_controller_wb.v lines=236-250
                  we <= we+1;
                  we_m_tx_bd <= 1;
                  int_ack =  0;
                  if  (we[1:0]==2'b00)
                    we_m_tx_bd <= 0;
                  else if  (we[1:0]==2'b01)
                    dat_in_m_tx_bd <=  wb_dat_i;
                  else
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000006 file=sdc/sd_controller_wb/sd_controller_wb.v lines=245-249
                    begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000006 file=sdc/sd_controller_wb/sd_controller_wb.v lines=245-249
                      int_ack =  1;
                      we<= 0;
                      we_m_tx_bd <= 0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000006 file=sdc/sd_controller_wb/sd_controller_wb.v lines=245-249
                    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000006 file=sdc/sd_controller_wb/sd_controller_wb.v lines=245-249
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000007 file=sdc/sd_controller_wb/sd_controller_wb.v lines=236-250
                end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000007 file=sdc/sd_controller_wb/sd_controller_wb.v lines=236-250
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000003 file=sdc/sd_controller_wb/sd_controller_wb.v lines=216-251
          `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000003 file=sdc/sd_controller_wb/sd_controller_wb.v lines=216-251
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000004 file=sdc/sd_controller_wb/sd_controller_wb.v lines=252-290
	        `ifdef RAM_MEM_WIDTH_16
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000004 file=sdc/sd_controller_wb/sd_controller_wb.v lines=252-290
              `bd_rx:
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000009 file=sdc/sd_controller_wb/sd_controller_wb.v lines=254-271
                begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000009 file=sdc/sd_controller_wb/sd_controller_wb.v lines=254-271
                  we <= we+1;
                  we_m_rx_bd <= 1;
                  int_ack =  0;
                  if  (we[1:0]==2'b00)
                    we_m_rx_bd <= 0;
                  else if  (we[1:0]==2'b01)
                    dat_in_m_rx_bd <=  wb_dat_i[15:0];
                  else if ( we[1:0]==2'b10)
                    dat_in_m_rx_bd <=  wb_dat_i[31:16];
                  else
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000008 file=sdc/sd_controller_wb/sd_controller_wb.v lines=265-269
                    begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000008 file=sdc/sd_controller_wb/sd_controller_wb.v lines=265-269
                      int_ack =  1;
                      we<= 0;
                      we_m_rx_bd <= 0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000008 file=sdc/sd_controller_wb/sd_controller_wb.v lines=265-269
                    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000008 file=sdc/sd_controller_wb/sd_controller_wb.v lines=265-269

//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000009 file=sdc/sd_controller_wb/sd_controller_wb.v lines=254-271
                end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000009 file=sdc/sd_controller_wb/sd_controller_wb.v lines=254-271
              `bd_tx:
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000011 file=sdc/sd_controller_wb/sd_controller_wb.v lines=273-289
                begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000011 file=sdc/sd_controller_wb/sd_controller_wb.v lines=273-289
                  we <= we+1;
                  we_m_tx_bd <= 1;
                  int_ack =  0;
                  if  (we[1:0]==2'b00)
                    we_m_tx_bd <= 0;
                  else if  (we[1:0]==2'b01)
                    dat_in_m_tx_bd <=  wb_dat_i[15:0];
                  else if ( we[1:0]==2'b10)
                    dat_in_m_tx_bd <=  wb_dat_i[31:16];
                  else
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000010 file=sdc/sd_controller_wb/sd_controller_wb.v lines=284-288
                    begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000010 file=sdc/sd_controller_wb/sd_controller_wb.v lines=284-288
                      int_ack =  1;
                      we<= 0;
                      we_m_tx_bd <= 0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000010 file=sdc/sd_controller_wb/sd_controller_wb.v lines=284-288
                    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000010 file=sdc/sd_controller_wb/sd_controller_wb.v lines=284-288
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000011 file=sdc/sd_controller_wb/sd_controller_wb.v lines=273-289
                end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000011 file=sdc/sd_controller_wb/sd_controller_wb.v lines=273-289
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000004 file=sdc/sd_controller_wb/sd_controller_wb.v lines=252-290
          `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_controller_wb/sd_controller_wb.v:pp_blk:000004 file=sdc/sd_controller_wb/sd_controller_wb.v lines=252-290

//__RB_CUT_TAIL__ type=case id=sdc/sd_controller_wb/sd_controller_wb.v:case:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=187-292
            endcase
//__RB_CUT_END__ type=case id=sdc/sd_controller_wb/sd_controller_wb.v:case:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=187-292
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000012 file=sdc/sd_controller_wb/sd_controller_wb.v lines=186-293
          end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000012 file=sdc/sd_controller_wb/sd_controller_wb.v lines=186-293
        wb_ack_o =   wb_cyc_i & wb_stb_i & ~wb_ack_o & int_ack;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000013 file=sdc/sd_controller_wb/sd_controller_wb.v lines=181-295
      end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000013 file=sdc/sd_controller_wb/sd_controller_wb.v lines=181-295
    else if (write_req_s)
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000014 file=sdc/sd_controller_wb/sd_controller_wb.v lines=297-303
      begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000014 file=sdc/sd_controller_wb/sd_controller_wb.v lines=297-303
        new_cmd <=  1'b1 ;
        cmd_setting_reg <=   cmd_set_s;
        argument_reg  <=  cmd_arg_s ;
        cmd_int_busy<=  1;
        we_ack <= 1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000014 file=sdc/sd_controller_wb/sd_controller_wb.v lines=297-303
      end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000014 file=sdc/sd_controller_wb/sd_controller_wb.v lines=297-303

    if (status_reg[0])
      int_busy <=  0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000015 file=sdc/sd_controller_wb/sd_controller_wb.v lines=179-307
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000015 file=sdc/sd_controller_wb/sd_controller_wb.v lines=179-307
    //wb_ack_o =   wb_cyc_i & wb_stb_i & ~wb_ack_o & int_ack;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000016 file=sdc/sd_controller_wb/sd_controller_wb.v lines=150-309
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000016 file=sdc/sd_controller_wb/sd_controller_wb.v lines=150-309
//__RB_CUT_TAIL__ type=always id=sdc/sd_controller_wb/sd_controller_wb.v:proc:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=149-309
//__RB_CUT_END__ type=always id=sdc/sd_controller_wb/sd_controller_wb.v:proc:000001 file=sdc/sd_controller_wb/sd_controller_wb.v lines=149-309

//__RB_CUT_BEGIN__ type=always id=sdc/sd_controller_wb/sd_controller_wb.v:proc:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=311-355
always @(posedge wb_clk_i )
//__RB_CUT_BODY__ type=always id=sdc/sd_controller_wb/sd_controller_wb.v:proc:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=311-355
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000018 file=sdc/sd_controller_wb/sd_controller_wb.v lines=312-355
  begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000018 file=sdc/sd_controller_wb/sd_controller_wb.v lines=312-355
    if (wb_stb_i  & wb_cyc_i)
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000017 file=sdc/sd_controller_wb/sd_controller_wb.v lines=314-354
      begin //CS
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000017 file=sdc/sd_controller_wb/sd_controller_wb.v lines=314-354
//__RB_CUT_BEGIN__ type=case id=sdc/sd_controller_wb/sd_controller_wb.v:case:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=315-353
        case (wb_adr_i)
          `argument:
            wb_dat_o  <=   argument_reg ;
          `command :
            wb_dat_o <=  cmd_setting_reg ;
          `status :
            wb_dat_o <=  status_reg ;
          `resp1 :
            wb_dat_o <=  cmd_resp_1 ;

          `controller :
            wb_dat_o <=  controll_setting_reg ;
          `block :
            wb_dat_o <=  block_size_reg ;
          `power :
            wb_dat_o <=  power_controll_reg ;
          `software :
            wb_dat_o  <=  software_reset_reg ;
          `timeout :
            wb_dat_o  <=  time_out_reg ;
          `normal_isr :
            wb_dat_o <=  normal_int_status_reg ;
          `error_isr :
            wb_dat_o  <=  error_int_status_reg ;
          `normal_iser :
            wb_dat_o <=  normal_int_signal_enable_reg ;
          `error_iser :
            wb_dat_o  <=  error_int_signal_enable_reg ;
          `clock_d :
            wb_dat_o  <= clock_divider;
          `capa  :
            wb_dat_o  <=  capabilies_reg ;
          `bd_status :
            wb_dat_o  <=  Bd_Status_reg;
          `bd_isr :
            wb_dat_o  <=  Bd_isr_reg ;
          `bd_iser :
            wb_dat_o  <=  Bd_isr_enable_reg ;
//__RB_CUT_TAIL__ type=case id=sdc/sd_controller_wb/sd_controller_wb.v:case:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=315-353
        endcase
//__RB_CUT_END__ type=case id=sdc/sd_controller_wb/sd_controller_wb.v:case:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=315-353
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000017 file=sdc/sd_controller_wb/sd_controller_wb.v lines=314-354
      end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000017 file=sdc/sd_controller_wb/sd_controller_wb.v lines=314-354
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000018 file=sdc/sd_controller_wb/sd_controller_wb.v lines=312-355
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_controller_wb/sd_controller_wb.v:begin_end:000018 file=sdc/sd_controller_wb/sd_controller_wb.v lines=312-355
//__RB_CUT_TAIL__ type=always id=sdc/sd_controller_wb/sd_controller_wb.v:proc:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=311-355
//__RB_CUT_END__ type=always id=sdc/sd_controller_wb/sd_controller_wb.v:proc:000002 file=sdc/sd_controller_wb/sd_controller_wb.v lines=311-355



endmodule
