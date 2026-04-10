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
    // Init
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    // Body
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[0U])) {
        bufp->chgWData(oldp+0,(vlSelf->tb__DOT__stim1__DOT__TEST_KEYS[0]),128);
        bufp->chgWData(oldp+4,(vlSelf->tb__DOT__stim1__DOT__TEST_KEYS[1]),128);
        bufp->chgWData(oldp+8,(vlSelf->tb__DOT__stim1__DOT__TEST_KEYS[2]),128);
        bufp->chgWData(oldp+12,(vlSelf->tb__DOT__stim1__DOT__TEST_KEYS[3]),128);
        bufp->chgWData(oldp+16,(vlSelf->tb__DOT__stim1__DOT__TEST_CIPHER[0]),128);
        bufp->chgWData(oldp+20,(vlSelf->tb__DOT__stim1__DOT__TEST_CIPHER[1]),128);
        bufp->chgWData(oldp+24,(vlSelf->tb__DOT__stim1__DOT__TEST_CIPHER[2]),128);
        bufp->chgWData(oldp+28,(vlSelf->tb__DOT__stim1__DOT__TEST_CIPHER[3]),128);
    }
    if (VL_UNLIKELY((vlSelf->__Vm_traceActivity[1U] 
                     | vlSelf->__Vm_traceActivity[2U]))) {
        bufp->chgBit(oldp+32,(vlSelf->tb__DOT__rst));
        bufp->chgBit(oldp+33,(vlSelf->tb__DOT__kld));
        bufp->chgBit(oldp+34,(vlSelf->tb__DOT__ld));
        bufp->chgWData(oldp+35,(vlSelf->tb__DOT__key),128);
        bufp->chgWData(oldp+39,(vlSelf->tb__DOT__text_in),128);
        bufp->chgBit(oldp+43,(vlSelf->tb__DOT__wavedrom_enable));
        bufp->chgBit(oldp+44,(vlSelf->tb__DOT__stim1__DOT__reset_test__Vstatic__arfail));
        bufp->chgBit(oldp+45,(vlSelf->tb__DOT__stim1__DOT__reset_test__Vstatic__srfail));
        bufp->chgBit(oldp+46,(vlSelf->tb__DOT__stim1__DOT__reset_test__Vstatic__datafail));
    }
    if (VL_UNLIKELY(vlSelf->__Vm_traceActivity[3U])) {
        bufp->chgWData(oldp+47,(vlSelf->tb__DOT__stats1),224);
        bufp->chgBit(oldp+54,(vlSelf->tb__DOT__done_ref));
        bufp->chgBit(oldp+55,(vlSelf->tb__DOT__done_dut));
        bufp->chgWData(oldp+56,(vlSelf->tb__DOT__text_out_ref),128);
        bufp->chgWData(oldp+60,(vlSelf->tb__DOT__text_out_dut),128);
        bufp->chgBit(oldp+64,(vlSelf->tb__DOT__tb_match_text));
        bufp->chgBit(oldp+65,(vlSelf->tb__DOT__tb_match_done));
        bufp->chgBit(oldp+66,(((IData)(vlSelf->tb__DOT__tb_match_text) 
                               & (IData)(vlSelf->tb__DOT__tb_match_done))));
        bufp->chgIData(oldp+67,(vlSelf->tb__DOT__good1__DOT__u0__DOT__w
                                [0U]),32);
        bufp->chgIData(oldp+68,(vlSelf->tb__DOT__good1__DOT__u0__DOT__w
                                [1U]),32);
        bufp->chgIData(oldp+69,(vlSelf->tb__DOT__good1__DOT__u0__DOT__w
                                [2U]),32);
        bufp->chgIData(oldp+70,(vlSelf->tb__DOT__good1__DOT__u0__DOT__w
                                [3U]),32);
        bufp->chgIData(oldp+71,(vlSelf->tb__DOT__good1__DOT__w0),32);
        bufp->chgIData(oldp+72,(vlSelf->tb__DOT__good1__DOT__w1),32);
        bufp->chgIData(oldp+73,(vlSelf->tb__DOT__good1__DOT__w2),32);
        bufp->chgIData(oldp+74,(vlSelf->tb__DOT__good1__DOT__w3),32);
        bufp->chgWData(oldp+75,(vlSelf->tb__DOT__good1__DOT__text_in_r),128);
        bufp->chgCData(oldp+79,(vlSelf->tb__DOT__good1__DOT__sa00),8);
        bufp->chgCData(oldp+80,(vlSelf->tb__DOT__good1__DOT__sa01),8);
        bufp->chgCData(oldp+81,(vlSelf->tb__DOT__good1__DOT__sa02),8);
        bufp->chgCData(oldp+82,(vlSelf->tb__DOT__good1__DOT__sa03),8);
        bufp->chgCData(oldp+83,(vlSelf->tb__DOT__good1__DOT__sa10),8);
        bufp->chgCData(oldp+84,(vlSelf->tb__DOT__good1__DOT__sa11),8);
        bufp->chgCData(oldp+85,(vlSelf->tb__DOT__good1__DOT__sa12),8);
        bufp->chgCData(oldp+86,(vlSelf->tb__DOT__good1__DOT__sa13),8);
        bufp->chgCData(oldp+87,(vlSelf->tb__DOT__good1__DOT__sa20),8);
        bufp->chgCData(oldp+88,(vlSelf->tb__DOT__good1__DOT__sa21),8);
        bufp->chgCData(oldp+89,(vlSelf->tb__DOT__good1__DOT__sa22),8);
        bufp->chgCData(oldp+90,(vlSelf->tb__DOT__good1__DOT__sa23),8);
        bufp->chgCData(oldp+91,(vlSelf->tb__DOT__good1__DOT__sa30),8);
        bufp->chgCData(oldp+92,(vlSelf->tb__DOT__good1__DOT__sa31),8);
        bufp->chgCData(oldp+93,(vlSelf->tb__DOT__good1__DOT__sa32),8);
        bufp->chgCData(oldp+94,(vlSelf->tb__DOT__good1__DOT__sa33),8);
        bufp->chgCData(oldp+95,((vlSelf->tb__DOT__good1__DOT__temp_result 
                                 >> 0x18U)),8);
        bufp->chgCData(oldp+96,((vlSelf->tb__DOT__good1__DOT__temp_result1 
                                 >> 0x18U)),8);
        bufp->chgCData(oldp+97,((vlSelf->tb__DOT__good1__DOT__temp_result2 
                                 >> 0x18U)),8);
        bufp->chgCData(oldp+98,((vlSelf->tb__DOT__good1__DOT__temp_result3 
                                 >> 0x18U)),8);
        bufp->chgCData(oldp+99,((0xffU & (vlSelf->tb__DOT__good1__DOT__temp_result 
                                          >> 0x10U))),8);
        bufp->chgCData(oldp+100,((0xffU & (vlSelf->tb__DOT__good1__DOT__temp_result1 
                                           >> 0x10U))),8);
        bufp->chgCData(oldp+101,((0xffU & (vlSelf->tb__DOT__good1__DOT__temp_result2 
                                           >> 0x10U))),8);
        bufp->chgCData(oldp+102,((0xffU & (vlSelf->tb__DOT__good1__DOT__temp_result3 
                                           >> 0x10U))),8);
        bufp->chgCData(oldp+103,((0xffU & (vlSelf->tb__DOT__good1__DOT__temp_result 
                                           >> 8U))),8);
        bufp->chgCData(oldp+104,((0xffU & (vlSelf->tb__DOT__good1__DOT__temp_result1 
                                           >> 8U))),8);
        bufp->chgCData(oldp+105,((0xffU & (vlSelf->tb__DOT__good1__DOT__temp_result2 
                                           >> 8U))),8);
        bufp->chgCData(oldp+106,((0xffU & (vlSelf->tb__DOT__good1__DOT__temp_result3 
                                           >> 8U))),8);
        bufp->chgCData(oldp+107,((0xffU & vlSelf->tb__DOT__good1__DOT__temp_result)),8);
        bufp->chgCData(oldp+108,((0xffU & vlSelf->tb__DOT__good1__DOT__temp_result1)),8);
        bufp->chgCData(oldp+109,((0xffU & vlSelf->tb__DOT__good1__DOT__temp_result2)),8);
        bufp->chgCData(oldp+110,((0xffU & vlSelf->tb__DOT__good1__DOT__temp_result3)),8);
        bufp->chgCData(oldp+111,(vlSymsp->TOP__tb__DOT__good1__DOT__us00.b),8);
        bufp->chgCData(oldp+112,(vlSymsp->TOP__tb__DOT__good1__DOT__us01.b),8);
        bufp->chgCData(oldp+113,(vlSymsp->TOP__tb__DOT__good1__DOT__us02.b),8);
        bufp->chgCData(oldp+114,(vlSymsp->TOP__tb__DOT__good1__DOT__us03.b),8);
        bufp->chgCData(oldp+115,(vlSymsp->TOP__tb__DOT__good1__DOT__us10.b),8);
        bufp->chgCData(oldp+116,(vlSymsp->TOP__tb__DOT__good1__DOT__us11.b),8);
        bufp->chgCData(oldp+117,(vlSymsp->TOP__tb__DOT__good1__DOT__us12.b),8);
        bufp->chgCData(oldp+118,(vlSymsp->TOP__tb__DOT__good1__DOT__us13.b),8);
        bufp->chgCData(oldp+119,(vlSymsp->TOP__tb__DOT__good1__DOT__us20.b),8);
        bufp->chgCData(oldp+120,(vlSymsp->TOP__tb__DOT__good1__DOT__us21.b),8);
        bufp->chgCData(oldp+121,(vlSymsp->TOP__tb__DOT__good1__DOT__us22.b),8);
        bufp->chgCData(oldp+122,(vlSymsp->TOP__tb__DOT__good1__DOT__us23.b),8);
        bufp->chgCData(oldp+123,(vlSymsp->TOP__tb__DOT__good1__DOT__us30.b),8);
        bufp->chgCData(oldp+124,(vlSymsp->TOP__tb__DOT__good1__DOT__us31.b),8);
        bufp->chgCData(oldp+125,(vlSymsp->TOP__tb__DOT__good1__DOT__us32.b),8);
        bufp->chgCData(oldp+126,(vlSymsp->TOP__tb__DOT__good1__DOT__us33.b),8);
        bufp->chgCData(oldp+127,(vlSelf->tb__DOT__good1__DOT__sa00_ark),8);
        bufp->chgCData(oldp+128,(vlSelf->tb__DOT__good1__DOT__sa01_ark),8);
        bufp->chgCData(oldp+129,(vlSelf->tb__DOT__good1__DOT__sa02_ark),8);
        bufp->chgCData(oldp+130,(vlSelf->tb__DOT__good1__DOT__sa03_ark),8);
        bufp->chgCData(oldp+131,(vlSelf->tb__DOT__good1__DOT__sa10_ark),8);
        bufp->chgCData(oldp+132,(vlSelf->tb__DOT__good1__DOT__sa11_ark),8);
        bufp->chgCData(oldp+133,(vlSelf->tb__DOT__good1__DOT__sa12_ark),8);
        bufp->chgCData(oldp+134,(vlSelf->tb__DOT__good1__DOT__sa13_ark),8);
        bufp->chgCData(oldp+135,(vlSelf->tb__DOT__good1__DOT__sa20_ark),8);
        bufp->chgCData(oldp+136,(vlSelf->tb__DOT__good1__DOT__sa21_ark),8);
        bufp->chgCData(oldp+137,(vlSelf->tb__DOT__good1__DOT__sa22_ark),8);
        bufp->chgCData(oldp+138,(vlSelf->tb__DOT__good1__DOT__sa23_ark),8);
        bufp->chgCData(oldp+139,(vlSelf->tb__DOT__good1__DOT__sa30_ark),8);
        bufp->chgCData(oldp+140,(vlSelf->tb__DOT__good1__DOT__sa31_ark),8);
        bufp->chgCData(oldp+141,(vlSelf->tb__DOT__good1__DOT__sa32_ark),8);
        bufp->chgCData(oldp+142,(vlSelf->tb__DOT__good1__DOT__sa33_ark),8);
        bufp->chgBit(oldp+143,(vlSelf->tb__DOT__good1__DOT__ld_r));
        bufp->chgBit(oldp+144,(vlSelf->tb__DOT__good1__DOT__go));
        bufp->chgCData(oldp+145,(vlSelf->tb__DOT__good1__DOT__dcnt),4);
        bufp->chgIData(oldp+146,(vlSelf->tb__DOT__good1__DOT__temp_result),32);
        bufp->chgIData(oldp+147,(vlSelf->tb__DOT__good1__DOT__temp_result1),32);
        bufp->chgIData(oldp+148,(vlSelf->tb__DOT__good1__DOT__temp_result2),32);
        bufp->chgIData(oldp+149,(vlSelf->tb__DOT__good1__DOT__temp_result3),32);
        bufp->chgCData(oldp+150,(vlSelf->tb__DOT__good1__DOT__pmul_e__Vstatic__two),8);
        bufp->chgCData(oldp+151,(vlSelf->tb__DOT__good1__DOT__pmul_e__Vstatic__four),8);
        bufp->chgCData(oldp+152,(vlSelf->tb__DOT__good1__DOT__pmul_e__Vstatic__eight),8);
        bufp->chgCData(oldp+153,(vlSelf->tb__DOT__good1__DOT__pmul_9__Vstatic__two),8);
        bufp->chgCData(oldp+154,(vlSelf->tb__DOT__good1__DOT__pmul_9__Vstatic__four),8);
        bufp->chgCData(oldp+155,(vlSelf->tb__DOT__good1__DOT__pmul_9__Vstatic__eight),8);
        bufp->chgCData(oldp+156,(vlSelf->tb__DOT__good1__DOT__pmul_d__Vstatic__two),8);
        bufp->chgCData(oldp+157,(vlSelf->tb__DOT__good1__DOT__pmul_d__Vstatic__four),8);
        bufp->chgCData(oldp+158,(vlSelf->tb__DOT__good1__DOT__pmul_d__Vstatic__eight),8);
        bufp->chgCData(oldp+159,(vlSelf->tb__DOT__good1__DOT__pmul_b__Vstatic__two),8);
        bufp->chgCData(oldp+160,(vlSelf->tb__DOT__good1__DOT__pmul_b__Vstatic__four),8);
        bufp->chgCData(oldp+161,(vlSelf->tb__DOT__good1__DOT__pmul_b__Vstatic__eight),8);
        bufp->chgWData(oldp+162,(vlSelf->tb__DOT__good1__DOT__kb[0]),128);
        bufp->chgWData(oldp+166,(vlSelf->tb__DOT__good1__DOT__kb[1]),128);
        bufp->chgWData(oldp+170,(vlSelf->tb__DOT__good1__DOT__kb[2]),128);
        bufp->chgWData(oldp+174,(vlSelf->tb__DOT__good1__DOT__kb[3]),128);
        bufp->chgWData(oldp+178,(vlSelf->tb__DOT__good1__DOT__kb[4]),128);
        bufp->chgWData(oldp+182,(vlSelf->tb__DOT__good1__DOT__kb[5]),128);
        bufp->chgWData(oldp+186,(vlSelf->tb__DOT__good1__DOT__kb[6]),128);
        bufp->chgWData(oldp+190,(vlSelf->tb__DOT__good1__DOT__kb[7]),128);
        bufp->chgWData(oldp+194,(vlSelf->tb__DOT__good1__DOT__kb[8]),128);
        bufp->chgWData(oldp+198,(vlSelf->tb__DOT__good1__DOT__kb[9]),128);
        bufp->chgWData(oldp+202,(vlSelf->tb__DOT__good1__DOT__kb[10]),128);
        bufp->chgCData(oldp+206,(vlSelf->tb__DOT__good1__DOT__kcnt),4);
        bufp->chgBit(oldp+207,(vlSelf->tb__DOT__good1__DOT__kdone));
        bufp->chgBit(oldp+208,(vlSelf->tb__DOT__good1__DOT__kb_ld));
        bufp->chgIData(oldp+209,(vlSelf->tb__DOT__good1__DOT__u0__DOT__w[0]),32);
        bufp->chgIData(oldp+210,(vlSelf->tb__DOT__good1__DOT__u0__DOT__w[1]),32);
        bufp->chgIData(oldp+211,(vlSelf->tb__DOT__good1__DOT__u0__DOT__w[2]),32);
        bufp->chgIData(oldp+212,(vlSelf->tb__DOT__good1__DOT__u0__DOT__w[3]),32);
        bufp->chgIData(oldp+213,(vlSelf->tb__DOT__good1__DOT__u0__DOT__subword),32);
        bufp->chgIData(oldp+214,(vlSelf->tb__DOT__good1__DOT__u0__DOT__rcon),32);
        bufp->chgCData(oldp+215,(vlSelf->tb__DOT__good1__DOT__u0__DOT__r0__DOT__rcnt),4);
        bufp->chgCData(oldp+216,((0xfU & ((IData)(1U) 
                                          + (IData)(vlSelf->tb__DOT__good1__DOT__u0__DOT__r0__DOT__rcnt)))),4);
        bufp->chgIData(oldp+217,(vlSelf->tb__DOT__top_module1__DOT__u0__DOT__w
                                 [0U]),32);
        bufp->chgIData(oldp+218,(vlSelf->tb__DOT__top_module1__DOT__u0__DOT__w
                                 [1U]),32);
        bufp->chgIData(oldp+219,(vlSelf->tb__DOT__top_module1__DOT__u0__DOT__w
                                 [2U]),32);
        bufp->chgIData(oldp+220,(vlSelf->tb__DOT__top_module1__DOT__u0__DOT__w
                                 [3U]),32);
        bufp->chgIData(oldp+221,(vlSelf->tb__DOT__top_module1__DOT__w0),32);
        bufp->chgIData(oldp+222,(vlSelf->tb__DOT__top_module1__DOT__w1),32);
        bufp->chgIData(oldp+223,(vlSelf->tb__DOT__top_module1__DOT__w2),32);
        bufp->chgIData(oldp+224,(vlSelf->tb__DOT__top_module1__DOT__w3),32);
        bufp->chgWData(oldp+225,(vlSelf->tb__DOT__top_module1__DOT__text_in_r),128);
        bufp->chgCData(oldp+229,(vlSelf->tb__DOT__top_module1__DOT__sa00),8);
        bufp->chgCData(oldp+230,(vlSelf->tb__DOT__top_module1__DOT__sa01),8);
        bufp->chgCData(oldp+231,(vlSelf->tb__DOT__top_module1__DOT__sa02),8);
        bufp->chgCData(oldp+232,(vlSelf->tb__DOT__top_module1__DOT__sa03),8);
        bufp->chgCData(oldp+233,(vlSelf->tb__DOT__top_module1__DOT__sa10),8);
        bufp->chgCData(oldp+234,(vlSelf->tb__DOT__top_module1__DOT__sa11),8);
        bufp->chgCData(oldp+235,(vlSelf->tb__DOT__top_module1__DOT__sa12),8);
        bufp->chgCData(oldp+236,(vlSelf->tb__DOT__top_module1__DOT__sa13),8);
        bufp->chgCData(oldp+237,(vlSelf->tb__DOT__top_module1__DOT__sa20),8);
        bufp->chgCData(oldp+238,(vlSelf->tb__DOT__top_module1__DOT__sa21),8);
        bufp->chgCData(oldp+239,(vlSelf->tb__DOT__top_module1__DOT__sa22),8);
        bufp->chgCData(oldp+240,(vlSelf->tb__DOT__top_module1__DOT__sa23),8);
        bufp->chgCData(oldp+241,(vlSelf->tb__DOT__top_module1__DOT__sa30),8);
        bufp->chgCData(oldp+242,(vlSelf->tb__DOT__top_module1__DOT__sa31),8);
        bufp->chgCData(oldp+243,(vlSelf->tb__DOT__top_module1__DOT__sa32),8);
        bufp->chgCData(oldp+244,(vlSelf->tb__DOT__top_module1__DOT__sa33),8);
        bufp->chgCData(oldp+245,((vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out0 
                                  >> 0x18U)),8);
        bufp->chgCData(oldp+246,((vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out1 
                                  >> 0x18U)),8);
        bufp->chgCData(oldp+247,((vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out2 
                                  >> 0x18U)),8);
        bufp->chgCData(oldp+248,((vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out3 
                                  >> 0x18U)),8);
        bufp->chgCData(oldp+249,((0xffU & (vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out0 
                                           >> 0x10U))),8);
        bufp->chgCData(oldp+250,((0xffU & (vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out1 
                                           >> 0x10U))),8);
        bufp->chgCData(oldp+251,((0xffU & (vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out2 
                                           >> 0x10U))),8);
        bufp->chgCData(oldp+252,((0xffU & (vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out3 
                                           >> 0x10U))),8);
        bufp->chgCData(oldp+253,((0xffU & (vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out0 
                                           >> 8U))),8);
        bufp->chgCData(oldp+254,((0xffU & (vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out1 
                                           >> 8U))),8);
        bufp->chgCData(oldp+255,((0xffU & (vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out2 
                                           >> 8U))),8);
        bufp->chgCData(oldp+256,((0xffU & (vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out3 
                                           >> 8U))),8);
        bufp->chgCData(oldp+257,((0xffU & vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out0)),8);
        bufp->chgCData(oldp+258,((0xffU & vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out1)),8);
        bufp->chgCData(oldp+259,((0xffU & vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out2)),8);
        bufp->chgCData(oldp+260,((0xffU & vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out3)),8);
        bufp->chgCData(oldp+261,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us00.b),8);
        bufp->chgCData(oldp+262,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us01.b),8);
        bufp->chgCData(oldp+263,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us02.b),8);
        bufp->chgCData(oldp+264,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us03.b),8);
        bufp->chgCData(oldp+265,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us10.b),8);
        bufp->chgCData(oldp+266,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us11.b),8);
        bufp->chgCData(oldp+267,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us12.b),8);
        bufp->chgCData(oldp+268,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us13.b),8);
        bufp->chgCData(oldp+269,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us20.b),8);
        bufp->chgCData(oldp+270,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us21.b),8);
        bufp->chgCData(oldp+271,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us22.b),8);
        bufp->chgCData(oldp+272,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us23.b),8);
        bufp->chgCData(oldp+273,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us30.b),8);
        bufp->chgCData(oldp+274,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us31.b),8);
        bufp->chgCData(oldp+275,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us32.b),8);
        bufp->chgCData(oldp+276,(vlSymsp->TOP__tb__DOT__top_module1__DOT__us33.b),8);
        bufp->chgCData(oldp+277,(vlSelf->tb__DOT__top_module1__DOT__sa00_ark),8);
        bufp->chgCData(oldp+278,(vlSelf->tb__DOT__top_module1__DOT__sa01_ark),8);
        bufp->chgCData(oldp+279,(vlSelf->tb__DOT__top_module1__DOT__sa02_ark),8);
        bufp->chgCData(oldp+280,(vlSelf->tb__DOT__top_module1__DOT__sa03_ark),8);
        bufp->chgCData(oldp+281,(vlSelf->tb__DOT__top_module1__DOT__sa10_ark),8);
        bufp->chgCData(oldp+282,(vlSelf->tb__DOT__top_module1__DOT__sa11_ark),8);
        bufp->chgCData(oldp+283,(vlSelf->tb__DOT__top_module1__DOT__sa12_ark),8);
        bufp->chgCData(oldp+284,(vlSelf->tb__DOT__top_module1__DOT__sa13_ark),8);
        bufp->chgCData(oldp+285,(vlSelf->tb__DOT__top_module1__DOT__sa20_ark),8);
        bufp->chgCData(oldp+286,(vlSelf->tb__DOT__top_module1__DOT__sa21_ark),8);
        bufp->chgCData(oldp+287,(vlSelf->tb__DOT__top_module1__DOT__sa22_ark),8);
        bufp->chgCData(oldp+288,(vlSelf->tb__DOT__top_module1__DOT__sa23_ark),8);
        bufp->chgCData(oldp+289,(vlSelf->tb__DOT__top_module1__DOT__sa30_ark),8);
        bufp->chgCData(oldp+290,(vlSelf->tb__DOT__top_module1__DOT__sa31_ark),8);
        bufp->chgCData(oldp+291,(vlSelf->tb__DOT__top_module1__DOT__sa32_ark),8);
        bufp->chgCData(oldp+292,(vlSelf->tb__DOT__top_module1__DOT__sa33_ark),8);
        bufp->chgBit(oldp+293,(vlSelf->tb__DOT__top_module1__DOT__ld_r));
        bufp->chgBit(oldp+294,(vlSelf->tb__DOT__top_module1__DOT__go));
        bufp->chgCData(oldp+295,(vlSelf->tb__DOT__top_module1__DOT__dcnt),4);
        bufp->chgIData(oldp+296,(vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out0),32);
        bufp->chgIData(oldp+297,(vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out1),32);
        bufp->chgIData(oldp+298,(vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out2),32);
        bufp->chgIData(oldp+299,(vlSelf->tb__DOT__top_module1__DOT__inv_mix_col_out3),32);
        bufp->chgCData(oldp+300,(vlSelf->tb__DOT__top_module1__DOT__pmul_e__Vstatic__two),8);
        bufp->chgCData(oldp+301,(vlSelf->tb__DOT__top_module1__DOT__pmul_e__Vstatic__four),8);
        bufp->chgCData(oldp+302,(vlSelf->tb__DOT__top_module1__DOT__pmul_e__Vstatic__eight),8);
        bufp->chgCData(oldp+303,(vlSelf->tb__DOT__top_module1__DOT__pmul_9__Vstatic__two),8);
        bufp->chgCData(oldp+304,(vlSelf->tb__DOT__top_module1__DOT__pmul_9__Vstatic__four),8);
        bufp->chgCData(oldp+305,(vlSelf->tb__DOT__top_module1__DOT__pmul_9__Vstatic__eight),8);
        bufp->chgCData(oldp+306,(vlSelf->tb__DOT__top_module1__DOT__pmul_d__Vstatic__two),8);
        bufp->chgCData(oldp+307,(vlSelf->tb__DOT__top_module1__DOT__pmul_d__Vstatic__four),8);
        bufp->chgCData(oldp+308,(vlSelf->tb__DOT__top_module1__DOT__pmul_d__Vstatic__eight),8);
        bufp->chgCData(oldp+309,(vlSelf->tb__DOT__top_module1__DOT__pmul_b__Vstatic__two),8);
        bufp->chgCData(oldp+310,(vlSelf->tb__DOT__top_module1__DOT__pmul_b__Vstatic__four),8);
        bufp->chgCData(oldp+311,(vlSelf->tb__DOT__top_module1__DOT__pmul_b__Vstatic__eight),8);
        bufp->chgWData(oldp+312,(vlSelf->tb__DOT__top_module1__DOT__kb[0]),128);
        bufp->chgWData(oldp+316,(vlSelf->tb__DOT__top_module1__DOT__kb[1]),128);
        bufp->chgWData(oldp+320,(vlSelf->tb__DOT__top_module1__DOT__kb[2]),128);
        bufp->chgWData(oldp+324,(vlSelf->tb__DOT__top_module1__DOT__kb[3]),128);
        bufp->chgWData(oldp+328,(vlSelf->tb__DOT__top_module1__DOT__kb[4]),128);
        bufp->chgWData(oldp+332,(vlSelf->tb__DOT__top_module1__DOT__kb[5]),128);
        bufp->chgWData(oldp+336,(vlSelf->tb__DOT__top_module1__DOT__kb[6]),128);
        bufp->chgWData(oldp+340,(vlSelf->tb__DOT__top_module1__DOT__kb[7]),128);
        bufp->chgWData(oldp+344,(vlSelf->tb__DOT__top_module1__DOT__kb[8]),128);
        bufp->chgWData(oldp+348,(vlSelf->tb__DOT__top_module1__DOT__kb[9]),128);
        bufp->chgWData(oldp+352,(vlSelf->tb__DOT__top_module1__DOT__kb[10]),128);
        bufp->chgCData(oldp+356,(vlSelf->tb__DOT__top_module1__DOT__kcnt),4);
        bufp->chgBit(oldp+357,(vlSelf->tb__DOT__top_module1__DOT__kdone));
        bufp->chgBit(oldp+358,(vlSelf->tb__DOT__top_module1__DOT__kb_ld));
        bufp->chgIData(oldp+359,(vlSelf->tb__DOT__top_module1__DOT__u0__DOT__w[0]),32);
        bufp->chgIData(oldp+360,(vlSelf->tb__DOT__top_module1__DOT__u0__DOT__w[1]),32);
        bufp->chgIData(oldp+361,(vlSelf->tb__DOT__top_module1__DOT__u0__DOT__w[2]),32);
        bufp->chgIData(oldp+362,(vlSelf->tb__DOT__top_module1__DOT__u0__DOT__w[3]),32);
        bufp->chgIData(oldp+363,(vlSelf->tb__DOT__top_module1__DOT__u0__DOT__subword),32);
        bufp->chgIData(oldp+364,(vlSelf->tb__DOT__top_module1__DOT__u0__DOT__rcon),32);
        bufp->chgCData(oldp+365,(vlSelf->tb__DOT__top_module1__DOT__u0__DOT__r0__DOT__rcnt),4);
        bufp->chgCData(oldp+366,((0xfU & ((IData)(1U) 
                                          + (IData)(vlSelf->tb__DOT__top_module1__DOT__u0__DOT__r0__DOT__rcnt)))),4);
        bufp->chgCData(oldp+367,((0xffU & (vlSelf->tb__DOT__good1__DOT__u0__DOT__w
                                           [3U] >> 0x10U))),8);
        bufp->chgCData(oldp+368,(vlSymsp->TOP__tb__DOT__good1__DOT__u0__DOT__u0.b),8);
        bufp->chgCData(oldp+369,((0xffU & (vlSelf->tb__DOT__good1__DOT__u0__DOT__w
                                           [3U] >> 8U))),8);
        bufp->chgCData(oldp+370,(vlSymsp->TOP__tb__DOT__good1__DOT__u0__DOT__u1.b),8);
        bufp->chgCData(oldp+371,((0xffU & vlSelf->tb__DOT__good1__DOT__u0__DOT__w
                                  [3U])),8);
        bufp->chgCData(oldp+372,(vlSymsp->TOP__tb__DOT__good1__DOT__u0__DOT__u2.b),8);
        bufp->chgCData(oldp+373,((vlSelf->tb__DOT__good1__DOT__u0__DOT__w
                                  [3U] >> 0x18U)),8);
        bufp->chgCData(oldp+374,(vlSymsp->TOP__tb__DOT__good1__DOT__u0__DOT__u3.b),8);
        bufp->chgCData(oldp+375,((0xffU & (vlSelf->tb__DOT__top_module1__DOT__u0__DOT__w
                                           [3U] >> 0x10U))),8);
        bufp->chgCData(oldp+376,(vlSymsp->TOP__tb__DOT__top_module1__DOT__u0__DOT__u0.b),8);
        bufp->chgCData(oldp+377,((0xffU & (vlSelf->tb__DOT__top_module1__DOT__u0__DOT__w
                                           [3U] >> 8U))),8);
        bufp->chgCData(oldp+378,(vlSymsp->TOP__tb__DOT__top_module1__DOT__u0__DOT__u1.b),8);
        bufp->chgCData(oldp+379,((0xffU & vlSelf->tb__DOT__top_module1__DOT__u0__DOT__w
                                  [3U])),8);
        bufp->chgCData(oldp+380,(vlSymsp->TOP__tb__DOT__top_module1__DOT__u0__DOT__u2.b),8);
        bufp->chgCData(oldp+381,((vlSelf->tb__DOT__top_module1__DOT__u0__DOT__w
                                  [3U] >> 0x18U)),8);
        bufp->chgCData(oldp+382,(vlSymsp->TOP__tb__DOT__top_module1__DOT__u0__DOT__u3.b),8);
    }
    bufp->chgBit(oldp+383,(vlSelf->tb__DOT__clk));
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
    vlSymsp->TOP.__Vm_traceActivity[3U] = 0U;
}
