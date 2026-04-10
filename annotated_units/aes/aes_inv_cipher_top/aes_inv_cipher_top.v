module aes_inv_cipher_top(clk, rst, kld, ld, done, key, text_in, text_out );
//__RB_CUT_GROUP_BEGIN__ type=port_section id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:port_section:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=2-7
input		clk, rst;
input		kld, ld;
output		done;
input	[127:0]	key;
input	[127:0]	text_in;
output	[127:0]	text_out;
//__RB_CUT_GROUP_END__ type=port_section id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:port_section:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=2-7

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:internal_signal:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=14-39
wire	[31:0]	wk0, wk1, wk2, wk3;
reg	[31:0]	w0, w1, w2, w3;
reg	[127:0]	text_in_r;
reg	[127:0]	text_out;
reg	[7:0]	sa00, sa01, sa02, sa03;
reg	[7:0]	sa10, sa11, sa12, sa13;
reg	[7:0]	sa20, sa21, sa22, sa23;
reg	[7:0]	sa30, sa31, sa32, sa33;
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
wire	[7:0]	sa00_ark, sa01_ark, sa02_ark, sa03_ark;
wire	[7:0]	sa10_ark, sa11_ark, sa12_ark, sa13_ark;
wire	[7:0]	sa20_ark, sa21_ark, sa22_ark, sa23_ark;
wire	[7:0]	sa30_ark, sa31_ark, sa32_ark, sa33_ark;
reg		ld_r, go, done;
reg	[3:0]	dcnt;
//__RB_CUT_GROUP_END__ type=internal_signal id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:internal_signal:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=14-39

////////////////////////////////////////////////////////////////////
//
// Misc Logic
//解密过程的轮控制：
//复位时计数器清零；完成时计数器清零；加载新数据时计数器置1；
//go信号有效时每周期递增
//计数到11且不在加载状态时置位完成信号

//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:reg_cluster:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=49-69
//__RB_CUT_GROUP_BEGIN__ type=counter_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:counter_cluster:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=49-58
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=49-56
always @(posedge clk)
//__RB_CUT_BODY__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=49-56
	if(!rst)	dcnt <=  4'h0;
	else
	if(done)	dcnt <=  4'h0;
	else
	if(ld)		dcnt <=  4'h1;
	else
	if(go)		dcnt <=  dcnt + 4'h1;
//__RB_CUT_TAIL__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=49-56
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=49-56

//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=58-58
always @(posedge clk)	done <=  (dcnt==4'hb) & !ld;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=58-58
//__RB_CUT_GROUP_END__ type=counter_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:counter_cluster:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=49-58

//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=60-65
always @(posedge clk)
//__RB_CUT_BODY__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=60-65
	if(!rst)	go <=  1'b0;
	else
	if(ld)		go <=  1'b1;
	else
	if(done)	go <=  1'b0;
//__RB_CUT_TAIL__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=60-65
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=60-65

//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=67-67
always @(posedge clk)	if(ld)	text_in_r <=  text_in;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=67-67

//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=69-69
always @(posedge clk)	ld_r <=  ld;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=69-69
//__RB_CUT_GROUP_END__ type=reg_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:reg_cluster:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=49-69

////////////////////////////////////////////////////////////////////
//
// Initial Permutation
//

//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:reg_cluster:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=76-91
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000006 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=76-76
always @(posedge clk)	sa33 <=  ld_r ? text_in_r[007:000] ^ w3[07:00] : sa33_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000006 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=76-76
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000007 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=77-77
always @(posedge clk)	sa23 <=  ld_r ? text_in_r[015:008] ^ w3[15:08] : sa23_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000007 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=77-77
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000008 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=78-78
always @(posedge clk)	sa13 <=  ld_r ? text_in_r[023:016] ^ w3[23:16] : sa13_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000008 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=78-78
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000009 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=79-79
always @(posedge clk)	sa03 <=  ld_r ? text_in_r[031:024] ^ w3[31:24] : sa03_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000009 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=79-79
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000010 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=80-80
always @(posedge clk)	sa32 <=  ld_r ? text_in_r[039:032] ^ w2[07:00] : sa32_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000010 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=80-80
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000011 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=81-81
always @(posedge clk)	sa22 <=  ld_r ? text_in_r[047:040] ^ w2[15:08] : sa22_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000011 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=81-81
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000012 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=82-82
always @(posedge clk)	sa12 <=  ld_r ? text_in_r[055:048] ^ w2[23:16] : sa12_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000012 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=82-82
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000013 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=83-83
always @(posedge clk)	sa02 <=  ld_r ? text_in_r[063:056] ^ w2[31:24] : sa02_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000013 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=83-83
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000014 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=84-84
always @(posedge clk)	sa31 <=  ld_r ? text_in_r[071:064] ^ w1[07:00] : sa31_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000014 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=84-84
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000015 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=85-85
always @(posedge clk)	sa21 <=  ld_r ? text_in_r[079:072] ^ w1[15:08] : sa21_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000015 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=85-85
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000016 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=86-86
always @(posedge clk)	sa11 <=  ld_r ? text_in_r[087:080] ^ w1[23:16] : sa11_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000016 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=86-86
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000017 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=87-87
always @(posedge clk)	sa01 <=  ld_r ? text_in_r[095:088] ^ w1[31:24] : sa01_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000017 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=87-87
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000018 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=88-88
always @(posedge clk)	sa30 <=  ld_r ? text_in_r[103:096] ^ w0[07:00] : sa30_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000018 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=88-88
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000019 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=89-89
always @(posedge clk)	sa20 <=  ld_r ? text_in_r[111:104] ^ w0[15:08] : sa20_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000019 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=89-89
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000020 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=90-90
always @(posedge clk)	sa10 <=  ld_r ? text_in_r[119:112] ^ w0[23:16] : sa10_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000020 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=90-90
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000021 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=91-91
always @(posedge clk)	sa00 <=  ld_r ? text_in_r[127:120] ^ w0[31:24] : sa00_next;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000021 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=91-91
//__RB_CUT_GROUP_END__ type=reg_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:reg_cluster:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=76-91

////////////////////////////////////////////////////////////////////
//
// Round Permutations
//
//逆向轮变换实现
//1.逆向行位移变换
//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:assign_cluster:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=99-132
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=99-99
assign sa00_sr = sa00;//0行不移位
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=99-99
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=100-100
assign sa01_sr = sa01;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=100-100
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=101-101
assign sa02_sr = sa02;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=101-101
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=102-102
assign sa03_sr = sa03;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=102-102
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=103-103
assign sa10_sr = sa13;//1行右移3字节
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=103-103
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000006 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=104-104
assign sa11_sr = sa10;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000006 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=104-104
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000007 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=105-105
assign sa12_sr = sa11;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000007 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=105-105
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000008 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=106-106
assign sa13_sr = sa12;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000008 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=106-106
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000009 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=107-107
assign sa20_sr = sa22;//2行右移2字节
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000009 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=107-107
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000010 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=108-108
assign sa21_sr = sa23;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000010 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=108-108
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000011 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=109-109
assign sa22_sr = sa20;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000011 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=109-109
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000012 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=110-110
assign sa23_sr = sa21;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000012 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=110-110
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000013 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=111-111
assign sa30_sr = sa31;//3行右移1字节
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000013 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=111-111
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000014 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=112-112
assign sa31_sr = sa32;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000014 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=112-112
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000015 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=113-113
assign sa32_sr = sa33;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000015 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=113-113
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000016 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=114-114
assign sa33_sr = sa30;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000016 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=114-114

//2.轮密钥加
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000017 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=117-117
assign sa00_ark = sa00_sub ^ w0[31:24];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000017 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=117-117
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000018 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=118-118
assign sa01_ark = sa01_sub ^ w1[31:24];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000018 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=118-118
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000019 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=119-119
assign sa02_ark = sa02_sub ^ w2[31:24];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000019 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=119-119
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000020 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=120-120
assign sa03_ark = sa03_sub ^ w3[31:24];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000020 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=120-120
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000021 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=121-121
assign sa10_ark = sa10_sub ^ w0[23:16];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000021 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=121-121
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000022 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=122-122
assign sa11_ark = sa11_sub ^ w1[23:16];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000022 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=122-122
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000023 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=123-123
assign sa12_ark = sa12_sub ^ w2[23:16];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000023 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=123-123
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000024 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=124-124
assign sa13_ark = sa13_sub ^ w3[23:16];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000024 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=124-124
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000025 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=125-125
assign sa20_ark = sa20_sub ^ w0[15:08];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000025 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=125-125
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000026 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=126-126
assign sa21_ark = sa21_sub ^ w1[15:08];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000026 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=126-126
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000027 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=127-127
assign sa22_ark = sa22_sub ^ w2[15:08];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000027 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=127-127
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000028 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=128-128
assign sa23_ark = sa23_sub ^ w3[15:08];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000028 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=128-128
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000029 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=129-129
assign sa30_ark = sa30_sub ^ w0[07:00];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000029 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=129-129
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000030 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=130-130
assign sa31_ark = sa31_sub ^ w1[07:00];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000030 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=130-130
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000031 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=131-131
assign sa32_ark = sa32_sub ^ w2[07:00];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000031 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=131-131
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000032 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=132-132
assign sa33_ark = sa33_sub ^ w3[07:00];
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000032 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=132-132
//__RB_CUT_GROUP_END__ type=assign_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:assign_cluster:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=99-132

//3.逆向列混合
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:internal_signal:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=135-135
wire [31:0] inv_mix_col_out0, inv_mix_col_out1, inv_mix_col_out2, inv_mix_col_out3;
//__RB_CUT_GROUP_END__ type=internal_signal id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:internal_signal:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=135-135

//__RB_CUT_GROUP_BEGIN__ type=assign_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:assign_cluster:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=137-145
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000033 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=137-137
assign inv_mix_col_out0 = inv_mix_col(sa00_ark,sa10_ark,sa20_ark,sa30_ark);
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000033 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=137-137
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000034 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=138-138
assign inv_mix_col_out1 = inv_mix_col(sa01_ark,sa11_ark,sa21_ark,sa31_ark);
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000034 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=138-138
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000035 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=139-139
assign inv_mix_col_out2 = inv_mix_col(sa02_ark,sa12_ark,sa22_ark,sa32_ark);
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000035 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=139-139
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000036 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=140-140
assign inv_mix_col_out3 = inv_mix_col(sa03_ark,sa13_ark,sa23_ark,sa33_ark);
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000036 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=140-140

//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000037 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=142-142
assign {sa00_next, sa10_next, sa20_next, sa30_next} = inv_mix_col_out0 ;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000037 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=142-142
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000038 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=143-143
assign {sa01_next, sa11_next, sa21_next, sa31_next} = inv_mix_col_out1 ;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000038 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=143-143
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000039 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=144-144
assign {sa02_next, sa12_next, sa22_next, sa32_next} = inv_mix_col_out2 ;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000039 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=144-144
//__RB_CUT_BEGIN__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000040 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=145-145
assign {sa03_next, sa13_next, sa23_next, sa33_next} = inv_mix_col_out3 ;
//__RB_CUT_END__ type=assign id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:assign:000040 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=145-145
//__RB_CUT_GROUP_END__ type=assign_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:assign_cluster:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=137-145

////////////////////////////////////////////////////////////////////
//
// Final Text Output
//

//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:reg_cluster:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=152-167
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000022 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=152-152
always @(posedge clk) text_out[127:120] <=  sa00_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000022 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=152-152
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000023 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=153-153
always @(posedge clk) text_out[095:088] <=  sa01_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000023 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=153-153
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000024 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=154-154
always @(posedge clk) text_out[063:056] <=  sa02_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000024 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=154-154
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000025 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=155-155
always @(posedge clk) text_out[031:024] <=  sa03_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000025 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=155-155
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000026 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=156-156
always @(posedge clk) text_out[119:112] <=  sa10_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000026 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=156-156
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000027 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=157-157
always @(posedge clk) text_out[087:080] <=  sa11_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000027 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=157-157
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000028 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=158-158
always @(posedge clk) text_out[055:048] <=  sa12_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000028 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=158-158
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000029 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=159-159
always @(posedge clk) text_out[023:016] <=  sa13_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000029 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=159-159
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000030 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=160-160
always @(posedge clk) text_out[111:104] <=  sa20_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000030 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=160-160
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000031 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=161-161
always @(posedge clk) text_out[079:072] <=  sa21_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000031 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=161-161
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000032 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=162-162
always @(posedge clk) text_out[047:040] <=  sa22_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000032 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=162-162
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000033 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=163-163
always @(posedge clk) text_out[015:008] <=  sa23_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000033 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=163-163
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000034 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=164-164
always @(posedge clk) text_out[103:096] <=  sa30_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000034 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=164-164
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000035 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=165-165
always @(posedge clk) text_out[071:064] <=  sa31_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000035 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=165-165
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000036 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=166-166
always @(posedge clk) text_out[039:032] <=  sa32_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000036 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=166-166
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000037 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=167-167
always @(posedge clk) text_out[007:000] <=  sa33_ark;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000037 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=167-167
//__RB_CUT_GROUP_END__ type=reg_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:reg_cluster:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=152-167

////////////////////////////////////////////////////////////////////
//
// Generic Functions
//列混合运算

//__RB_CUT_BEGIN__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=174-182
function [31:0] inv_mix_col;
//__RB_CUT_HEAD__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=174-182
input	[7:0]	s0,s1,s2,s3;
//__RB_CUT_BODY__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=174-182
//__RB_CUT_BEGIN__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=176-181
begin
//__RB_CUT_BODY__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=176-181
inv_mix_col[31:24]=pmul_e(s0)^pmul_b(s1)^pmul_d(s2)^pmul_9(s3);
inv_mix_col[23:16]=pmul_9(s0)^pmul_e(s1)^pmul_b(s2)^pmul_d(s3);
inv_mix_col[15:08]=pmul_d(s0)^pmul_9(s1)^pmul_e(s2)^pmul_b(s3);
inv_mix_col[07:00]=pmul_b(s0)^pmul_d(s1)^pmul_9(s2)^pmul_e(s3);
//__RB_CUT_TAIL__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=176-181
end
//__RB_CUT_END__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=176-181
//__RB_CUT_TAIL__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=174-182
endfunction
//__RB_CUT_END__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=174-182

// Some synthesis tools don't like xtime being called recursevly ...
//GF(2^8)乘法运算

//×14
//__RB_CUT_BEGIN__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=188-197
function [7:0] pmul_e;
//__RB_CUT_HEAD__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=188-197
input [7:0] b;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:internal_signal:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=190-190
reg [7:0] two,four,eight;
//__RB_CUT_GROUP_END__ type=internal_signal id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:internal_signal:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=190-190
//__RB_CUT_BODY__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=188-197
//__RB_CUT_BEGIN__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=191-196
begin
//__RB_CUT_BODY__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=191-196
two=xtime(b);//×2
four=xtime(two);//×4
eight=xtime(four);//×8
pmul_e=eight^four^two;//8+4+2=14
//__RB_CUT_TAIL__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=191-196
end
//__RB_CUT_END__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=191-196
//__RB_CUT_TAIL__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=188-197
endfunction
//__RB_CUT_END__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=188-197

//__RB_CUT_BEGIN__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=199-205
function [7:0] pmul_9;
//__RB_CUT_HEAD__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=199-205
input [7:0] b;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:internal_signal:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=201-201
reg [7:0] two,four,eight;
//__RB_CUT_GROUP_END__ type=internal_signal id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:internal_signal:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=201-201
//__RB_CUT_BODY__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=199-205
//__RB_CUT_BEGIN__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=202-204
begin
//__RB_CUT_BODY__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=202-204
two=xtime(b);four=xtime(two);eight=xtime(four);pmul_9=eight^b;
//__RB_CUT_TAIL__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=202-204
end
//__RB_CUT_END__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=202-204
//__RB_CUT_TAIL__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=199-205
endfunction
//__RB_CUT_END__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=199-205

//__RB_CUT_BEGIN__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=207-213
function [7:0] pmul_d;
//__RB_CUT_HEAD__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=207-213
input [7:0] b;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:internal_signal:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=209-209
reg [7:0] two,four,eight;
//__RB_CUT_GROUP_END__ type=internal_signal id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:internal_signal:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=209-209
//__RB_CUT_BODY__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=207-213
//__RB_CUT_BEGIN__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=210-212
begin
//__RB_CUT_BODY__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=210-212
two=xtime(b);four=xtime(two);eight=xtime(four);pmul_d=eight^four^b;
//__RB_CUT_TAIL__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=210-212
end
//__RB_CUT_END__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=210-212
//__RB_CUT_TAIL__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=207-213
endfunction
//__RB_CUT_END__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=207-213

//__RB_CUT_BEGIN__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=215-221
function [7:0] pmul_b;
//__RB_CUT_HEAD__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=215-221
input [7:0] b;
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:internal_signal:000006 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=217-217
reg [7:0] two,four,eight;
//__RB_CUT_GROUP_END__ type=internal_signal id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:internal_signal:000006 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=217-217
//__RB_CUT_BODY__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=215-221
//__RB_CUT_BEGIN__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=218-220
begin
//__RB_CUT_BODY__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=218-220
two=xtime(b);four=xtime(two);eight=xtime(four);pmul_b=eight^two^b;
//__RB_CUT_TAIL__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=218-220
end
//__RB_CUT_END__ type=begin_end id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:begin_end:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=218-220
//__RB_CUT_TAIL__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=215-221
endfunction
//__RB_CUT_END__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=215-221

//__RB_CUT_BEGIN__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000006 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=223-225
function [7:0] xtime;
//__RB_CUT_BODY__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000006 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=223-225
input [7:0] b;xtime={b[6:0],1'b0}^(8'h1b&{8{b[7]}});
//__RB_CUT_TAIL__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000006 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=223-225
endfunction
//__RB_CUT_END__ type=function id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:function:000006 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=223-225

////////////////////////////////////////////////////////////////////
//
// Key Buffer
//
//密钥缓存相关寄存器和计数器
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:internal_signal:000007 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=232-235
reg	[127:0]	kb[10:0];//11个轮密钥的缓存
reg	[3:0]	kcnt;//密钥缓存计数器
reg		kdone;//密钥加载完成标志
reg		kb_ld;//密钥缓存加载使能
//__RB_CUT_GROUP_END__ type=internal_signal id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:internal_signal:000007 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=232-235

//密钥缓存计数器控制，kcnt逆序存储轮密钥
//__RB_CUT_GROUP_BEGIN__ type=reg_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:reg_cluster:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=238-257
//__RB_CUT_GROUP_BEGIN__ type=counter_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:counter_cluster:000006 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=238-256
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000038 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=238-243
always @(posedge clk)
//__RB_CUT_BODY__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000038 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=238-243
	if(!rst)	kcnt <=  4'ha;
	else
	if(kld)		kcnt <=  4'ha;
	else
	if(kb_ld)	kcnt <=  kcnt - 4'h1;
//__RB_CUT_TAIL__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000038 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=238-243
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000038 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=238-243

//密钥加载控制
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000039 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=246-251
always @(posedge clk)
//__RB_CUT_BODY__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000039 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=246-251
	if(!rst)	kb_ld <=  1'b0;
	else
	if(kld)		kb_ld <=  1'b1;
	else
	if(kcnt==4'h0)	kb_ld <=  1'b0;
//__RB_CUT_TAIL__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000039 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=246-251
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000039 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=246-251

//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000040 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=253-253
always @(posedge clk)	kdone <=  (kcnt==4'h0) & !kld;
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000040 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=253-253

//密钥缓存写入和读取
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000041 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=256-256
always @(posedge clk)	if(kb_ld) kb[kcnt] <=  {wk3, wk2, wk1, wk0};//存储轮密钥
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000041 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=256-256
//__RB_CUT_GROUP_END__ type=counter_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:counter_cluster:000006 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=238-256
//__RB_CUT_BEGIN__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000042 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=257-257
always @(posedge clk)	{w3, w2, w1, w0} <=  kb[dcnt];//读取轮密钥
//__RB_CUT_END__ type=always id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:proc:000042 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=257-257
//__RB_CUT_GROUP_END__ type=reg_cluster id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:grp:reg_cluster:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=238-257

////////////////////////////////////////////////////////////////////
//
// Modules
//

//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=264-271
aes_key_expand_128 u0(
	.clk(		clk	),
	.kld(		kld	),
	.key(		key	),
	.wo_0(		wk0	),
	.wo_1(		wk1	),
	.wo_2(		wk2	),
	.wo_3(		wk3	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000001 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=264-271

//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=273-273
aes_inv_sbox us00(	.a(	sa00_sr	),	.b(	sa00_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000002 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=273-273
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=274-274
aes_inv_sbox us01(	.a(	sa01_sr	),	.b(	sa01_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000003 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=274-274
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=275-275
aes_inv_sbox us02(	.a(	sa02_sr	),	.b(	sa02_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000004 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=275-275
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=276-276
aes_inv_sbox us03(	.a(	sa03_sr	),	.b(	sa03_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000005 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=276-276
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000006 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=277-277
aes_inv_sbox us10(	.a(	sa10_sr	),	.b(	sa10_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000006 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=277-277
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000007 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=278-278
aes_inv_sbox us11(	.a(	sa11_sr	),	.b(	sa11_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000007 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=278-278
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000008 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=279-279
aes_inv_sbox us12(	.a(	sa12_sr	),	.b(	sa12_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000008 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=279-279
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000009 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=280-280
aes_inv_sbox us13(	.a(	sa13_sr	),	.b(	sa13_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000009 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=280-280
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000010 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=281-281
aes_inv_sbox us20(	.a(	sa20_sr	),	.b(	sa20_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000010 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=281-281
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000011 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=282-282
aes_inv_sbox us21(	.a(	sa21_sr	),	.b(	sa21_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000011 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=282-282
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000012 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=283-283
aes_inv_sbox us22(	.a(	sa22_sr	),	.b(	sa22_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000012 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=283-283
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000013 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=284-284
aes_inv_sbox us23(	.a(	sa23_sr	),	.b(	sa23_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000013 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=284-284
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000014 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=285-285
aes_inv_sbox us30(	.a(	sa30_sr	),	.b(	sa30_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000014 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=285-285
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000015 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=286-286
aes_inv_sbox us31(	.a(	sa31_sr	),	.b(	sa31_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000015 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=286-286
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000016 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=287-287
aes_inv_sbox us32(	.a(	sa32_sr	),	.b(	sa32_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000016 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=287-287
//__RB_CUT_BEGIN__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000017 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=288-288
aes_inv_sbox us33(	.a(	sa33_sr	),	.b(	sa33_sub	));
//__RB_CUT_END__ type=instantiation id=aes/aes_inv_cipher_top/aes_inv_cipher_top.v:inst:000017 file=aes/aes_inv_cipher_top/aes_inv_cipher_top.v lines=288-288

endmodule