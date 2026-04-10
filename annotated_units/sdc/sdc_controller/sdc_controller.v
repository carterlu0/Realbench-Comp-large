`include "sd_defines.v"

module sdc_controller(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=sdc/sdc_controller/sdc_controller.v:grp:port_section:000001 file=sdc/sdc_controller/sdc_controller.v lines=4-25
  
  // WISHBONE common
  wb_clk_i, wb_rst_i, wb_dat_i, wb_dat_o, 

  // WISHBONE slave
  wb_adr_i, wb_sel_i, wb_we_i, wb_cyc_i, wb_stb_i, wb_ack_o, 

  // WISHBONE master
  m_wb_adr_o, m_wb_sel_o, m_wb_we_o, 
  m_wb_dat_o, m_wb_dat_i, m_wb_cyc_o, 
  m_wb_stb_o, m_wb_ack_i, 
  m_wb_cti_o, m_wb_bte_o,
  //SD BUS
  
  sd_cmd_dat_i,sd_cmd_out_o,  sd_cmd_oe_o, card_detect,
  sd_dat_dat_i, sd_dat_out_o , sd_dat_oe_o, sd_clk_o_pad
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000001 file=sdc/sdc_controller/sdc_controller.v lines=20-22
  `ifdef SDC_CLK_SEP
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000001 file=sdc/sdc_controller/sdc_controller.v lines=20-22
   ,sd_clk_i_pad
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000001 file=sdc/sdc_controller/sdc_controller.v lines=20-22
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000001 file=sdc/sdc_controller/sdc_controller.v lines=20-22
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000002 file=sdc/sdc_controller/sdc_controller.v lines=23-25
  `ifdef SDC_IRQ_ENABLE
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000002 file=sdc/sdc_controller/sdc_controller.v lines=23-25
   ,int_a, int_b, int_c  
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000002 file=sdc/sdc_controller/sdc_controller.v lines=23-25
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000002 file=sdc/sdc_controller/sdc_controller.v lines=23-25
//__RB_CUT_GROUP_END__ type=port_section id=sdc/sdc_controller/sdc_controller.v:grp:port_section:000001 file=sdc/sdc_controller/sdc_controller.v lines=4-25
);



// WISHBONE common
input           wb_clk_i;     // WISHBONE clock
input           wb_rst_i;     // WISHBONE reset
input   [31:0]  wb_dat_i;     // WISHBONE data input
output  [31:0]  wb_dat_o;     // WISHBONE data output
     // WISHBONE error output
input 			card_detect;
// WISHBONE slave
input   [7:0]  wb_adr_i;     // WISHBONE address input
input   [3:0]  wb_sel_i;     // WISHBONE byte select input
input          wb_we_i;      // WISHBONE write enable input
input          wb_cyc_i;     // WISHBONE cycle input
input          wb_stb_i;     // WISHBONE strobe input

output          wb_ack_o;     // WISHBONE acknowledge output

// WISHBONE master
output  [31:0]  m_wb_adr_o;
output  [3:0]   m_wb_sel_o;
output          m_wb_we_o;

input   [31:0]  m_wb_dat_i;
output  [31:0]  m_wb_dat_o;
output          m_wb_cyc_o;
output          m_wb_stb_o;
input           m_wb_ack_i;
output  [2:0]   m_wb_cti_o;
output	[1:0]	m_wb_bte_o;
//SD port

input  wire [3:0] sd_dat_dat_i;   //Data in from SDcard
output wire [3:0] sd_dat_out_o; //Data out to SDcard
output wire sd_dat_oe_o; //SD Card tristate Data Output enable (Connects on the SoC TopLevel)

input  wire sd_cmd_dat_i; //Command in from SDcard
output wire sd_cmd_out_o; //Command out to SDcard
output wire sd_cmd_oe_o; //SD Card tristate CMD Output enable (Connects on the SoC TopLevel)
output sd_clk_o_pad;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000003 file=sdc/sdc_controller/sdc_controller.v lines=68-70
  `ifdef SDC_CLK_SEP
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000003 file=sdc/sdc_controller/sdc_controller.v lines=68-70
   input wire sd_clk_i_pad;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000003 file=sdc/sdc_controller/sdc_controller.v lines=68-70
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000003 file=sdc/sdc_controller/sdc_controller.v lines=68-70
//IRQ
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000004 file=sdc/sdc_controller/sdc_controller.v lines=72-74
`ifdef SDC_IRQ_ENABLE
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000004 file=sdc/sdc_controller/sdc_controller.v lines=72-74
   output int_a, int_b, int_c ; 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000004 file=sdc/sdc_controller/sdc_controller.v lines=72-74
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000004 file=sdc/sdc_controller/sdc_controller.v lines=72-74
  

// signal definition completion
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sdc_controller/sdc_controller.v:grp:internal_signal:000001 file=sdc/sdc_controller/sdc_controller.v lines=78-174
wire new_cmd;
wire d_write;
wire d_read;
wire error_isr_reset;
wire normal_isr_reset;
wire go_idle;
wire req_out_master;
wire ack_out_master;
wire req_in_host;
wire ack_in_host;
wire rd;
wire we_rx;
wire start_tx_fifo;
wire start_rx_fifo;
wire tx_e;
wire tx_f;
wire full_rx;
wire busy_n;
wire trans_complete;
wire crc_ok;
wire ack_transfer;
wire ack_o_s_tx;
wire ack_o_s_rx;
wire cidat_w;
wire cmd_int_busy;
wire Bd_isr_reset;
wire we_m_tx_bd;
wire we_m_rx_bd;
wire we_ack;
wire int_ack;
wire m_wb_we_o_tx;
wire m_wb_cyc_o_tx;
wire m_wb_stb_o_tx;
wire m_wb_cti_o_tx;
wire m_wb_bte_o_tx;
wire m_wb_we_o_rx;
wire m_wb_cyc_o_rx;
wire m_wb_stb_o_rx;
wire m_wb_cti_o_rx;
wire m_wb_bte_o_rx;
wire m_wb_bte;

wire int_busy;



//Wires from SD_CMD_MASTER Module 
wire [15:0] status_reg_w;
wire [31:0] cmd_resp_1_w;
wire [15:0]normal_int_status_reg_w;
wire [4:0]error_int_status_reg_w; 
 

wire[31:0]  argument_reg;
wire[15:0]  cmd_setting_reg;
reg[15:0]   status_reg;
reg[31:0]   cmd_resp_1;
wire[7:0]   software_reset_reg; 
wire[15:0]  time_out_reg;   
reg[15:0]   normal_int_status_reg; 
reg[15:0]   error_int_status_reg;
wire[15:0]  normal_int_signal_enable_reg;
wire[15:0]  error_int_signal_enable_reg;
wire[7:0]   clock_divider;
reg[15:0]   Bd_Status_reg;   
reg[7:0]    Bd_isr_reg;
wire[7:0]   Bd_isr_enable_reg;

 
//Rx Buffer  Descriptor internal signals



wire [`BD_WIDTH-1 :0] free_bd_rx_bd; //NO free Rx_bd
wire new_rx_bd;  // New Bd writen
wire [`RAM_MEM_WIDTH-1:0] dat_out_s_rx_bd; //Data out from Rx_bd to Slave

//Tx Buffer Descriptor internal signals
wire [`RAM_MEM_WIDTH-1:0] dat_in_m_rx_bd; //Data in to Rx_bd from Master
wire [`RAM_MEM_WIDTH-1:0] dat_in_m_tx_bd;
wire [`BD_WIDTH-1 :0] free_bd_tx_bd;
wire new_tx_bd;
wire [`RAM_MEM_WIDTH-1:0] dat_out_s_tx_bd;
wire [7:0] bd_int_st_w; //Wire to BD status register

//Wires for connecting Bd registers with the SD_Data_master module
wire re_s_tx_bd_w;
wire a_cmp_tx_bd_w;
wire re_s_rx_bd_w;
wire a_cmp_rx_bd_w;
wire write_req_s; //SD_Data_master want acces to the CMD line.
wire cmd_busy; //CMD line busy no access granted

wire [31:0] cmd_arg_s; //SD_Data_master CMD Argument
wire [15:0] cmd_set_s; //SD_Data_master Settings Argument
wire [31:0] sys_adr; //System addres the DMA whil Read/Write to/from
wire [1:0]start_dat_t; //Start data transfer
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sdc_controller/sdc_controller.v:grp:internal_signal:000001 file=sdc/sdc_controller/sdc_controller.v lines=78-174

//Signals to Syncronize busy signaling betwen Wishbone access and SD_Data_master access to the CMD line (Also manage the status reg uppdate)

//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000001 file=sdc/sdc_controller/sdc_controller.v lines=178-178
assign cmd_busy = int_busy | status_reg[0];
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000001 file=sdc/sdc_controller/sdc_controller.v lines=178-178
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sdc_controller/sdc_controller.v:grp:internal_signal:000002 file=sdc/sdc_controller/sdc_controller.v lines=179-196
wire status_reg_busy;


//Wires from SD_DATA_SERIAL_HOST_1 to the FIFO
wire [`SD_BUS_W -1 : 0 ]data_in_rx_fifo;
wire [31: 0 ] data_fout_tx_fifo;
wire [31:0] m_wb_dat_o_rx;
wire [3:0] m_wb_sel_o_tx;
wire [31:0] m_wb_adr_o_tx;
wire [31:0] m_wb_adr_o_rx;

//SD clock 
wire sd_clk_i; //Sd_clk provided to the system
wire sd_clk_o; //Sd_clk used in the system 


//sd_clk_o to be used i set here
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000005 file=sdc/sdc_controller/sdc_controller.v lines=196-198
`ifdef SDC_CLK_BUS_CLK
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sdc_controller/sdc_controller.v:grp:internal_signal:000002 file=sdc/sdc_controller/sdc_controller.v lines=179-196
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000005 file=sdc/sdc_controller/sdc_controller.v lines=196-198
//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000002 file=sdc/sdc_controller/sdc_controller.v lines=197-197
  assign sd_clk_i = wb_clk_i;
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000002 file=sdc/sdc_controller/sdc_controller.v lines=197-197
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000005 file=sdc/sdc_controller/sdc_controller.v lines=196-198
`endif 
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000005 file=sdc/sdc_controller/sdc_controller.v lines=196-198
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000006 file=sdc/sdc_controller/sdc_controller.v lines=199-201
`ifdef SDC_CLK_SEP
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000006 file=sdc/sdc_controller/sdc_controller.v lines=199-201
//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000003 file=sdc/sdc_controller/sdc_controller.v lines=200-200
   assign sd_clk_i = sd_clk_i_pad;
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000003 file=sdc/sdc_controller/sdc_controller.v lines=200-200
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000006 file=sdc/sdc_controller/sdc_controller.v lines=199-201
  `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000006 file=sdc/sdc_controller/sdc_controller.v lines=199-201

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000007 file=sdc/sdc_controller/sdc_controller.v lines=203-205
`ifdef SDC_CLK_STATIC
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000007 file=sdc/sdc_controller/sdc_controller.v lines=203-205
//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000004 file=sdc/sdc_controller/sdc_controller.v lines=204-204
   assign sd_clk_o = sd_clk_i;
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000004 file=sdc/sdc_controller/sdc_controller.v lines=204-204
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000007 file=sdc/sdc_controller/sdc_controller.v lines=203-205
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000007 file=sdc/sdc_controller/sdc_controller.v lines=203-205
   
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000008 file=sdc/sdc_controller/sdc_controller.v lines=207-214
`ifdef SDC_CLK_DYNAMIC
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000008 file=sdc/sdc_controller/sdc_controller.v lines=207-214
//__RB_CUT_BEGIN__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000001 file=sdc/sdc_controller/sdc_controller.v lines=208-213
  sd_clock_divider clock_divider_1 (
 .CLK (sd_clk_i),
 .DIVIDER (clock_divider),
 .RST  (wb_rst_i | software_reset_reg[0]),
 .SD_CLK  (sd_clk_o)  
);
//__RB_CUT_END__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000001 file=sdc/sdc_controller/sdc_controller.v lines=208-213
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000008 file=sdc/sdc_controller/sdc_controller.v lines=207-214
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000008 file=sdc/sdc_controller/sdc_controller.v lines=207-214
//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000005 file=sdc/sdc_controller/sdc_controller.v lines=215-215
assign sd_clk_o_pad  = sd_clk_o ;
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000005 file=sdc/sdc_controller/sdc_controller.v lines=215-215

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sdc_controller/sdc_controller.v:grp:internal_signal:000003 file=sdc/sdc_controller/sdc_controller.v lines=217-220
wire [15:0] settings;
wire [7:0] serial_status;
wire [39:0] cmd_out_master;
wire [39:0] cmd_in_host;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sdc_controller/sdc_controller.v:grp:internal_signal:000003 file=sdc/sdc_controller/sdc_controller.v lines=217-220

//__RB_CUT_BEGIN__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000002 file=sdc/sdc_controller/sdc_controller.v lines=222-249
sd_cmd_master cmd_master_1
(
    .CLK_PAD_IO     (wb_clk_i),
    .RST_PAD_I      (wb_rst_i | software_reset_reg[0]),
    .New_CMD        (new_cmd),
    .data_write     (d_write),
    .data_read      (d_read),
    .ARG_REG        (argument_reg),
    .CMD_SET_REG    (cmd_setting_reg[13:0]),
    .STATUS_REG     (status_reg_w),
    .TIMEOUT_REG    (time_out_reg),
    .RESP_1_REG     (cmd_resp_1_w),
    .ERR_INT_REG    (error_int_status_reg_w),
    .NORMAL_INT_REG (normal_int_status_reg_w),
    .ERR_INT_RST    (error_isr_reset),
    .NORMAL_INT_RST (normal_isr_reset),
    .settings       (settings),
    .go_idle_o      (go_idle),
    .cmd_out        (cmd_out_master ),
    .req_out        (req_out_master ),
    .ack_out        (ack_out_master ),
    .req_in         (req_in_host),
    .ack_in         (ack_in_host),
    .cmd_in         (cmd_in_host),
    .serial_status (serial_status),
    .card_detect (card_detect)

);
//__RB_CUT_END__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000002 file=sdc/sdc_controller/sdc_controller.v lines=222-249


//__RB_CUT_BEGIN__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000003 file=sdc/sdc_controller/sdc_controller.v lines=252-267
sd_cmd_serial_host cmd_serial_host_1(
    .SD_CLK_IN  (sd_clk_o), 
    .RST_IN     (wb_rst_i | software_reset_reg[0] | go_idle),
    .SETTING_IN (settings),
    .CMD_IN     (cmd_out_master),
    .REQ_IN     (req_out_master),
    .ACK_IN     (ack_out_master),
    .REQ_OUT    (req_in_host), 
    .ACK_OUT    (ack_in_host),
    .CMD_OUT    (cmd_in_host),
    .STATUS     (serial_status),
    .cmd_dat_i  (sd_cmd_dat_i),
    .cmd_out_o  (sd_cmd_out_o),
    .cmd_oe_o   ( sd_cmd_oe_o),
    .st_dat_t   (start_dat_t)
);
//__RB_CUT_END__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000003 file=sdc/sdc_controller/sdc_controller.v lines=252-267


//__RB_CUT_BEGIN__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000004 file=sdc/sdc_controller/sdc_controller.v lines=270-307
sd_data_master data_master_1 
(
    .clk            (wb_clk_i),
    .rst            (wb_rst_i | software_reset_reg[0]),
    .dat_in_tx      (dat_out_s_tx_bd),
    .free_tx_bd     (free_bd_tx_bd),
    .ack_i_s_tx     (ack_o_s_tx ),
    .re_s_tx        (re_s_tx_bd_w), 
    .a_cmp_tx       (a_cmp_tx_bd_w),
    .dat_in_rx      (dat_out_s_rx_bd),
    .free_rx_bd     (free_bd_rx_bd),
    .ack_i_s_rx     (ack_o_s_rx),
    .re_s_rx        (re_s_rx_bd_w), 
    .a_cmp_rx       (a_cmp_rx_bd_w),
    .cmd_busy       (cmd_busy),
    .we_req         (write_req_s),
    .we_ack         (we_ack),
    .d_write        (d_write),
    .d_read         (d_read),
    .cmd_arg        (cmd_arg_s),
    .cmd_set        (cmd_set_s),
    .cmd_tsf_err    (normal_int_status_reg[15]) ,
    .card_status    (cmd_resp_1[12:8])   ,
    .start_tx_fifo  (start_tx_fifo),
    .start_rx_fifo  (start_rx_fifo),
    .sys_adr        (sys_adr),
    .tx_empt        (tx_e ),
    .tx_full        (tx_f ),
    .rx_full        (full_rx ),
    .busy_n         (busy_n),
    .transm_complete(trans_complete ),
    .crc_ok         (crc_ok),
    .ack_transfer   (ack_transfer),
    .Dat_Int_Status (bd_int_st_w),
    .Dat_Int_Status_rst (Bd_isr_reset),
    .CIDAT           (cidat_w),
	.transfer_type  (cmd_setting_reg[15:14])
);
//__RB_CUT_END__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000004 file=sdc/sdc_controller/sdc_controller.v lines=270-307
 
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sdc_controller/sdc_controller.v:grp:internal_signal:000004 file=sdc/sdc_controller/sdc_controller.v lines=309-309
wire [31:0] data_out_tx_fifo;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sdc_controller/sdc_controller.v:grp:internal_signal:000004 file=sdc/sdc_controller/sdc_controller.v lines=309-309
//__RB_CUT_BEGIN__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000005 file=sdc/sdc_controller/sdc_controller.v lines=310-325
sd_data_serial_host sd_data_serial_host_1(
    .sd_clk         (sd_clk_o),
    .rst            (wb_rst_i | software_reset_reg[0]),
    .data_in        (data_out_tx_fifo),
    .rd             (rd), 
    .data_out       (data_in_rx_fifo),
    .we             (we_rx),
    .DAT_oe_o       (sd_dat_oe_o),
    .DAT_dat_o      (sd_dat_out_o),
    .DAT_dat_i      (sd_dat_dat_i),
    .start_dat      (start_dat_t),
    .ack_transfer   (ack_transfer),
    .busy_n         (busy_n),
    .transm_complete(trans_complete ),
    .crc_ok         (crc_ok)
);
//__RB_CUT_END__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000005 file=sdc/sdc_controller/sdc_controller.v lines=310-325


//__RB_CUT_BEGIN__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000006 file=sdc/sdc_controller/sdc_controller.v lines=328-340
sd_bd rx_bd
(
    .clk        (wb_clk_i),
    .rst       (wb_rst_i | software_reset_reg[0]),
    .we_m      (we_m_rx_bd),
    .dat_in_m  (dat_in_m_rx_bd),
    .free_bd   (free_bd_rx_bd),
    .re_s      (re_s_rx_bd_w),
    .ack_o_s   (ack_o_s_rx),
    .a_cmp     (a_cmp_rx_bd_w),
    .dat_out_s (dat_out_s_rx_bd)

);
//__RB_CUT_END__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000006 file=sdc/sdc_controller/sdc_controller.v lines=328-340

//__RB_CUT_BEGIN__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000007 file=sdc/sdc_controller/sdc_controller.v lines=342-353
sd_bd tx_bd
(
    .clk       (wb_clk_i),
    .rst       (wb_rst_i | software_reset_reg[0]),
    .we_m      (we_m_tx_bd),
    .dat_in_m  (dat_in_m_tx_bd),
    .free_bd   (free_bd_tx_bd),
    .ack_o_s   (ack_o_s_tx),
    .re_s      (re_s_tx_bd_w),
    .a_cmp     (a_cmp_tx_bd_w),
    .dat_out_s (dat_out_s_tx_bd)
);
//__RB_CUT_END__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000007 file=sdc/sdc_controller/sdc_controller.v lines=342-353


//__RB_CUT_BEGIN__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000008 file=sdc/sdc_controller/sdc_controller.v lines=356-374
sd_fifo_tx_filler fifo_filer_tx (
    .clk        (wb_clk_i),
    .rst        (wb_rst_i | software_reset_reg[0]),
    .m_wb_adr_o (m_wb_adr_o_tx),
    .m_wb_we_o  (m_wb_we_o_tx),
    .m_wb_dat_i (m_wb_dat_i),
    .m_wb_cyc_o (m_wb_cyc_o_tx),
    .m_wb_stb_o (m_wb_stb_o_tx),
    .m_wb_ack_i (m_wb_ack_i),
    .m_wb_cti_o (m_wb_cti_o_tx),
	  .m_wb_bte_o (m_wb_bte_o_tx),
    .en         (start_tx_fifo),
    .adr        (sys_adr),
    .sd_clk     (sd_clk_o),
    .dat_o      (data_out_tx_fifo   ),
    .rd         (rd),
    .empty      (tx_e),
    .fe         (tx_f)
);
//__RB_CUT_END__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000008 file=sdc/sdc_controller/sdc_controller.v lines=356-374

//__RB_CUT_BEGIN__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000009 file=sdc/sdc_controller/sdc_controller.v lines=376-393
sd_fifo_rx_filler fifo_filer_rx (
    .clk        (wb_clk_i),
    .rst        (wb_rst_i | software_reset_reg[0]),
    .m_wb_adr_o (m_wb_adr_o_rx),
    .m_wb_we_o  (m_wb_we_o_rx),
    .m_wb_dat_o (m_wb_dat_o),
    .m_wb_cyc_o (m_wb_cyc_o_rx),
    .m_wb_stb_o (m_wb_stb_o_rx),
    .m_wb_ack_i (m_wb_ack_i),
    .m_wb_cti_o (m_wb_cti_o_rx),
	  .m_wb_bte_o (m_wb_bte_o_rx),
    .en         (start_rx_fifo),
    .adr        (sys_adr),
    .sd_clk     (sd_clk_o),
    .dat_i      (data_in_rx_fifo   ),
    .wr         (we_rx),
    .full       (full_rx)
);
//__RB_CUT_END__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000009 file=sdc/sdc_controller/sdc_controller.v lines=376-393

//__RB_CUT_BEGIN__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000010 file=sdc/sdc_controller/sdc_controller.v lines=395-436
sd_controller_wb sd_controller_wb0
	(
	 .wb_clk_i          (wb_clk_i),
	 .wb_rst_i          (wb_rst_i),
	 .wb_dat_i          (wb_dat_i),
	 .wb_dat_o          (wb_dat_o),
	 .wb_adr_i          (wb_adr_i[7:0]),
	 .wb_sel_i          (wb_sel_i),
	 .wb_we_i           (wb_we_i),
	 .wb_stb_i          (wb_stb_i),
	 .wb_cyc_i          (wb_cyc_i),
	 .wb_ack_o          (wb_ack_o),
   	 .we_m_tx_bd        (we_m_tx_bd),
     .new_cmd           (new_cmd), 
     .we_m_rx_bd        (we_m_rx_bd),   
    .we_ack             (we_ack),
    .int_ack            (int_ack),
    .cmd_int_busy       (cmd_int_busy),
    .Bd_isr_reset       (Bd_isr_reset),     
    .normal_isr_reset   (normal_isr_reset),
    .error_isr_reset    (error_isr_reset),
    .int_busy           (int_busy),
    .dat_in_m_tx_bd     (dat_in_m_tx_bd),
    .dat_in_m_rx_bd     (dat_in_m_rx_bd),
    .write_req_s        (write_req_s),
    .cmd_set_s          (cmd_set_s),
    .cmd_arg_s          (cmd_arg_s),
    .argument_reg       (argument_reg),
    .cmd_setting_reg    (cmd_setting_reg),
    .status_reg         (status_reg),
    .cmd_resp_1         (cmd_resp_1),
    .software_reset_reg (software_reset_reg ),
    .time_out_reg       (time_out_reg ),
    .normal_int_status_reg  (normal_int_status_reg),
    .error_int_status_reg   (error_int_status_reg ),
    .normal_int_signal_enable_reg   (normal_int_signal_enable_reg),
    .error_int_signal_enable_reg    (error_int_signal_enable_reg),
    .clock_divider                  (clock_divider ),
    .Bd_Status_reg                  (Bd_Status_reg),
    .Bd_isr_reg                     (Bd_isr_reg ),
    .Bd_isr_enable_reg              (Bd_isr_enable_reg)
	 );
//__RB_CUT_END__ type=instantiation id=sdc/sdc_controller/sdc_controller.v:inst:000010 file=sdc/sdc_controller/sdc_controller.v lines=395-436





//MUX For WB master acces granted to RX or TX FIFO filler
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=sdc/sdc_controller/sdc_controller.v:grp:assign_cluster:000001 file=sdc/sdc_controller/sdc_controller.v lines=443-450
//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000006 file=sdc/sdc_controller/sdc_controller.v lines=443-443
assign m_wb_cyc_o = start_tx_fifo ? m_wb_cyc_o_tx :start_rx_fifo ?m_wb_cyc_o_rx: 0;
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000006 file=sdc/sdc_controller/sdc_controller.v lines=443-443
//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000007 file=sdc/sdc_controller/sdc_controller.v lines=444-444
assign m_wb_stb_o = start_tx_fifo ? m_wb_stb_o_tx :start_rx_fifo ?m_wb_stb_o_rx: 0;
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000007 file=sdc/sdc_controller/sdc_controller.v lines=444-444

//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000008 file=sdc/sdc_controller/sdc_controller.v lines=446-446
assign m_wb_cti_o = start_tx_fifo ? m_wb_cti_o_tx :start_rx_fifo ?m_wb_cti_o_rx: 0;
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000008 file=sdc/sdc_controller/sdc_controller.v lines=446-446
//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000009 file=sdc/sdc_controller/sdc_controller.v lines=447-447
assign m_wb_bte = start_tx_fifo ? m_wb_bte_o_tx :start_rx_fifo ?m_wb_bte_o_rx: 0;
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000009 file=sdc/sdc_controller/sdc_controller.v lines=447-447
//assign m_wb_dat_o = m_wb_dat_o_rx;
//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000010 file=sdc/sdc_controller/sdc_controller.v lines=449-449
assign m_wb_we_o = start_tx_fifo ? m_wb_we_o_tx :start_rx_fifo ?m_wb_we_o_rx: 0;
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000010 file=sdc/sdc_controller/sdc_controller.v lines=449-449
//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000011 file=sdc/sdc_controller/sdc_controller.v lines=450-450
assign m_wb_adr_o = start_tx_fifo ? m_wb_adr_o_tx :start_rx_fifo ?m_wb_adr_o_rx: 0;
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000011 file=sdc/sdc_controller/sdc_controller.v lines=450-450
//__RB_CUT_GROUP_END__ type=assign_cluster id=sdc/sdc_controller/sdc_controller.v:grp:assign_cluster:000001 file=sdc/sdc_controller/sdc_controller.v lines=443-450

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000009 file=sdc/sdc_controller/sdc_controller.v lines=452-456
`ifdef SDC_IRQ_ENABLE
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=sdc/sdc_controller/sdc_controller.v:grp:assign_cluster:000002 file=sdc/sdc_controller/sdc_controller.v lines=453-455
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000009 file=sdc/sdc_controller/sdc_controller.v lines=452-456
//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000012 file=sdc/sdc_controller/sdc_controller.v lines=453-453
assign int_a =  |(normal_int_status_reg &  normal_int_signal_enable_reg) ;
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000012 file=sdc/sdc_controller/sdc_controller.v lines=453-453
//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000013 file=sdc/sdc_controller/sdc_controller.v lines=454-454
assign int_b =  |(error_int_status_reg & error_int_signal_enable_reg);
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000013 file=sdc/sdc_controller/sdc_controller.v lines=454-454
//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000014 file=sdc/sdc_controller/sdc_controller.v lines=455-455
assign int_c =  |(Bd_isr_reg & Bd_isr_enable_reg);
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000014 file=sdc/sdc_controller/sdc_controller.v lines=455-455
//__RB_CUT_GROUP_END__ type=assign_cluster id=sdc/sdc_controller/sdc_controller.v:grp:assign_cluster:000002 file=sdc/sdc_controller/sdc_controller.v lines=453-455
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000009 file=sdc/sdc_controller/sdc_controller.v lines=452-456
`endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sdc_controller/sdc_controller.v:pp_blk:000009 file=sdc/sdc_controller/sdc_controller.v lines=452-456

//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000015 file=sdc/sdc_controller/sdc_controller.v lines=458-458
assign m_wb_sel_o = 4'b1111;
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000015 file=sdc/sdc_controller/sdc_controller.v lines=458-458

//Set Bd_Status_reg
//__RB_CUT_BEGIN__ type=always id=sdc/sdc_controller/sdc_controller.v:proc:000001 file=sdc/sdc_controller/sdc_controller.v lines=461-472
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sdc_controller/sdc_controller.v:begin_end:000001 file=sdc/sdc_controller/sdc_controller.v lines=461-472
always @ (posedge wb_clk_i ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sdc_controller/sdc_controller.v:begin_end:000001 file=sdc/sdc_controller/sdc_controller.v lines=461-472
  Bd_Status_reg[15:8]=free_bd_rx_bd;
  Bd_Status_reg[7:0]=free_bd_tx_bd;
  cmd_resp_1<= cmd_resp_1_w;
  normal_int_status_reg<= normal_int_status_reg_w  ;
  error_int_status_reg<= error_int_status_reg_w  ;
  status_reg[0]<= status_reg_busy;
  status_reg[15:1]<=  status_reg_w[15:1]; 
  status_reg[1] <= cidat_w; 
  Bd_isr_reg<=bd_int_st_w;

//__RB_CUT_TAIL__ type=begin_end id=sdc/sdc_controller/sdc_controller.v:begin_end:000001 file=sdc/sdc_controller/sdc_controller.v lines=461-472
end
//__RB_CUT_TAIL__ type=always id=sdc/sdc_controller/sdc_controller.v:proc:000001 file=sdc/sdc_controller/sdc_controller.v lines=461-472
//__RB_CUT_END__ type=always id=sdc/sdc_controller/sdc_controller.v:proc:000001 file=sdc/sdc_controller/sdc_controller.v lines=461-472
//__RB_CUT_END__ type=begin_end id=sdc/sdc_controller/sdc_controller.v:begin_end:000001 file=sdc/sdc_controller/sdc_controller.v lines=461-472


 
//cmd_int_busy is set when an internal access to the CMD buss is granted then immidetly uppdate the status busy bit to prevent buss access to cmd
//__RB_CUT_BEGIN__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000016 file=sdc/sdc_controller/sdc_controller.v lines=477-477
assign status_reg_busy = cmd_int_busy ? 1'b1: status_reg_w[0];
//__RB_CUT_END__ type=assign id=sdc/sdc_controller/sdc_controller.v:assign:000016 file=sdc/sdc_controller/sdc_controller.v lines=477-477





endmodule
