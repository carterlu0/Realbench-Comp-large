module sd_fifo_tx_filler
( 
//__RB_CUT_GROUP_BEGIN__ type=port_section id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:grp:port_section:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=3-24
    input clk,
    input rst,
    //WB Signals
    output  [31:0]  m_wb_adr_o,
    output  reg     m_wb_we_o,
    input   [31:0]  m_wb_dat_i,
    output  reg     m_wb_cyc_o,
    output  reg     m_wb_stb_o,
    input          m_wb_ack_i,
    output  reg    [2:0] m_wb_cti_o,
    output  reg    [1:0] m_wb_bte_o,

    //Data Master Control signals
    input en,
    input [31:0] adr,

    //Data Serial signals 
    input sd_clk,
    output [31:0] dat_o,
    input rd,
    output empty,
    output fe
//__RB_CUT_GROUP_END__ type=port_section id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:grp:port_section:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=3-24
);

// 内部信号声明
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:grp:internal_signal:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=28-36
reg reset_tx_fifo;
reg [31:0] din;
reg wr_tx;
reg [8:0] we;
reg [8:0] offset;
wire [5:0] mem_empt;
reg first;
reg ackd;
reg delay;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:grp:internal_signal:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=28-36

// 原始模块实例化
//__RB_CUT_BEGIN__ type=instantiation id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:inst:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=39-50
sd_tx_fifo Tx_Fifo (
    .d(din),
    .wr(wr_tx),
    .wclk(clk),
    .q(dat_o),
    .rd(rd),
    .full(fe),
    .empty(empty),
    .mem_empt(mem_empt),
    .rclk(sd_clk),
    .rst(rst | reset_tx_fifo)
);
//__RB_CUT_END__ type=instantiation id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:inst:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=39-50

// 地址计算
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:assign:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=53-53
assign m_wb_adr_o = adr + offset;
//__RB_CUT_END__ type=assign id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:assign:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=53-53

// 主状态机逻辑
//__RB_CUT_BEGIN__ type=always id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:proc:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=56-107
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000008 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=56-107
always @(posedge clk or posedge rst) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000008 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=56-107
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=57-71
    if (rst) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=57-71
        offset <= 0;
        we <= 8'h1;
        m_wb_we_o <= 0;
        m_wb_cyc_o <= 0;
        m_wb_stb_o <= 0;
        wr_tx <= 0;
        ackd <= 1;
        delay <= 0;
        reset_tx_fifo <= 1;
        first <= 1;
        din <= 0;
        m_wb_bte_o <= 2'b00;
        m_wb_cti_o <= 3'b000;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=57-71
    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=57-71
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000006 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=72-99
    else if (en) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000006 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=72-99
        reset_tx_fifo <= 0;
        
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000002 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=75-81
        if (m_wb_ack_i) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000002 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=75-81
            wr_tx <= 1;
            din <= m_wb_dat_i;
            m_wb_cyc_o <= 0;
            m_wb_stb_o <= 0;
            delay <= ~delay;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000002 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=75-81
        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000002 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=75-81
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000003 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=82-84
        else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000003 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=82-84
            wr_tx <= 0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000003 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=82-84
        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000003 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=82-84
        
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000004 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=86-91
        if (delay) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000004 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=86-91
            offset <= offset + `MEM_OFFSET;
            ackd <= ~ackd;
            delay <= ~delay;
            wr_tx <= 0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000004 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=86-91
        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000004 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=86-91
        
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000005 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=93-98
        if (!m_wb_ack_i && !fe && ackd) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000005 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=93-98
            m_wb_we_o <= 0;
            m_wb_cyc_o <= 1;
            m_wb_stb_o <= 1;
            ackd <= 0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000005 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=93-98
        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000005 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=93-98
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000006 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=72-99
    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000006 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=72-99
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000007 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=100-106
    else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000007 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=100-106
        offset <= 0;
        reset_tx_fifo <= 1;
        m_wb_cyc_o <= 0;
        m_wb_stb_o <= 0;
        m_wb_we_o <= 0;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000007 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=100-106
    end
//__RB_CUT_END__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000007 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=100-106
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000008 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=56-107
end
//__RB_CUT_TAIL__ type=always id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:proc:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=56-107
//__RB_CUT_END__ type=always id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:proc:000001 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=56-107
//__RB_CUT_END__ type=begin_end id=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v:begin_end:000008 file=sdc/sd_fifo_tx_filler/sd_fifo_tx_filler.v lines=56-107



endmodule