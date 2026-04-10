// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_sd_bd.h for the primary calling header

#include "Vtb_sd_bd__pch.h"
#include "Vtb_sd_bd__Syms.h"
#include "Vtb_sd_bd___024root.h"

VL_ATTR_COLD void Vtb_sd_bd___024root___eval_static__TOP(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_static__TOP\n"); );
    // Body
    vlSelf->tb_sd_bd__DOT__clk = 0U;
    ++(vlSymsp->__Vcoverage[0]);
}

VL_ATTR_COLD void Vtb_sd_bd___024root___eval_initial__TOP(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_initial__TOP\n"); );
    // Body
    vlSymsp->_vm_contextp__->dumpfile(std::string{"wave.vcd"});
    vlSymsp->_traceDumpOpen();
    ++(vlSymsp->__Vcoverage[3]);
}

VL_ATTR_COLD void Vtb_sd_bd___024root___eval_final__TOP(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_final__TOP\n"); );
    // Body
    if ((0U != vlSelf->tb_sd_bd__DOT__stats1[6U])) {
        VL_WRITEF_NX("Hint: Output 'free_bd' has %0d mismatches. First mismatch occurred at time %0d.\n",0,
                     32,vlSelf->tb_sd_bd__DOT__stats1[6U],
                     32,vlSelf->tb_sd_bd__DOT__stats1[5U]);
        ++(vlSymsp->__Vcoverage[4]);
    } else {
        VL_WRITEF_NX("Hint: Output 'free_bd' has no mismatches.\n",0);
        ++(vlSymsp->__Vcoverage[5]);
    }
    if ((0U != vlSelf->tb_sd_bd__DOT__stats1[4U])) {
        VL_WRITEF_NX("Hint: Output 'ack_o_s' has %0d mismatches. First mismatch occurred at time %0d.\n",0,
                     32,vlSelf->tb_sd_bd__DOT__stats1[4U],
                     32,vlSelf->tb_sd_bd__DOT__stats1[3U]);
        ++(vlSymsp->__Vcoverage[6]);
    } else {
        VL_WRITEF_NX("Hint: Output 'ack_o_s' has no mismatches.\n",0);
        ++(vlSymsp->__Vcoverage[7]);
    }
    if ((0U != vlSelf->tb_sd_bd__DOT__stats1[2U])) {
        VL_WRITEF_NX("Hint: Output 'dat_out_s' has %0d mismatches. First mismatch occurred at time %0d.\n",0,
                     32,vlSelf->tb_sd_bd__DOT__stats1[2U],
                     32,vlSelf->tb_sd_bd__DOT__stats1[1U]);
        ++(vlSymsp->__Vcoverage[8]);
    } else {
        VL_WRITEF_NX("Hint: Output 'dat_out_s' has no mismatches.\n",0);
        ++(vlSymsp->__Vcoverage[9]);
    }
    VL_WRITEF_NX("Hint: Total mismatched samples is %1d out of %1d samples\n\nSimulation finished at %0# ps\n",0,
                 32,vlSelf->tb_sd_bd__DOT__stats1[8U],
                 32,vlSelf->tb_sd_bd__DOT__stats1[0U],
                 64,VL_TIME_UNITED_Q(1));
    ++(vlSymsp->__Vcoverage[10]);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_sd_bd___024root___dump_triggers__stl(Vtb_sd_bd___024root* vlSelf);
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_sd_bd___024root___eval_triggers__stl(Vtb_sd_bd___024root* vlSelf) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___eval_triggers__stl\n"); );
    // Body
    vlSelf->__VstlTriggered.set(0U, (IData)(vlSelf->__VstlFirstIteration));
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_sd_bd___024root___dump_triggers__stl(vlSelf);
    }
#endif
}

VL_ATTR_COLD void Vtb_sd_bd___024root___configure_coverage(Vtb_sd_bd___024root* vlSelf, bool first) {
    (void)vlSelf;  // Prevent unused variable warning
    Vtb_sd_bd__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_sd_bd___024root___configure_coverage\n"); );
    // Body
    (void)first;  // Prevent unused variable warning
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[0]), first, "sd_bd_testbench.sv", 20, 15, ".tb_sd_bd", "v_line/tb_sd_bd", "block", "20");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[1]), first, "sd_bd_testbench.sv", 21, 13, ".tb_sd_bd", "v_line/tb_sd_bd", "block", "21");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[2]), first, "sd_bd_testbench.sv", 21, 5, ".tb_sd_bd", "v_line/tb_sd_bd", "block", "21");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[3]), first, "sd_bd_testbench.sv", 82, 5, ".tb_sd_bd", "v_line/tb_sd_bd", "block", "82-84");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[4]), first, "sd_bd_testbench.sv", 89, 9, ".tb_sd_bd", "v_branch/tb_sd_bd", "if", "89-91");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[5]), first, "sd_bd_testbench.sv", 89, 10, ".tb_sd_bd", "v_branch/tb_sd_bd", "else", "93");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[6]), first, "sd_bd_testbench.sv", 95, 9, ".tb_sd_bd", "v_branch/tb_sd_bd", "if", "95-97");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[7]), first, "sd_bd_testbench.sv", 95, 10, ".tb_sd_bd", "v_branch/tb_sd_bd", "else", "99");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[8]), first, "sd_bd_testbench.sv", 101, 9, ".tb_sd_bd", "v_branch/tb_sd_bd", "if", "101-103");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[9]), first, "sd_bd_testbench.sv", 101, 10, ".tb_sd_bd", "v_branch/tb_sd_bd", "else", "105");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[10]), first, "sd_bd_testbench.sv", 88, 5, ".tb_sd_bd", "v_line/tb_sd_bd", "block", "88,107-109");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[11]), first, "sd_bd_testbench.sv", 123, 13, ".tb_sd_bd", "v_branch/tb_sd_bd", "if", "123");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[12]), first, "sd_bd_testbench.sv", 123, 14, ".tb_sd_bd", "v_branch/tb_sd_bd", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[13]), first, "sd_bd_testbench.sv", 122, 9, ".tb_sd_bd", "v_branch/tb_sd_bd", "if", "122,124");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[14]), first, "sd_bd_testbench.sv", 122, 10, ".tb_sd_bd", "v_branch/tb_sd_bd", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[15]), first, "sd_bd_testbench.sv", 128, 13, ".tb_sd_bd", "v_branch/tb_sd_bd", "if", "128");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[16]), first, "sd_bd_testbench.sv", 128, 14, ".tb_sd_bd", "v_branch/tb_sd_bd", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[17]), first, "sd_bd_testbench.sv", 127, 9, ".tb_sd_bd", "v_branch/tb_sd_bd", "if", "127,129");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[18]), first, "sd_bd_testbench.sv", 127, 10, ".tb_sd_bd", "v_branch/tb_sd_bd", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[19]), first, "sd_bd_testbench.sv", 133, 13, ".tb_sd_bd", "v_branch/tb_sd_bd", "if", "133");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[20]), first, "sd_bd_testbench.sv", 133, 14, ".tb_sd_bd", "v_branch/tb_sd_bd", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[21]), first, "sd_bd_testbench.sv", 132, 9, ".tb_sd_bd", "v_branch/tb_sd_bd", "if", "132,134");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[22]), first, "sd_bd_testbench.sv", 132, 10, ".tb_sd_bd", "v_branch/tb_sd_bd", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[23]), first, "sd_bd_testbench.sv", 138, 13, ".tb_sd_bd", "v_branch/tb_sd_bd", "if", "138");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[24]), first, "sd_bd_testbench.sv", 138, 14, ".tb_sd_bd", "v_branch/tb_sd_bd", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[25]), first, "sd_bd_testbench.sv", 137, 9, ".tb_sd_bd", "v_branch/tb_sd_bd", "if", "137,139");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[26]), first, "sd_bd_testbench.sv", 137, 10, ".tb_sd_bd", "v_branch/tb_sd_bd", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[27]), first, "sd_bd_testbench.sv", 119, 5, ".tb_sd_bd", "v_line/tb_sd_bd", "block", "119-120");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[28]), first, "sd_bd_testbench.sv", 144, 5, ".tb_sd_bd", "v_line/tb_sd_bd", "block", "144-147");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[29]), first, "sd_bd_stimulus_gen.sv", 14, 10, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "14-16");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[30]), first, "sd_bd_stimulus_gen.sv", 19, 10, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "19-20");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[31]), first, "sd_bd_stimulus_gen.sv", 29, 9, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "29");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[32]), first, "sd_bd_stimulus_gen.sv", 39, 14, ".tb_sd_bd.stim1", "v_branch/stimulus_gen", "if", "39-41");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[33]), first, "sd_bd_stimulus_gen.sv", 39, 15, ".tb_sd_bd.stim1", "v_branch/stimulus_gen", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[34]), first, "sd_bd_stimulus_gen.sv", 37, 9, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "elsif", "37-38");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[35]), first, "sd_bd_stimulus_gen.sv", 24, 10, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "24,27-29,31-35");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[36]), first, "sd_bd_stimulus_gen.sv", 50, 9, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "50");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[37]), first, "sd_bd_stimulus_gen.sv", 73, 17, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "73");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[38]), first, "sd_bd_stimulus_gen.sv", 70, 13, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "70-75");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[39]), first, "sd_bd_stimulus_gen.sv", 81, 17, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "81");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[40]), first, "sd_bd_stimulus_gen.sv", 79, 13, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "79-83");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[41]), first, "sd_bd_stimulus_gen.sv", 91, 17, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "91");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[42]), first, "sd_bd_stimulus_gen.sv", 87, 13, ".tb_sd_bd.stim1", "v_branch/stimulus_gen", "if", "87-91");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[43]), first, "sd_bd_stimulus_gen.sv", 87, 14, ".tb_sd_bd.stim1", "v_branch/stimulus_gen", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[44]), first, "sd_bd_stimulus_gen.sv", 68, 9, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "68,70,79");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[45]), first, "sd_bd_stimulus_gen.sv", 100, 13, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "100-105");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[46]), first, "sd_bd_stimulus_gen.sv", 109, 13, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "109-113");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[47]), first, "sd_bd_stimulus_gen.sv", 117, 13, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "117-121");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[48]), first, "sd_bd_stimulus_gen.sv", 98, 9, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "98,100,109,117,125");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[49]), first, "sd_bd_stimulus_gen.sv", 132, 13, ".tb_sd_bd.stim1", "v_branch/stimulus_gen", "if", "132");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[50]), first, "sd_bd_stimulus_gen.sv", 132, 14, ".tb_sd_bd.stim1", "v_branch/stimulus_gen", "else", "133");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[51]), first, "sd_bd_stimulus_gen.sv", 135, 13, ".tb_sd_bd.stim1", "v_branch/stimulus_gen", "if", "135");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[52]), first, "sd_bd_stimulus_gen.sv", 135, 14, ".tb_sd_bd.stim1", "v_branch/stimulus_gen", "else", "136");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[53]), first, "sd_bd_stimulus_gen.sv", 138, 13, ".tb_sd_bd.stim1", "v_branch/stimulus_gen", "if", "138");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[54]), first, "sd_bd_stimulus_gen.sv", 138, 14, ".tb_sd_bd.stim1", "v_branch/stimulus_gen", "else", "139");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[55]), first, "sd_bd_stimulus_gen.sv", 144, 13, ".tb_sd_bd.stim1", "v_branch/stimulus_gen", "if", "144-145");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[56]), first, "sd_bd_stimulus_gen.sv", 144, 14, ".tb_sd_bd.stim1", "v_branch/stimulus_gen", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[57]), first, "sd_bd_stimulus_gen.sv", 149, 13, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "149");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[58]), first, "sd_bd_stimulus_gen.sv", 130, 9, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "130,141,149");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[59]), first, "sd_bd_stimulus_gen.sv", 154, 9, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "154-165");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[60]), first, "sd_bd_stimulus_gen.sv", 170, 9, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "170");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[61]), first, "sd_bd_stimulus_gen.sv", 44, 5, ".tb_sd_bd.stim1", "v_line/stimulus_gen", "block", "44,46-47,50-52,55-64,67-68,94,97-98,127,130,153-154,167,170-171,173");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[62]), first, "sd_bd_ref.sv", 136, 7, ".tb_sd_bd.good1", "v_branch/ref_sd_bd", "if", "136-137");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[63]), first, "sd_bd_ref.sv", 136, 8, ".tb_sd_bd.good1", "v_branch/ref_sd_bd", "else", "139-141");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[64]), first, "sd_bd_ref.sv", 133, 5, ".tb_sd_bd.good1", "v_branch/ref_sd_bd", "if", "133-135");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[65]), first, "sd_bd_ref.sv", 133, 6, ".tb_sd_bd.good1", "v_branch/ref_sd_bd", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[66]), first, "sd_bd_ref.sv", 132, 8, ".tb_sd_bd.good1", "v_branch/ref_sd_bd", "if", "132");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[67]), first, "sd_bd_ref.sv", 132, 9, ".tb_sd_bd.good1", "v_branch/ref_sd_bd", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[68]), first, "sd_bd_ref.sv", 124, 3, ".tb_sd_bd.good1", "v_line/ref_sd_bd", "elsif", "124-125,127-129");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[69]), first, "sd_bd_ref.sv", 120, 1, ".tb_sd_bd.good1", "v_line/ref_sd_bd", "block", "120-122");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[70]), first, "sd_bd_ref.sv", 161, 5, ".tb_sd_bd.good1", "v_branch/ref_sd_bd", "if", "161-162");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[71]), first, "sd_bd_ref.sv", 161, 6, ".tb_sd_bd.good1", "v_branch/ref_sd_bd", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[72]), first, "sd_bd_ref.sv", 159, 8, ".tb_sd_bd.good1", "v_line/ref_sd_bd", "if", "159-160");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[73]), first, "sd_bd_ref.sv", 159, 9, ".tb_sd_bd.good1", "v_line/ref_sd_bd", "else", "166");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[74]), first, "sd_bd_ref.sv", 156, 8, ".tb_sd_bd.good1", "v_line/ref_sd_bd", "elsif", "156-157");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[75]), first, "sd_bd_ref.sv", 152, 3, ".tb_sd_bd.good1", "v_line/ref_sd_bd", "elsif", "152-154");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[76]), first, "sd_bd_ref.sv", 150, 1, ".tb_sd_bd.good1", "v_line/ref_sd_bd", "block", "150-151");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[77]), first, "sd_bd_ref.sv", 183, 6, ".tb_sd_bd.good1", "v_branch/ref_sd_bd", "if", "183-184");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[78]), first, "sd_bd_ref.sv", 183, 7, ".tb_sd_bd.good1", "v_branch/ref_sd_bd", "else", "187");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[79]), first, "sd_bd_ref.sv", 179, 8, ".tb_sd_bd.good1", "v_line/ref_sd_bd", "if", "179-182");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[80]), first, "sd_bd_ref.sv", 179, 9, ".tb_sd_bd.good1", "v_line/ref_sd_bd", "else", "191");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[81]), first, "sd_bd_ref.sv", 174, 3, ".tb_sd_bd.good1", "v_line/ref_sd_bd", "elsif", "174-177");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[82]), first, "sd_bd_ref.sv", 171, 1, ".tb_sd_bd.good1", "v_line/ref_sd_bd", "block", "171-172");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[83]), first, "sd_bd_top.sv", 143, 7, ".tb_sd_bd.top_module1", "v_branch/sd_bd", "if", "143-144");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[84]), first, "sd_bd_top.sv", 143, 8, ".tb_sd_bd.top_module1", "v_branch/sd_bd", "else", "146-148");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[85]), first, "sd_bd_top.sv", 140, 5, ".tb_sd_bd.top_module1", "v_branch/sd_bd", "if", "140-142");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[86]), first, "sd_bd_top.sv", 140, 6, ".tb_sd_bd.top_module1", "v_branch/sd_bd", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[87]), first, "sd_bd_top.sv", 139, 8, ".tb_sd_bd.top_module1", "v_branch/sd_bd", "if", "139");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[88]), first, "sd_bd_top.sv", 139, 9, ".tb_sd_bd.top_module1", "v_branch/sd_bd", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[89]), first, "sd_bd_top.sv", 131, 3, ".tb_sd_bd.top_module1", "v_line/sd_bd", "elsif", "131-132,134-136");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[90]), first, "sd_bd_top.sv", 127, 1, ".tb_sd_bd.top_module1", "v_line/sd_bd", "block", "127-129");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[91]), first, "sd_bd_top.sv", 168, 5, ".tb_sd_bd.top_module1", "v_branch/sd_bd", "if", "168-169");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[92]), first, "sd_bd_top.sv", 168, 6, ".tb_sd_bd.top_module1", "v_branch/sd_bd", "else", "");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[93]), first, "sd_bd_top.sv", 166, 8, ".tb_sd_bd.top_module1", "v_line/sd_bd", "if", "166-167");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[94]), first, "sd_bd_top.sv", 166, 9, ".tb_sd_bd.top_module1", "v_line/sd_bd", "else", "173");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[95]), first, "sd_bd_top.sv", 163, 8, ".tb_sd_bd.top_module1", "v_line/sd_bd", "elsif", "163-164");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[96]), first, "sd_bd_top.sv", 159, 3, ".tb_sd_bd.top_module1", "v_line/sd_bd", "elsif", "159-161");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[97]), first, "sd_bd_top.sv", 157, 1, ".tb_sd_bd.top_module1", "v_line/sd_bd", "block", "157-158");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[98]), first, "sd_bd_top.sv", 190, 6, ".tb_sd_bd.top_module1", "v_branch/sd_bd", "if", "190-191");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[99]), first, "sd_bd_top.sv", 190, 7, ".tb_sd_bd.top_module1", "v_branch/sd_bd", "else", "194");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[100]), first, "sd_bd_top.sv", 186, 8, ".tb_sd_bd.top_module1", "v_line/sd_bd", "if", "186-189");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[101]), first, "sd_bd_top.sv", 186, 9, ".tb_sd_bd.top_module1", "v_line/sd_bd", "else", "198");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[102]), first, "sd_bd_top.sv", 181, 3, ".tb_sd_bd.top_module1", "v_line/sd_bd", "elsif", "181-184");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[103]), first, "sd_bd_top.sv", 178, 1, ".tb_sd_bd.top_module1", "v_line/sd_bd", "block", "178-179");
    vlSelf->__vlCoverInsert(&(vlSymsp->__Vcoverage[104]), first, "sd_bd_top.sv", 204, 1, ".tb_sd_bd.top_module1", "v_line/sd_bd", "block", "204-205");
}
