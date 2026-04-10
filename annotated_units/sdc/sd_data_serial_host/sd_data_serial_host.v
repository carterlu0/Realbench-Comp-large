

`include "sd_defines.v"


module sd_data_serial_host(
//__RB_CUT_GROUP_BEGIN__ type=port_section id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:port_section:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=7-26
input sd_clk,
input rst,
//Tx Fifo
input [31:0] data_in ,

output reg rd,
//Rx Fifo
output  reg  [`SD_BUS_W-1:0] data_out ,
output reg we,
//tristate data
output reg DAT_oe_o,
output reg[`SD_BUS_W-1:0] DAT_dat_o,
input  [`SD_BUS_W-1:0] DAT_dat_i,
//Controll signals
input [1:0] start_dat,
input ack_transfer,

output reg busy_n,
output reg transm_complete,
output reg crc_ok
//__RB_CUT_GROUP_END__ type=port_section id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:port_section:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=7-26
);

//CRC16 
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:internal_signal:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=30-36
reg [`SD_BUS_W-1:0] crc_in;
reg crc_en;
reg crc_rst;
wire [15:0] crc_out [`SD_BUS_W-1:0];
reg  [`SD_BUS_W-1:0] temp_in;
  
reg [10:0] transf_cnt;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:internal_signal:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=30-36
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:param_decl:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=37-37
parameter SIZE = 6;
//__RB_CUT_GROUP_END__ type=param_decl id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:param_decl:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=37-37
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:internal_signal:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=38-39
reg [SIZE-1:0] state;
reg [SIZE-1:0] next_state;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:internal_signal:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=38-39
//__RB_CUT_GROUP_BEGIN__ type=param_decl id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:param_decl:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=40-45
parameter IDLE        = 6'b000001;
parameter WRITE_DAT   = 6'b000010;
parameter WRITE_CRC   = 6'b000100;
parameter WRITE_BUSY  = 6'b001000;
parameter READ_WAIT   = 6'b010000;      
parameter READ_DAT    = 6'b100000;
//__RB_CUT_GROUP_END__ type=param_decl id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:param_decl:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=40-45
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:internal_signal:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=46-47
reg [2:0] crc_status; 
reg busy_int;   
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:internal_signal:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=46-47

genvar i;
//__RB_CUT_BEGIN__ type=generate id=sdc/sd_data_serial_host/sd_data_serial_host.v:generate:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=50-54
generate
//__RB_CUT_BODY__ type=generate id=sdc/sd_data_serial_host/sd_data_serial_host.v:generate:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=50-54
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=51-53
for(i=0; i<`SD_BUS_W; i=i+1) begin:CRC_16_gen
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=51-53
//__RB_CUT_BEGIN__ type=instantiation id=sdc/sd_data_serial_host/sd_data_serial_host.v:inst:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=52-52
  sd_crc_16 CRC_16_i (crc_in[i],crc_en, sd_clk, crc_rst, crc_out[i]);
//__RB_CUT_END__ type=instantiation id=sdc/sd_data_serial_host/sd_data_serial_host.v:inst:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=52-52
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=51-53
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=51-53
//__RB_CUT_TAIL__ type=generate id=sdc/sd_data_serial_host/sd_data_serial_host.v:generate:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=50-54
endgenerate
//__RB_CUT_END__ type=generate id=sdc/sd_data_serial_host/sd_data_serial_host.v:generate:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=50-54

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:internal_signal:000004 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=56-57
reg ack_transfer_int;
reg ack_q;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:internal_signal:000004 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=56-57
//__RB_CUT_BEGIN__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=58-67
always @ (posedge sd_clk or posedge rst   )
//__RB_CUT_BODY__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=58-67
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000004 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=59-67
begin: ACK_SYNC
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000004 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=59-67
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=60-62
if (rst) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=60-62
  ack_transfer_int <=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=60-62
  ack_q<=0;end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=60-62
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=63-66
else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=63-66
  ack_q<=ack_transfer;
  ack_transfer_int<=ack_q;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=63-66
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=63-66
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000004 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=59-67
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000004 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=59-67
//__RB_CUT_TAIL__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=58-67
//__RB_CUT_END__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=58-67

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:internal_signal:000005 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=69-69
reg q_start_bit;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:internal_signal:000005 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=69-69
//__RB_CUT_GROUP_BEGIN__ type=fsm id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:fsm:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=70-152
//__RB_CUT_GROUP_BEGIN__ type=counter_cluster id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:counter_cluster:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=70-126
//__RB_CUT_BEGIN__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=70-126
always @ (state or start_dat or q_start_bit or  transf_cnt or crc_status or busy_int or DAT_dat_i or ack_transfer_int)
//__RB_CUT_BODY__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=70-126
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000011 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=71-126
begin : FSM_COMBO
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000011 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=71-126
 next_state  = 0;   
//__RB_CUT_BEGIN__ type=case id=sdc/sd_data_serial_host/sd_data_serial_host.v:case:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=73-125
case(state)
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000005 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=74-81
  IDLE: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000005 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=74-81
   if (start_dat == 2'b01) 
      next_state=WRITE_DAT;
    else if  (start_dat == 2'b10) 
      next_state=READ_WAIT;
    else 
      next_state=IDLE;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000005 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=74-81
    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000005 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=74-81
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000006 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=82-89
  WRITE_DAT: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000006 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=82-89
    if (transf_cnt >= `BIT_BLOCK) 
       next_state= WRITE_CRC;
   else if (start_dat == 2'b11)
        next_state=IDLE;
    else 
       next_state=WRITE_DAT;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000006 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=82-89
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000006 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=82-89

//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000007 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=91-97
  WRITE_CRC: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000007 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=91-97
    if (crc_status ==0) 
       next_state= WRITE_BUSY;
    else 
       next_state=WRITE_CRC;
    
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000007 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=91-97
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000007 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=91-97
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000008 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=98-103
  WRITE_BUSY: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000008 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=98-103
      if ( (busy_int ==1)  & ack_transfer_int)
       next_state= IDLE;
    else 
       next_state  = WRITE_BUSY;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000008 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=98-103
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000008 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=98-103
  
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000009 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=105-110
  READ_WAIT: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000009 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=105-110
    if (q_start_bit== 0 ) 
       next_state= READ_DAT;
    else 
       next_state=READ_WAIT;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000009 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=105-110
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000009 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=105-110
  
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000010 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=112-119
  READ_DAT: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000010 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=112-119
    if ( ack_transfer_int)  //Startbit consumed...
       next_state= IDLE;
    else if (start_dat == 2'b11)
        next_state=IDLE;   
    else 
       next_state=READ_DAT;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000010 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=112-119
    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000010 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=112-119
    
    
    
 
  
//__RB_CUT_TAIL__ type=case id=sdc/sd_data_serial_host/sd_data_serial_host.v:case:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=73-125
 endcase
//__RB_CUT_END__ type=case id=sdc/sd_data_serial_host/sd_data_serial_host.v:case:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=73-125
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000011 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=71-126
end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000011 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=71-126
//__RB_CUT_TAIL__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=70-126
//__RB_CUT_END__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=70-126
//__RB_CUT_GROUP_END__ type=counter_cluster id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:counter_cluster:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=70-126

//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:reg_cluster:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=128-152
//__RB_CUT_BEGIN__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=128-140
always @ (posedge sd_clk or posedge rst   )
//__RB_CUT_BODY__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=128-140
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000014 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=129-140
 begin :START_SYNC
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000014 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=129-140
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000012 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=130-132
  if (rst ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000012 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=130-132
    q_start_bit<=1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000012 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=130-132
 end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000012 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=130-132
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000013 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=133-139
 else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000013 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=133-139
    if (!DAT_dat_i[0] & state == READ_WAIT)
    q_start_bit <= 0;
    else
    q_start_bit <= 1;
    
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000013 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=133-139
 end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000013 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=133-139
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000014 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=129-140
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000014 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=129-140
//__RB_CUT_TAIL__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=128-140
//__RB_CUT_END__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=128-140


//----------------Seq logic------------
//__RB_CUT_BEGIN__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000004 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=144-152
always @ (posedge sd_clk or posedge rst   )
//__RB_CUT_BODY__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000004 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=144-152
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000017 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=145-152
begin : FSM_SEQ
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000017 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=145-152
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000015 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=146-148
  if (rst ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000015 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=146-148
    state <= #1 IDLE;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000015 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=146-148
 end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000015 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=146-148
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000016 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=149-151
 else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000016 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=149-151
    state <= #1 next_state;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000016 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=149-151
 end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000016 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=149-151
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000017 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=145-152
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000017 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=145-152
//__RB_CUT_TAIL__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000004 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=144-152
//__RB_CUT_END__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000004 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=144-152
//__RB_CUT_GROUP_END__ type=reg_cluster id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:reg_cluster:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=128-152
//__RB_CUT_GROUP_END__ type=fsm id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:fsm:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=70-152

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:internal_signal:000006 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=154-159
reg [4:0] crc_c;
reg [3:0] last_din;
reg [2:0] crc_s ;
reg [31:0] write_buf_0,write_buf_1, sd_data_out;
reg out_buff_ptr,in_buff_ptr;
reg [2:0] data_send_index;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:internal_signal:000006 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=154-159
         
//__RB_CUT_GROUP_BEGIN__ type=counter_cluster id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:counter_cluster:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=161-440
//__RB_CUT_BEGIN__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000005 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=161-440
always @ (negedge sd_clk or posedge rst   )
//__RB_CUT_BODY__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000005 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=161-440
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000053 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=162-440
begin  : FSM_OUT
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000053 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=162-440
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000018 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=163-187
 if (rst) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000018 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=163-187
write_buf_0<=0;
write_buf_1<=0;
   DAT_oe_o<=0;
   crc_en<=0;
   crc_rst<=1;
   transf_cnt<=0;
   crc_c<=15;
   rd<=0;
   last_din<=0;
   crc_c<=0;
   crc_in<=0;
   DAT_dat_o<=0;
   crc_status<=7;
   crc_s<=0;
   transm_complete<=0;
   busy_n<=1;
   we<=0;
   data_out<=0;
   crc_ok<=0;
   busy_int<=0;
     data_send_index<=0;
        out_buff_ptr<=0;
        in_buff_ptr<=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000018 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=163-187
 end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000018 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=163-187
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000052 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=188-438
 else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000052 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=188-438
//__RB_CUT_BEGIN__ type=case id=sdc/sd_data_serial_host/sd_data_serial_host.v:case:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=189-436
 case(state)
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000019 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=190-206
   IDLE: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000019 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=190-206
      DAT_oe_o<=0;
      DAT_dat_o<=4'b1111;
      crc_en<=0;
      crc_rst<=1;
      transf_cnt<=0;
      crc_c<=16;
      crc_status<=7;
      crc_s<=0;
      we<=0;
      rd<=0;
      busy_n<=1;
        data_send_index<=0;
        out_buff_ptr<=0;
        in_buff_ptr<=0;
     
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000019 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=190-206
   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000019 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=190-206
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000043 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=207-354
   WRITE_DAT: begin    
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000043 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=207-354
      transm_complete <=0;  
      busy_n<=0;
      crc_ok<=0;
      transf_cnt<=transf_cnt+1; 
       rd<=0; 
       
      
        
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000020 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=216-224
      if ( (in_buff_ptr != out_buff_ptr) ||  (!transf_cnt) ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000020 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=216-224
        rd <=1;           
       if (!in_buff_ptr)
         write_buf_0<=data_in;         
       else
        write_buf_1 <=data_in;    
        
       in_buff_ptr<=in_buff_ptr+1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000020 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=216-224
     end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000020 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=216-224
     
      if (!out_buff_ptr)
        sd_data_out<=write_buf_0;
      else
       sd_data_out<=write_buf_1;
        
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000021 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=231-248
        if (transf_cnt==1) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000021 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=231-248
          
          crc_rst<=0;
          crc_en<=1;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=235-238
          `ifdef LITLE_ENDIAN 
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=235-238
          	last_din <=write_buf_0[3:0]; 
          	crc_in<= write_buf_0[3:0]; 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=235-238
          `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000001 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=235-238
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=239-242
          `ifdef BIG_ENDIAN 
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=239-242
          	last_din <=write_buf_0[31:28]; 
          	crc_in<= write_buf_0[31:28]; 
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=239-242
          `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=239-242
          
          DAT_oe_o<=1;  
          DAT_dat_o<=0;
          
          data_send_index<=1;    
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000021 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=231-248
        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000021 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=231-248
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000039 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=249-334
        else if ( (transf_cnt>=2) && (transf_cnt<=`BIT_BLOCK-`CRC_OFF )) begin                 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000039 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=249-334
          DAT_oe_o<=1;    
//__RB_CUT_BEGIN__ type=case id=sdc/sd_data_serial_host/sd_data_serial_host.v:case:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=251-324
        case (data_send_index) 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=252-286
          `ifdef LITLE_ENDIAN 
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=252-286
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000022 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=253-256
           0:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000022 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=253-256
              last_din <=sd_data_out[3:0];
              crc_in <=sd_data_out[3:0];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000022 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=253-256
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000022 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=253-256
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000023 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=257-260
           1:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000023 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=257-260
              last_din <=sd_data_out[7:4];
              crc_in <=sd_data_out[7:4];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000023 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=257-260
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000023 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=257-260
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000024 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=261-264
           2:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000024 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=261-264
              last_din <=sd_data_out[11:8];
              crc_in <=sd_data_out[11:8];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000024 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=261-264
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000024 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=261-264
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000025 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=265-268
           3:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000025 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=265-268
              last_din <=sd_data_out[15:12];
              crc_in <=sd_data_out[15:12];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000025 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=265-268
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000025 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=265-268
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000026 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=269-272
           4:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000026 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=269-272
              last_din <=sd_data_out[19:16];
              crc_in <=sd_data_out[19:16];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000026 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=269-272
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000026 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=269-272
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000027 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=273-276
           5:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000027 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=273-276
              last_din <=sd_data_out[23:20];
              crc_in <=sd_data_out[23:20];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000027 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=273-276
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000027 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=273-276
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000028 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=277-281
           6:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000028 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=277-281
              last_din <=sd_data_out[27:24];
              crc_in <=sd_data_out[27:24];
              out_buff_ptr<=out_buff_ptr+1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000028 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=277-281
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000028 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=277-281
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000029 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=282-285
           7:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000029 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=282-285
              last_din <=sd_data_out[31:28];
              crc_in <=sd_data_out[31:28];              
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000029 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=282-285
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000029 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=282-285
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=252-286
          `endif  
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=252-286
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000004 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=287-321
          `ifdef BIG_ENDIAN 
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000004 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=287-321
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000030 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=288-291
           0:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000030 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=288-291
              last_din <=sd_data_out[31:28];
              crc_in <=sd_data_out[31:28];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000030 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=288-291
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000030 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=288-291
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000031 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=292-295
           1:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000031 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=292-295
              last_din <=sd_data_out[27:24];
              crc_in <=sd_data_out[27:24];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000031 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=292-295
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000031 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=292-295
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000032 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=296-299
           2:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000032 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=296-299
              last_din <=sd_data_out[23:20];
              crc_in <=sd_data_out[23:20];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000032 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=296-299
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000032 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=296-299
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000033 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=300-303
           3:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000033 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=300-303
              last_din <=sd_data_out[19:16];
              crc_in <=sd_data_out[19:16];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000033 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=300-303
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000033 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=300-303
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000034 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=304-307
           4:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000034 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=304-307
              last_din <=sd_data_out[15:12];
              crc_in <=sd_data_out[15:12];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000034 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=304-307
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000034 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=304-307
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000035 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=308-311
           5:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000035 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=308-311
              last_din <=sd_data_out[11:8];
              crc_in <=sd_data_out[11:8];
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000035 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=308-311
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000035 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=308-311
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000036 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=312-316
           6:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000036 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=312-316
              last_din <=sd_data_out[7:4];
              crc_in <=sd_data_out[7:4];
              out_buff_ptr<=out_buff_ptr+1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000036 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=312-316
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000036 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=312-316
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000037 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=317-320
           7:begin 
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000037 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=317-320
              last_din <=sd_data_out[3:0];
              crc_in <=sd_data_out[3:0];              
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000037 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=317-320
           end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000037 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=317-320
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000004 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=287-321
          `endif  
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000004 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=287-321
          
           
//__RB_CUT_TAIL__ type=case id=sdc/sd_data_serial_host/sd_data_serial_host.v:case:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=251-324
         endcase 
//__RB_CUT_END__ type=case id=sdc/sd_data_serial_host/sd_data_serial_host.v:case:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=251-324
          data_send_index<=data_send_index+1;
                   
          DAT_dat_o<= last_din; 
          
            
                    
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000038 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=331-333
          if ( transf_cnt >=`BIT_BLOCK-`CRC_OFF ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000038 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=331-333
             crc_en<=0;             
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000038 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=331-333
         end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000038 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=331-333
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000039 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=249-334
       end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000039 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=249-334
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000040 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=335-344
       else if (transf_cnt>`BIT_BLOCK-`CRC_OFF & crc_c!=0) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000040 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=335-344
        rd<=0;
         crc_en<=0;
         crc_c<=crc_c-1;      
         DAT_oe_o<=1; 
         DAT_dat_o[0]<=crc_out[0][crc_c-1];
         DAT_dat_o[1]<=crc_out[1][crc_c-1];
         DAT_dat_o[2]<=crc_out[2][crc_c-1];
         DAT_dat_o[3]<=crc_out[3][crc_c-1];         
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000040 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=335-344
       end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000040 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=335-344
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000041 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=345-349
       else if (transf_cnt==`BIT_BLOCK-2) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000041 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=345-349
          DAT_oe_o<=1; 
          DAT_dat_o<=4'b1111;
           rd<=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000041 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=345-349
      end   
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000041 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=345-349
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000042 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=350-353
       else if (transf_cnt !=0) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000042 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=350-353
         DAT_oe_o<=0; 
         rd<=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000042 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=350-353
         end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000042 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=350-353
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000043 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=207-354
   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000043 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=207-354
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000044 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=355-361
   WRITE_CRC : begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000044 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=355-361
      rd<=0;
      DAT_oe_o<=0; 
      crc_status<=crc_status-1;
      if  (( crc_status<=4) && ( crc_status>=2) )
      crc_s[crc_status-2] <=DAT_dat_i[0];    
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000044 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=355-361
   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000044 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=355-361
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000045 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=362-372
   WRITE_BUSY : begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000045 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=362-372
       transm_complete <=1;
     if (crc_s == 3'b010) 
       crc_ok<=1;     
     else 
       crc_ok<=0;  
            
       busy_int<=DAT_dat_i[0];
    
      
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000045 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=362-372
   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000045 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=362-372
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000046 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=373-381
   READ_WAIT:begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000046 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=373-381
      DAT_oe_o<=0;
      crc_rst<=0;
      crc_en<=1;
      crc_in<=0; 
      crc_c<=15;// end 
      busy_n<=0;
      transm_complete<=0; 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000046 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=373-381
   end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000046 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=373-381
   
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000051 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=383-432
   READ_DAT: begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000051 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=383-432
     
       
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000047 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=386-394
     if (transf_cnt<`BIT_BLOCK_REC) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000047 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=386-394
       we<=1;
     
       data_out<=DAT_dat_i;
       crc_in<=DAT_dat_i;
       crc_ok<=1;
       transf_cnt<=transf_cnt+1; 
              
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000047 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=386-394
     end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000047 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=386-394
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000050 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=395-428
     else if  ( transf_cnt <= (`BIT_BLOCK_REC +`BIT_CRC_CYCLE)) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000050 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=395-428
       transf_cnt<=transf_cnt+1; 
       crc_en<=0;  
       last_din <=DAT_dat_i; 
       
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000049 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=400-427
       if (transf_cnt> `BIT_BLOCK_REC) begin       
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000049 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=400-427
        crc_c<=crc_c-1;
          we<=0;
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000005 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=403-406
        `ifdef SD_BUS_WIDTH_1
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000005 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=403-406
         if  (crc_out[0][crc_status] == last_din[0])
           crc_ok<=0;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000005 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=403-406
        `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000005 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=403-406
        
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000006 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=408-418
       `ifdef SD_BUS_WIDTH_4
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000006 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=408-418
          if  (crc_out[0][crc_c] != last_din[0])
           crc_ok<=0;
          if  (crc_out[1][crc_c] != last_din[1])
           crc_ok<=0;
          if  (crc_out[2][crc_c] != last_din[2])
           crc_ok<=0;
          if  (crc_out[3][crc_c] != last_din[3])
           crc_ok<=0;  
         
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000006 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=408-418
        `endif   
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000006 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=408-418
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000007 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=419-421
         `ifdef SIM
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000007 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=419-421
          crc_ok<=1;
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000007 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=419-421
       `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_data_serial_host/sd_data_serial_host.v:pp_blk:000007 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=419-421
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000048 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=422-426
         if (crc_c==0) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000048 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=422-426
          transm_complete <=1;
          busy_n<=0;
           we<=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000048 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=422-426
         end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000048 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=422-426
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000049 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=400-427
      end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000049 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=400-427
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000050 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=395-428
    end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000050 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=395-428
    
      
        
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000051 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=383-432
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000051 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=383-432
   
   
  
//__RB_CUT_TAIL__ type=case id=sdc/sd_data_serial_host/sd_data_serial_host.v:case:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=189-436
 endcase 
//__RB_CUT_END__ type=case id=sdc/sd_data_serial_host/sd_data_serial_host.v:case:000003 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=189-436
 
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000052 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=188-438
 end
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000052 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=188-438

//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000053 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=162-440
end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_data_serial_host/sd_data_serial_host.v:begin_end:000053 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=162-440
//__RB_CUT_TAIL__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000005 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=161-440
//__RB_CUT_END__ type=always id=sdc/sd_data_serial_host/sd_data_serial_host.v:proc:000005 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=161-440
//__RB_CUT_GROUP_END__ type=counter_cluster id=sdc/sd_data_serial_host/sd_data_serial_host.v:grp:counter_cluster:000002 file=sdc/sd_data_serial_host/sd_data_serial_host.v lines=161-440
   








//Sync





  
  
endmodule





