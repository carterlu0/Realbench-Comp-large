`include "sd_defines.v"
module sd_cmd_master(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=sdc/sd_cmd_master/sd_cmd_master.v:grp:port_section:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=3-32
input CLK_PAD_IO,

input RST_PAD_I,
input New_CMD,
input data_write,
input data_read,



input [31:0]ARG_REG,
input [13:0]CMD_SET_REG,
input [15:0] TIMEOUT_REG,
output reg [15:0] STATUS_REG,
output reg [31:0] RESP_1_REG,

output reg [4:0] ERR_INT_REG, 
output reg [15:0] NORMAL_INT_REG, 
input ERR_INT_RST,
input NORMAL_INT_RST,

output reg [15:0] settings,
output reg go_idle_o,
output reg  [39:0] cmd_out,
output reg req_out,
output reg ack_out,
input req_in,
input ack_in,
input [39:0] cmd_in,
input [7:0] serial_status,
input card_detect
//__RB_CUT_GROUP_END__ type=port_section id=sdc/sd_cmd_master/sd_cmd_master.v:grp:port_section:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=3-32
);
 
  







//__RB_CUT_GROUP_BEGIN__ type=param_decl id=sdc/sd_cmd_master/sd_cmd_master.v:grp:param_decl:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=43-58
`define dat_ava status[6]
`define crc_valid status[5] 
`define small_rsp 7'b0101000
`define big_rsp 7'b1111111

`define CMDI CMD_SET_REG[13:8]
`define WORD_SELECT CMD_SET_REG[7:6]
`define CICE CMD_SET_REG[4]
`define CRCE CMD_SET_REG[3]
`define RTS CMD_SET_REG[1:0]
`define CTE ERR_INT_REG[0]
`define CCRCE ERR_INT_REG[1]
`define CIE  ERR_INT_REG[3]
`define EI NORMAL_INT_REG[15]
`define CC  NORMAL_INT_REG[0]
`define CICMD STATUS_REG[0]
//__RB_CUT_GROUP_END__ type=param_decl id=sdc/sd_cmd_master/sd_cmd_master.v:grp:param_decl:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=43-58
             

//-----------Types--------------------------------------------------------

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_cmd_master/sd_cmd_master.v:grp:internal_signal:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=63-75
reg CRC_check_enable;
reg index_check_enable;
reg [6:0]response_size;


reg card_present;


reg [3:0]debounce;

reg [15:0]status;
reg [15:0]  Watchdog_Cnt;
reg complete;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_cmd_master/sd_cmd_master.v:grp:internal_signal:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=63-75



//__RB_CUT_GROUP_BEGIN__ type=param_decl id=sdc/sd_cmd_master/sd_cmd_master.v:grp:param_decl:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=79-79
parameter SIZE = 3;
//__RB_CUT_GROUP_END__ type=param_decl id=sdc/sd_cmd_master/sd_cmd_master.v:grp:param_decl:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=79-79
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_cmd_master/sd_cmd_master.v:grp:internal_signal:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=80-81
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_cmd_master/sd_cmd_master.v:grp:internal_signal:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=80-81

//__RB_CUT_GROUP_BEGIN__ type=param_decl id=sdc/sd_cmd_master/sd_cmd_master.v:grp:param_decl:000003 file=sdc/sd_cmd_master/sd_cmd_master.v lines=83-85
parameter IDLE   =  3'b001;
parameter SETUP   =  3'b010;
parameter EXECUTE  =  3'b100;
//__RB_CUT_GROUP_END__ type=param_decl id=sdc/sd_cmd_master/sd_cmd_master.v:grp:param_decl:000003 file=sdc/sd_cmd_master/sd_cmd_master.v lines=83-85
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_cmd_master/sd_cmd_master.v:grp:internal_signal:000003 file=sdc/sd_cmd_master/sd_cmd_master.v lines=86-89
reg ack_in_int;
reg ack_q;
reg req_q;
reg req_in_int;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_cmd_master/sd_cmd_master.v:grp:internal_signal:000003 file=sdc/sd_cmd_master/sd_cmd_master.v lines=86-89

//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=sdc/sd_cmd_master/sd_cmd_master.v:grp:reg_cluster:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=91-141
//__RB_CUT_BEGIN__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=91-101
always @ (posedge CLK_PAD_IO or posedge RST_PAD_I   )
//__RB_CUT_BODY__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=91-101
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000003 file=sdc/sd_cmd_master/sd_cmd_master.v lines=92-101
begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000003 file=sdc/sd_cmd_master/sd_cmd_master.v lines=92-101
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=93-96
  if (RST_PAD_I) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=93-96
    req_q<=0;
    req_in_int<=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=93-96
 end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=93-96
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=97-100
else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=97-100
  req_q<=req_in;  
  req_in_int<=req_q;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=97-100
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=97-100
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000003 file=sdc/sd_cmd_master/sd_cmd_master.v lines=92-101
end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000003 file=sdc/sd_cmd_master/sd_cmd_master.v lines=92-101
//__RB_CUT_TAIL__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=91-101
//__RB_CUT_END__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=91-101

//---------------Input ports---------------


//__RB_CUT_BEGIN__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=106-125
always @ (posedge CLK_PAD_IO or posedge RST_PAD_I   )
//__RB_CUT_BODY__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=106-125
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000007 file=sdc/sd_cmd_master/sd_cmd_master.v lines=107-125
begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000007 file=sdc/sd_cmd_master/sd_cmd_master.v lines=107-125
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000004 file=sdc/sd_cmd_master/sd_cmd_master.v lines=108-111
  if (RST_PAD_I) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000004 file=sdc/sd_cmd_master/sd_cmd_master.v lines=108-111
    debounce<=0;
    card_present<=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000004 file=sdc/sd_cmd_master/sd_cmd_master.v lines=108-111
 end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000004 file=sdc/sd_cmd_master/sd_cmd_master.v lines=108-111
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000006 file=sdc/sd_cmd_master/sd_cmd_master.v lines=112-124
else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000006 file=sdc/sd_cmd_master/sd_cmd_master.v lines=112-124
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000005 file=sdc/sd_cmd_master/sd_cmd_master.v lines=113-116
	if (!card_detect) begin//Card present
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000005 file=sdc/sd_cmd_master/sd_cmd_master.v lines=113-116
		if (debounce!=4'b1111)
			debounce<=debounce+1'b1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000005 file=sdc/sd_cmd_master/sd_cmd_master.v lines=113-116
	end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000005 file=sdc/sd_cmd_master/sd_cmd_master.v lines=113-116
	else	
		 debounce<=0;

	if (debounce==4'b1111)
       card_present<=1'b1;
	else 
	   card_present<=1'b0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000006 file=sdc/sd_cmd_master/sd_cmd_master.v lines=112-124
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000006 file=sdc/sd_cmd_master/sd_cmd_master.v lines=112-124
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000007 file=sdc/sd_cmd_master/sd_cmd_master.v lines=107-125
end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000007 file=sdc/sd_cmd_master/sd_cmd_master.v lines=107-125
//__RB_CUT_TAIL__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=106-125
//__RB_CUT_END__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=106-125



//__RB_CUT_BEGIN__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000003 file=sdc/sd_cmd_master/sd_cmd_master.v lines=129-141
always @ (posedge CLK_PAD_IO or posedge RST_PAD_I   )
//__RB_CUT_BODY__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000003 file=sdc/sd_cmd_master/sd_cmd_master.v lines=129-141
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000010 file=sdc/sd_cmd_master/sd_cmd_master.v lines=130-141
begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000010 file=sdc/sd_cmd_master/sd_cmd_master.v lines=130-141
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000008 file=sdc/sd_cmd_master/sd_cmd_master.v lines=131-134
  if (RST_PAD_I) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000008 file=sdc/sd_cmd_master/sd_cmd_master.v lines=131-134
    ack_q<=0;
    ack_in_int<=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000008 file=sdc/sd_cmd_master/sd_cmd_master.v lines=131-134
 end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000008 file=sdc/sd_cmd_master/sd_cmd_master.v lines=131-134
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000009 file=sdc/sd_cmd_master/sd_cmd_master.v lines=135-138
else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000009 file=sdc/sd_cmd_master/sd_cmd_master.v lines=135-138
  ack_q<=ack_in;
  ack_in_int<=ack_q;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000009 file=sdc/sd_cmd_master/sd_cmd_master.v lines=135-138
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000009 file=sdc/sd_cmd_master/sd_cmd_master.v lines=135-138
  
  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000010 file=sdc/sd_cmd_master/sd_cmd_master.v lines=130-141
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000010 file=sdc/sd_cmd_master/sd_cmd_master.v lines=130-141
//__RB_CUT_TAIL__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000003 file=sdc/sd_cmd_master/sd_cmd_master.v lines=129-141
//__RB_CUT_END__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000003 file=sdc/sd_cmd_master/sd_cmd_master.v lines=129-141
//__RB_CUT_GROUP_END__ type=reg_cluster id=sdc/sd_cmd_master/sd_cmd_master.v:grp:reg_cluster:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=91-141



//__RB_CUT_GROUP_BEGIN__ type=fsm id=sdc/sd_cmd_master/sd_cmd_master.v:grp:fsm:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=145-191
//__RB_CUT_BEGIN__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000004 file=sdc/sd_cmd_master/sd_cmd_master.v lines=145-178
always @ ( state or New_CMD or complete or ack_in_int )
//__RB_CUT_BODY__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000004 file=sdc/sd_cmd_master/sd_cmd_master.v lines=145-178
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000018 file=sdc/sd_cmd_master/sd_cmd_master.v lines=146-178
begin : FSM_COMBO
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000018 file=sdc/sd_cmd_master/sd_cmd_master.v lines=146-178
    next_state = 0;

//__RB_CUT_BEGIN__ type=case id=sdc/sd_cmd_master/sd_cmd_master.v:case:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=149-176
 case(state)
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000013 file=sdc/sd_cmd_master/sd_cmd_master.v lines=150-157
 IDLE:   begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000013 file=sdc/sd_cmd_master/sd_cmd_master.v lines=150-157
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000011 file=sdc/sd_cmd_master/sd_cmd_master.v lines=151-153
      if (New_CMD) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000011 file=sdc/sd_cmd_master/sd_cmd_master.v lines=151-153
          next_state = SETUP;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000011 file=sdc/sd_cmd_master/sd_cmd_master.v lines=151-153
      end     
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000011 file=sdc/sd_cmd_master/sd_cmd_master.v lines=151-153
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000012 file=sdc/sd_cmd_master/sd_cmd_master.v lines=154-156
      else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000012 file=sdc/sd_cmd_master/sd_cmd_master.v lines=154-156
         next_state = IDLE;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000012 file=sdc/sd_cmd_master/sd_cmd_master.v lines=154-156
      end   
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000012 file=sdc/sd_cmd_master/sd_cmd_master.v lines=154-156
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000013 file=sdc/sd_cmd_master/sd_cmd_master.v lines=150-157
 end       
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000013 file=sdc/sd_cmd_master/sd_cmd_master.v lines=150-157
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000014 file=sdc/sd_cmd_master/sd_cmd_master.v lines=158-163
 SETUP:begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000014 file=sdc/sd_cmd_master/sd_cmd_master.v lines=158-163
    if (ack_in_int)             
       next_state = EXECUTE;  
     else   
       next_state = SETUP;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000014 file=sdc/sd_cmd_master/sd_cmd_master.v lines=158-163
   end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000014 file=sdc/sd_cmd_master/sd_cmd_master.v lines=158-163
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000017 file=sdc/sd_cmd_master/sd_cmd_master.v lines=164-171
 EXECUTE:    begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000017 file=sdc/sd_cmd_master/sd_cmd_master.v lines=164-171
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000015 file=sdc/sd_cmd_master/sd_cmd_master.v lines=165-167
       if (complete) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000015 file=sdc/sd_cmd_master/sd_cmd_master.v lines=165-167
          next_state = IDLE;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000015 file=sdc/sd_cmd_master/sd_cmd_master.v lines=165-167
      end     
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000015 file=sdc/sd_cmd_master/sd_cmd_master.v lines=165-167
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000016 file=sdc/sd_cmd_master/sd_cmd_master.v lines=168-170
      else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000016 file=sdc/sd_cmd_master/sd_cmd_master.v lines=168-170
         next_state = EXECUTE;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000016 file=sdc/sd_cmd_master/sd_cmd_master.v lines=168-170
      end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000016 file=sdc/sd_cmd_master/sd_cmd_master.v lines=168-170
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000017 file=sdc/sd_cmd_master/sd_cmd_master.v lines=164-171
 end       
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000017 file=sdc/sd_cmd_master/sd_cmd_master.v lines=164-171
   
  
 default : next_state  = IDLE;
 
//__RB_CUT_TAIL__ type=case id=sdc/sd_cmd_master/sd_cmd_master.v:case:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=149-176
 endcase 
//__RB_CUT_END__ type=case id=sdc/sd_cmd_master/sd_cmd_master.v:case:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=149-176
    
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000018 file=sdc/sd_cmd_master/sd_cmd_master.v lines=146-178
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000018 file=sdc/sd_cmd_master/sd_cmd_master.v lines=146-178
//__RB_CUT_TAIL__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000004 file=sdc/sd_cmd_master/sd_cmd_master.v lines=145-178
//__RB_CUT_END__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000004 file=sdc/sd_cmd_master/sd_cmd_master.v lines=145-178

 
 

//__RB_CUT_BEGIN__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000005 file=sdc/sd_cmd_master/sd_cmd_master.v lines=183-191
always @ (posedge CLK_PAD_IO or posedge RST_PAD_I   )
//__RB_CUT_BODY__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000005 file=sdc/sd_cmd_master/sd_cmd_master.v lines=183-191
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000021 file=sdc/sd_cmd_master/sd_cmd_master.v lines=184-191
begin : FSM_SEQ
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000021 file=sdc/sd_cmd_master/sd_cmd_master.v lines=184-191
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000019 file=sdc/sd_cmd_master/sd_cmd_master.v lines=185-187
  if (RST_PAD_I ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000019 file=sdc/sd_cmd_master/sd_cmd_master.v lines=185-187
    state <= #1 IDLE;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000019 file=sdc/sd_cmd_master/sd_cmd_master.v lines=185-187
 end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000019 file=sdc/sd_cmd_master/sd_cmd_master.v lines=185-187
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000020 file=sdc/sd_cmd_master/sd_cmd_master.v lines=188-190
 else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000020 file=sdc/sd_cmd_master/sd_cmd_master.v lines=188-190
    state <= #1 next_state;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000020 file=sdc/sd_cmd_master/sd_cmd_master.v lines=188-190
 end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000020 file=sdc/sd_cmd_master/sd_cmd_master.v lines=188-190
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000021 file=sdc/sd_cmd_master/sd_cmd_master.v lines=184-191
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000021 file=sdc/sd_cmd_master/sd_cmd_master.v lines=184-191
//__RB_CUT_TAIL__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000005 file=sdc/sd_cmd_master/sd_cmd_master.v lines=183-191
//__RB_CUT_END__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000005 file=sdc/sd_cmd_master/sd_cmd_master.v lines=183-191
//__RB_CUT_GROUP_END__ type=fsm id=sdc/sd_cmd_master/sd_cmd_master.v:grp:fsm:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=145-191



//__RB_CUT_GROUP_BEGIN__ type=counter_cluster id=sdc/sd_cmd_master/sd_cmd_master.v:grp:counter_cluster:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=195-323
//__RB_CUT_BEGIN__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000006 file=sdc/sd_cmd_master/sd_cmd_master.v lines=195-323
always @ (posedge CLK_PAD_IO or posedge RST_PAD_I   )
//__RB_CUT_BODY__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000006 file=sdc/sd_cmd_master/sd_cmd_master.v lines=195-323
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000038 file=sdc/sd_cmd_master/sd_cmd_master.v lines=196-323
begin  
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000038 file=sdc/sd_cmd_master/sd_cmd_master.v lines=196-323
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000022 file=sdc/sd_cmd_master/sd_cmd_master.v lines=197-218
 if (RST_PAD_I ) begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000022 file=sdc/sd_cmd_master/sd_cmd_master.v lines=197-218
    CRC_check_enable=0;
    complete =0;
    RESP_1_REG = 0;
 
    ERR_INT_REG =0;
    NORMAL_INT_REG=0;
    STATUS_REG=0;
    status=0; 
    cmd_out =0 ;
    settings=0;
    response_size=0;
    req_out=0;
    index_check_enable=0; 
    ack_out=0; 
    Watchdog_Cnt=0;
    
    `CCRCE=0;
    `EI = 0;
    `CC = 0; 
     go_idle_o=0;  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000022 file=sdc/sd_cmd_master/sd_cmd_master.v lines=197-218
 end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000022 file=sdc/sd_cmd_master/sd_cmd_master.v lines=197-218
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000037 file=sdc/sd_cmd_master/sd_cmd_master.v lines=219-322
 else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000037 file=sdc/sd_cmd_master/sd_cmd_master.v lines=219-322
 NORMAL_INT_REG[1] = card_present;
 NORMAL_INT_REG[2] = ~card_present;
 complete=0;
//__RB_CUT_BEGIN__ type=case id=sdc/sd_cmd_master/sd_cmd_master.v:case:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=223-317
 case(state)
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000024 file=sdc/sd_cmd_master/sd_cmd_master.v lines=224-235
 IDLE: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000024 file=sdc/sd_cmd_master/sd_cmd_master.v lines=224-235
    go_idle_o=0;  
    req_out=0;
		ack_out =0;
		`CICMD =0; 
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000023 file=sdc/sd_cmd_master/sd_cmd_master.v lines=229-234
    if ( req_in_int == 1) begin     //Status change
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000023 file=sdc/sd_cmd_master/sd_cmd_master.v lines=229-234
        status=serial_status;
        ack_out = 1;
      
        
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000023 file=sdc/sd_cmd_master/sd_cmd_master.v lines=229-234
    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000023 file=sdc/sd_cmd_master/sd_cmd_master.v lines=229-234
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000024 file=sdc/sd_cmd_master/sd_cmd_master.v lines=224-235
 end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000024 file=sdc/sd_cmd_master/sd_cmd_master.v lines=224-235
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000028 file=sdc/sd_cmd_master/sd_cmd_master.v lines=236-266
 SETUP:  begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000028 file=sdc/sd_cmd_master/sd_cmd_master.v lines=236-266
     
     NORMAL_INT_REG=0; 
     ERR_INT_REG =0;
  
     index_check_enable = `CICE; 
     CRC_check_enable = `CRCE;
    
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000025 file=sdc/sd_cmd_master/sd_cmd_master.v lines=244-246
    if ( (`RTS  == 2'b10 ) || ( `RTS == 2'b11)) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000025 file=sdc/sd_cmd_master/sd_cmd_master.v lines=244-246
      response_size =  7'b0101000; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000025 file=sdc/sd_cmd_master/sd_cmd_master.v lines=244-246
    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000025 file=sdc/sd_cmd_master/sd_cmd_master.v lines=244-246
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000026 file=sdc/sd_cmd_master/sd_cmd_master.v lines=247-249
    else if (`RTS == 2'b01) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000026 file=sdc/sd_cmd_master/sd_cmd_master.v lines=247-249
      response_size = 7'b1111111; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000026 file=sdc/sd_cmd_master/sd_cmd_master.v lines=247-249
    end    
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000026 file=sdc/sd_cmd_master/sd_cmd_master.v lines=247-249
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000027 file=sdc/sd_cmd_master/sd_cmd_master.v lines=250-252
    else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000027 file=sdc/sd_cmd_master/sd_cmd_master.v lines=250-252
       response_size=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000027 file=sdc/sd_cmd_master/sd_cmd_master.v lines=250-252
    end    
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000027 file=sdc/sd_cmd_master/sd_cmd_master.v lines=250-252
    
    cmd_out[39:38]=2'b01;         
    cmd_out[37:32]=`CMDI;  //CMD_INDEX
    cmd_out[31:0]= ARG_REG;           //CMD_Argument      
    settings[14:13]=`WORD_SELECT;             //Reserved
    settings[12] = data_read; //Type of command
    settings[11] = data_write;
    settings[10:8]=3'b111;            //Delay
    settings[7]=`CRCE;         //CRC-check
    settings[6:0]=response_size;   //response size    
    Watchdog_Cnt = 0;
    
    `CICMD =1;    
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000028 file=sdc/sd_cmd_master/sd_cmd_master.v lines=236-266
 end   
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000028 file=sdc/sd_cmd_master/sd_cmd_master.v lines=236-266
 
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000036 file=sdc/sd_cmd_master/sd_cmd_master.v lines=268-316
 EXECUTE: begin   
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000036 file=sdc/sd_cmd_master/sd_cmd_master.v lines=268-316
    Watchdog_Cnt = Watchdog_Cnt +1;
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000030 file=sdc/sd_cmd_master/sd_cmd_master.v lines=270-277
    if (Watchdog_Cnt>TIMEOUT_REG) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000030 file=sdc/sd_cmd_master/sd_cmd_master.v lines=270-277
      `CTE=1;
      `EI = 1;
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000029 file=sdc/sd_cmd_master/sd_cmd_master.v lines=273-275
      if (ack_in == 1) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000029 file=sdc/sd_cmd_master/sd_cmd_master.v lines=273-275
         complete=1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000029 file=sdc/sd_cmd_master/sd_cmd_master.v lines=273-275
      end   
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000029 file=sdc/sd_cmd_master/sd_cmd_master.v lines=273-275
      go_idle_o=1; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000030 file=sdc/sd_cmd_master/sd_cmd_master.v lines=270-277
    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000030 file=sdc/sd_cmd_master/sd_cmd_master.v lines=270-277
    
    //Default
    req_out=0;
		ack_out =0;
    
    //Start sending when serial module is ready
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000031 file=sdc/sd_cmd_master/sd_cmd_master.v lines=284-286
   	if (ack_in_int == 1) begin	    	     
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000031 file=sdc/sd_cmd_master/sd_cmd_master.v lines=284-286
	    		req_out =1;	   			   		
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000031 file=sdc/sd_cmd_master/sd_cmd_master.v lines=284-286
	  end	
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000031 file=sdc/sd_cmd_master/sd_cmd_master.v lines=284-286
	   //Incoming New Status 
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000035 file=sdc/sd_cmd_master/sd_cmd_master.v lines=288-315
	  else if ( req_in_int == 1) begin   
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000035 file=sdc/sd_cmd_master/sd_cmd_master.v lines=288-315
        status=serial_status;
      
        ack_out = 1; 
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000034 file=sdc/sd_cmd_master/sd_cmd_master.v lines=292-314
        if ( `dat_ava ) begin //Data avaible
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000034 file=sdc/sd_cmd_master/sd_cmd_master.v lines=292-314
           complete=1;
            `EI = 0;
             
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000032 file=sdc/sd_cmd_master/sd_cmd_master.v lines=296-300
           if (CRC_check_enable & ~`crc_valid) begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000032 file=sdc/sd_cmd_master/sd_cmd_master.v lines=296-300
            `CCRCE=1;
            `EI = 1;
             
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000032 file=sdc/sd_cmd_master/sd_cmd_master.v lines=296-300
           end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000032 file=sdc/sd_cmd_master/sd_cmd_master.v lines=296-300
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000033 file=sdc/sd_cmd_master/sd_cmd_master.v lines=301-305
           if (index_check_enable &  (cmd_out[37:32] != cmd_in [37:32]) ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000033 file=sdc/sd_cmd_master/sd_cmd_master.v lines=301-305
            `CIE=1;
            `EI = 1;
            
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000033 file=sdc/sd_cmd_master/sd_cmd_master.v lines=301-305
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000033 file=sdc/sd_cmd_master/sd_cmd_master.v lines=301-305
          
             
             `CC = 1;  
            
             if (response_size !=0)
              RESP_1_REG=cmd_in[31:0];
            
          // end 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000034 file=sdc/sd_cmd_master/sd_cmd_master.v lines=292-314
         end ////Data avaible
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000034 file=sdc/sd_cmd_master/sd_cmd_master.v lines=292-314
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000035 file=sdc/sd_cmd_master/sd_cmd_master.v lines=288-315
       end //Status change
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000035 file=sdc/sd_cmd_master/sd_cmd_master.v lines=288-315
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000036 file=sdc/sd_cmd_master/sd_cmd_master.v lines=268-316
     end //EXECUTE state
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000036 file=sdc/sd_cmd_master/sd_cmd_master.v lines=268-316
//__RB_CUT_TAIL__ type=case id=sdc/sd_cmd_master/sd_cmd_master.v:case:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=223-317
   endcase
//__RB_CUT_END__ type=case id=sdc/sd_cmd_master/sd_cmd_master.v:case:000002 file=sdc/sd_cmd_master/sd_cmd_master.v lines=223-317
   if (ERR_INT_RST)
     ERR_INT_REG=0;
   if (NORMAL_INT_RST)
     NORMAL_INT_REG=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000037 file=sdc/sd_cmd_master/sd_cmd_master.v lines=219-322
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000037 file=sdc/sd_cmd_master/sd_cmd_master.v lines=219-322
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000038 file=sdc/sd_cmd_master/sd_cmd_master.v lines=196-323
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_cmd_master/sd_cmd_master.v:begin_end:000038 file=sdc/sd_cmd_master/sd_cmd_master.v lines=196-323
//__RB_CUT_TAIL__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000006 file=sdc/sd_cmd_master/sd_cmd_master.v lines=195-323
//__RB_CUT_END__ type=always id=sdc/sd_cmd_master/sd_cmd_master.v:proc:000006 file=sdc/sd_cmd_master/sd_cmd_master.v lines=195-323
//__RB_CUT_GROUP_END__ type=counter_cluster id=sdc/sd_cmd_master/sd_cmd_master.v:grp:counter_cluster:000001 file=sdc/sd_cmd_master/sd_cmd_master.v lines=195-323

endmodule
