// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtb__Syms.h"


void Vtb___024root__trace_chg_0_sub_0(Vtb___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vtb___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root__trace_chg_0\n"); );
    // Init
    Vtb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb___024root*>(voidSelf);
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    // Body
    Vtb___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vtb___024root__trace_chg_0_sub_0(Vtb___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root__trace_chg_0_sub_0\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY(vlSelfRef.__Vm_traceActivity[1U])) {
        bufp->chgWData(oldp+0,(vlSelfRef.tb__DOT__stats1),160);
    }
    if (VL_UNLIKELY(vlSelfRef.__Vm_traceActivity[2U])) {
        bufp->chgIData(oldp+5,(vlSelfRef.tb__DOT__out_ref),32);
        bufp->chgIData(oldp+6,(vlSelfRef.tb__DOT__out_dut),32);
        bufp->chgBit(oldp+7,((vlSelfRef.tb__DOT__out_ref 
                              == (vlSelfRef.tb__DOT__out_ref 
                                  ^ (vlSelfRef.tb__DOT__out_dut 
                                     ^ vlSelfRef.tb__DOT__out_ref)))));
        bufp->chgBit(oldp+8,((vlSelfRef.tb__DOT__out_ref 
                              != (vlSelfRef.tb__DOT__out_ref 
                                  ^ (vlSelfRef.tb__DOT__out_dut 
                                     ^ vlSelfRef.tb__DOT__out_ref)))));
        bufp->chgCData(oldp+9,(vlSelfRef.tb__DOT__good1__DOT__rcnt),4);
        bufp->chgCData(oldp+10,((0xfU & ((IData)(1U) 
                                         + (IData)(vlSelfRef.tb__DOT__good1__DOT__rcnt)))),4);
        bufp->chgCData(oldp+11,(vlSelfRef.tb__DOT__top_module1__DOT__rcnt),4);
        bufp->chgCData(oldp+12,((0xfU & ((IData)(1U) 
                                         + (IData)(vlSelfRef.tb__DOT__top_module1__DOT__rcnt)))),4);
    }
    bufp->chgBit(oldp+13,(vlSelfRef.tb__DOT__clk));
    bufp->chgBit(oldp+14,(vlSelfRef.tb__DOT__kld));
}

void Vtb___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root__trace_cleanup\n"); );
    // Init
    Vtb___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb___024root*>(voidSelf);
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    // Body
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[2U] = 0U;
}
