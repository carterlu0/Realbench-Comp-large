`include "sd_defines.v"

module sd_fifo_rx_filler
( 
//__RB_CUT_GROUP_BEGIN__ type=port_section id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:grp:port_section:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=5-26
    input clk,
    input rst,
    //WB Signals
    output  [31:0]  m_wb_adr_o,
    output  reg     m_wb_we_o,
    output reg [31:0] m_wb_dat_o,
    output reg      m_wb_cyc_o,
    output reg      m_wb_stb_o,
    input           m_wb_ack_i,
    output reg [2:0] m_wb_cti_o,
    output reg [1:0] m_wb_bte_o,

    //Data Master Control signals
    input en,
    input [31:0] adr,

    //Data Serial signals 
    input sd_clk,
    input [`SD_BUS_W-1:0] dat_i,
    input wr,
    output full,
    output empty
//__RB_CUT_GROUP_END__ type=port_section id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:grp:port_section:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=5-26
);

    // 内部信号定义与原模块相同
//__RB_CUT_GROUP_BEGIN__ type=internal_signal id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:grp:internal_signal:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=30-34
    wire [31:0] dat_o;
    reg rd;
    reg reset_rx_fifo;
    reg [8:0] offset;
    reg wb_free;
//__RB_CUT_GROUP_END__ type=internal_signal id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:grp:internal_signal:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=30-34

    // 实例化原始FIFO
//__RB_CUT_BEGIN__ type=instantiation id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:inst:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=37-48
    sd_rx_fifo Rx_Fifo (
        .d(dat_i),
        .wr(wr),
        .wclk(sd_clk),
        .q(dat_o),
        .rd(rd),
        .full(full),
        .empty(empty),
        .mem_empt(),
        .rclk(clk),
        .rst(rst | reset_rx_fifo)
    );
//__RB_CUT_END__ type=instantiation id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:inst:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=37-48

    // 地址计算逻辑
//__RB_CUT_BEGIN__ type=assign id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:assign:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=51-51
    assign m_wb_adr_o = adr + offset;
//__RB_CUT_END__ type=assign id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:assign:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=51-51

    // 主要状态机逻辑保持不变
//__RB_CUT_BEGIN__ type=always id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:proc:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=54-97
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000006 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=54-97
    always @(posedge clk or posedge rst) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000006 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=54-97
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=55-66
        if (rst) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=55-66
            offset <= 0;
            m_wb_we_o <= 0;
            m_wb_cyc_o <= 0;
            m_wb_stb_o <= 0;
            wb_free <= 1;
            m_wb_dat_o <= 0;
            rd <= 0;
            reset_rx_fifo <= 1;
            m_wb_bte_o <= 2'b00;
            m_wb_cti_o <= 3'b000;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=55-66
        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=55-66
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000004 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=67-87
        else if (en) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000004 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=67-87
            rd <= 0;
            reset_rx_fifo <= 0;
            
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000002 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=71-78
            if (!empty & wb_free) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000002 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=71-78
                rd <= 1;
                m_wb_dat_o <= #1 dat_o;
                m_wb_we_o <= #1 1;
                m_wb_cyc_o <= #1 1;
                m_wb_stb_o <= #1 1; 
                wb_free <= 0;   
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000002 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=71-78
            end
//__RB_CUT_END__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000002 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=71-78

//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000003 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=80-86
            if (!wb_free & m_wb_ack_i) begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000003 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=80-86
                m_wb_we_o <= 0;
                m_wb_cyc_o <= 0;
                m_wb_stb_o <= 0;
                offset <= offset + `MEM_OFFSET;
                wb_free <= 1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000003 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=80-86
            end 
//__RB_CUT_END__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000003 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=80-86
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000004 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=67-87
        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000004 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=67-87
//__RB_CUT_BEGIN__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000005 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=88-96
        else begin
//__RB_CUT_BODY__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000005 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=88-96
            reset_rx_fifo <= 1;
            rd <= 0;
            offset <= 0;
            m_wb_cyc_o <= 0;
            m_wb_stb_o <= 0; 
            m_wb_we_o <= 0; 
            wb_free <= 1;
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000005 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=88-96
        end
//__RB_CUT_END__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000005 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=88-96
//__RB_CUT_TAIL__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000006 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=54-97
    end
//__RB_CUT_TAIL__ type=always id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:proc:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=54-97
//__RB_CUT_END__ type=always id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:proc:000001 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=54-97
//__RB_CUT_END__ type=begin_end id=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v:begin_end:000006 file=sdc/sd_fifo_rx_filler/sd_fifo_rx_filler.v lines=54-97

    
endmodule