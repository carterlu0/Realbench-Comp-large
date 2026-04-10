`include "sd_defines.v"
//-------------------------
//-------------------------
module sd_cmd_serial_host ( SD_CLK_IN, RST_IN, SETTING_IN ,CMD_IN, REQ_IN, ACK_OUT, REQ_OUT,ACK_IN, CMD_OUT, STATUS, cmd_dat_i, cmd_out_o, cmd_oe_o, st_dat_t);
//__RB_CUT_GROUP_BEGIN__ type=port_section id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:port_section:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=5-22
//---------------Input ports---------------
input SD_CLK_IN;
input  RST_IN;
input [15:0] SETTING_IN;   
                      
input [39:0] CMD_IN;
input   REQ_IN;
input ACK_IN;
input cmd_dat_i;

//---------------Output ports---------------
output [39:0] CMD_OUT;
output ACK_OUT;
output REQ_OUT;
output [7:0] STATUS;
output reg cmd_oe_o; 
output reg cmd_out_o;
output reg [1:0] st_dat_t;
//__RB_CUT_GROUP_END__ type=port_section id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:port_section:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=5-22
//---------------Input ports Data Type------  
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:internal_signal:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=24-45
wire SD_CLK_IN;
wire RST_IN;
wire [15:0] SETTING_IN;
wire [39:0] CMD_IN;
wire REQ_IN;
wire ACK_IN;

//---------------Output ports Data Type------  
reg  [39:0] CMD_OUT;
wire ACK_OUT  ;
reg  [7:0] STATUS;
reg  REQ_OUT;

//-------------Internal Constant-------------

//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:pp_blk:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=39-43
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:pp_blk:000001:br:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=39-40
`ifdef SIM
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:pp_blk:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=39-43
//__RB_CUT_BODY__ type=pp_ifdef_branch id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:pp_blk:000001:br:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=39-40
 `define INIT_DELAY 2
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:pp_blk:000001:br:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=39-40
//__RB_CUT_END__ type=pp_ifdef_branch id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:pp_blk:000001:br:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=39-40
//__RB_CUT_BEGIN__ type=pp_else_branch id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:pp_blk:000001:br:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=41-42
`else
//__RB_CUT_BODY__ type=pp_else_branch id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:pp_blk:000001:br:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=41-42
  `define INIT_DELAY 64
//__RB_CUT_TAIL__ type=pp_else_branch id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:pp_blk:000001:br:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=41-42
//__RB_CUT_END__ type=pp_else_branch id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:pp_blk:000001:br:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=41-42
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:pp_blk:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=39-43
 `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:pp_blk:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=39-43
  
`define NCR 2 
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:internal_signal:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=24-45
parameter SEND_SIZE = 48;
parameter SIZE = 10;
parameter CONTENT_SIZE = 40;
parameter 
    INIT   =  10'b0000_0000_01,
    IDLE   =  10'b0000_0000_10,
    WRITE_WR	    =  10'b0000_0001_00,
    DLY_WR       =  10'b0000_0010_00,
    READ_WR      =  10'b0000_0100_00,
	  DLY_READ    	=  10'b0000_1000_00, 
 	  ACK_WR		     =  10'b0001_0000_00, 
	  WRITE_WO	    =  10'b0010_0000_00, 
	  DLY_WO	      =  10'b0100_0000_00, 
	  ACK_WO	      =  10'b1000_0000_00;
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:param_decl:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=60-61
parameter Read_Delay = 7;	
parameter EIGHT_PAD = 8;
//__RB_CUT_GROUP_END__ type=param_decl id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:param_decl:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=60-61
//---------------Internal variable----------- 
//-Internal settings/buffers
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:internal_signal:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=64-106
reg [6:0] Response_Size;
reg [2:0] Delay_Cycler;
reg [CONTENT_SIZE-1:0] In_Buff; 
reg [39:0] Out_Buff;
//-Internal State input
reg Write_Read;
reg Write_Only; 

//-CRC
reg [4:0] word_select_counter;
reg CRC_RST;
reg [6:0]CRC_IN;
wire [6:0] CRC_VAL; 
reg CRC_Enable;
reg CRC_OUT;
reg CRC_Check_On;
reg Crc_Buffering;
reg CRC_Valid;
//-Internal Counterns
  //6 bit sent counter
reg [7:0]Cmd_Cnt; //8 bit recive counter
reg [2:0]Delay_Cnt; //3 bit Delay counter
//-State Variable
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
//Misc
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:param_decl:000003 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=90-91
`define Vector_Index  (CONTENT_SIZE-1-Cmd_Cnt) 
`define Bit_Nr (SEND_SIZE-Cmd_Cnt)
//__RB_CUT_GROUP_END__ type=param_decl id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:param_decl:000003 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=90-91
	
//TRI-STATE
reg block_write;
reg block_read;


//
reg [1:0]word_select;
reg FSM_ACK;
reg DECODER_ACK;

reg q;
reg Req_internal_in;
reg q1;
reg Ack_internal_in;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:internal_signal:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=64-106
//------------------------------------------   
//__RB_CUT_BEGIN__ type=instantiation id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:inst:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=108-113
sd_crc_7 CRC_7( 
CRC_OUT,
CRC_Enable,
SD_CLK_IN,
CRC_RST,
CRC_VAL);
//__RB_CUT_END__ type=instantiation id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:inst:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=108-113
//------------------------------------------  
//__RB_CUT_GROUP_BEGIN__ type=fsm id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:fsm:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=115-572
//__RB_CUT_GROUP_BEGIN__ type=handshake id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:handshake:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=115-280
//__RB_CUT_GROUP_BEGIN__ type=counter_cluster id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:counter_cluster:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=115-197
//__RB_CUT_BEGIN__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=115-197
always @ (state or Delay_Cnt or Write_Read or Cmd_Cnt or Write_Only or Ack_internal_in or  cmd_dat_i or Response_Size or Delay_Cycler)
//__RB_CUT_BODY__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=115-197
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000020 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=116-197
begin : FSM_COMBO
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000020 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=116-197
 next_state  = 0;   
//__RB_CUT_BEGIN__ type=case id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:case:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=118-196
case(state)  
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000003 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=119-129
INIT: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000003 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=119-129
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=120-122
  if (Cmd_Cnt >= `INIT_DELAY )begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=120-122
     next_state = IDLE;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=120-122
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=120-122
 
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=124-127
  else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=124-127
     
      next_state = INIT;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=124-127
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=124-127
  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000003 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=119-129
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000003 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=119-129

                                                
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000007 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=132-142
IDLE: begin        
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000007 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=132-142
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000004 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=133-135
	 if (Write_Read ) begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000004 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=133-135
        next_state = WRITE_WR;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000004 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=133-135
      end   
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000004 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=133-135
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000005 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=136-138
      else if (Write_Only  ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000005 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=136-138
        next_state = WRITE_WO;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000005 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=136-138
      end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000005 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=136-138
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000006 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=139-141
      else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000006 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=139-141
         next_state = IDLE;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000006 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=139-141
      end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000006 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=139-141
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000007 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=132-142
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000007 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=132-142
WRITE_WR: 
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000008 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=144-146
      if (Cmd_Cnt >=SEND_SIZE-1) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000008 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=144-146
        next_state = DLY_WR;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000008 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=144-146
      end      
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000008 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=144-146
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000009 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=147-149
      else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000009 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=147-149
        next_state = WRITE_WR; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000009 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=147-149
      end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000009 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=147-149
WRITE_WO: 
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000010 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=151-153
      if (Cmd_Cnt >= SEND_SIZE-1) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000010 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=151-153
        next_state = DLY_WO;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000010 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=151-153
      end      
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000010 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=151-153
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000011 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=154-156
      else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000011 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=154-156
        next_state = WRITE_WO; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000011 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=154-156
      end 	  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000011 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=154-156
DLY_WR : 
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000012 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=158-160
      if ( (Delay_Cnt >= `NCR) && ( !cmd_dat_i)) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000012 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=158-160
        next_state = READ_WR;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000012 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=158-160
      end      
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000012 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=158-160
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000013 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=161-163
      else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000013 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=161-163
        next_state = DLY_WR; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000013 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=161-163
      end 	  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000013 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=161-163
DLY_WO :
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000014 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=165-167
       if (Delay_Cnt >= Delay_Cycler) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000014 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=165-167
        next_state = ACK_WO;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000014 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=165-167
      end      
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000014 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=165-167
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000015 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=168-170
      else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000015 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=168-170
        next_state = DLY_WO; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000015 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=168-170
      end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000015 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=168-170
READ_WR : 
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000016 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=172-174
      if (Cmd_Cnt >= (Response_Size+EIGHT_PAD)) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000016 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=172-174
        next_state = DLY_READ;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000016 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=172-174
      end      
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000016 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=172-174
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000017 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=175-177
      else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000017 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=175-177
        next_state = READ_WR; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000017 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=175-177
      end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000017 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=175-177
		
ACK_WO : 
      next_state = IDLE; 
             
DLY_READ :
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000018 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=183-185
     if (Ack_internal_in ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000018 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=183-185
        next_state = ACK_WR;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000018 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=183-185
      end      
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000018 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=183-185
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000019 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=186-188
      else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000019 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=186-188
        next_state = DLY_READ; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000019 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=186-188
      end 	  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000019 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=186-188
      
ACK_WR  :
        next_state = IDLE; 


default : next_state  = INIT;
 
//__RB_CUT_TAIL__ type=case id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:case:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=118-196
 endcase     
//__RB_CUT_END__ type=case id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:case:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=118-196
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000020 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=116-197
end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000020 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=116-197
//__RB_CUT_TAIL__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=115-197
//__RB_CUT_END__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=115-197
//__RB_CUT_GROUP_END__ type=counter_cluster id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:counter_cluster:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=115-197
  //----
    	 
//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:reg_cluster:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=200-273
//__RB_CUT_BEGIN__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=200-212
always @ (posedge SD_CLK_IN or posedge RST_IN)
//__RB_CUT_BODY__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=200-212
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000023 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=201-212
begin : REQ_SYNC
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000023 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=201-212
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000021 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=202-205
	if  (RST_IN ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000021 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=202-205
		Req_internal_in <=1'b0;
		q <=1'b0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000021 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=202-205
	end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000021 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=202-205
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000022 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=206-209
	else begin  
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000022 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=206-209
		q<=REQ_IN;
		Req_internal_in<=q;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000022 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=206-209
	end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000022 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=206-209


//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000023 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=201-212
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000023 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=201-212
//__RB_CUT_TAIL__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=200-212
//__RB_CUT_END__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=200-212

//__RB_CUT_BEGIN__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000003 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=214-226
always @ (posedge SD_CLK_IN or posedge RST_IN)
//__RB_CUT_BODY__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000003 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=214-226
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000026 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=215-226
begin :ACK_SYNC
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000026 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=215-226
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000024 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=216-219
	if  (RST_IN ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000024 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=216-219
		Ack_internal_in <=1'b0;
		q1 <=1'b0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000024 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=216-219
	end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000024 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=216-219
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000025 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=220-223
	else begin  
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000025 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=220-223
		q1<=ACK_IN;
		Ack_internal_in<=q1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000025 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=220-223
	end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000025 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=220-223


//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000026 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=215-226
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000026 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=215-226
//__RB_CUT_TAIL__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000003 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=214-226
//__RB_CUT_END__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000003 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=214-226





		 
		 
//__RB_CUT_BEGIN__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000004 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=234-273
always @ (posedge SD_CLK_IN or posedge RST_IN )
//__RB_CUT_BODY__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000004 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=234-273
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000033 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=235-273
  begin:COMMAND_DECODER
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000033 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=235-273
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000027 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=236-247
  if (RST_IN ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000027 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=236-247
		  Delay_Cycler <=3'b0;
		  Response_Size <=7'b0; 
		  DECODER_ACK <= 1;
		  Write_Read<=1'b0;
	    Write_Only<=1'b0;
	    CRC_Check_On <=0;
	    In_Buff <=0;
	    block_write<=0;
	    block_read <=0;
	    word_select<=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000027 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=236-247
   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000027 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=236-247
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000032 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=248-272
   else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000032 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=248-272
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000030 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=249-266
			if (Req_internal_in == 1) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000030 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=249-266
				Response_Size[6:0] <=  SETTING_IN [6:0];
				CRC_Check_On <= SETTING_IN [7];
				Delay_Cycler[2:0] <= SETTING_IN [10:8];
				block_write <= SETTING_IN [11];
				block_read <= SETTING_IN [12];
				word_select <=SETTING_IN [14:13];
				In_Buff <= CMD_IN;
				DECODER_ACK<=0;	
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000028 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=258-261
				if (SETTING_IN [6:0]>0) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000028 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=258-261
				   Write_Read<=1'b1;
				   Write_Only<=1'b0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000028 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=258-261
				end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000028 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=258-261
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000029 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=262-265
				else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000029 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=262-265
					Write_Read<=1'b0;
				  Write_Only<=1'b1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000029 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=262-265
				end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000029 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=262-265
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000030 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=249-266
			end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000030 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=249-266
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000031 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=267-271
			else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000031 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=267-271
				Write_Read<=1'b0;
				Write_Only<=1'b0;
				DECODER_ACK <= 1;			
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000031 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=267-271
			end	
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000031 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=267-271
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000032 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=248-272
    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000032 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=248-272
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000033 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=235-273
 end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000033 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=235-273
//__RB_CUT_TAIL__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000004 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=234-273
//__RB_CUT_END__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000004 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=234-273
//__RB_CUT_GROUP_END__ type=reg_cluster id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:reg_cluster:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=200-273
//End block COMMAND_DECODER  

//-------Function for Combo logic-----------------



//__RB_CUT_BEGIN__ type=assign id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:assign:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=280-280
assign ACK_OUT = FSM_ACK & DECODER_ACK;
//__RB_CUT_END__ type=assign id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:assign:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=280-280
//__RB_CUT_GROUP_END__ type=handshake id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:handshake:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=115-280

//----------------Seq logic------------
//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:reg_cluster:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=283-572
//__RB_CUT_BEGIN__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000005 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=283-292
always @ (posedge SD_CLK_IN or posedge RST_IN   )
//__RB_CUT_BODY__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000005 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=283-292
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000036 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=284-292
begin : FSM_SEQ
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000036 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=284-292
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000034 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=285-287
  if (RST_IN ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000034 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=285-287
    state <= #1 INIT;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000034 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=285-287
 end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000034 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=285-287

//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000035 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=289-291
 else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000035 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=289-291
    state <= #1 next_state;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000035 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=289-291
 end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000035 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=289-291
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000036 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=284-292
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000036 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=284-292
//__RB_CUT_TAIL__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000005 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=283-292
//__RB_CUT_END__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000005 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=283-292

//-------------OUTPUT_LOGIC-------
//__RB_CUT_GROUP_BEGIN__ type=counter_cluster id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:counter_cluster:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=295-572
//__RB_CUT_BEGIN__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000006 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=295-572
always @ (posedge SD_CLK_IN or posedge RST_IN   )
//__RB_CUT_BODY__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000006 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=295-572
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000089 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=296-572
begin : FSM_OUT
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000089 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=296-572
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000037 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=297-317
 if (RST_IN ) begin    
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000037 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=297-317
	    CRC_Enable=0;
	    word_select_counter<=0;
	    Delay_Cnt =0;
	   	cmd_oe_o=1; 		
	    cmd_out_o = 1;  
	  	 Out_Buff =0;
	   	FSM_ACK=1;
		REQ_OUT =0;
		  CRC_RST =1;
		  CRC_OUT =0;
		  CRC_IN =0;
		  CMD_OUT =0;	
	   	Crc_Buffering =0; 
	   	STATUS = 0;
	   	CRC_Valid=0;
	   	Cmd_Cnt=0;
	   	st_dat_t<=0;
	   
   	
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000037 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=297-317
 end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000037 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=297-317
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000088 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=318-571
 else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000088 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=318-571
//__RB_CUT_BEGIN__ type=case id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:case:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=319-570
  case(state)
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000038 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=320-324
	INIT : begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000038 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=320-324
		Cmd_Cnt=Cmd_Cnt+1;
		cmd_oe_o=1; 		
		cmd_out_o = 1;  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000038 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=320-324
	end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000038 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=320-324
    
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000039 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=326-335
	IDLE : begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000039 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=326-335
		cmd_oe_o=0;      //Put CMD to Z  
		Delay_Cnt =0;
		Cmd_Cnt =0;
		CRC_RST =1;
		CRC_Enable=0; 
		CMD_OUT=0;
		st_dat_t<=0;
		word_select_counter<=0;		   
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000039 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=326-335
	end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000039 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=326-335
	
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000049 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=337-381
	WRITE_WR:   begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000049 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=337-381
	   FSM_ACK=0;
       CRC_RST =0;
	   CRC_Enable=1;  
     
   
    
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000040 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=344-347
     if (Cmd_Cnt==0) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000040 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=344-347
       STATUS = 16'b0000_0000_0000_0001;
       REQ_OUT=1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000040 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=344-347
     end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000040 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=344-347
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000041 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=348-350
     else if (Ack_internal_in) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000041 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=348-350
       REQ_OUT=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000041 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=348-350
     end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000041 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=348-350
         
        //Wait one cycle before sending, for setting up the CRC unit.
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000047 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=353-376
     if (Crc_Buffering==1)  begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000047 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=353-376
        cmd_oe_o =1;
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000044 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=355-362
        if (`Bit_Nr > 8 ) begin  // 1->40 CMD, (41 >= CNT && CNT <=47) CRC, 48 stop_bit
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000044 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=355-362
				   cmd_out_o = In_Buff[`Vector_Index]; 
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000042 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=357-359
				   if (`Bit_Nr > 9 ) begin //1 step ahead
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000042 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=357-359
			       CRC_OUT = In_Buff[`Vector_Index-1];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000042 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=357-359
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000043 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=359-361
			     end else begin
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000042 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=357-359
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000043 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=359-361
			       CRC_Enable=0;  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000043 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=359-361
				   end    
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000043 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=359-361
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000044 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=355-362
			  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000044 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=355-362
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000045 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=363-371
			  else if ( (`Bit_Nr <=8) && (`Bit_Nr >=2) ) begin			 	
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000045 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=363-371
				  CRC_Enable=0; 
				  cmd_out_o = CRC_VAL[(`Bit_Nr)-2];	
				  
		    	  if (block_read & block_write)
		    	    st_dat_t<=2'b11;
		    	  else  if  (block_read)
		    	    st_dat_t<=2'b10;    				
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000045 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=363-371
			  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000045 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=363-371
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000046 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=372-374
			  else begin        
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000046 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=372-374
				  cmd_out_o =1'b1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000046 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=372-374
			  end		
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000046 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=372-374
			  Cmd_Cnt = Cmd_Cnt+1 ;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000047 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=353-376
		end		
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000047 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=353-376
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000048 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=377-380
	  else begin //Pre load CRC
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000048 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=377-380
		    Crc_Buffering=1;
	   	  CRC_OUT = In_Buff[`Vector_Index];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000048 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=377-380
	  end	  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000048 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=377-380
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000049 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=337-381
 	end 	
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000049 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=337-381

//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000059 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=383-426
	WRITE_WO:  begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000059 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=383-426
	   FSM_ACK=0;
     CRC_RST =0;
	   CRC_Enable=1;  
         
    
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000050 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=389-392
     if (Cmd_Cnt==0) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000050 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=389-392
       STATUS[3:0] = 16'b0000_0000_0000_0010;
       REQ_OUT=1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000050 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=389-392
     end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000050 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=389-392
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000051 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=393-395
     else if (Ack_internal_in) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000051 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=393-395
       REQ_OUT=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000051 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=393-395
     end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000051 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=393-395
       
    
        
        //Wait one cycle before sending, for setting up the CRC unit.
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000057 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=400-421
     if (Crc_Buffering==1)  begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000057 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=400-421
        cmd_oe_o =1;  
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000054 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=402-410
        if (`Bit_Nr > 8 ) begin  // 1->40 CMD, (41 >= CNT && CNT <=47) CRC, 48 stop_bit
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000054 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=402-410
			     cmd_out_o = In_Buff[`Vector_Index]; 
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000052 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=404-406
			     if (`Bit_Nr > 9 ) begin //1 step ahead
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000052 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=404-406
			        CRC_OUT = In_Buff[`Vector_Index-1];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000052 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=404-406
			     end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000052 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=404-406
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000053 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=407-409
           else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000053 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=407-409
			        CRC_Enable=0;  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000053 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=407-409
			     end    
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000053 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=407-409
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000054 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=402-410
		    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000054 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=402-410
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000055 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=411-416
		    else if( (`Bit_Nr <=8) && (`Bit_Nr >=2) ) begin			 	
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000055 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=411-416
			     CRC_Enable=0; 
		       cmd_out_o = CRC_VAL[(`Bit_Nr)-2];	
		       if  (block_read)
		    	    st_dat_t<=2'b10;			
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000055 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=411-416
		    end		 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000055 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=411-416
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000056 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=417-419
	  	   else begin        
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000056 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=417-419
		  	    cmd_out_o =1'b1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000056 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=417-419
		    end		
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000056 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=417-419
			  Cmd_Cnt = Cmd_Cnt+1;	
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000057 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=400-421
		end		
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000057 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=400-421
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000058 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=422-425
		else begin //Pre load CRC
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000058 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=422-425
		   Crc_Buffering=1;
	   	 CRC_OUT = In_Buff[`Vector_Index];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000058 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=422-425
	  end	  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000058 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=422-425
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000059 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=383-426
 	end 	
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000059 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=383-426
	
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000062 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=428-443
	DLY_WR :  begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000062 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=428-443
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000060 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=429-432
	   if (Delay_Cnt==0) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000060 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=429-432
         STATUS[3:0] = 4'b0011;
         REQ_OUT=1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000060 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=429-432
      end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000060 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=429-432
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000061 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=433-435
      else if (Ack_internal_in) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000061 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=433-435
       REQ_OUT=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000061 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=433-435
     end      
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000061 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=433-435
		  CRC_Enable=0;
		  CRC_RST =1;
		  Cmd_Cnt = 1; 
		  cmd_oe_o=0; 	
		  if (Delay_Cnt<3'b111)
		    Delay_Cnt =Delay_Cnt+1;  
		  Crc_Buffering=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000062 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=428-443
    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000062 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=428-443
	
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000065 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=445-461
    DLY_WO :  begin  
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000065 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=445-461
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000063 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=446-451
      if (Delay_Cnt==0) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000063 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=446-451
         STATUS[3:0] = 4'b0100;
         STATUS[5] = 0;
         STATUS[6] = 1;
         REQ_OUT=1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000063 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=446-451
      end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000063 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=446-451
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000064 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=452-454
      else if (Ack_internal_in) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000064 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=452-454
       REQ_OUT=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000064 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=452-454
     end   
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000064 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=452-454
		  CRC_Enable=0;
		  CRC_RST =1;
		  Cmd_Cnt = 0; 
		  cmd_oe_o=0;
	    Delay_Cnt =Delay_Cnt+1;  
	    Crc_Buffering=0;     
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000065 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=445-461
    end	
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000065 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=445-461
    
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000082 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=463-537
    READ_WR :  begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000082 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=463-537
      Delay_Cnt =0;
      CRC_RST =0;
	    CRC_Enable=1;        
      cmd_oe_o =0;
      
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000066 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=469-473
	   if (Cmd_Cnt==1) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000066 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=469-473
       STATUS[3:0] = 16'b0000_0000_0000_0101;
       REQ_OUT=1;
       Out_Buff[39]=0; //startbit (0)
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000066 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=469-473
     end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000066 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=469-473
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000067 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=474-476
     else if (Ack_internal_in) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000067 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=474-476
       REQ_OUT=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000067 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=474-476
     end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000067 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=474-476
	     
	     
	     
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000077 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=480-516
      if (Cmd_Cnt < (Response_Size))begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000077 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=480-516
        
        if (Cmd_Cnt<8 ) //1+1+6 (S,T,Index)          
          Out_Buff[39-Cmd_Cnt] = cmd_dat_i; 
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000076 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=484-513
        else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000076 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=484-513
          
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000069 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=486-491
          if (word_select == 2'b00) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000069 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=486-491
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000068 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=487-490
            if(Cmd_Cnt<40) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000068 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=487-490
		          word_select_counter<= word_select_counter+1;
		          Out_Buff[31-word_select_counter] = cmd_dat_i;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000068 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=487-490
		         end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000068 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=487-490
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000069 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=486-491
		      end    
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000069 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=486-491
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000071 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=492-498
          else if (word_select == 2'b01) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000071 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=492-498
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000070 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=493-496
            if ( (Cmd_Cnt>=40) && (Cmd_Cnt<72) )begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000070 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=493-496
		          word_select_counter<= word_select_counter+1;
		          Out_Buff[31-word_select_counter] = cmd_dat_i;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000070 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=493-496
		         end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000070 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=493-496
		      
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000071 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=492-498
		      end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000071 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=492-498
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000073 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=499-504
          else if  (word_select == 2'b10) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000073 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=499-504
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000072 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=500-503
           if ( (Cmd_Cnt>=72) && (Cmd_Cnt<104) )begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000072 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=500-503
		          word_select_counter<= word_select_counter+1;
		          Out_Buff[31-word_select_counter] = cmd_dat_i;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000072 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=500-503
		         end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000072 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=500-503
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000073 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=499-504
		      end	     
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000073 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=499-504
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000075 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=505-510
          else if  (word_select == 2'b11) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000075 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=505-510
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000074 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=506-509
           if ( (Cmd_Cnt>=104) && (Cmd_Cnt<128) )begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000074 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=506-509
		          word_select_counter<= word_select_counter+1;
		          Out_Buff[31-word_select_counter] = cmd_dat_i;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000074 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=506-509
		         end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000074 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=506-509
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000075 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=505-510
		      end	  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000075 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=505-510
          
          
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000076 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=484-513
		    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000076 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=484-513
		    CRC_OUT = cmd_dat_i;  
		        
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000077 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=480-516
      end       
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000077 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=480-516
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000078 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=517-520
      else if ( Cmd_Cnt - Response_Size <=6 ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000078 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=517-520
			  CRC_IN [(Response_Size+6)-(Cmd_Cnt)] = cmd_dat_i;
			  CRC_Enable=0;  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000078 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=517-520
      end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000078 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=517-520
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000081 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=521-535
      else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000081 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=521-535
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000079 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=522-525
			   if ((CRC_IN != CRC_VAL) && ( CRC_Check_On == 1)) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000079 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=522-525
				   CRC_Valid=0;	
				   CRC_Enable=0;			  			
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000079 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=522-525
		    	end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000079 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=522-525
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000080 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=526-529
		    	else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000080 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=526-529
		    	CRC_Valid=1;
		    	CRC_Enable=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000080 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=526-529
		    	end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000080 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=526-529
		    	if (block_read & block_write)
		    	    st_dat_t<=2'b11;
		    	else if (block_write)
		    	  st_dat_t<=2'b01;
		    	 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000081 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=521-535
      end        
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000081 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=521-535
       Cmd_Cnt = Cmd_Cnt+1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000082 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=463-537
   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000082 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=463-537
    
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000085 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=539-558
   DLY_READ:  begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000085 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=539-558
     
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000083 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=541-546
     if (Delay_Cnt==0) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000083 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=541-546
       STATUS[3:0] = 4'b0110;
       STATUS[5] = CRC_Valid;
       STATUS[6] = 1;
       REQ_OUT=1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000083 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=541-546
     end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000083 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=541-546
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000084 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=547-549
     else if (Ack_internal_in) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000084 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=547-549
       REQ_OUT=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000084 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=547-549
     end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000084 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=547-549
        
		  CRC_Enable=0;
		  CRC_RST =1;
		  Cmd_Cnt = 0; 		 
		  cmd_oe_o=0; 
      
      CMD_OUT[39:0]=Out_Buff;
		  Delay_Cnt =Delay_Cnt+1;       
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000085 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=539-558
    end	
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000085 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=539-558
    
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000086 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=560-562
	ACK_WO:  begin    
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000086 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=560-562
		  FSM_ACK=1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000086 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=560-562
    end	
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000086 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=560-562
	
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000087 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=564-568
	ACK_WR:  begin    
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000087 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=564-568
		  FSM_ACK=1;
		  REQ_OUT =0;	
		
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000087 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=564-568
    end	
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000087 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=564-568
	
//__RB_CUT_TAIL__ type=case id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:case:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=319-570
   endcase
//__RB_CUT_END__ type=case id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:case:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=319-570
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000088 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=318-571
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000088 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=318-571
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000089 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=296-572
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:begin_end:000089 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=296-572
//__RB_CUT_TAIL__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000006 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=295-572
//__RB_CUT_END__ type=always id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:proc:000006 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=295-572
//__RB_CUT_GROUP_END__ type=counter_cluster id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:counter_cluster:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=295-572
//__RB_CUT_GROUP_END__ type=reg_cluster id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:reg_cluster:000002 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=283-572
//__RB_CUT_GROUP_END__ type=fsm id=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v:grp:fsm:000001 file=sdc/sd_cmd_serial_host/sd_cmd_serial_host.v lines=115-572
  
  
endmodule


