`include "sd_defines.v"

module sd_data_master (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=sdc/sd_data_master/sd_data_master.v:grp:port_section:000001 file=sdc/sd_data_master/sd_data_master.v lines=4-50
  input clk,
  input rst,
  //Tx Bd
 
  input [`RAM_MEM_WIDTH-1:0] dat_in_tx,
  input [`BD_WIDTH-1:0] free_tx_bd,
  input ack_i_s_tx,
  output reg re_s_tx,
  output reg a_cmp_tx,
  //Rx Bd

  input [`RAM_MEM_WIDTH-1:0] dat_in_rx,
  input [`BD_WIDTH-1:0] free_rx_bd,
  input ack_i_s_rx,
  output reg re_s_rx,
  output reg a_cmp_rx,
  //Input from SD-Host Reg
  input  cmd_busy, //STATUS_REG[0] and mux  
  //Output to SD-Host Reg
  output reg we_req,
  input we_ack,
  output reg d_write,
  output reg d_read,
  output reg [31:0] cmd_arg,
  output reg [15:0] cmd_set,
  input cmd_tsf_err,
  input [4:0] card_status,
  //To fifo filler
  output reg start_tx_fifo,
  output reg start_rx_fifo,
  output reg [31:0] sys_adr,
  input tx_empt,
  input tx_full,
  input rx_full,

  //SD-DATA_Host
  input busy_n     ,
  input transm_complete ,
  input crc_ok,
  output reg ack_transfer, 
  //status output
  output reg  [7:0] Dat_Int_Status ,
  input Dat_Int_Status_rst,
  output reg  CIDAT,
  input [1:0] transfer_type
  
    
//__RB_CUT_GROUP_END__ type=port_section id=sdc/sd_data_master/sd_data_master.v:grp:port_section:000001 file=sdc/sd_data_master/sd_data_master.v lines=4-50
  );
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=sdc/sd_data_master/sd_data_master.v:grp:param_decl:000001 file=sdc/sd_data_master/sd_data_master.v lines=52-54
`define RESEND_MAX_CNT 3
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000001 file=sdc/sd_data_master/sd_data_master.v lines=53-61
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=sdc/sd_data_master/sd_data_master.v:pp_blk:000001:br:000001 file=sdc/sd_data_master/sd_data_master.v lines=53-56
`ifdef RAM_MEM_WIDTH_32
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000001 file=sdc/sd_data_master/sd_data_master.v lines=53-61
//__RB_CUT_BODY__ type=pp_ifdef_branch id=sdc/sd_data_master/sd_data_master.v:pp_blk:000001:br:000001 file=sdc/sd_data_master/sd_data_master.v lines=53-56
      `define READ_CYCLE 2
//__RB_CUT_GROUP_END__ type=param_decl id=sdc/sd_data_master/sd_data_master.v:grp:param_decl:000001 file=sdc/sd_data_master/sd_data_master.v lines=52-54
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_data_master/sd_data_master.v:grp:internal_signal:000001 file=sdc/sd_data_master/sd_data_master.v lines=55-69
       reg [1:0]bd_cnt  ;
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=sdc/sd_data_master/sd_data_master.v:grp:param_decl:000002 file=sdc/sd_data_master/sd_data_master.v lines=56-58
       `define BD_EMPTY (`BD_SIZE  /2) 
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=sdc/sd_data_master/sd_data_master.v:pp_blk:000001:br:000001 file=sdc/sd_data_master/sd_data_master.v lines=53-56
//__RB_CUT_END__ type=pp_ifdef_branch id=sdc/sd_data_master/sd_data_master.v:pp_blk:000001:br:000001 file=sdc/sd_data_master/sd_data_master.v lines=53-56
//__RB_CUT_BEGIN__ type=pp_else_branch id=sdc/sd_data_master/sd_data_master.v:pp_blk:000001:br:000002 file=sdc/sd_data_master/sd_data_master.v lines=57-60
`else `ifdef  RAM_MEM_WIDTH_16
//__RB_CUT_BODY__ type=pp_else_branch id=sdc/sd_data_master/sd_data_master.v:pp_blk:000001:br:000002 file=sdc/sd_data_master/sd_data_master.v lines=57-60
      `define READ_CYCLE 4
//__RB_CUT_GROUP_END__ type=param_decl id=sdc/sd_data_master/sd_data_master.v:grp:param_decl:000002 file=sdc/sd_data_master/sd_data_master.v lines=56-58
       reg [2:0] bd_cnt;
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=sdc/sd_data_master/sd_data_master.v:grp:param_decl:000003 file=sdc/sd_data_master/sd_data_master.v lines=60-62
       `define BD_EMPTY (`BD_SIZE  /4) 
//__RB_CUT_TAIL__ type=pp_else_branch id=sdc/sd_data_master/sd_data_master.v:pp_blk:000001:br:000002 file=sdc/sd_data_master/sd_data_master.v lines=57-60
//__RB_CUT_END__ type=pp_else_branch id=sdc/sd_data_master/sd_data_master.v:pp_blk:000001:br:000002 file=sdc/sd_data_master/sd_data_master.v lines=57-60
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000001 file=sdc/sd_data_master/sd_data_master.v lines=53-61
   `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000001 file=sdc/sd_data_master/sd_data_master.v lines=53-61
`endif 
//__RB_CUT_GROUP_END__ type=param_decl id=sdc/sd_data_master/sd_data_master.v:grp:param_decl:000003 file=sdc/sd_data_master/sd_data_master.v lines=60-62

reg send_done;
reg rec_done;
reg rec_failed;
reg tx_cycle;
reg rx_cycle;
reg [2:0] resend_try_cnt;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_data_master/sd_data_master.v:grp:internal_signal:000001 file=sdc/sd_data_master/sd_data_master.v lines=55-69

//__RB_CUT_GROUP_BEGIN__ type=param_decl id=sdc/sd_data_master/sd_data_master.v:grp:param_decl:000004 file=sdc/sd_data_master/sd_data_master.v lines=71-77
parameter CMD24 = 16'h181A ; // 011000 0001 1010
parameter CMD17 = 16'h111A; //  010001 0001 1010
parameter CMD12 = 16'hC1A ; //  001100 0001 1010
parameter ACMD13 = 16'hD1A ; // 001101 0001 1010  //SD STATUS
parameter ACMD51 = 16'h331A ; //110011 0001 1010 //SCR Register

parameter SIZE = 9;
//__RB_CUT_GROUP_END__ type=param_decl id=sdc/sd_data_master/sd_data_master.v:grp:param_decl:000004 file=sdc/sd_data_master/sd_data_master.v lines=71-77
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_data_master/sd_data_master.v:grp:internal_signal:000002 file=sdc/sd_data_master/sd_data_master.v lines=78-79
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;  
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_data_master/sd_data_master.v:grp:internal_signal:000002 file=sdc/sd_data_master/sd_data_master.v lines=78-79
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=sdc/sd_data_master/sd_data_master.v:grp:param_decl:000005 file=sdc/sd_data_master/sd_data_master.v lines=80-88
parameter IDLE             =  9'b000000001;
parameter GET_TX_BD        =  9'b000000010;
parameter GET_RX_BD        =  9'b000000100;
parameter SEND_CMD         =  9'b000001000;
parameter RECIVE_CMD       =  9'b000010000;
parameter DATA_TRANSFER    =  9'b000100000;
parameter STOP             =  9'b001000000;
parameter STOP_SEND        =  9'b010000000;
parameter STOP_RECIVE_CMD  =  9'b100000000;
//__RB_CUT_GROUP_END__ type=param_decl id=sdc/sd_data_master/sd_data_master.v:grp:param_decl:000005 file=sdc/sd_data_master/sd_data_master.v lines=80-88

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_data_master/sd_data_master.v:grp:internal_signal:000003 file=sdc/sd_data_master/sd_data_master.v lines=90-93
reg trans_done;
reg trans_failed;
reg internal_transm_complete;
reg transm_complete_q;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_data_master/sd_data_master.v:grp:internal_signal:000003 file=sdc/sd_data_master/sd_data_master.v lines=90-93

//__RB_CUT_BEGIN__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000001 file=sdc/sd_data_master/sd_data_master.v lines=95-107
always @ (posedge clk or posedge rst )
//__RB_CUT_BODY__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000001 file=sdc/sd_data_master/sd_data_master.v lines=95-107
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000003 file=sdc/sd_data_master/sd_data_master.v lines=96-107
begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000003 file=sdc/sd_data_master/sd_data_master.v lines=96-107
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000001 file=sdc/sd_data_master/sd_data_master.v lines=97-100
	if  (rst) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000001 file=sdc/sd_data_master/sd_data_master.v lines=97-100
		internal_transm_complete <=1'b0;
		transm_complete_q<=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000001 file=sdc/sd_data_master/sd_data_master.v lines=97-100
	end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000001 file=sdc/sd_data_master/sd_data_master.v lines=97-100
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000002 file=sdc/sd_data_master/sd_data_master.v lines=101-104
	else begin  
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000002 file=sdc/sd_data_master/sd_data_master.v lines=101-104
		transm_complete_q<=transm_complete;
		internal_transm_complete<=transm_complete_q;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000002 file=sdc/sd_data_master/sd_data_master.v lines=101-104
	end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000002 file=sdc/sd_data_master/sd_data_master.v lines=101-104


//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000003 file=sdc/sd_data_master/sd_data_master.v lines=96-107
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000003 file=sdc/sd_data_master/sd_data_master.v lines=96-107
//__RB_CUT_TAIL__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000001 file=sdc/sd_data_master/sd_data_master.v lines=95-107
//__RB_CUT_END__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000001 file=sdc/sd_data_master/sd_data_master.v lines=95-107




//__RB_CUT_GROUP_BEGIN__ type=fsm id=sdc/sd_data_master/sd_data_master.v:grp:fsm:000001 file=sdc/sd_data_master/sd_data_master.v lines=112-214
//__RB_CUT_GROUP_BEGIN__ type=counter_cluster id=sdc/sd_data_master/sd_data_master.v:grp:counter_cluster:000001 file=sdc/sd_data_master/sd_data_master.v lines=112-203
//__RB_CUT_BEGIN__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000002 file=sdc/sd_data_master/sd_data_master.v lines=112-203
always @ (state or resend_try_cnt or tx_full or free_tx_bd or free_rx_bd or bd_cnt or send_done or rec_done or rec_failed or trans_done or trans_failed)
//__RB_CUT_BODY__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000002 file=sdc/sd_data_master/sd_data_master.v lines=112-203
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000023 file=sdc/sd_data_master/sd_data_master.v lines=113-203
begin : FSM_COMBO
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000023 file=sdc/sd_data_master/sd_data_master.v lines=113-203
 next_state  = 0;   
//__RB_CUT_BEGIN__ type=case id=sdc/sd_data_master/sd_data_master.v:case:000001 file=sdc/sd_data_master/sd_data_master.v lines=115-201
case(state)  
  
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000007 file=sdc/sd_data_master/sd_data_master.v lines=117-127
  IDLE: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000007 file=sdc/sd_data_master/sd_data_master.v lines=117-127
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000004 file=sdc/sd_data_master/sd_data_master.v lines=118-120
   if (free_tx_bd !=`BD_EMPTY)begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000004 file=sdc/sd_data_master/sd_data_master.v lines=118-120
      next_state = GET_TX_BD;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000004 file=sdc/sd_data_master/sd_data_master.v lines=118-120
   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000004 file=sdc/sd_data_master/sd_data_master.v lines=118-120
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000005 file=sdc/sd_data_master/sd_data_master.v lines=121-123
   else if (free_rx_bd !=`BD_EMPTY) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000005 file=sdc/sd_data_master/sd_data_master.v lines=121-123
      next_state = GET_RX_BD;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000005 file=sdc/sd_data_master/sd_data_master.v lines=121-123
   end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000005 file=sdc/sd_data_master/sd_data_master.v lines=121-123
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000006 file=sdc/sd_data_master/sd_data_master.v lines=124-126
   else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000006 file=sdc/sd_data_master/sd_data_master.v lines=124-126
      next_state = IDLE;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000006 file=sdc/sd_data_master/sd_data_master.v lines=124-126
   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000006 file=sdc/sd_data_master/sd_data_master.v lines=124-126
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000007 file=sdc/sd_data_master/sd_data_master.v lines=117-127
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000007 file=sdc/sd_data_master/sd_data_master.v lines=117-127
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000010 file=sdc/sd_data_master/sd_data_master.v lines=128-135
  GET_TX_BD: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000010 file=sdc/sd_data_master/sd_data_master.v lines=128-135
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000008 file=sdc/sd_data_master/sd_data_master.v lines=129-131
    if ( ( bd_cnt> `READ_CYCLE-1) && (tx_full==1) )begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000008 file=sdc/sd_data_master/sd_data_master.v lines=129-131
     next_state = SEND_CMD;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000008 file=sdc/sd_data_master/sd_data_master.v lines=129-131
    end   
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000008 file=sdc/sd_data_master/sd_data_master.v lines=129-131
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000009 file=sdc/sd_data_master/sd_data_master.v lines=132-134
    else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000009 file=sdc/sd_data_master/sd_data_master.v lines=132-134
     next_state = GET_TX_BD;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000009 file=sdc/sd_data_master/sd_data_master.v lines=132-134
    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000009 file=sdc/sd_data_master/sd_data_master.v lines=132-134
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000010 file=sdc/sd_data_master/sd_data_master.v lines=128-135
  end   
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000010 file=sdc/sd_data_master/sd_data_master.v lines=128-135
  
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000013 file=sdc/sd_data_master/sd_data_master.v lines=137-144
  GET_RX_BD: begin  
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000013 file=sdc/sd_data_master/sd_data_master.v lines=137-144
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000011 file=sdc/sd_data_master/sd_data_master.v lines=138-140
    if (bd_cnt >= (`READ_CYCLE-1))begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000011 file=sdc/sd_data_master/sd_data_master.v lines=138-140
     next_state = SEND_CMD;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000011 file=sdc/sd_data_master/sd_data_master.v lines=138-140
    end   
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000011 file=sdc/sd_data_master/sd_data_master.v lines=138-140
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000012 file=sdc/sd_data_master/sd_data_master.v lines=141-143
    else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000012 file=sdc/sd_data_master/sd_data_master.v lines=141-143
     next_state = GET_RX_BD;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000012 file=sdc/sd_data_master/sd_data_master.v lines=141-143
    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000012 file=sdc/sd_data_master/sd_data_master.v lines=141-143
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000013 file=sdc/sd_data_master/sd_data_master.v lines=137-144
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000013 file=sdc/sd_data_master/sd_data_master.v lines=137-144
  
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000016 file=sdc/sd_data_master/sd_data_master.v lines=146-153
  SEND_CMD: begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000016 file=sdc/sd_data_master/sd_data_master.v lines=146-153
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000014 file=sdc/sd_data_master/sd_data_master.v lines=147-149
   if (send_done)begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000014 file=sdc/sd_data_master/sd_data_master.v lines=147-149
     next_state = RECIVE_CMD;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000014 file=sdc/sd_data_master/sd_data_master.v lines=147-149
    end   
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000014 file=sdc/sd_data_master/sd_data_master.v lines=147-149
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000015 file=sdc/sd_data_master/sd_data_master.v lines=150-152
    else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000015 file=sdc/sd_data_master/sd_data_master.v lines=150-152
     next_state = SEND_CMD;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000015 file=sdc/sd_data_master/sd_data_master.v lines=150-152
    end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000015 file=sdc/sd_data_master/sd_data_master.v lines=150-152
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000016 file=sdc/sd_data_master/sd_data_master.v lines=146-153
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000016 file=sdc/sd_data_master/sd_data_master.v lines=146-153
    
  
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000017 file=sdc/sd_data_master/sd_data_master.v lines=156-163
 RECIVE_CMD: begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000017 file=sdc/sd_data_master/sd_data_master.v lines=156-163
    if (rec_done)
      next_state = DATA_TRANSFER;       
    else if (rec_failed)
      next_state =  SEND_CMD;
    else 
      next_state = RECIVE_CMD;    
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000017 file=sdc/sd_data_master/sd_data_master.v lines=156-163
   end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000017 file=sdc/sd_data_master/sd_data_master.v lines=156-163

//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000018 file=sdc/sd_data_master/sd_data_master.v lines=165-172
  DATA_TRANSFER: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000018 file=sdc/sd_data_master/sd_data_master.v lines=165-172
    if (trans_done)
      next_state = IDLE;
   else if (trans_failed)
      next_state = STOP;
   else
      next_state = DATA_TRANSFER;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000018 file=sdc/sd_data_master/sd_data_master.v lines=165-172
   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000018 file=sdc/sd_data_master/sd_data_master.v lines=165-172
  
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000019 file=sdc/sd_data_master/sd_data_master.v lines=174-176
  STOP: begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000019 file=sdc/sd_data_master/sd_data_master.v lines=174-176
     next_state = STOP_SEND;     
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000019 file=sdc/sd_data_master/sd_data_master.v lines=174-176
   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000019 file=sdc/sd_data_master/sd_data_master.v lines=174-176
   
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000022 file=sdc/sd_data_master/sd_data_master.v lines=178-185
   STOP_SEND: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000022 file=sdc/sd_data_master/sd_data_master.v lines=178-185
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000020 file=sdc/sd_data_master/sd_data_master.v lines=179-181
    if (send_done)begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000020 file=sdc/sd_data_master/sd_data_master.v lines=179-181
     next_state =IDLE;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000020 file=sdc/sd_data_master/sd_data_master.v lines=179-181
    end   
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000020 file=sdc/sd_data_master/sd_data_master.v lines=179-181
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000021 file=sdc/sd_data_master/sd_data_master.v lines=182-184
    else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000021 file=sdc/sd_data_master/sd_data_master.v lines=182-184
     next_state = STOP_SEND;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000021 file=sdc/sd_data_master/sd_data_master.v lines=182-184
    end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000021 file=sdc/sd_data_master/sd_data_master.v lines=182-184
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000022 file=sdc/sd_data_master/sd_data_master.v lines=178-185
   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000022 file=sdc/sd_data_master/sd_data_master.v lines=178-185
   
  //  STOP_RECIVE_CMD : begin
  //   if (rec_done)
  //     next_state = SEND_CMD;       
  //   else if (rec_failed)
  //     next_state =  STOP;
  //   else if (resend_try_cnt>=`RESEND_MAX_CNT)
  //     next_state = IDLE;
  //   else 
  //     next_state = STOP_RECIVE_CMD;    
  //  end 
 
   
 
 default : next_state  = IDLE; 
//__RB_CUT_TAIL__ type=case id=sdc/sd_data_master/sd_data_master.v:case:000001 file=sdc/sd_data_master/sd_data_master.v lines=115-201
 endcase
//__RB_CUT_END__ type=case id=sdc/sd_data_master/sd_data_master.v:case:000001 file=sdc/sd_data_master/sd_data_master.v lines=115-201

//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000023 file=sdc/sd_data_master/sd_data_master.v lines=113-203
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000023 file=sdc/sd_data_master/sd_data_master.v lines=113-203
//__RB_CUT_TAIL__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000002 file=sdc/sd_data_master/sd_data_master.v lines=112-203
//__RB_CUT_END__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000002 file=sdc/sd_data_master/sd_data_master.v lines=112-203
//__RB_CUT_GROUP_END__ type=counter_cluster id=sdc/sd_data_master/sd_data_master.v:grp:counter_cluster:000001 file=sdc/sd_data_master/sd_data_master.v lines=112-203

//----------------Seq logic------------
//__RB_CUT_BEGIN__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000003 file=sdc/sd_data_master/sd_data_master.v lines=206-214
always @ (posedge clk or posedge rst   )
//__RB_CUT_BODY__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000003 file=sdc/sd_data_master/sd_data_master.v lines=206-214
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000026 file=sdc/sd_data_master/sd_data_master.v lines=207-214
begin : FSM_SEQ
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000026 file=sdc/sd_data_master/sd_data_master.v lines=207-214
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000024 file=sdc/sd_data_master/sd_data_master.v lines=208-210
  if (rst ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000024 file=sdc/sd_data_master/sd_data_master.v lines=208-210
    state <= #1 IDLE;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000024 file=sdc/sd_data_master/sd_data_master.v lines=208-210
 end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000024 file=sdc/sd_data_master/sd_data_master.v lines=208-210
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000025 file=sdc/sd_data_master/sd_data_master.v lines=211-213
 else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000025 file=sdc/sd_data_master/sd_data_master.v lines=211-213
    state <= #1 next_state;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000025 file=sdc/sd_data_master/sd_data_master.v lines=211-213
 end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000025 file=sdc/sd_data_master/sd_data_master.v lines=211-213
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000026 file=sdc/sd_data_master/sd_data_master.v lines=207-214
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000026 file=sdc/sd_data_master/sd_data_master.v lines=207-214
//__RB_CUT_TAIL__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000003 file=sdc/sd_data_master/sd_data_master.v lines=206-214
//__RB_CUT_END__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000003 file=sdc/sd_data_master/sd_data_master.v lines=206-214
//__RB_CUT_GROUP_END__ type=fsm id=sdc/sd_data_master/sd_data_master.v:grp:fsm:000001 file=sdc/sd_data_master/sd_data_master.v lines=112-214



//Output logic-----------------


//__RB_CUT_GROUP_BEGIN__ type=counter_cluster id=sdc/sd_data_master/sd_data_master.v:grp:counter_cluster:000002 file=sdc/sd_data_master/sd_data_master.v lines=221-508
//__RB_CUT_BEGIN__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000004 file=sdc/sd_data_master/sd_data_master.v lines=221-508
always @ (posedge clk or posedge rst   )
//__RB_CUT_BODY__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000004 file=sdc/sd_data_master/sd_data_master.v lines=221-508
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000071 file=sdc/sd_data_master/sd_data_master.v lines=222-508
begin  
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000071 file=sdc/sd_data_master/sd_data_master.v lines=222-508
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000027 file=sdc/sd_data_master/sd_data_master.v lines=223-249
 if (rst) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000027 file=sdc/sd_data_master/sd_data_master.v lines=223-249
      send_done<=0;
      bd_cnt<=0;
      sys_adr<=0;
      cmd_arg<=0;
      rec_done<=0;
      start_tx_fifo<=0;
      start_rx_fifo<=0;
      send_done<=0;
      rec_failed<=0;
      d_write <=0;  
      d_read <=0;  
      trans_failed<=0;
      trans_done<=0;
      tx_cycle <=0;
      rx_cycle <=0;
      ack_transfer<=0;
      a_cmp_tx<=0;           
      a_cmp_rx<=0;
      CIDAT<=0;
      Dat_Int_Status<=0;
      we_req<=0;
      re_s_tx<=0;
      re_s_rx<=0;
      cmd_set<=0;
      resend_try_cnt=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000027 file=sdc/sd_data_master/sd_data_master.v lines=223-249
 end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000027 file=sdc/sd_data_master/sd_data_master.v lines=223-249
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000070 file=sdc/sd_data_master/sd_data_master.v lines=250-506
 else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000070 file=sdc/sd_data_master/sd_data_master.v lines=250-506
//__RB_CUT_BEGIN__ type=case id=sdc/sd_data_master/sd_data_master.v:case:000002 file=sdc/sd_data_master/sd_data_master.v lines=251-503
  case(state)
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000028 file=sdc/sd_data_master/sd_data_master.v lines=252-272
     IDLE: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000028 file=sdc/sd_data_master/sd_data_master.v lines=252-272
      send_done<=0;
      bd_cnt<=0;
      sys_adr<=0;
      cmd_arg<=0;
      rec_done<=0;
      rec_failed<=0;
      start_tx_fifo<=0;
      start_rx_fifo<=0;
      send_done<=0;     
      d_write <=0;  
      d_read <=0; 
      trans_failed<=0;
      trans_done<=0;
      tx_cycle <=0;
      rx_cycle <=0;
      ack_transfer<=0;
      a_cmp_tx<=0;           
      a_cmp_rx<=0;
      resend_try_cnt=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000028 file=sdc/sd_data_master/sd_data_master.v lines=252-272
     end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000028 file=sdc/sd_data_master/sd_data_master.v lines=252-272
     
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000037 file=sdc/sd_data_master/sd_data_master.v lines=274-320
     GET_RX_BD: begin                 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000037 file=sdc/sd_data_master/sd_data_master.v lines=274-320
        //0,1,2,3...
      re_s_rx <= 1;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000002 file=sdc/sd_data_master/sd_data_master.v lines=277-288
     `ifdef  RAM_MEM_WIDTH_32
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000002 file=sdc/sd_data_master/sd_data_master.v lines=277-288
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000031 file=sdc/sd_data_master/sd_data_master.v lines=278-287
     	if (ack_i_s_rx) begin        
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000031 file=sdc/sd_data_master/sd_data_master.v lines=278-287
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000029 file=sdc/sd_data_master/sd_data_master.v lines=279-282
	        if( bd_cnt == 2'b0) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000029 file=sdc/sd_data_master/sd_data_master.v lines=279-282
	           sys_adr  <= dat_in_rx;
	           bd_cnt <= bd_cnt+1;   
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000029 file=sdc/sd_data_master/sd_data_master.v lines=279-282
	     	end           
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000029 file=sdc/sd_data_master/sd_data_master.v lines=279-282
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000030 file=sdc/sd_data_master/sd_data_master.v lines=283-286
	        else if ( bd_cnt == 2'b1) begin  
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000030 file=sdc/sd_data_master/sd_data_master.v lines=283-286
	           cmd_arg  <= dat_in_rx;
	           re_s_rx <= 0; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000030 file=sdc/sd_data_master/sd_data_master.v lines=283-286
	        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000030 file=sdc/sd_data_master/sd_data_master.v lines=283-286
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000031 file=sdc/sd_data_master/sd_data_master.v lines=278-287
	   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000031 file=sdc/sd_data_master/sd_data_master.v lines=278-287
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000002 file=sdc/sd_data_master/sd_data_master.v lines=277-288
      `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000002 file=sdc/sd_data_master/sd_data_master.v lines=277-288
      
      
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000003 file=sdc/sd_data_master/sd_data_master.v lines=291-309
      `ifdef  RAM_MEM_WIDTH_16
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000003 file=sdc/sd_data_master/sd_data_master.v lines=291-309
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000036 file=sdc/sd_data_master/sd_data_master.v lines=292-308
      	if (ack_i_s_rx) begin        
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000036 file=sdc/sd_data_master/sd_data_master.v lines=292-308
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000032 file=sdc/sd_data_master/sd_data_master.v lines=293-295
	        if( bd_cnt == 2'b00) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000032 file=sdc/sd_data_master/sd_data_master.v lines=293-295
	           sys_adr [15:0] <= dat_in_rx; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000032 file=sdc/sd_data_master/sd_data_master.v lines=293-295
	        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000032 file=sdc/sd_data_master/sd_data_master.v lines=293-295
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000033 file=sdc/sd_data_master/sd_data_master.v lines=296-298
	        else if ( bd_cnt == 2'b01)  begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000033 file=sdc/sd_data_master/sd_data_master.v lines=296-298
	           sys_adr [31:16] <= dat_in_rx; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000033 file=sdc/sd_data_master/sd_data_master.v lines=296-298
	        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000033 file=sdc/sd_data_master/sd_data_master.v lines=296-298
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000034 file=sdc/sd_data_master/sd_data_master.v lines=299-302
	        else if ( bd_cnt == 2) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000034 file=sdc/sd_data_master/sd_data_master.v lines=299-302
	          cmd_arg [15:0] <= dat_in_rx;
	          re_s_rx <= 0; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000034 file=sdc/sd_data_master/sd_data_master.v lines=299-302
	        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000034 file=sdc/sd_data_master/sd_data_master.v lines=299-302
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000035 file=sdc/sd_data_master/sd_data_master.v lines=303-306
	        else if ( bd_cnt == 3) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000035 file=sdc/sd_data_master/sd_data_master.v lines=303-306
	           cmd_arg [31:16] <= dat_in_rx;
	           re_s_rx <= 0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000035 file=sdc/sd_data_master/sd_data_master.v lines=303-306
	         end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000035 file=sdc/sd_data_master/sd_data_master.v lines=303-306
	         bd_cnt <= bd_cnt+1;       
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000036 file=sdc/sd_data_master/sd_data_master.v lines=292-308
	   	end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000036 file=sdc/sd_data_master/sd_data_master.v lines=292-308
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000003 file=sdc/sd_data_master/sd_data_master.v lines=291-309
       `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000003 file=sdc/sd_data_master/sd_data_master.v lines=291-309
     //Add Later Save last block addres for comparison with current (For multiple block cmd)
     //Add support for Pre-erased
      if (transfer_type==2'b00)
		   cmd_set <= CMD17;
		else if (transfer_type==2'b01)
		   cmd_set <= ACMD13;	 
		else 
      	   cmd_set <= ACMD51;

      rx_cycle<=1;  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000037 file=sdc/sd_data_master/sd_data_master.v lines=274-320
     end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000037 file=sdc/sd_data_master/sd_data_master.v lines=274-320
          
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000046 file=sdc/sd_data_master/sd_data_master.v lines=322-369
     GET_TX_BD:  begin             
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000046 file=sdc/sd_data_master/sd_data_master.v lines=322-369
        //0,1,2,3...
      re_s_tx <= 1;
      if ( bd_cnt == `READ_CYCLE)
        re_s_tx <= 0;
        
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000004 file=sdc/sd_data_master/sd_data_master.v lines=328-341
       `ifdef  RAM_MEM_WIDTH_32
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000004 file=sdc/sd_data_master/sd_data_master.v lines=328-341
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000040 file=sdc/sd_data_master/sd_data_master.v lines=329-340
     	 if (ack_i_s_tx) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000040 file=sdc/sd_data_master/sd_data_master.v lines=329-340
        
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000038 file=sdc/sd_data_master/sd_data_master.v lines=331-334
	        if( bd_cnt == 2'b0) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000038 file=sdc/sd_data_master/sd_data_master.v lines=331-334
	           sys_adr  <= dat_in_tx;
	           bd_cnt <= bd_cnt+1;   
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000038 file=sdc/sd_data_master/sd_data_master.v lines=331-334
	     	end           
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000038 file=sdc/sd_data_master/sd_data_master.v lines=331-334
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000039 file=sdc/sd_data_master/sd_data_master.v lines=335-339
	        else if ( bd_cnt == 2'b1) begin  
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000039 file=sdc/sd_data_master/sd_data_master.v lines=335-339
	           cmd_arg  <= dat_in_tx;
	           re_s_tx <= 0; 
			   start_tx_fifo<=1;  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000039 file=sdc/sd_data_master/sd_data_master.v lines=335-339
        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000039 file=sdc/sd_data_master/sd_data_master.v lines=335-339
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000040 file=sdc/sd_data_master/sd_data_master.v lines=329-340
	   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000040 file=sdc/sd_data_master/sd_data_master.v lines=329-340
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000004 file=sdc/sd_data_master/sd_data_master.v lines=328-341
       `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000004 file=sdc/sd_data_master/sd_data_master.v lines=328-341
      
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000005 file=sdc/sd_data_master/sd_data_master.v lines=343-363
      `ifdef  RAM_MEM_WIDTH_16
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000005 file=sdc/sd_data_master/sd_data_master.v lines=343-363
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000045 file=sdc/sd_data_master/sd_data_master.v lines=344-362
      if (ack_i_s_tx) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000045 file=sdc/sd_data_master/sd_data_master.v lines=344-362
        
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000041 file=sdc/sd_data_master/sd_data_master.v lines=346-348
        if( bd_cnt == 0) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000041 file=sdc/sd_data_master/sd_data_master.v lines=346-348
           sys_adr [15:0] <= dat_in_tx; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000041 file=sdc/sd_data_master/sd_data_master.v lines=346-348
           bd_cnt <= bd_cnt+1;   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000041 file=sdc/sd_data_master/sd_data_master.v lines=346-348
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000042 file=sdc/sd_data_master/sd_data_master.v lines=349-351
        else if ( bd_cnt == 1)  begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000042 file=sdc/sd_data_master/sd_data_master.v lines=349-351
           sys_adr [31:16] <= dat_in_tx;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000042 file=sdc/sd_data_master/sd_data_master.v lines=349-351
           bd_cnt <= bd_cnt+1;    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000042 file=sdc/sd_data_master/sd_data_master.v lines=349-351
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000043 file=sdc/sd_data_master/sd_data_master.v lines=352-355
        else if ( bd_cnt == 2) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000043 file=sdc/sd_data_master/sd_data_master.v lines=352-355
          cmd_arg [15:0] <= dat_in_tx;
          re_s_tx <= 0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000043 file=sdc/sd_data_master/sd_data_master.v lines=352-355
          bd_cnt <= bd_cnt+1;    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000043 file=sdc/sd_data_master/sd_data_master.v lines=352-355
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000044 file=sdc/sd_data_master/sd_data_master.v lines=356-361
        else if ( bd_cnt == 3) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000044 file=sdc/sd_data_master/sd_data_master.v lines=356-361
           cmd_arg [31:16] <= dat_in_tx;
           re_s_tx <= 0;
           bd_cnt <= bd_cnt+1;
		   start_tx_fifo<=1;  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000044 file=sdc/sd_data_master/sd_data_master.v lines=356-361
         end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000044 file=sdc/sd_data_master/sd_data_master.v lines=356-361
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000045 file=sdc/sd_data_master/sd_data_master.v lines=344-362
       end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000045 file=sdc/sd_data_master/sd_data_master.v lines=344-362
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000005 file=sdc/sd_data_master/sd_data_master.v lines=343-363
       `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_data_master/sd_data_master.v:pp_blk:000005 file=sdc/sd_data_master/sd_data_master.v lines=343-363
     //Add Later Save last block addres for comparison with current (For multiple block cmd)
     //Add support for Pre-erased
      cmd_set <= CMD24;  
      tx_cycle <=1;   
        
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000046 file=sdc/sd_data_master/sd_data_master.v lines=322-369
   end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000046 file=sdc/sd_data_master/sd_data_master.v lines=322-369
   
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000051 file=sdc/sd_data_master/sd_data_master.v lines=371-392
     SEND_CMD : begin  
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000051 file=sdc/sd_data_master/sd_data_master.v lines=371-392
       rec_done<=0;     
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000047 file=sdc/sd_data_master/sd_data_master.v lines=373-376
       if (rx_cycle)    begin     
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000047 file=sdc/sd_data_master/sd_data_master.v lines=373-376
         re_s_rx <=0; 
         d_read<=1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000047 file=sdc/sd_data_master/sd_data_master.v lines=373-376
       end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000047 file=sdc/sd_data_master/sd_data_master.v lines=373-376
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000048 file=sdc/sd_data_master/sd_data_master.v lines=377-380
       else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000048 file=sdc/sd_data_master/sd_data_master.v lines=377-380
         re_s_tx <=0; 
         d_write<=1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000048 file=sdc/sd_data_master/sd_data_master.v lines=377-380
        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000048 file=sdc/sd_data_master/sd_data_master.v lines=377-380
       start_rx_fifo<=0; //Reset FIFO  
      // start_tx_fifo<=0;  //Reset FIFO 
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000049 file=sdc/sd_data_master/sd_data_master.v lines=383-386
       if (!cmd_busy) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000049 file=sdc/sd_data_master/sd_data_master.v lines=383-386
         we_req <= 1;  
         
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000049 file=sdc/sd_data_master/sd_data_master.v lines=383-386
       end  //When send complete change state and wait for reply
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000049 file=sdc/sd_data_master/sd_data_master.v lines=383-386
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000050 file=sdc/sd_data_master/sd_data_master.v lines=387-391
       if (we_ack) begin     
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000050 file=sdc/sd_data_master/sd_data_master.v lines=387-391
           send_done<=1;
           we_req <= 1;  
          
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000050 file=sdc/sd_data_master/sd_data_master.v lines=387-391
       end       
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000050 file=sdc/sd_data_master/sd_data_master.v lines=387-391
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000051 file=sdc/sd_data_master/sd_data_master.v lines=371-392
    end   
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000051 file=sdc/sd_data_master/sd_data_master.v lines=371-392
   
   
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000057 file=sdc/sd_data_master/sd_data_master.v lines=395-432
    RECIVE_CMD : begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000057 file=sdc/sd_data_master/sd_data_master.v lines=395-432
         //When waiting for reply fill TX fifo
        if (rx_cycle)
         start_rx_fifo<=1; //start_fifo prebuffering
       //else
         //start_rx_fifo <=1;
        
         we_req <= 0;  
          
         send_done<=0;
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000056 file=sdc/sd_data_master/sd_data_master.v lines=405-431
       if (!cmd_busy) begin //Means the sending is completed,
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000056 file=sdc/sd_data_master/sd_data_master.v lines=405-431
         d_read<=0; 
         d_write<=0;  
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000054 file=sdc/sd_data_master/sd_data_master.v lines=408-426
         if (!cmd_tsf_err) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000054 file=sdc/sd_data_master/sd_data_master.v lines=408-426
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000053 file=sdc/sd_data_master/sd_data_master.v lines=409-424
           if (card_status[0]) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000053 file=sdc/sd_data_master/sd_data_master.v lines=409-424
               
                if ( (card_status[4:1] == 4'b0100) || (card_status[4:1] == 4'b0110) || (card_status[4:1] == 4'b0101) )
                    rec_done<=1;
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000052 file=sdc/sd_data_master/sd_data_master.v lines=413-417
                else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000052 file=sdc/sd_data_master/sd_data_master.v lines=413-417
                    rec_failed<=1;
                    Dat_Int_Status[4] <=1; 
                       start_tx_fifo<=0;  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000052 file=sdc/sd_data_master/sd_data_master.v lines=413-417
                end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000052 file=sdc/sd_data_master/sd_data_master.v lines=413-417
                
                 
                                     
               //Check card_status[5:1] for state 4 or 6... 
               //If wrong state change interupt status reg,so software can put card in
               // transfer state and restart/cancel Data transfer
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000053 file=sdc/sd_data_master/sd_data_master.v lines=409-424
          end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000053 file=sdc/sd_data_master/sd_data_master.v lines=409-424
          
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000054 file=sdc/sd_data_master/sd_data_master.v lines=408-426
         end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000054 file=sdc/sd_data_master/sd_data_master.v lines=408-426
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000055 file=sdc/sd_data_master/sd_data_master.v lines=427-430
         else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000055 file=sdc/sd_data_master/sd_data_master.v lines=427-430
             rec_failed<=1;  //CRC-Error, CIC-Error or timeout 
                start_tx_fifo<=0;  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000055 file=sdc/sd_data_master/sd_data_master.v lines=427-430
                end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000055 file=sdc/sd_data_master/sd_data_master.v lines=427-430
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000056 file=sdc/sd_data_master/sd_data_master.v lines=405-431
       end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000056 file=sdc/sd_data_master/sd_data_master.v lines=405-431
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000057 file=sdc/sd_data_master/sd_data_master.v lines=395-432
    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000057 file=sdc/sd_data_master/sd_data_master.v lines=395-432
    
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000067 file=sdc/sd_data_master/sd_data_master.v lines=434-475
    DATA_TRANSFER: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000067 file=sdc/sd_data_master/sd_data_master.v lines=434-475
       CIDAT<=1;
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000059 file=sdc/sd_data_master/sd_data_master.v lines=436-441
     if (tx_cycle) begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000059 file=sdc/sd_data_master/sd_data_master.v lines=436-441
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000058 file=sdc/sd_data_master/sd_data_master.v lines=437-440
      if (tx_empt) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000058 file=sdc/sd_data_master/sd_data_master.v lines=437-440
         Dat_Int_Status[2] <=1;
         trans_failed<=1;  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000058 file=sdc/sd_data_master/sd_data_master.v lines=437-440
       end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000058 file=sdc/sd_data_master/sd_data_master.v lines=437-440
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000059 file=sdc/sd_data_master/sd_data_master.v lines=436-441
     end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000059 file=sdc/sd_data_master/sd_data_master.v lines=436-441
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000061 file=sdc/sd_data_master/sd_data_master.v lines=442-447
     else begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000061 file=sdc/sd_data_master/sd_data_master.v lines=442-447
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000060 file=sdc/sd_data_master/sd_data_master.v lines=443-446
       if (rx_full) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000060 file=sdc/sd_data_master/sd_data_master.v lines=443-446
         Dat_Int_Status[2] <=1; 
         trans_failed<=1; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000060 file=sdc/sd_data_master/sd_data_master.v lines=443-446
      end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000060 file=sdc/sd_data_master/sd_data_master.v lines=443-446
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000061 file=sdc/sd_data_master/sd_data_master.v lines=442-447
    end            
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000061 file=sdc/sd_data_master/sd_data_master.v lines=442-447
      //Check for fifo underflow, 
      //2 DO: if deteced stop transfer, reset data host
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000066 file=sdc/sd_data_master/sd_data_master.v lines=450-474
      if (internal_transm_complete) begin //Transfer complete
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000066 file=sdc/sd_data_master/sd_data_master.v lines=450-474
         ack_transfer<=1;
        
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000062 file=sdc/sd_data_master/sd_data_master.v lines=453-456
         if ((!crc_ok) && (busy_n))  begin //Wrong CRC and Data line free.
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000062 file=sdc/sd_data_master/sd_data_master.v lines=453-456
            Dat_Int_Status[5] <=1; 
            trans_failed<=1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000062 file=sdc/sd_data_master/sd_data_master.v lines=453-456
         end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000062 file=sdc/sd_data_master/sd_data_master.v lines=453-456
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000065 file=sdc/sd_data_master/sd_data_master.v lines=457-472
         else if ((crc_ok) && (busy_n)) begin //Data Line free
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000065 file=sdc/sd_data_master/sd_data_master.v lines=457-472
           trans_done <=1;       

//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000063 file=sdc/sd_data_master/sd_data_master.v lines=460-464
			if (tx_cycle) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000063 file=sdc/sd_data_master/sd_data_master.v lines=460-464
				a_cmp_tx<=1;
				if (free_tx_bd ==`BD_EMPTY-1 )
					Dat_Int_Status[0]<=1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000063 file=sdc/sd_data_master/sd_data_master.v lines=460-464
			end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000063 file=sdc/sd_data_master/sd_data_master.v lines=460-464
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000064 file=sdc/sd_data_master/sd_data_master.v lines=465-469
			else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000064 file=sdc/sd_data_master/sd_data_master.v lines=465-469
				a_cmp_rx<=1;                        
				if (free_rx_bd ==`BD_EMPTY-1)
					Dat_Int_Status[0]<=1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000064 file=sdc/sd_data_master/sd_data_master.v lines=465-469
			end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000064 file=sdc/sd_data_master/sd_data_master.v lines=465-469
    
 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000065 file=sdc/sd_data_master/sd_data_master.v lines=457-472
       end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000065 file=sdc/sd_data_master/sd_data_master.v lines=457-472
   
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000066 file=sdc/sd_data_master/sd_data_master.v lines=450-474
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000066 file=sdc/sd_data_master/sd_data_master.v lines=450-474
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000067 file=sdc/sd_data_master/sd_data_master.v lines=434-475
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000067 file=sdc/sd_data_master/sd_data_master.v lines=434-475
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000068 file=sdc/sd_data_master/sd_data_master.v lines=476-488
  STOP: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000068 file=sdc/sd_data_master/sd_data_master.v lines=476-488
    cmd_set <= CMD12;
    rec_done<=0;
    rec_failed<=0;     
    send_done<=0;  
    trans_failed<=0;
    trans_done<=0;    
    d_read<=1; 
    d_write<=1; 
    start_rx_fifo <=0;
    start_tx_fifo <=0;         
     
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000068 file=sdc/sd_data_master/sd_data_master.v lines=476-488
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000068 file=sdc/sd_data_master/sd_data_master.v lines=476-488
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000069 file=sdc/sd_data_master/sd_data_master.v lines=489-497
   STOP_SEND: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000069 file=sdc/sd_data_master/sd_data_master.v lines=489-497
      resend_try_cnt=resend_try_cnt+1;
      if (resend_try_cnt==`RESEND_MAX_CNT)
          Dat_Int_Status[1]<=1;
      if (!cmd_busy) 
         we_req <= 1;      
      if (we_ack)      
           send_done<=1;    
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000069 file=sdc/sd_data_master/sd_data_master.v lines=489-497
   end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000069 file=sdc/sd_data_master/sd_data_master.v lines=489-497
  
  //  STOP_RECIVE_CMD: begin
  //    we_req <= 0; 
  //   end
  
//__RB_CUT_TAIL__ type=case id=sdc/sd_data_master/sd_data_master.v:case:000002 file=sdc/sd_data_master/sd_data_master.v lines=251-503
  endcase  
//__RB_CUT_END__ type=case id=sdc/sd_data_master/sd_data_master.v:case:000002 file=sdc/sd_data_master/sd_data_master.v lines=251-503
  if (Dat_Int_Status_rst)
    Dat_Int_Status<=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000070 file=sdc/sd_data_master/sd_data_master.v lines=250-506
 end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000070 file=sdc/sd_data_master/sd_data_master.v lines=250-506
  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000071 file=sdc/sd_data_master/sd_data_master.v lines=222-508
end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_master/sd_data_master.v:begin_end:000071 file=sdc/sd_data_master/sd_data_master.v lines=222-508
//__RB_CUT_TAIL__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000004 file=sdc/sd_data_master/sd_data_master.v lines=221-508
//__RB_CUT_END__ type=always id=sdc/sd_data_master/sd_data_master.v:proc:000004 file=sdc/sd_data_master/sd_data_master.v lines=221-508
//__RB_CUT_GROUP_END__ type=counter_cluster id=sdc/sd_data_master/sd_data_master.v:grp:counter_cluster:000002 file=sdc/sd_data_master/sd_data_master.v lines=221-508
  
endmodule 
