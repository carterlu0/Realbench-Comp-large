// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtb_sd_bd__Syms.h"


void Vtb_sd_bd___024root__trace_chg_0_sub_0(Vtb_sd_bd___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vtb_sd_bd___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root__trace_chg_0\n"); );
    // Init
    Vtb_sd_bd___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb_sd_bd___024root*>(voidSelf);
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vtb_sd_bd___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vtb_sd_bd___024root__trace_chg_0_sub_0(Vtb_sd_bd___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root__trace_chg_0_sub_0\n"); );
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY((vlSelf->__Vm_traceActivity[1U] 
                     | vlSelf->__Vm_traceActivity[2U]))) {
        bufp->chgBit(oldp+0,(vlSelf->tb_sd_bd__DOT__rst));
        bufp->chgBit(oldp+1,(vlSelf->tb_sd_bd__DOT__we_m));
        bufp->chgSData(oldp+2,(vlSelf->tb_sd_bd__DOT__dat_in_m),16);
        bufp->chgBit(oldp+3,(vlSelf->tb_sd_bd__DOT__re_s));
        bufp->chgBit(oldp+4,(vlSelf->tb_sd_bd__DOT__a_cmp));
        bufp->chgWData(oldp+5,(vlSelf->tb_sd_bd__DOT__wavedrom_title),512);
        bufp->chgBit(oldp+21,(vlSelf->tb_sd_bd__DOT__wavedrom_enable));
        bufp->chgBit(oldp+22,(vlSelf->tb_sd_bd__DOT__stim1__DOT__reset_test__Vstatic__arfail));
        bufp->chgBit(oldp+23,(vlSelf->tb_sd_bd__DOT__stim1__DOT__reset_test__Vstatic__srfail));
        bufp->chgBit(oldp+24,(vlSelf->tb_sd_bd__DOT__stim1__DOT__reset_test__Vstatic__datafail));
    }
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[3U])) {
        bufp->chgWData(oldp+25,(vlSelf->tb_sd_bd__DOT__stats1),288);
        bufp->chgBit(oldp+34,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__delay_re_s));
    }
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[4U])) {
        bufp->chgCData(oldp+35,(vlSelf->tb_sd_bd__DOT__free_bd_ref),5);
        bufp->chgCData(oldp+36,(vlSelf->tb_sd_bd__DOT__free_bd_dut),5);
        bufp->chgBit(oldp+37,(vlSelf->tb_sd_bd__DOT__ack_o_s_ref));
        bufp->chgBit(oldp+38,(vlSelf->tb_sd_bd__DOT__ack_o_s_dut));
        bufp->chgSData(oldp+39,(vlSelf->tb_sd_bd__DOT__dat_out_s_ref),16);
        bufp->chgSData(oldp+40,(vlSelf->tb_sd_bd__DOT__dat_out_s_dut),16);
        bufp->chgBit(oldp+41,((vlSelf->tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0 
                               == (vlSelf->tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0 
                                   ^ ((((IData)(vlSelf->tb_sd_bd__DOT__free_bd_dut) 
                                        << 0x11U) | 
                                       (((IData)(vlSelf->tb_sd_bd__DOT__ack_o_s_dut) 
                                         << 0x10U) 
                                        | (IData)(vlSelf->tb_sd_bd__DOT__dat_out_s_dut))) 
                                      ^ vlSelf->tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0)))));
        bufp->chgBit(oldp+42,((vlSelf->tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0 
                               != (vlSelf->tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0 
                                   ^ ((((IData)(vlSelf->tb_sd_bd__DOT__free_bd_dut) 
                                        << 0x11U) | 
                                       (((IData)(vlSelf->tb_sd_bd__DOT__ack_o_s_dut) 
                                         << 0x10U) 
                                        | (IData)(vlSelf->tb_sd_bd__DOT__dat_out_s_dut))) 
                                      ^ vlSelf->tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0)))));
        bufp->chgBit(oldp+43,(vlSelf->tb_sd_bd__DOT__good1__DOT__new_bw));
        bufp->chgBit(oldp+44,(vlSelf->tb_sd_bd__DOT__good1__DOT__last_a_cmp));
        bufp->chgSData(oldp+45,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[0]),16);
        bufp->chgSData(oldp+46,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[1]),16);
        bufp->chgSData(oldp+47,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[2]),16);
        bufp->chgSData(oldp+48,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[3]),16);
        bufp->chgSData(oldp+49,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[4]),16);
        bufp->chgSData(oldp+50,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[5]),16);
        bufp->chgSData(oldp+51,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[6]),16);
        bufp->chgSData(oldp+52,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[7]),16);
        bufp->chgSData(oldp+53,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[8]),16);
        bufp->chgSData(oldp+54,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[9]),16);
        bufp->chgSData(oldp+55,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[10]),16);
        bufp->chgSData(oldp+56,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[11]),16);
        bufp->chgSData(oldp+57,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[12]),16);
        bufp->chgSData(oldp+58,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[13]),16);
        bufp->chgSData(oldp+59,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[14]),16);
        bufp->chgSData(oldp+60,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[15]),16);
        bufp->chgSData(oldp+61,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[16]),16);
        bufp->chgSData(oldp+62,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[17]),16);
        bufp->chgSData(oldp+63,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[18]),16);
        bufp->chgSData(oldp+64,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[19]),16);
        bufp->chgSData(oldp+65,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[20]),16);
        bufp->chgSData(oldp+66,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[21]),16);
        bufp->chgSData(oldp+67,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[22]),16);
        bufp->chgSData(oldp+68,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[23]),16);
        bufp->chgSData(oldp+69,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[24]),16);
        bufp->chgSData(oldp+70,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[25]),16);
        bufp->chgSData(oldp+71,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[26]),16);
        bufp->chgSData(oldp+72,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[27]),16);
        bufp->chgSData(oldp+73,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[28]),16);
        bufp->chgSData(oldp+74,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[29]),16);
        bufp->chgSData(oldp+75,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[30]),16);
        bufp->chgSData(oldp+76,(vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[31]),16);
        bufp->chgCData(oldp+77,(vlSelf->tb_sd_bd__DOT__good1__DOT__write_cnt),2);
        bufp->chgCData(oldp+78,(vlSelf->tb_sd_bd__DOT__good1__DOT__read_s_cnt),2);
        bufp->chgBit(oldp+79,(vlSelf->tb_sd_bd__DOT__good1__DOT__read_cnt));
        bufp->chgCData(oldp+80,(vlSelf->tb_sd_bd__DOT__good1__DOT__m_wr_pnt),5);
        bufp->chgCData(oldp+81,(vlSelf->tb_sd_bd__DOT__good1__DOT__s_rd_pnt),5);
        bufp->chgBit(oldp+82,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__new_bw));
        bufp->chgBit(oldp+83,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__last_a_cmp));
        bufp->chgSData(oldp+84,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[0]),16);
        bufp->chgSData(oldp+85,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[1]),16);
        bufp->chgSData(oldp+86,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[2]),16);
        bufp->chgSData(oldp+87,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[3]),16);
        bufp->chgSData(oldp+88,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[4]),16);
        bufp->chgSData(oldp+89,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[5]),16);
        bufp->chgSData(oldp+90,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[6]),16);
        bufp->chgSData(oldp+91,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[7]),16);
        bufp->chgSData(oldp+92,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[8]),16);
        bufp->chgSData(oldp+93,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[9]),16);
        bufp->chgSData(oldp+94,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[10]),16);
        bufp->chgSData(oldp+95,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[11]),16);
        bufp->chgSData(oldp+96,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[12]),16);
        bufp->chgSData(oldp+97,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[13]),16);
        bufp->chgSData(oldp+98,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[14]),16);
        bufp->chgSData(oldp+99,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[15]),16);
        bufp->chgSData(oldp+100,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[16]),16);
        bufp->chgSData(oldp+101,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[17]),16);
        bufp->chgSData(oldp+102,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[18]),16);
        bufp->chgSData(oldp+103,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[19]),16);
        bufp->chgSData(oldp+104,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[20]),16);
        bufp->chgSData(oldp+105,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[21]),16);
        bufp->chgSData(oldp+106,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[22]),16);
        bufp->chgSData(oldp+107,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[23]),16);
        bufp->chgSData(oldp+108,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[24]),16);
        bufp->chgSData(oldp+109,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[25]),16);
        bufp->chgSData(oldp+110,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[26]),16);
        bufp->chgSData(oldp+111,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[27]),16);
        bufp->chgSData(oldp+112,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[28]),16);
        bufp->chgSData(oldp+113,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[29]),16);
        bufp->chgSData(oldp+114,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[30]),16);
        bufp->chgSData(oldp+115,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[31]),16);
        bufp->chgCData(oldp+116,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__write_cnt),2);
        bufp->chgCData(oldp+117,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__read_s_cnt),2);
        bufp->chgBit(oldp+118,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__read_cnt));
        bufp->chgCData(oldp+119,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__m_wr_pnt),5);
        bufp->chgCData(oldp+120,(vlSelf->tb_sd_bd__DOT__top_module1__DOT__s_rd_pnt),5);
    }
    bufp->chgBit(oldp+121,(vlSelf->tb_sd_bd__DOT__clk));
}

void Vtb_sd_bd___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root__trace_cleanup\n"); );
    // Init
    Vtb_sd_bd___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb_sd_bd___024root*>(voidSelf);
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[2U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[3U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[4U] = 0U;
}
