
`include "sd_defines.v"



module sd_bd (
//__RB_CUT_GROUP_BEGIN__ type=port_section id=sdc/sd_bd/sd_bd.v:grp:port_section:000001 file=sdc/sd_bd/sd_bd.v lines=7-19
input clk,
input rst,
//input stb_m,
input we_m,

input [`RAM_MEM_WIDTH-1:0] dat_in_m, 

output reg [`BD_WIDTH-1 :0] free_bd,

input  re_s,
output reg ack_o_s,
input a_cmp,
output reg[`RAM_MEM_WIDTH-1:0] dat_out_s
//__RB_CUT_GROUP_END__ type=port_section id=sdc/sd_bd/sd_bd.v:grp:port_section:000001 file=sdc/sd_bd/sd_bd.v lines=7-19
);
 
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_bd/sd_bd.v:grp:internal_signal:000001 file=sdc/sd_bd/sd_bd.v lines=22-36
 reg new_bw;
reg last_a_cmp;
 
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_bd/sd_bd.v:pp_blk:000003 file=sdc/sd_bd/sd_bd.v lines=25-194
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000003:br:000001 file=sdc/sd_bd/sd_bd.v lines=25-103
`ifdef RAM_MEM_WIDTH_32   
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_bd/sd_bd.v:pp_blk:000003 file=sdc/sd_bd/sd_bd.v lines=25-194
//__RB_CUT_BODY__ type=pp_ifdef_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000003:br:000001 file=sdc/sd_bd/sd_bd.v lines=25-103
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_bd/sd_bd.v:pp_blk:000001 file=sdc/sd_bd/sd_bd.v lines=26-30
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000001:br:000001 file=sdc/sd_bd/sd_bd.v lines=26-27
`ifdef ACTEL
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_bd/sd_bd.v:pp_blk:000001 file=sdc/sd_bd/sd_bd.v lines=26-30
//__RB_CUT_BODY__ type=pp_ifdef_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000001:br:000001 file=sdc/sd_bd/sd_bd.v lines=26-27
reg [`RAM_MEM_WIDTH -1:0] bd_mem [ `BD_SIZE -1 :0]; /* synthesis syn_ramstyle = "no_rw_check"*/
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000001:br:000001 file=sdc/sd_bd/sd_bd.v lines=26-27
//__RB_CUT_END__ type=pp_ifdef_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000001:br:000001 file=sdc/sd_bd/sd_bd.v lines=26-27
//__RB_CUT_BEGIN__ type=pp_else_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000001:br:000002 file=sdc/sd_bd/sd_bd.v lines=28-29
`else
//__RB_CUT_BODY__ type=pp_else_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000001:br:000002 file=sdc/sd_bd/sd_bd.v lines=28-29
reg [`RAM_MEM_WIDTH -1:0] bd_mem [ `BD_SIZE -1 :0];
//__RB_CUT_TAIL__ type=pp_else_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000001:br:000002 file=sdc/sd_bd/sd_bd.v lines=28-29
//__RB_CUT_END__ type=pp_else_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000001:br:000002 file=sdc/sd_bd/sd_bd.v lines=28-29
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_bd/sd_bd.v:pp_blk:000001 file=sdc/sd_bd/sd_bd.v lines=26-30
`endif 
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_bd/sd_bd.v:pp_blk:000001 file=sdc/sd_bd/sd_bd.v lines=26-30

reg write_cnt; 
reg read_cnt;
reg [`BD_WIDTH -1 :0] m_wr_pnt;

reg [`BD_WIDTH -1 :0] s_rd_pnt ;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_bd/sd_bd.v:grp:internal_signal:000001 file=sdc/sd_bd/sd_bd.v lines=22-36
 
 //Main side read/write  
//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=sdc/sd_bd/sd_bd.v:grp:reg_cluster:000001 file=sdc/sd_bd/sd_bd.v lines=39-102
//__RB_CUT_GROUP_BEGIN__ type=counter_cluster id=sdc/sd_bd/sd_bd.v:grp:counter_cluster:000001 file=sdc/sd_bd/sd_bd.v lines=39-68
//__RB_CUT_BEGIN__ type=always id=sdc/sd_bd/sd_bd.v:proc:000001 file=sdc/sd_bd/sd_bd.v lines=39-68
always @(posedge clk or posedge rst )
//__RB_CUT_BODY__ type=always id=sdc/sd_bd/sd_bd.v:proc:000001 file=sdc/sd_bd/sd_bd.v lines=39-68
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000006 file=sdc/sd_bd/sd_bd.v lines=40-68
begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000006 file=sdc/sd_bd/sd_bd.v lines=40-68
   new_bw <=0;  
  
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000001 file=sdc/sd_bd/sd_bd.v lines=43-50
  if (rst) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000001 file=sdc/sd_bd/sd_bd.v lines=43-50
    m_wr_pnt<=0;
    
    write_cnt<=0;
    new_bw <=0; 

   
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000001 file=sdc/sd_bd/sd_bd.v lines=43-50
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000001 file=sdc/sd_bd/sd_bd.v lines=43-50
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000005 file=sdc/sd_bd/sd_bd.v lines=51-63
  else if (we_m) begin    
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000005 file=sdc/sd_bd/sd_bd.v lines=51-63
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000004 file=sdc/sd_bd/sd_bd.v lines=52-62
    if (free_bd >0) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000004 file=sdc/sd_bd/sd_bd.v lines=52-62
      write_cnt <=~ write_cnt;
      m_wr_pnt<=m_wr_pnt+1;
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000002 file=sdc/sd_bd/sd_bd.v lines=55-57
      if (!write_cnt) begin  //First write indicate source buffer addr
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000002 file=sdc/sd_bd/sd_bd.v lines=55-57
        bd_mem[m_wr_pnt]<=dat_in_m;            
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000002 file=sdc/sd_bd/sd_bd.v lines=55-57
      end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000002 file=sdc/sd_bd/sd_bd.v lines=55-57
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000003 file=sdc/sd_bd/sd_bd.v lines=58-61
      else begin        //Second write indicate SD card block addr
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000003 file=sdc/sd_bd/sd_bd.v lines=58-61
        bd_mem[m_wr_pnt]<=dat_in_m;
        new_bw <=1;     
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000003 file=sdc/sd_bd/sd_bd.v lines=58-61
      end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000003 file=sdc/sd_bd/sd_bd.v lines=58-61
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000004 file=sdc/sd_bd/sd_bd.v lines=52-62
     end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000004 file=sdc/sd_bd/sd_bd.v lines=52-62
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000005 file=sdc/sd_bd/sd_bd.v lines=51-63
  end   
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000005 file=sdc/sd_bd/sd_bd.v lines=51-63
  
        
          
        
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000006 file=sdc/sd_bd/sd_bd.v lines=40-68
end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000006 file=sdc/sd_bd/sd_bd.v lines=40-68
//__RB_CUT_TAIL__ type=always id=sdc/sd_bd/sd_bd.v:proc:000001 file=sdc/sd_bd/sd_bd.v lines=39-68
//__RB_CUT_END__ type=always id=sdc/sd_bd/sd_bd.v:proc:000001 file=sdc/sd_bd/sd_bd.v lines=39-68
//__RB_CUT_GROUP_END__ type=counter_cluster id=sdc/sd_bd/sd_bd.v:grp:counter_cluster:000001 file=sdc/sd_bd/sd_bd.v lines=39-68



//__RB_CUT_BEGIN__ type=always id=sdc/sd_bd/sd_bd.v:proc:000002 file=sdc/sd_bd/sd_bd.v lines=72-85
always @ (posedge clk or posedge rst)
//__RB_CUT_BODY__ type=always id=sdc/sd_bd/sd_bd.v:proc:000002 file=sdc/sd_bd/sd_bd.v lines=72-85
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000010 file=sdc/sd_bd/sd_bd.v lines=73-85
begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000010 file=sdc/sd_bd/sd_bd.v lines=73-85
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000007 file=sdc/sd_bd/sd_bd.v lines=74-76
  if (rst) begin  
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000007 file=sdc/sd_bd/sd_bd.v lines=74-76
    free_bd <=(`BD_SIZE  /2);
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000007 file=sdc/sd_bd/sd_bd.v lines=74-76
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000007 file=sdc/sd_bd/sd_bd.v lines=74-76
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000008 file=sdc/sd_bd/sd_bd.v lines=77-79
  else if (new_bw ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000008 file=sdc/sd_bd/sd_bd.v lines=77-79
    free_bd <= free_bd-1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000008 file=sdc/sd_bd/sd_bd.v lines=77-79
  end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000008 file=sdc/sd_bd/sd_bd.v lines=77-79
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000009 file=sdc/sd_bd/sd_bd.v lines=80-83
  else if  (a_cmp) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000009 file=sdc/sd_bd/sd_bd.v lines=80-83
     free_bd <= free_bd+1;
    
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000009 file=sdc/sd_bd/sd_bd.v lines=80-83
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000009 file=sdc/sd_bd/sd_bd.v lines=80-83
  
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000010 file=sdc/sd_bd/sd_bd.v lines=73-85
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000010 file=sdc/sd_bd/sd_bd.v lines=73-85
//__RB_CUT_TAIL__ type=always id=sdc/sd_bd/sd_bd.v:proc:000002 file=sdc/sd_bd/sd_bd.v lines=72-85
//__RB_CUT_END__ type=always id=sdc/sd_bd/sd_bd.v:proc:000002 file=sdc/sd_bd/sd_bd.v lines=72-85


//Second side read
//__RB_CUT_BEGIN__ type=always id=sdc/sd_bd/sd_bd.v:proc:000003 file=sdc/sd_bd/sd_bd.v lines=89-102
always @(posedge clk or posedge rst)
//__RB_CUT_BODY__ type=always id=sdc/sd_bd/sd_bd.v:proc:000003 file=sdc/sd_bd/sd_bd.v lines=89-102
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000013 file=sdc/sd_bd/sd_bd.v lines=90-102
begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000013 file=sdc/sd_bd/sd_bd.v lines=90-102
   
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000011 file=sdc/sd_bd/sd_bd.v lines=92-95
  if (rst) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000011 file=sdc/sd_bd/sd_bd.v lines=92-95
    s_rd_pnt<=0;
	
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000011 file=sdc/sd_bd/sd_bd.v lines=92-95
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000011 file=sdc/sd_bd/sd_bd.v lines=92-95
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000012 file=sdc/sd_bd/sd_bd.v lines=96-101
  else if (re_s) begin    
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000012 file=sdc/sd_bd/sd_bd.v lines=96-101
    s_rd_pnt<=s_rd_pnt+1;
    dat_out_s<= bd_mem[s_rd_pnt];            
  
   
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000012 file=sdc/sd_bd/sd_bd.v lines=96-101
  end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000012 file=sdc/sd_bd/sd_bd.v lines=96-101
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000013 file=sdc/sd_bd/sd_bd.v lines=90-102
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000013 file=sdc/sd_bd/sd_bd.v lines=90-102
//__RB_CUT_TAIL__ type=always id=sdc/sd_bd/sd_bd.v:proc:000003 file=sdc/sd_bd/sd_bd.v lines=89-102
//__RB_CUT_END__ type=always id=sdc/sd_bd/sd_bd.v:proc:000003 file=sdc/sd_bd/sd_bd.v lines=89-102
//__RB_CUT_GROUP_END__ type=reg_cluster id=sdc/sd_bd/sd_bd.v:grp:reg_cluster:000001 file=sdc/sd_bd/sd_bd.v lines=39-102

//__RB_CUT_TAIL__ type=pp_ifdef_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000003:br:000001 file=sdc/sd_bd/sd_bd.v lines=25-103
//__RB_CUT_END__ type=pp_ifdef_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000003:br:000001 file=sdc/sd_bd/sd_bd.v lines=25-103
//__RB_CUT_BEGIN__ type=pp_else_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000003:br:000002 file=sdc/sd_bd/sd_bd.v lines=104-193
`else `ifdef RAM_MEM_WIDTH_16   
//__RB_CUT_BODY__ type=pp_else_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000003:br:000002 file=sdc/sd_bd/sd_bd.v lines=104-193
//__RB_CUT_BEGIN__ type=pp_ifdef_block id=sdc/sd_bd/sd_bd.v:pp_blk:000002 file=sdc/sd_bd/sd_bd.v lines=105-109
//__RB_CUT_BEGIN__ type=pp_ifdef_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000002:br:000001 file=sdc/sd_bd/sd_bd.v lines=105-106
`ifdef ACTEL
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_bd/sd_bd.v:grp:internal_signal:000002 file=sdc/sd_bd/sd_bd.v lines=106-117
//__RB_CUT_BODY__ type=pp_ifdef_block id=sdc/sd_bd/sd_bd.v:pp_blk:000002 file=sdc/sd_bd/sd_bd.v lines=105-109
//__RB_CUT_BODY__ type=pp_ifdef_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000002:br:000001 file=sdc/sd_bd/sd_bd.v lines=105-106
reg [ `RAM_MEM_WIDTH -1:0] bd_mem [ `BD_SIZE -1 :0];  //synthesis syn_ramstyle = "no_rw_check"
//__RB_CUT_TAIL__ type=pp_ifdef_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000002:br:000001 file=sdc/sd_bd/sd_bd.v lines=105-106
//__RB_CUT_END__ type=pp_ifdef_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000002:br:000001 file=sdc/sd_bd/sd_bd.v lines=105-106
//__RB_CUT_BEGIN__ type=pp_else_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000002:br:000002 file=sdc/sd_bd/sd_bd.v lines=107-108
`else
//__RB_CUT_BODY__ type=pp_else_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000002:br:000002 file=sdc/sd_bd/sd_bd.v lines=107-108
reg [ `RAM_MEM_WIDTH -1:0] bd_mem [ `BD_SIZE -1 :0];
//__RB_CUT_TAIL__ type=pp_else_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000002:br:000002 file=sdc/sd_bd/sd_bd.v lines=107-108
//__RB_CUT_END__ type=pp_else_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000002:br:000002 file=sdc/sd_bd/sd_bd.v lines=107-108
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_bd/sd_bd.v:pp_blk:000002 file=sdc/sd_bd/sd_bd.v lines=105-109
`endif 
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_bd/sd_bd.v:pp_blk:000002 file=sdc/sd_bd/sd_bd.v lines=105-109

reg [1:0]write_cnt; 
reg [1:0]read_s_cnt;
reg read_cnt;

reg [`BD_WIDTH -1 :0] m_wr_pnt;

reg [`BD_WIDTH -1 :0] s_rd_pnt ;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_bd/sd_bd.v:grp:internal_signal:000002 file=sdc/sd_bd/sd_bd.v lines=106-117
 
 //Main side read/write  
//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=sdc/sd_bd/sd_bd.v:grp:reg_cluster:000002 file=sdc/sd_bd/sd_bd.v lines=120-192
//__RB_CUT_GROUP_BEGIN__ type=counter_cluster id=sdc/sd_bd/sd_bd.v:grp:counter_cluster:000002 file=sdc/sd_bd/sd_bd.v lines=120-148
//__RB_CUT_BEGIN__ type=always id=sdc/sd_bd/sd_bd.v:proc:000004 file=sdc/sd_bd/sd_bd.v lines=120-148
always @(posedge clk or posedge rst )
//__RB_CUT_BODY__ type=always id=sdc/sd_bd/sd_bd.v:proc:000004 file=sdc/sd_bd/sd_bd.v lines=120-148
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000019 file=sdc/sd_bd/sd_bd.v lines=121-148
begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000019 file=sdc/sd_bd/sd_bd.v lines=121-148
   new_bw <=0;  
  
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000014 file=sdc/sd_bd/sd_bd.v lines=124-131
  if (rst) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000014 file=sdc/sd_bd/sd_bd.v lines=124-131
    m_wr_pnt<=0;
    
    write_cnt<=0;
    new_bw <=0; 
    read_cnt<=0;
   
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000014 file=sdc/sd_bd/sd_bd.v lines=124-131
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000014 file=sdc/sd_bd/sd_bd.v lines=124-131
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000018 file=sdc/sd_bd/sd_bd.v lines=132-144
  else if (we_m) begin    
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000018 file=sdc/sd_bd/sd_bd.v lines=132-144
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000017 file=sdc/sd_bd/sd_bd.v lines=133-143
    if (free_bd >0) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000017 file=sdc/sd_bd/sd_bd.v lines=133-143
      write_cnt <=write_cnt+1;
      m_wr_pnt<=m_wr_pnt+1;
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000015 file=sdc/sd_bd/sd_bd.v lines=136-138
      if (!write_cnt[1]) begin      //First write indicate source buffer addr (2x16)
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000015 file=sdc/sd_bd/sd_bd.v lines=136-138
        bd_mem[m_wr_pnt]<=dat_in_m;             
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000015 file=sdc/sd_bd/sd_bd.v lines=136-138
      end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000015 file=sdc/sd_bd/sd_bd.v lines=136-138
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000016 file=sdc/sd_bd/sd_bd.v lines=139-142
      else begin        //Second write indicate SD card block addr (2x16)
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000016 file=sdc/sd_bd/sd_bd.v lines=139-142
        bd_mem[m_wr_pnt]<=dat_in_m;
        new_bw <=write_cnt[0];      //Second 16 bytes writen, complete BD
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000016 file=sdc/sd_bd/sd_bd.v lines=139-142
      end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000016 file=sdc/sd_bd/sd_bd.v lines=139-142
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000017 file=sdc/sd_bd/sd_bd.v lines=133-143
     end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000017 file=sdc/sd_bd/sd_bd.v lines=133-143
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000018 file=sdc/sd_bd/sd_bd.v lines=132-144
  end   
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000018 file=sdc/sd_bd/sd_bd.v lines=132-144
   
    

//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000019 file=sdc/sd_bd/sd_bd.v lines=121-148
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000019 file=sdc/sd_bd/sd_bd.v lines=121-148
//__RB_CUT_TAIL__ type=always id=sdc/sd_bd/sd_bd.v:proc:000004 file=sdc/sd_bd/sd_bd.v lines=120-148
//__RB_CUT_END__ type=always id=sdc/sd_bd/sd_bd.v:proc:000004 file=sdc/sd_bd/sd_bd.v lines=120-148
//__RB_CUT_GROUP_END__ type=counter_cluster id=sdc/sd_bd/sd_bd.v:grp:counter_cluster:000002 file=sdc/sd_bd/sd_bd.v lines=120-148

//__RB_CUT_BEGIN__ type=always id=sdc/sd_bd/sd_bd.v:proc:000005 file=sdc/sd_bd/sd_bd.v lines=150-167
always @(posedge clk or posedge rst)
//__RB_CUT_BODY__ type=always id=sdc/sd_bd/sd_bd.v:proc:000005 file=sdc/sd_bd/sd_bd.v lines=150-167
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000023 file=sdc/sd_bd/sd_bd.v lines=151-167
begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000023 file=sdc/sd_bd/sd_bd.v lines=151-167
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000020 file=sdc/sd_bd/sd_bd.v lines=152-155
  if (rst) begin  
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000020 file=sdc/sd_bd/sd_bd.v lines=152-155
    free_bd <=(`BD_SIZE  /4);
    last_a_cmp<=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000020 file=sdc/sd_bd/sd_bd.v lines=152-155
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000020 file=sdc/sd_bd/sd_bd.v lines=152-155
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000021 file=sdc/sd_bd/sd_bd.v lines=156-158
  else if (new_bw ) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000021 file=sdc/sd_bd/sd_bd.v lines=156-158
    free_bd <= free_bd-1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000021 file=sdc/sd_bd/sd_bd.v lines=156-158
  end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000021 file=sdc/sd_bd/sd_bd.v lines=156-158
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000022 file=sdc/sd_bd/sd_bd.v lines=159-164
  else if  (a_cmp) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000022 file=sdc/sd_bd/sd_bd.v lines=159-164
    last_a_cmp <=a_cmp;
    if (!last_a_cmp)
     free_bd <= free_bd+1;
     
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000022 file=sdc/sd_bd/sd_bd.v lines=159-164
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000022 file=sdc/sd_bd/sd_bd.v lines=159-164
 else
  last_a_cmp <=a_cmp;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000023 file=sdc/sd_bd/sd_bd.v lines=151-167
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000023 file=sdc/sd_bd/sd_bd.v lines=151-167
//__RB_CUT_TAIL__ type=always id=sdc/sd_bd/sd_bd.v:proc:000005 file=sdc/sd_bd/sd_bd.v lines=150-167
//__RB_CUT_END__ type=always id=sdc/sd_bd/sd_bd.v:proc:000005 file=sdc/sd_bd/sd_bd.v lines=150-167


//Second side read
//__RB_CUT_GROUP_BEGIN__ type=counter_cluster id=sdc/sd_bd/sd_bd.v:grp:counter_cluster:000003 file=sdc/sd_bd/sd_bd.v lines=171-192
//__RB_CUT_BEGIN__ type=always id=sdc/sd_bd/sd_bd.v:proc:000006 file=sdc/sd_bd/sd_bd.v lines=171-192
always @(posedge clk or posedge rst)
//__RB_CUT_BODY__ type=always id=sdc/sd_bd/sd_bd.v:proc:000006 file=sdc/sd_bd/sd_bd.v lines=171-192
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000026 file=sdc/sd_bd/sd_bd.v lines=172-192
begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000026 file=sdc/sd_bd/sd_bd.v lines=172-192
   
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000024 file=sdc/sd_bd/sd_bd.v lines=174-178
  if (rst) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000024 file=sdc/sd_bd/sd_bd.v lines=174-178
    s_rd_pnt<=0;
	  read_s_cnt<=0;
	  ack_o_s<=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000024 file=sdc/sd_bd/sd_bd.v lines=174-178
  end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000024 file=sdc/sd_bd/sd_bd.v lines=174-178
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000025 file=sdc/sd_bd/sd_bd.v lines=179-189
  else if (re_s) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000025 file=sdc/sd_bd/sd_bd.v lines=179-189
    read_s_cnt <=read_s_cnt+1;
    s_rd_pnt<=s_rd_pnt+1;
    ack_o_s<=1;
     if (!read_s_cnt[1])       //First read indicate source buffer addr (2x16)
        dat_out_s<= bd_mem[s_rd_pnt];           
      
      else         //Second read indicate SD card block addr (2x16)
        dat_out_s<= bd_mem[s_rd_pnt];
      
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000025 file=sdc/sd_bd/sd_bd.v lines=179-189
  end  
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000025 file=sdc/sd_bd/sd_bd.v lines=179-189
  else
    ack_o_s<=0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000026 file=sdc/sd_bd/sd_bd.v lines=172-192
end
//__RB_CUT_END__ type=begin_end id=sdc/sd_bd/sd_bd.v:begin_end:000026 file=sdc/sd_bd/sd_bd.v lines=172-192
//__RB_CUT_TAIL__ type=always id=sdc/sd_bd/sd_bd.v:proc:000006 file=sdc/sd_bd/sd_bd.v lines=171-192
//__RB_CUT_END__ type=always id=sdc/sd_bd/sd_bd.v:proc:000006 file=sdc/sd_bd/sd_bd.v lines=171-192
//__RB_CUT_GROUP_END__ type=counter_cluster id=sdc/sd_bd/sd_bd.v:grp:counter_cluster:000003 file=sdc/sd_bd/sd_bd.v lines=171-192
//__RB_CUT_GROUP_END__ type=reg_cluster id=sdc/sd_bd/sd_bd.v:grp:reg_cluster:000002 file=sdc/sd_bd/sd_bd.v lines=120-192

//__RB_CUT_TAIL__ type=pp_else_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000003:br:000002 file=sdc/sd_bd/sd_bd.v lines=104-193
//__RB_CUT_END__ type=pp_else_branch id=sdc/sd_bd/sd_bd.v:pp_blk:000003:br:000002 file=sdc/sd_bd/sd_bd.v lines=104-193
//__RB_CUT_TAIL__ type=pp_ifdef_block id=sdc/sd_bd/sd_bd.v:pp_blk:000003 file=sdc/sd_bd/sd_bd.v lines=25-194
 `endif
//__RB_CUT_END__ type=pp_ifdef_block id=sdc/sd_bd/sd_bd.v:pp_blk:000003 file=sdc/sd_bd/sd_bd.v lines=25-194

`endif


endmodule

