// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_sd_bd.h for the primary calling header

#include "Vtb_sd_bd__pch.h"
#include "Vtb_sd_bd___024root.h"

VL_ATTR_COLD void Vtb_sd_bd___024root___eval_static__TOP(Vtb_sd_bd___024root* vlSelf);

VL_ATTR_COLD void Vtb_sd_bd___024root___eval_static(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_static\n"); );
    // Body
    Vtb_sd_bd___024root___eval_static__TOP(vlSelf);
}

VL_ATTR_COLD void Vtb_sd_bd___024root___eval_final__TOP(Vtb_sd_bd___024root* vlSelf);

VL_ATTR_COLD void Vtb_sd_bd___024root___eval_final(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_final\n"); );
    // Body
    Vtb_sd_bd___024root___eval_final__TOP(vlSelf);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_sd_bd___024root___dump_triggers__stl(Vtb_sd_bd___024root* vlSelf);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_sd_bd___024root___eval_phase__stl(Vtb_sd_bd___024root* vlSelf);

VL_ATTR_COLD void Vtb_sd_bd___024root___eval_settle(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_settle\n"); );
    // Init
    IData/*31:0*/ __VstlIterCount;
    CData/*0:0*/ __VstlContinue;
    // Body
    __VstlIterCount = 0U;
    vlSelf->__VstlFirstIteration = 1U;
    __VstlContinue = 1U;
    while (__VstlContinue) {
        if (VL_UNLIKELY((0x64U < __VstlIterCount))) {
#ifdef VL_DEBUG
            Vtb_sd_bd___024root___dump_triggers__stl(vlSelf);
#endif
            VL_FATAL_MT("sd_bd_testbench.sv", 3, "", "Settle region did not converge.");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
        __VstlContinue = 0U;
        if (Vtb_sd_bd___024root___eval_phase__stl(vlSelf)) {
            __VstlContinue = 1U;
        }
        vlSelf->__VstlFirstIteration = 0U;
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_sd_bd___024root___dump_triggers__stl(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ vlSelf->__VstlTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VstlTriggered.word(0U))) {
        VL_DBG_MSGF("         'stl' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_sd_bd___024root___stl_sequent__TOP__0(Vtb_sd_bd___024root* vlSelf);

VL_ATTR_COLD void Vtb_sd_bd___024root___eval_stl(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_stl\n"); );
    // Body
    if ((1ULL & vlSelf->__VstlTriggered.word(0U))) {
        Vtb_sd_bd___024root___stl_sequent__TOP__0(vlSelf);
        vlSelf->__Vm_traceActivity[4U] = 1U;
        vlSelf->__Vm_traceActivity[3U] = 1U;
        vlSelf->__Vm_traceActivity[2U] = 1U;
        vlSelf->__Vm_traceActivity[1U] = 1U;
        vlSelf->__Vm_traceActivity[0U] = 1U;
    }
}

VL_ATTR_COLD void Vtb_sd_bd___024root___stl_sequent__TOP__0(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___stl_sequent__TOP__0\n"); );
    // Body
    vlSelf->tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0 
        = (((IData)(vlSelf->tb_sd_bd__DOT__free_bd_ref) 
            << 0x11U) | (((IData)(vlSelf->tb_sd_bd__DOT__ack_o_s_ref) 
                          << 0x10U) | (IData)(vlSelf->tb_sd_bd__DOT__dat_out_s_ref)));
}

VL_ATTR_COLD void Vtb_sd_bd___024root___eval_triggers__stl(Vtb_sd_bd___024root* vlSelf);

VL_ATTR_COLD bool Vtb_sd_bd___024root___eval_phase__stl(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_phase__stl\n"); );
    // Init
    CData/*0:0*/ __VstlExecute;
    // Body
    Vtb_sd_bd___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = vlSelf->__VstlTriggered.any();
    if (__VstlExecute) {
        Vtb_sd_bd___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_sd_bd___024root___dump_triggers__act(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ vlSelf->__VactTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 0 is active: @(posedge tb_sd_bd.clk)\n");
    }
    if ((2ULL & vlSelf->__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 1 is active: @(posedge tb_sd_bd.clk or posedge tb_sd_bd.rst)\n");
    }
    if ((4ULL & vlSelf->__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 2 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
    if ((8ULL & vlSelf->__VactTriggered.word(0U))) {
        VL_DBG_MSGF("         'act' region trigger index 3 is active: @(negedge tb_sd_bd.clk)\n");
    }
}
#endif  // VL_DEBUG

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_sd_bd___024root___dump_triggers__nba(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___dump_triggers__nba\n"); );
    // Body
    if ((1U & (~ vlSelf->__VnbaTriggered.any()))) {
        VL_DBG_MSGF("         No triggers active\n");
    }
    if ((1ULL & vlSelf->__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 0 is active: @(posedge tb_sd_bd.clk)\n");
    }
    if ((2ULL & vlSelf->__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 1 is active: @(posedge tb_sd_bd.clk or posedge tb_sd_bd.rst)\n");
    }
    if ((4ULL & vlSelf->__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 2 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
    if ((8ULL & vlSelf->__VnbaTriggered.word(0U))) {
        VL_DBG_MSGF("         'nba' region trigger index 3 is active: @(negedge tb_sd_bd.clk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_sd_bd___024root___ctor_var_reset(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___ctor_var_reset\n"); );
    // Body
    VL_ZERO_RESET_W(288, vlSelf->tb_sd_bd__DOT__stats1);
    vlSelf->tb_sd_bd__DOT__clk = VL_RAND_RESET_I(1);
    vlSelf->tb_sd_bd__DOT__rst = VL_RAND_RESET_I(1);
    vlSelf->tb_sd_bd__DOT__we_m = VL_RAND_RESET_I(1);
    vlSelf->tb_sd_bd__DOT__dat_in_m = VL_RAND_RESET_I(16);
    vlSelf->tb_sd_bd__DOT__free_bd_ref = VL_RAND_RESET_I(5);
    vlSelf->tb_sd_bd__DOT__free_bd_dut = VL_RAND_RESET_I(5);
    vlSelf->tb_sd_bd__DOT__re_s = VL_RAND_RESET_I(1);
    vlSelf->tb_sd_bd__DOT__ack_o_s_ref = VL_RAND_RESET_I(1);
    vlSelf->tb_sd_bd__DOT__ack_o_s_dut = VL_RAND_RESET_I(1);
    vlSelf->tb_sd_bd__DOT__a_cmp = VL_RAND_RESET_I(1);
    vlSelf->tb_sd_bd__DOT__dat_out_s_ref = VL_RAND_RESET_I(16);
    vlSelf->tb_sd_bd__DOT__dat_out_s_dut = VL_RAND_RESET_I(16);
    VL_RAND_RESET_W(512, vlSelf->tb_sd_bd__DOT__wavedrom_title);
    vlSelf->tb_sd_bd__DOT__wavedrom_enable = VL_RAND_RESET_I(1);
    vlSelf->tb_sd_bd__DOT____VdfgRegularize_h4e4634a2_0_0 = VL_RAND_RESET_I(22);
    vlSelf->tb_sd_bd__DOT__stim1__DOT__reset_test__Vstatic__arfail = 0;
    vlSelf->tb_sd_bd__DOT__stim1__DOT__reset_test__Vstatic__srfail = 0;
    vlSelf->tb_sd_bd__DOT__stim1__DOT__reset_test__Vstatic__datafail = 0;
    vlSelf->tb_sd_bd__DOT__good1__DOT__new_bw = VL_RAND_RESET_I(1);
    vlSelf->tb_sd_bd__DOT__good1__DOT__last_a_cmp = VL_RAND_RESET_I(1);
    for (int __Vi0 = 0; __Vi0 < 32; ++__Vi0) {
        vlSelf->tb_sd_bd__DOT__good1__DOT__bd_mem[__Vi0] = VL_RAND_RESET_I(16);
    }
    vlSelf->tb_sd_bd__DOT__good1__DOT__write_cnt = VL_RAND_RESET_I(2);
    vlSelf->tb_sd_bd__DOT__good1__DOT__read_s_cnt = VL_RAND_RESET_I(2);
    vlSelf->tb_sd_bd__DOT__good1__DOT__read_cnt = VL_RAND_RESET_I(1);
    vlSelf->tb_sd_bd__DOT__good1__DOT__m_wr_pnt = VL_RAND_RESET_I(5);
    vlSelf->tb_sd_bd__DOT__good1__DOT__s_rd_pnt = VL_RAND_RESET_I(5);
    vlSelf->tb_sd_bd__DOT__top_module1__DOT__new_bw = VL_RAND_RESET_I(1);
    vlSelf->tb_sd_bd__DOT__top_module1__DOT__last_a_cmp = VL_RAND_RESET_I(1);
    for (int __Vi0 = 0; __Vi0 < 32; ++__Vi0) {
        vlSelf->tb_sd_bd__DOT__top_module1__DOT__bd_mem[__Vi0] = VL_RAND_RESET_I(16);
    }
    vlSelf->tb_sd_bd__DOT__top_module1__DOT__write_cnt = VL_RAND_RESET_I(2);
    vlSelf->tb_sd_bd__DOT__top_module1__DOT__read_s_cnt = VL_RAND_RESET_I(2);
    vlSelf->tb_sd_bd__DOT__top_module1__DOT__read_cnt = VL_RAND_RESET_I(1);
    vlSelf->tb_sd_bd__DOT__top_module1__DOT__m_wr_pnt = VL_RAND_RESET_I(5);
    vlSelf->tb_sd_bd__DOT__top_module1__DOT__s_rd_pnt = VL_RAND_RESET_I(5);
    vlSelf->tb_sd_bd__DOT__top_module1__DOT__delay_re_s = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__tb_sd_bd__DOT__clk__0 = VL_RAND_RESET_I(1);
    vlSelf->__Vtrigprevexpr___TOP__tb_sd_bd__DOT__rst__0 = VL_RAND_RESET_I(1);
    for (int __Vi0 = 0; __Vi0 < 5; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = 0;
    }
}
