// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb.h for the primary calling header

#include "Vtb__pch.h"
#include "Vtb__Syms.h"
#include "Vtb___024root.h"

VL_ATTR_COLD void Vtb___024root___eval_static__TOP(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___eval_static__TOP\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb__DOT__clk = 0U;
    ++(vlSymsp->__Vcoverage[0]);
}

VL_ATTR_COLD void Vtb___024root___eval_initial__TOP(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___eval_initial__TOP\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSymsp->_vm_contextp__->dumpfile(std::string{"wave.vcd"});
    vlSymsp->_traceDumpOpen();
    ++(vlSymsp->__Vcoverage[3]);
}

VL_ATTR_COLD void Vtb___024root___eval_final__TOP(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___eval_final__TOP\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((0U != vlSelfRef.tb__DOT__stats1[2U])) {
        VL_WRITEF_NX("Hint: Output 'out' has %0d mismatches. First mismatch occurred at time %0d.\n",0,
                     32,vlSelfRef.tb__DOT__stats1[2U],
                     32,vlSelfRef.tb__DOT__stats1[1U]);
        ++(vlSymsp->__Vcoverage[4]);
    } else {
        VL_WRITEF_NX("Hint: Output 'out' has no mismatches.\n",0);
        ++(vlSymsp->__Vcoverage[5]);
    }
    VL_WRITEF_NX("\nHint: Total mismatched samples is %1d out of %1d samples\n\nSimulation finished at %0# ps\nMismatches: %1d in %1d samples\n",0,
                 32,vlSelfRef.tb__DOT__stats1[4U],32,
                 vlSelfRef.tb__DOT__stats1[0U],64,VL_TIME_UNITED_Q(1),
                 32,vlSelfRef.tb__DOT__stats1[4U],32,
                 vlSelfRef.tb__DOT__stats1[0U]);
    ++(vlSymsp->__Vcoverage[6]);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb___024root___dump_triggers__stl(Vtb___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb___024root___eval_triggers__stl(Vtb___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___eval_triggers__stl\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered.set(0U, (IData)(vlSelfRef.__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb___024root___dump_triggers__stl(vlSelf);
    }
#endif
}

VL_ATTR_COLD void Vtb___024root___configure_coverage(Vtb___024root* vlSelf, bool first) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb___024root___configure_coverage\n"); );
    auto &vlSelfRef = std::ref(*vlSelf).get();
    // Body
    (void)first;  // Prevent unused variable warning
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[0]), first, "aes_rcon_testbench.sv", 14, 15, ".tb", "v_line/tb", "block", "14");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[1]), first, "aes_rcon_testbench.sv", 15, 13, ".tb", "v_line/tb", "block", "15");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[2]), first, "aes_rcon_testbench.sv", 15, 5, ".tb", "v_line/tb", "block", "15");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[3]), first, "aes_rcon_testbench.sv", 46, 5, ".tb", "v_line/tb", "block", "46-48");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[4]), first, "aes_rcon_testbench.sv", 53, 9, ".tb", "v_branch/tb", "if", "53-55");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[5]), first, "aes_rcon_testbench.sv", 53, 10, ".tb", "v_branch/tb", "else", "57");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[6]), first, "aes_rcon_testbench.sv", 52, 5, ".tb", "v_line/tb", "block", "52,59-62");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[7]), first, "aes_rcon_testbench.sv", 73, 13, ".tb", "v_branch/tb", "if", "73");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[8]), first, "aes_rcon_testbench.sv", 73, 14, ".tb", "v_branch/tb", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[9]), first, "aes_rcon_testbench.sv", 72, 9, ".tb", "v_branch/tb", "if", "72,74");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[10]), first, "aes_rcon_testbench.sv", 72, 10, ".tb", "v_branch/tb", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[11]), first, "aes_rcon_testbench.sv", 78, 13, ".tb", "v_branch/tb", "if", "78");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[12]), first, "aes_rcon_testbench.sv", 78, 14, ".tb", "v_branch/tb", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[13]), first, "aes_rcon_testbench.sv", 77, 9, ".tb", "v_branch/tb", "if", "77,79");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[14]), first, "aes_rcon_testbench.sv", 77, 10, ".tb", "v_branch/tb", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[15]), first, "aes_rcon_testbench.sv", 69, 5, ".tb", "v_line/tb", "block", "69-70");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[16]), first, "aes_rcon_testbench.sv", 84, 5, ".tb", "v_line/tb", "block", "84-87");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[17]), first, "aes_rcon_stimulus_gen.sv", 13, 9, ".tb.stim1", "v_line/stimulus_gen", "block", "13");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[18]), first, "aes_rcon_stimulus_gen.sv", 20, 13, ".tb.stim1", "v_line/stimulus_gen", "block", "20");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[19]), first, "aes_rcon_stimulus_gen.sv", 16, 9, ".tb.stim1", "v_line/stimulus_gen", "block", "16-20");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[20]), first, "aes_rcon_stimulus_gen.sv", 28, 13, ".tb.stim1", "v_line/stimulus_gen", "block", "28");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[21]), first, "aes_rcon_stimulus_gen.sv", 24, 9, ".tb.stim1", "v_line/stimulus_gen", "block", "24-28");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[22]), first, "aes_rcon_stimulus_gen.sv", 32, 9, ".tb.stim1", "v_line/stimulus_gen", "block", "32-36");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[23]), first, "aes_rcon_stimulus_gen.sv", 43, 9, ".tb.stim1", "v_line/stimulus_gen", "block", "43");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[24]), first, "aes_rcon_stimulus_gen.sv", 5, 5, ".tb.stim1", "v_line/stimulus_gen", "block", "5-7,10-13,16,24,32,40-43,45");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[25]), first, "aes_rcon_ref.sv", 12, 2, ".tb.good1", "v_branch/ref_aes_rcon", "if", "12");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[26]), first, "aes_rcon_ref.sv", 12, 3, ".tb.good1", "v_branch/ref_aes_rcon", "else", "13");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[27]), first, "aes_rcon_ref.sv", 11, 1, ".tb.good1", "v_line/ref_aes_rcon", "block", "11");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[28]), first, "aes_rcon_ref.sv", 17, 2, ".tb.good1", "v_branch/ref_aes_rcon", "if", "17");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[29]), first, "aes_rcon_ref.sv", 17, 3, ".tb.good1", "v_branch/ref_aes_rcon", "else", "18");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[30]), first, "aes_rcon_ref.sv", 16, 1, ".tb.good1", "v_line/ref_aes_rcon", "block", "16");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[31]), first, "aes_rcon_ref.sv", 23, 8, ".tb.good1", "v_line/ref_aes_rcon", "case", "23");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[32]), first, "aes_rcon_ref.sv", 24, 8, ".tb.good1", "v_line/ref_aes_rcon", "case", "24");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[33]), first, "aes_rcon_ref.sv", 25, 8, ".tb.good1", "v_line/ref_aes_rcon", "case", "25");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[34]), first, "aes_rcon_ref.sv", 26, 8, ".tb.good1", "v_line/ref_aes_rcon", "case", "26");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[35]), first, "aes_rcon_ref.sv", 27, 8, ".tb.good1", "v_line/ref_aes_rcon", "case", "27");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[36]), first, "aes_rcon_ref.sv", 28, 8, ".tb.good1", "v_line/ref_aes_rcon", "case", "28");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[37]), first, "aes_rcon_ref.sv", 29, 8, ".tb.good1", "v_line/ref_aes_rcon", "case", "29");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[38]), first, "aes_rcon_ref.sv", 30, 8, ".tb.good1", "v_line/ref_aes_rcon", "case", "30");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[39]), first, "aes_rcon_ref.sv", 31, 8, ".tb.good1", "v_line/ref_aes_rcon", "case", "31");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[40]), first, "aes_rcon_ref.sv", 32, 8, ".tb.good1", "v_line/ref_aes_rcon", "case", "32");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[41]), first, "aes_rcon_ref.sv", 33, 4, ".tb.good1", "v_line/ref_aes_rcon", "case", "33");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[42]), first, "aes_rcon_ref.sv", 20, 17, ".tb.good1", "v_line/ref_aes_rcon", "block", "20,22");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[43]), first, "aes_rcon_top.sv", 12, 2, ".tb.top_module1", "v_branch/aes_rcon", "if", "12");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[44]), first, "aes_rcon_top.sv", 12, 3, ".tb.top_module1", "v_branch/aes_rcon", "else", "13");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[45]), first, "aes_rcon_top.sv", 11, 1, ".tb.top_module1", "v_line/aes_rcon", "block", "11");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[46]), first, "aes_rcon_top.sv", 17, 2, ".tb.top_module1", "v_branch/aes_rcon", "if", "17");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[47]), first, "aes_rcon_top.sv", 17, 3, ".tb.top_module1", "v_branch/aes_rcon", "else", "18");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[48]), first, "aes_rcon_top.sv", 16, 1, ".tb.top_module1", "v_line/aes_rcon", "block", "16");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[49]), first, "aes_rcon_top.sv", 23, 8, ".tb.top_module1", "v_line/aes_rcon", "case", "23");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[50]), first, "aes_rcon_top.sv", 24, 8, ".tb.top_module1", "v_line/aes_rcon", "case", "24");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[51]), first, "aes_rcon_top.sv", 25, 8, ".tb.top_module1", "v_line/aes_rcon", "case", "25");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[52]), first, "aes_rcon_top.sv", 26, 8, ".tb.top_module1", "v_line/aes_rcon", "case", "26");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[53]), first, "aes_rcon_top.sv", 27, 8, ".tb.top_module1", "v_line/aes_rcon", "case", "27");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[54]), first, "aes_rcon_top.sv", 28, 8, ".tb.top_module1", "v_line/aes_rcon", "case", "28");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[55]), first, "aes_rcon_top.sv", 29, 8, ".tb.top_module1", "v_line/aes_rcon", "case", "29");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[56]), first, "aes_rcon_top.sv", 30, 8, ".tb.top_module1", "v_line/aes_rcon", "case", "30");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[57]), first, "aes_rcon_top.sv", 31, 8, ".tb.top_module1", "v_line/aes_rcon", "case", "31");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[58]), first, "aes_rcon_top.sv", 32, 8, ".tb.top_module1", "v_line/aes_rcon", "case", "32");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[59]), first, "aes_rcon_top.sv", 33, 4, ".tb.top_module1", "v_line/aes_rcon", "case", "33");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[60]), first, "aes_rcon_top.sv", 20, 17, ".tb.top_module1", "v_line/aes_rcon", "block", "20,22");
}
