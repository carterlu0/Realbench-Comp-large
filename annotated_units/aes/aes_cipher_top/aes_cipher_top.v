//`include "timescale.v"

module aes_cipher_top(clk, rst, ld, done, key, text_in, text_out );
//__RB_CUT_GROUP_BEGIN__ type=port_section id=aes/aes_cipher_top/aes_cipher_top.v:grp:port_section:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=4-9
input		clk, rst;
input		ld;
output		done;
input	[127:0]	key;
input	[127:0]	text_in;
output	[127:0]	text_out;
//__RB_CUT_GROUP_END__ type=port_section id=aes/aes_cipher_top/aes_cipher_top.v:grp:port_section:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=4-9

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=aes/aes_cipher_top/aes_cipher_top.v:grp:internal_signal:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=16-43
wire	[31:0]	w0, w1, w2, w3;
reg	[127:0]	text_in_r;
reg	[127:0]	text_out;

//状态矩阵的组织
reg	[7:0]	sa00, sa01, sa02, sa03;//第0行
reg	[7:0]	sa10, sa11, sa12, sa13;//第1行
reg	[7:0]	sa20, sa21, sa22, sa23;//第2行
reg	[7:0]	sa30, sa31, sa32, sa33;//第3行

wire	[7:0]	sa00_next, sa01_next, sa02_next, sa03_next;
wire	[7:0]	sa10_next, sa11_next, sa12_next, sa13_next;
wire	[7:0]	sa20_next, sa21_next, sa22_next, sa23_next;
wire	[7:0]	sa30_next, sa31_next, sa32_next, sa33_next;
wire	[7:0]	sa00_sub, sa01_sub, sa02_sub, sa03_sub;
wire	[7:0]	sa10_sub, sa11_sub, sa12_sub, sa13_sub;
wire	[7:0]	sa20_sub, sa21_sub, sa22_sub, sa23_sub;
wire	[7:0]	sa30_sub, sa31_sub, sa32_sub, sa33_sub;
wire	[7:0]	sa00_sr, sa01_sr, sa02_sr, sa03_sr;
wire	[7:0]	sa10_sr, sa11_sr, sa12_sr, sa13_sr;
wire	[7:0]	sa20_sr, sa21_sr, sa22_sr, sa23_sr;
wire	[7:0]	sa30_sr, sa31_sr, sa32_sr, sa33_sr;
wire	[7:0]	sa00_mc, sa01_mc, sa02_mc, sa03_mc;
wire	[7:0]	sa10_mc, sa11_mc, sa12_mc, sa13_mc;
wire	[7:0]	sa20_mc, sa21_mc, sa22_mc, sa23_mc;
wire	[7:0]	sa30_mc, sa31_mc, sa32_mc, sa33_mc;
reg		done, ld_r;
reg	[3:0]	dcnt;
//__RB_CUT_GROUP_END__ type=internal_signal id=aes/aes_cipher_top/aes_cipher_top.v:grp:internal_signal:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=16-43

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//轮计数控制

//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=aes/aes_cipher_top/aes_cipher_top.v:grp:reg_cluster:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=50-61
//__RB_CUT_GROUP_BEGIN__ type=counter_cluster id=aes/aes_cipher_top/aes_cipher_top.v:grp:counter_cluster:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=50-59
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=50-55
always @(posedge clk)
//__RB_CUT_BODY__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=50-55
	if(!rst)	dcnt <=  4'h0;
	else
	if(ld)		dcnt <=  4'hb;//加载新数据时设为11（10轮加密+1轮初始轮密钥加）
	else
	if(|dcnt)	dcnt <=  dcnt - 4'h1;//每个时钟周期递减，直到完成所有轮
//__RB_CUT_TAIL__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=50-55
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=50-55
//“|”是归约运算符，对所有位进行或运算
//当dcnt不为0时即还有位是1时进行减1，为0时保持为0，防止计数器从0减到负数

//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=59-59
always @(posedge clk) done <=  !(|dcnt[3:1]) & dcnt[0] & !ld;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=59-59
//__RB_CUT_GROUP_END__ type=counter_cluster id=aes/aes_cipher_top/aes_cipher_top.v:grp:counter_cluster:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=50-59
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000003 file=aes/aes_cipher_top/aes_cipher_top.v lines=60-60
always @(posedge clk) if(ld) text_in_r <=  text_in;//输入数据缓存到text_in_r寄存器，当初始轮密钥加时使用
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000003 file=aes/aes_cipher_top/aes_cipher_top.v lines=60-60
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000004 file=aes/aes_cipher_top/aes_cipher_top.v lines=61-61
always @(posedge clk) ld_r <=  ld;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000004 file=aes/aes_cipher_top/aes_cipher_top.v lines=61-61
//__RB_CUT_GROUP_END__ type=reg_cluster id=aes/aes_cipher_top/aes_cipher_top.v:grp:reg_cluster:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=50-61

////////////////////////////////////////////////////////////////////
//
// Initial Permutation (AddRoundKey)
//
//初始轮密钥加操作
//
//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=aes/aes_cipher_top/aes_cipher_top.v:grp:reg_cluster:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=69-85
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000005 file=aes/aes_cipher_top/aes_cipher_top.v lines=69-69
always @(posedge clk)	sa33 <=  ld_r ? text_in_r[007:000] ^ w3[07:00] : sa33_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000005 file=aes/aes_cipher_top/aes_cipher_top.v lines=69-69
//当ld_r=1时：输入数据的最低字节与轮密钥w3的最低字节异或；当ld_r=0时：使用轮变换的结果sa33_next
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000006 file=aes/aes_cipher_top/aes_cipher_top.v lines=71-71
always @(posedge clk)	sa23 <=  ld_r ? text_in_r[015:008] ^ w3[15:08] : sa23_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000006 file=aes/aes_cipher_top/aes_cipher_top.v lines=71-71
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000007 file=aes/aes_cipher_top/aes_cipher_top.v lines=72-72
always @(posedge clk)	sa13 <=  ld_r ? text_in_r[023:016] ^ w3[23:16] : sa13_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000007 file=aes/aes_cipher_top/aes_cipher_top.v lines=72-72
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000008 file=aes/aes_cipher_top/aes_cipher_top.v lines=73-73
always @(posedge clk)	sa03 <=  ld_r ? text_in_r[031:024] ^ w3[31:24] : sa03_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000008 file=aes/aes_cipher_top/aes_cipher_top.v lines=73-73
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000009 file=aes/aes_cipher_top/aes_cipher_top.v lines=74-74
always @(posedge clk)	sa32 <=  ld_r ? text_in_r[039:032] ^ w2[07:00] : sa32_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000009 file=aes/aes_cipher_top/aes_cipher_top.v lines=74-74
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000010 file=aes/aes_cipher_top/aes_cipher_top.v lines=75-75
always @(posedge clk)	sa22 <=  ld_r ? text_in_r[047:040] ^ w2[15:08] : sa22_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000010 file=aes/aes_cipher_top/aes_cipher_top.v lines=75-75
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000011 file=aes/aes_cipher_top/aes_cipher_top.v lines=76-76
always @(posedge clk)	sa12 <=  ld_r ? text_in_r[055:048] ^ w2[23:16] : sa12_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000011 file=aes/aes_cipher_top/aes_cipher_top.v lines=76-76
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000012 file=aes/aes_cipher_top/aes_cipher_top.v lines=77-77
always @(posedge clk)	sa02 <=  ld_r ? text_in_r[063:056] ^ w2[31:24] : sa02_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000012 file=aes/aes_cipher_top/aes_cipher_top.v lines=77-77
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000013 file=aes/aes_cipher_top/aes_cipher_top.v lines=78-78
always @(posedge clk)	sa31 <=  ld_r ? text_in_r[071:064] ^ w1[07:00] : sa31_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000013 file=aes/aes_cipher_top/aes_cipher_top.v lines=78-78
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000014 file=aes/aes_cipher_top/aes_cipher_top.v lines=79-79
always @(posedge clk)	sa21 <=  ld_r ? text_in_r[079:072] ^ w1[15:08] : sa21_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000014 file=aes/aes_cipher_top/aes_cipher_top.v lines=79-79
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000015 file=aes/aes_cipher_top/aes_cipher_top.v lines=80-80
always @(posedge clk)	sa11 <=  ld_r ? text_in_r[087:080] ^ w1[23:16] : sa11_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000015 file=aes/aes_cipher_top/aes_cipher_top.v lines=80-80
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000016 file=aes/aes_cipher_top/aes_cipher_top.v lines=81-81
always @(posedge clk)	sa01 <=  ld_r ? text_in_r[095:088] ^ w1[31:24] : sa01_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000016 file=aes/aes_cipher_top/aes_cipher_top.v lines=81-81
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000017 file=aes/aes_cipher_top/aes_cipher_top.v lines=82-82
always @(posedge clk)	sa30 <=  ld_r ? text_in_r[103:096] ^ w0[07:00] : sa30_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000017 file=aes/aes_cipher_top/aes_cipher_top.v lines=82-82
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000018 file=aes/aes_cipher_top/aes_cipher_top.v lines=83-83
always @(posedge clk)	sa20 <=  ld_r ? text_in_r[111:104] ^ w0[15:08] : sa20_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000018 file=aes/aes_cipher_top/aes_cipher_top.v lines=83-83
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000019 file=aes/aes_cipher_top/aes_cipher_top.v lines=84-84
always @(posedge clk)	sa10 <=  ld_r ? text_in_r[119:112] ^ w0[23:16] : sa10_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000019 file=aes/aes_cipher_top/aes_cipher_top.v lines=84-84
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000020 file=aes/aes_cipher_top/aes_cipher_top.v lines=85-85
always @(posedge clk)	sa00 <=  ld_r ? text_in_r[127:120] ^ w0[31:24] : sa00_next;
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000020 file=aes/aes_cipher_top/aes_cipher_top.v lines=85-85
//__RB_CUT_GROUP_END__ type=reg_cluster id=aes/aes_cipher_top/aes_cipher_top.v:grp:reg_cluster:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=69-85

////////////////////////////////////////////////////////////////////
//
// Round Permutations
//
//加密轮变换流程
//2.shiftrows变换
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=aes/aes_cipher_top/aes_cipher_top.v:grp:assign_cluster:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=93-108
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=93-93
assign sa00_sr = sa00_sub;//第0行，不移位
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=93-93
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=94-94
assign sa01_sr = sa01_sub;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=94-94
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000003 file=aes/aes_cipher_top/aes_cipher_top.v lines=95-95
assign sa02_sr = sa02_sub;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000003 file=aes/aes_cipher_top/aes_cipher_top.v lines=95-95
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000004 file=aes/aes_cipher_top/aes_cipher_top.v lines=96-96
assign sa03_sr = sa03_sub;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000004 file=aes/aes_cipher_top/aes_cipher_top.v lines=96-96
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000005 file=aes/aes_cipher_top/aes_cipher_top.v lines=97-97
assign sa10_sr = sa11_sub;//第1行，循环左移1字节
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000005 file=aes/aes_cipher_top/aes_cipher_top.v lines=97-97
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000006 file=aes/aes_cipher_top/aes_cipher_top.v lines=98-98
assign sa11_sr = sa12_sub;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000006 file=aes/aes_cipher_top/aes_cipher_top.v lines=98-98
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000007 file=aes/aes_cipher_top/aes_cipher_top.v lines=99-99
assign sa12_sr = sa13_sub;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000007 file=aes/aes_cipher_top/aes_cipher_top.v lines=99-99
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000008 file=aes/aes_cipher_top/aes_cipher_top.v lines=100-100
assign sa13_sr = sa10_sub;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000008 file=aes/aes_cipher_top/aes_cipher_top.v lines=100-100
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000009 file=aes/aes_cipher_top/aes_cipher_top.v lines=101-101
assign sa20_sr = sa22_sub;//第2行，循环左移2字节
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000009 file=aes/aes_cipher_top/aes_cipher_top.v lines=101-101
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000010 file=aes/aes_cipher_top/aes_cipher_top.v lines=102-102
assign sa21_sr = sa23_sub;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000010 file=aes/aes_cipher_top/aes_cipher_top.v lines=102-102
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000011 file=aes/aes_cipher_top/aes_cipher_top.v lines=103-103
assign sa22_sr = sa20_sub;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000011 file=aes/aes_cipher_top/aes_cipher_top.v lines=103-103
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000012 file=aes/aes_cipher_top/aes_cipher_top.v lines=104-104
assign sa23_sr = sa21_sub;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000012 file=aes/aes_cipher_top/aes_cipher_top.v lines=104-104
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000013 file=aes/aes_cipher_top/aes_cipher_top.v lines=105-105
assign sa30_sr = sa33_sub;//第3行，循环左移3字节
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000013 file=aes/aes_cipher_top/aes_cipher_top.v lines=105-105
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000014 file=aes/aes_cipher_top/aes_cipher_top.v lines=106-106
assign sa31_sr = sa30_sub;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000014 file=aes/aes_cipher_top/aes_cipher_top.v lines=106-106
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000015 file=aes/aes_cipher_top/aes_cipher_top.v lines=107-107
assign sa32_sr = sa31_sub;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000015 file=aes/aes_cipher_top/aes_cipher_top.v lines=107-107
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000016 file=aes/aes_cipher_top/aes_cipher_top.v lines=108-108
assign sa33_sr = sa32_sub;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000016 file=aes/aes_cipher_top/aes_cipher_top.v lines=108-108
//__RB_CUT_GROUP_END__ type=assign_cluster id=aes/aes_cipher_top/aes_cipher_top.v:grp:assign_cluster:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=93-108

//加密轮变换流程
//3.MixColumns变换
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=aes/aes_cipher_top/aes_cipher_top.v:grp:internal_signal:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=112-112
wire [31:0] mix_col_out0, mix_col_out1, mix_col_out2, mix_col_out3;
//__RB_CUT_GROUP_END__ type=internal_signal id=aes/aes_cipher_top/aes_cipher_top.v:grp:internal_signal:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=112-112

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=aes/aes_cipher_top/aes_cipher_top.v:grp:assign_cluster:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=114-141
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000017 file=aes/aes_cipher_top/aes_cipher_top.v lines=114-114
assign mix_col_out0 = mix_col(sa00_sr,sa10_sr,sa20_sr,sa30_sr);
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000017 file=aes/aes_cipher_top/aes_cipher_top.v lines=114-114
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000018 file=aes/aes_cipher_top/aes_cipher_top.v lines=115-115
assign mix_col_out1 = mix_col(sa01_sr,sa11_sr,sa21_sr,sa31_sr);
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000018 file=aes/aes_cipher_top/aes_cipher_top.v lines=115-115
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000019 file=aes/aes_cipher_top/aes_cipher_top.v lines=116-116
assign mix_col_out2 = mix_col(sa02_sr,sa12_sr,sa22_sr,sa32_sr);
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000019 file=aes/aes_cipher_top/aes_cipher_top.v lines=116-116
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000020 file=aes/aes_cipher_top/aes_cipher_top.v lines=117-117
assign mix_col_out3 = mix_col(sa03_sr,sa13_sr,sa23_sr,sa33_sr);
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000020 file=aes/aes_cipher_top/aes_cipher_top.v lines=117-117

//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000021 file=aes/aes_cipher_top/aes_cipher_top.v lines=119-119
assign {sa00_mc, sa10_mc, sa20_mc, sa30_mc} = mix_col_out0;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000021 file=aes/aes_cipher_top/aes_cipher_top.v lines=119-119
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000022 file=aes/aes_cipher_top/aes_cipher_top.v lines=120-120
assign {sa01_mc, sa11_mc, sa21_mc, sa31_mc} = mix_col_out1;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000022 file=aes/aes_cipher_top/aes_cipher_top.v lines=120-120
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000023 file=aes/aes_cipher_top/aes_cipher_top.v lines=121-121
assign {sa02_mc, sa12_mc, sa22_mc, sa32_mc} = mix_col_out2;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000023 file=aes/aes_cipher_top/aes_cipher_top.v lines=121-121
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000024 file=aes/aes_cipher_top/aes_cipher_top.v lines=122-122
assign {sa03_mc, sa13_mc, sa23_mc, sa33_mc} = mix_col_out3;
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000024 file=aes/aes_cipher_top/aes_cipher_top.v lines=122-122

//加密轮变换流程
//4.轮密钥加
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000025 file=aes/aes_cipher_top/aes_cipher_top.v lines=126-126
assign sa00_next = sa00_mc ^ w0[31:24];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000025 file=aes/aes_cipher_top/aes_cipher_top.v lines=126-126
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000026 file=aes/aes_cipher_top/aes_cipher_top.v lines=127-127
assign sa01_next = sa01_mc ^ w1[31:24];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000026 file=aes/aes_cipher_top/aes_cipher_top.v lines=127-127
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000027 file=aes/aes_cipher_top/aes_cipher_top.v lines=128-128
assign sa02_next = sa02_mc ^ w2[31:24];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000027 file=aes/aes_cipher_top/aes_cipher_top.v lines=128-128
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000028 file=aes/aes_cipher_top/aes_cipher_top.v lines=129-129
assign sa03_next = sa03_mc ^ w3[31:24];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000028 file=aes/aes_cipher_top/aes_cipher_top.v lines=129-129
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000029 file=aes/aes_cipher_top/aes_cipher_top.v lines=130-130
assign sa10_next = sa10_mc ^ w0[23:16];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000029 file=aes/aes_cipher_top/aes_cipher_top.v lines=130-130
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000030 file=aes/aes_cipher_top/aes_cipher_top.v lines=131-131
assign sa11_next = sa11_mc ^ w1[23:16];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000030 file=aes/aes_cipher_top/aes_cipher_top.v lines=131-131
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000031 file=aes/aes_cipher_top/aes_cipher_top.v lines=132-132
assign sa12_next = sa12_mc ^ w2[23:16];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000031 file=aes/aes_cipher_top/aes_cipher_top.v lines=132-132
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000032 file=aes/aes_cipher_top/aes_cipher_top.v lines=133-133
assign sa13_next = sa13_mc ^ w3[23:16];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000032 file=aes/aes_cipher_top/aes_cipher_top.v lines=133-133
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000033 file=aes/aes_cipher_top/aes_cipher_top.v lines=134-134
assign sa20_next = sa20_mc ^ w0[15:08];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000033 file=aes/aes_cipher_top/aes_cipher_top.v lines=134-134
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000034 file=aes/aes_cipher_top/aes_cipher_top.v lines=135-135
assign sa21_next = sa21_mc ^ w1[15:08];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000034 file=aes/aes_cipher_top/aes_cipher_top.v lines=135-135
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000035 file=aes/aes_cipher_top/aes_cipher_top.v lines=136-136
assign sa22_next = sa22_mc ^ w2[15:08];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000035 file=aes/aes_cipher_top/aes_cipher_top.v lines=136-136
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000036 file=aes/aes_cipher_top/aes_cipher_top.v lines=137-137
assign sa23_next = sa23_mc ^ w3[15:08];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000036 file=aes/aes_cipher_top/aes_cipher_top.v lines=137-137
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000037 file=aes/aes_cipher_top/aes_cipher_top.v lines=138-138
assign sa30_next = sa30_mc ^ w0[07:00];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000037 file=aes/aes_cipher_top/aes_cipher_top.v lines=138-138
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000038 file=aes/aes_cipher_top/aes_cipher_top.v lines=139-139
assign sa31_next = sa31_mc ^ w1[07:00];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000038 file=aes/aes_cipher_top/aes_cipher_top.v lines=139-139
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000039 file=aes/aes_cipher_top/aes_cipher_top.v lines=140-140
assign sa32_next = sa32_mc ^ w2[07:00];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000039 file=aes/aes_cipher_top/aes_cipher_top.v lines=140-140
//__RB_CUT_BEGIN__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000040 file=aes/aes_cipher_top/aes_cipher_top.v lines=141-141
assign sa33_next = sa33_mc ^ w3[07:00];
//__RB_CUT_END__ type=assign id=aes/aes_cipher_top/aes_cipher_top.v:assign:000040 file=aes/aes_cipher_top/aes_cipher_top.v lines=141-141
//__RB_CUT_GROUP_END__ type=assign_cluster id=aes/aes_cipher_top/aes_cipher_top.v:grp:assign_cluster:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=114-141

////////////////////////////////////////////////////////////////////
//
// Final text output
//
//输出处理，最后一轮后的状态与最终轮密钥异或
//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=aes/aes_cipher_top/aes_cipher_top.v:grp:reg_cluster:000003 file=aes/aes_cipher_top/aes_cipher_top.v lines=148-163
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000021 file=aes/aes_cipher_top/aes_cipher_top.v lines=148-148
always @(posedge clk) text_out[127:120] <=  sa00_sr ^ w0[31:24];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000021 file=aes/aes_cipher_top/aes_cipher_top.v lines=148-148
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000022 file=aes/aes_cipher_top/aes_cipher_top.v lines=149-149
always @(posedge clk) text_out[095:088] <=  sa01_sr ^ w1[31:24];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000022 file=aes/aes_cipher_top/aes_cipher_top.v lines=149-149
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000023 file=aes/aes_cipher_top/aes_cipher_top.v lines=150-150
always @(posedge clk) text_out[063:056] <=  sa02_sr ^ w2[31:24];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000023 file=aes/aes_cipher_top/aes_cipher_top.v lines=150-150
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000024 file=aes/aes_cipher_top/aes_cipher_top.v lines=151-151
always @(posedge clk) text_out[031:024] <=  sa03_sr ^ w3[31:24];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000024 file=aes/aes_cipher_top/aes_cipher_top.v lines=151-151
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000025 file=aes/aes_cipher_top/aes_cipher_top.v lines=152-152
always @(posedge clk) text_out[119:112] <=  sa10_sr ^ w0[23:16];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000025 file=aes/aes_cipher_top/aes_cipher_top.v lines=152-152
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000026 file=aes/aes_cipher_top/aes_cipher_top.v lines=153-153
always @(posedge clk) text_out[087:080] <=  sa11_sr ^ w1[23:16];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000026 file=aes/aes_cipher_top/aes_cipher_top.v lines=153-153
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000027 file=aes/aes_cipher_top/aes_cipher_top.v lines=154-154
always @(posedge clk) text_out[055:048] <=  sa12_sr ^ w2[23:16];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000027 file=aes/aes_cipher_top/aes_cipher_top.v lines=154-154
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000028 file=aes/aes_cipher_top/aes_cipher_top.v lines=155-155
always @(posedge clk) text_out[023:016] <=  sa13_sr ^ w3[23:16];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000028 file=aes/aes_cipher_top/aes_cipher_top.v lines=155-155
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000029 file=aes/aes_cipher_top/aes_cipher_top.v lines=156-156
always @(posedge clk) text_out[111:104] <=  sa20_sr ^ w0[15:08];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000029 file=aes/aes_cipher_top/aes_cipher_top.v lines=156-156
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000030 file=aes/aes_cipher_top/aes_cipher_top.v lines=157-157
always @(posedge clk) text_out[079:072] <=  sa21_sr ^ w1[15:08];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000030 file=aes/aes_cipher_top/aes_cipher_top.v lines=157-157
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000031 file=aes/aes_cipher_top/aes_cipher_top.v lines=158-158
always @(posedge clk) text_out[047:040] <=  sa22_sr ^ w2[15:08];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000031 file=aes/aes_cipher_top/aes_cipher_top.v lines=158-158
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000032 file=aes/aes_cipher_top/aes_cipher_top.v lines=159-159
always @(posedge clk) text_out[015:008] <=  sa23_sr ^ w3[15:08];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000032 file=aes/aes_cipher_top/aes_cipher_top.v lines=159-159
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000033 file=aes/aes_cipher_top/aes_cipher_top.v lines=160-160
always @(posedge clk) text_out[103:096] <=  sa30_sr ^ w0[07:00];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000033 file=aes/aes_cipher_top/aes_cipher_top.v lines=160-160
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000034 file=aes/aes_cipher_top/aes_cipher_top.v lines=161-161
always @(posedge clk) text_out[071:064] <=  sa31_sr ^ w1[07:00];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000034 file=aes/aes_cipher_top/aes_cipher_top.v lines=161-161
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000035 file=aes/aes_cipher_top/aes_cipher_top.v lines=162-162
always @(posedge clk) text_out[039:032] <=  sa32_sr ^ w2[07:00];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000035 file=aes/aes_cipher_top/aes_cipher_top.v lines=162-162
//__RB_CUT_BEGIN__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000036 file=aes/aes_cipher_top/aes_cipher_top.v lines=163-163
always @(posedge clk) text_out[007:000] <=  sa33_sr ^ w3[07:00];
//__RB_CUT_END__ type=always id=aes/aes_cipher_top/aes_cipher_top.v:proc:000036 file=aes/aes_cipher_top/aes_cipher_top.v lines=163-163
//__RB_CUT_GROUP_END__ type=reg_cluster id=aes/aes_cipher_top/aes_cipher_top.v:grp:reg_cluster:000003 file=aes/aes_cipher_top/aes_cipher_top.v lines=148-163

////////////////////////////////////////////////////////////////////
//
// Generic Functions
//

//__RB_CUT_BEGIN__ type=function id=aes/aes_cipher_top/aes_cipher_top.v:function:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=170-179
function [31:0] mix_col;//实现GF(2^8)上的矩阵乘法
//__RB_CUT_HEAD__ type=function id=aes/aes_cipher_top/aes_cipher_top.v:function:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=170-179
input	[7:0]	s0,s1,s2,s3;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=aes/aes_cipher_top/aes_cipher_top.v:grp:internal_signal:000003 file=aes/aes_cipher_top/aes_cipher_top.v lines=172-172
reg	[7:0]	s0_o,s1_o,s2_o,s3_o;
//__RB_CUT_GROUP_END__ type=internal_signal id=aes/aes_cipher_top/aes_cipher_top.v:grp:internal_signal:000003 file=aes/aes_cipher_top/aes_cipher_top.v lines=172-172
//__RB_CUT_BODY__ type=function id=aes/aes_cipher_top/aes_cipher_top.v:function:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=170-179
//__RB_CUT_BEGIN__ type=begin_end id=aes/aes_cipher_top/aes_cipher_top.v:begin_end:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=173-178
begin
//__RB_CUT_BODY__ type=begin_end id=aes/aes_cipher_top/aes_cipher_top.v:begin_end:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=173-178
mix_col[31:24]=xtime(s0)^xtime(s1)^s1^s2^s3;
mix_col[23:16]=s0^xtime(s1)^xtime(s2)^s2^s3;
mix_col[15:08]=s0^s1^xtime(s2)^xtime(s3)^s3;
mix_col[07:00]=xtime(s0)^s0^s1^s2^xtime(s3);
//__RB_CUT_TAIL__ type=begin_end id=aes/aes_cipher_top/aes_cipher_top.v:begin_end:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=173-178
end
//__RB_CUT_END__ type=begin_end id=aes/aes_cipher_top/aes_cipher_top.v:begin_end:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=173-178
//__RB_CUT_TAIL__ type=function id=aes/aes_cipher_top/aes_cipher_top.v:function:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=170-179
endfunction
//__RB_CUT_END__ type=function id=aes/aes_cipher_top/aes_cipher_top.v:function:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=170-179

//__RB_CUT_BEGIN__ type=function id=aes/aes_cipher_top/aes_cipher_top.v:function:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=181-183
function [7:0] xtime;//实现GF(2^8)上的×2运算
//__RB_CUT_BODY__ type=function id=aes/aes_cipher_top/aes_cipher_top.v:function:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=181-183
input [7:0] b; xtime={b[6:0],1'b0}^(8'h1b&{8{b[7]}});
//__RB_CUT_TAIL__ type=function id=aes/aes_cipher_top/aes_cipher_top.v:function:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=181-183
endfunction
//__RB_CUT_END__ type=function id=aes/aes_cipher_top/aes_cipher_top.v:function:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=181-183

////////////////////////////////////////////////////////////////////
//
// Modules
//

//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=190-197
aes_key_expand_128 u0(
	.clk(		clk	),
	.kld(		ld	),
	.key(		key	),
	.wo_0(		w0	),
	.wo_1(		w1	),
	.wo_2(		w2	),
	.wo_3(		w3	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000001 file=aes/aes_cipher_top/aes_cipher_top.v lines=190-197

//加密轮变换流程
//1.subbyte变换
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=201-201
aes_sbox us00(	.a(	sa00	), .b(	sa00_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000002 file=aes/aes_cipher_top/aes_cipher_top.v lines=201-201
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000003 file=aes/aes_cipher_top/aes_cipher_top.v lines=202-202
aes_sbox us01(	.a(	sa01	), .b(	sa01_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000003 file=aes/aes_cipher_top/aes_cipher_top.v lines=202-202
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000004 file=aes/aes_cipher_top/aes_cipher_top.v lines=203-203
aes_sbox us02(	.a(	sa02	), .b(	sa02_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000004 file=aes/aes_cipher_top/aes_cipher_top.v lines=203-203
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000005 file=aes/aes_cipher_top/aes_cipher_top.v lines=204-204
aes_sbox us03(	.a(	sa03	), .b(	sa03_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000005 file=aes/aes_cipher_top/aes_cipher_top.v lines=204-204
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000006 file=aes/aes_cipher_top/aes_cipher_top.v lines=205-205
aes_sbox us10(	.a(	sa10	), .b(	sa10_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000006 file=aes/aes_cipher_top/aes_cipher_top.v lines=205-205
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000007 file=aes/aes_cipher_top/aes_cipher_top.v lines=206-206
aes_sbox us11(	.a(	sa11	), .b(	sa11_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000007 file=aes/aes_cipher_top/aes_cipher_top.v lines=206-206
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000008 file=aes/aes_cipher_top/aes_cipher_top.v lines=207-207
aes_sbox us12(	.a(	sa12	), .b(	sa12_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000008 file=aes/aes_cipher_top/aes_cipher_top.v lines=207-207
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000009 file=aes/aes_cipher_top/aes_cipher_top.v lines=208-208
aes_sbox us13(	.a(	sa13	), .b(	sa13_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000009 file=aes/aes_cipher_top/aes_cipher_top.v lines=208-208
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000010 file=aes/aes_cipher_top/aes_cipher_top.v lines=209-209
aes_sbox us20(	.a(	sa20	), .b(	sa20_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000010 file=aes/aes_cipher_top/aes_cipher_top.v lines=209-209
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000011 file=aes/aes_cipher_top/aes_cipher_top.v lines=210-210
aes_sbox us21(	.a(	sa21	), .b(	sa21_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000011 file=aes/aes_cipher_top/aes_cipher_top.v lines=210-210
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000012 file=aes/aes_cipher_top/aes_cipher_top.v lines=211-211
aes_sbox us22(	.a(	sa22	), .b(	sa22_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000012 file=aes/aes_cipher_top/aes_cipher_top.v lines=211-211
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000013 file=aes/aes_cipher_top/aes_cipher_top.v lines=212-212
aes_sbox us23(	.a(	sa23	), .b(	sa23_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000013 file=aes/aes_cipher_top/aes_cipher_top.v lines=212-212
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000014 file=aes/aes_cipher_top/aes_cipher_top.v lines=213-213
aes_sbox us30(	.a(	sa30	), .b(	sa30_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000014 file=aes/aes_cipher_top/aes_cipher_top.v lines=213-213
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000015 file=aes/aes_cipher_top/aes_cipher_top.v lines=214-214
aes_sbox us31(	.a(	sa31	), .b(	sa31_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000015 file=aes/aes_cipher_top/aes_cipher_top.v lines=214-214
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000016 file=aes/aes_cipher_top/aes_cipher_top.v lines=215-215
aes_sbox us32(	.a(	sa32	), .b(	sa32_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000016 file=aes/aes_cipher_top/aes_cipher_top.v lines=215-215
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000017 file=aes/aes_cipher_top/aes_cipher_top.v lines=216-216
aes_sbox us33(	.a(	sa33	), .b(	sa33_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_cipher_top/aes_cipher_top.v:inst:000017 file=aes/aes_cipher_top/aes_cipher_top.v lines=216-216

endmodule