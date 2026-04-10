// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table implementation internals

#include "Vtb__pch.h"
#include "Vtb.h"
#include "Vtb___024root.h"
#include "Vtb_aes_inv_sbox.h"
#include "Vtb_aes_sbox.h"

// FUNCTIONS
Vtb__Syms::~Vtb__Syms()
{
#ifdef VM_TRACE
    if (__Vm_dumping) _traceDumpClose();
#endif  // VM_TRACE
}

void Vtb__Syms::_traceDump() {
    const VerilatedLockGuard lock(__Vm_dumperMutex);
    __Vm_dumperp->dump(VL_TIME_Q());
}

void Vtb__Syms::_traceDumpOpen() {
    const VerilatedLockGuard lock(__Vm_dumperMutex);
    if (VL_UNLIKELY(!__Vm_dumperp)) {
        __Vm_dumperp = new VerilatedVcdC();
        __Vm_modelp->trace(__Vm_dumperp, 0, 0);
        std::string dumpfile = _vm_contextp__->dumpfileCheck();
        __Vm_dumperp->open(dumpfile.c_str());
        __Vm_dumping = true;
    }
}

void Vtb__Syms::_traceDumpClose() {
    const VerilatedLockGuard lock(__Vm_dumperMutex);
    __Vm_dumping = false;
    VL_DO_CLEAR(delete __Vm_dumperp, __Vm_dumperp = nullptr);
}

Vtb__Syms::Vtb__Syms(VerilatedContext* contextp, const char* namep, Vtb* modelp)
    : VerilatedSyms{contextp}
    // Setup internal state of the Syms class
    , __Vm_modelp{modelp}
    // Setup module instances
    , TOP{this, namep}
    , TOP__tb__DOT__good1__DOT__u0__DOT__u0{this, Verilated::catName(namep, "tb.good1.u0.u0")}
    , TOP__tb__DOT__good1__DOT__u0__DOT__u1{this, Verilated::catName(namep, "tb.good1.u0.u1")}
    , TOP__tb__DOT__good1__DOT__u0__DOT__u2{this, Verilated::catName(namep, "tb.good1.u0.u2")}
    , TOP__tb__DOT__good1__DOT__u0__DOT__u3{this, Verilated::catName(namep, "tb.good1.u0.u3")}
    , TOP__tb__DOT__good1__DOT__us00{this, Verilated::catName(namep, "tb.good1.us00")}
    , TOP__tb__DOT__good1__DOT__us01{this, Verilated::catName(namep, "tb.good1.us01")}
    , TOP__tb__DOT__good1__DOT__us02{this, Verilated::catName(namep, "tb.good1.us02")}
    , TOP__tb__DOT__good1__DOT__us03{this, Verilated::catName(namep, "tb.good1.us03")}
    , TOP__tb__DOT__good1__DOT__us10{this, Verilated::catName(namep, "tb.good1.us10")}
    , TOP__tb__DOT__good1__DOT__us11{this, Verilated::catName(namep, "tb.good1.us11")}
    , TOP__tb__DOT__good1__DOT__us12{this, Verilated::catName(namep, "tb.good1.us12")}
    , TOP__tb__DOT__good1__DOT__us13{this, Verilated::catName(namep, "tb.good1.us13")}
    , TOP__tb__DOT__good1__DOT__us20{this, Verilated::catName(namep, "tb.good1.us20")}
    , TOP__tb__DOT__good1__DOT__us21{this, Verilated::catName(namep, "tb.good1.us21")}
    , TOP__tb__DOT__good1__DOT__us22{this, Verilated::catName(namep, "tb.good1.us22")}
    , TOP__tb__DOT__good1__DOT__us23{this, Verilated::catName(namep, "tb.good1.us23")}
    , TOP__tb__DOT__good1__DOT__us30{this, Verilated::catName(namep, "tb.good1.us30")}
    , TOP__tb__DOT__good1__DOT__us31{this, Verilated::catName(namep, "tb.good1.us31")}
    , TOP__tb__DOT__good1__DOT__us32{this, Verilated::catName(namep, "tb.good1.us32")}
    , TOP__tb__DOT__good1__DOT__us33{this, Verilated::catName(namep, "tb.good1.us33")}
    , TOP__tb__DOT__top_module1__DOT__u0__DOT__u0{this, Verilated::catName(namep, "tb.top_module1.u0.u0")}
    , TOP__tb__DOT__top_module1__DOT__u0__DOT__u1{this, Verilated::catName(namep, "tb.top_module1.u0.u1")}
    , TOP__tb__DOT__top_module1__DOT__u0__DOT__u2{this, Verilated::catName(namep, "tb.top_module1.u0.u2")}
    , TOP__tb__DOT__top_module1__DOT__u0__DOT__u3{this, Verilated::catName(namep, "tb.top_module1.u0.u3")}
    , TOP__tb__DOT__top_module1__DOT__us00{this, Verilated::catName(namep, "tb.top_module1.us00")}
    , TOP__tb__DOT__top_module1__DOT__us01{this, Verilated::catName(namep, "tb.top_module1.us01")}
    , TOP__tb__DOT__top_module1__DOT__us02{this, Verilated::catName(namep, "tb.top_module1.us02")}
    , TOP__tb__DOT__top_module1__DOT__us03{this, Verilated::catName(namep, "tb.top_module1.us03")}
    , TOP__tb__DOT__top_module1__DOT__us10{this, Verilated::catName(namep, "tb.top_module1.us10")}
    , TOP__tb__DOT__top_module1__DOT__us11{this, Verilated::catName(namep, "tb.top_module1.us11")}
    , TOP__tb__DOT__top_module1__DOT__us12{this, Verilated::catName(namep, "tb.top_module1.us12")}
    , TOP__tb__DOT__top_module1__DOT__us13{this, Verilated::catName(namep, "tb.top_module1.us13")}
    , TOP__tb__DOT__top_module1__DOT__us20{this, Verilated::catName(namep, "tb.top_module1.us20")}
    , TOP__tb__DOT__top_module1__DOT__us21{this, Verilated::catName(namep, "tb.top_module1.us21")}
    , TOP__tb__DOT__top_module1__DOT__us22{this, Verilated::catName(namep, "tb.top_module1.us22")}
    , TOP__tb__DOT__top_module1__DOT__us23{this, Verilated::catName(namep, "tb.top_module1.us23")}
    , TOP__tb__DOT__top_module1__DOT__us30{this, Verilated::catName(namep, "tb.top_module1.us30")}
    , TOP__tb__DOT__top_module1__DOT__us31{this, Verilated::catName(namep, "tb.top_module1.us31")}
    , TOP__tb__DOT__top_module1__DOT__us32{this, Verilated::catName(namep, "tb.top_module1.us32")}
    , TOP__tb__DOT__top_module1__DOT__us33{this, Verilated::catName(namep, "tb.top_module1.us33")}
{
        // Check resources
        Verilated::stackCheck(323);
    // Configure time unit / time precision
    _vm_contextp__->timeunit(-12);
    _vm_contextp__->timeprecision(-12);
    // Setup each module's pointers to their submodules
    TOP.__PVT__tb__DOT__good1__DOT__u0__DOT__u0 = &TOP__tb__DOT__good1__DOT__u0__DOT__u0;
    TOP.__PVT__tb__DOT__good1__DOT__u0__DOT__u1 = &TOP__tb__DOT__good1__DOT__u0__DOT__u1;
    TOP.__PVT__tb__DOT__good1__DOT__u0__DOT__u2 = &TOP__tb__DOT__good1__DOT__u0__DOT__u2;
    TOP.__PVT__tb__DOT__good1__DOT__u0__DOT__u3 = &TOP__tb__DOT__good1__DOT__u0__DOT__u3;
    TOP.__PVT__tb__DOT__good1__DOT__us00 = &TOP__tb__DOT__good1__DOT__us00;
    TOP.__PVT__tb__DOT__good1__DOT__us01 = &TOP__tb__DOT__good1__DOT__us01;
    TOP.__PVT__tb__DOT__good1__DOT__us02 = &TOP__tb__DOT__good1__DOT__us02;
    TOP.__PVT__tb__DOT__good1__DOT__us03 = &TOP__tb__DOT__good1__DOT__us03;
    TOP.__PVT__tb__DOT__good1__DOT__us10 = &TOP__tb__DOT__good1__DOT__us10;
    TOP.__PVT__tb__DOT__good1__DOT__us11 = &TOP__tb__DOT__good1__DOT__us11;
    TOP.__PVT__tb__DOT__good1__DOT__us12 = &TOP__tb__DOT__good1__DOT__us12;
    TOP.__PVT__tb__DOT__good1__DOT__us13 = &TOP__tb__DOT__good1__DOT__us13;
    TOP.__PVT__tb__DOT__good1__DOT__us20 = &TOP__tb__DOT__good1__DOT__us20;
    TOP.__PVT__tb__DOT__good1__DOT__us21 = &TOP__tb__DOT__good1__DOT__us21;
    TOP.__PVT__tb__DOT__good1__DOT__us22 = &TOP__tb__DOT__good1__DOT__us22;
    TOP.__PVT__tb__DOT__good1__DOT__us23 = &TOP__tb__DOT__good1__DOT__us23;
    TOP.__PVT__tb__DOT__good1__DOT__us30 = &TOP__tb__DOT__good1__DOT__us30;
    TOP.__PVT__tb__DOT__good1__DOT__us31 = &TOP__tb__DOT__good1__DOT__us31;
    TOP.__PVT__tb__DOT__good1__DOT__us32 = &TOP__tb__DOT__good1__DOT__us32;
    TOP.__PVT__tb__DOT__good1__DOT__us33 = &TOP__tb__DOT__good1__DOT__us33;
    TOP.__PVT__tb__DOT__top_module1__DOT__u0__DOT__u0 = &TOP__tb__DOT__top_module1__DOT__u0__DOT__u0;
    TOP.__PVT__tb__DOT__top_module1__DOT__u0__DOT__u1 = &TOP__tb__DOT__top_module1__DOT__u0__DOT__u1;
    TOP.__PVT__tb__DOT__top_module1__DOT__u0__DOT__u2 = &TOP__tb__DOT__top_module1__DOT__u0__DOT__u2;
    TOP.__PVT__tb__DOT__top_module1__DOT__u0__DOT__u3 = &TOP__tb__DOT__top_module1__DOT__u0__DOT__u3;
    TOP.__PVT__tb__DOT__top_module1__DOT__us00 = &TOP__tb__DOT__top_module1__DOT__us00;
    TOP.__PVT__tb__DOT__top_module1__DOT__us01 = &TOP__tb__DOT__top_module1__DOT__us01;
    TOP.__PVT__tb__DOT__top_module1__DOT__us02 = &TOP__tb__DOT__top_module1__DOT__us02;
    TOP.__PVT__tb__DOT__top_module1__DOT__us03 = &TOP__tb__DOT__top_module1__DOT__us03;
    TOP.__PVT__tb__DOT__top_module1__DOT__us10 = &TOP__tb__DOT__top_module1__DOT__us10;
    TOP.__PVT__tb__DOT__top_module1__DOT__us11 = &TOP__tb__DOT__top_module1__DOT__us11;
    TOP.__PVT__tb__DOT__top_module1__DOT__us12 = &TOP__tb__DOT__top_module1__DOT__us12;
    TOP.__PVT__tb__DOT__top_module1__DOT__us13 = &TOP__tb__DOT__top_module1__DOT__us13;
    TOP.__PVT__tb__DOT__top_module1__DOT__us20 = &TOP__tb__DOT__top_module1__DOT__us20;
    TOP.__PVT__tb__DOT__top_module1__DOT__us21 = &TOP__tb__DOT__top_module1__DOT__us21;
    TOP.__PVT__tb__DOT__top_module1__DOT__us22 = &TOP__tb__DOT__top_module1__DOT__us22;
    TOP.__PVT__tb__DOT__top_module1__DOT__us23 = &TOP__tb__DOT__top_module1__DOT__us23;
    TOP.__PVT__tb__DOT__top_module1__DOT__us30 = &TOP__tb__DOT__top_module1__DOT__us30;
    TOP.__PVT__tb__DOT__top_module1__DOT__us31 = &TOP__tb__DOT__top_module1__DOT__us31;
    TOP.__PVT__tb__DOT__top_module1__DOT__us32 = &TOP__tb__DOT__top_module1__DOT__us32;
    TOP.__PVT__tb__DOT__top_module1__DOT__us33 = &TOP__tb__DOT__top_module1__DOT__us33;
    // Setup each module's pointer back to symbol table (for public functions)
    TOP.__Vconfigure(true);
    TOP__tb__DOT__good1__DOT__u0__DOT__u0.__Vconfigure(true);
    TOP__tb__DOT__good1__DOT__u0__DOT__u1.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__u0__DOT__u2.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__u0__DOT__u3.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us00.__Vconfigure(true);
    TOP__tb__DOT__good1__DOT__us01.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us02.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us03.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us10.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us11.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us12.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us13.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us20.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us21.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us22.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us23.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us30.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us31.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us32.__Vconfigure(false);
    TOP__tb__DOT__good1__DOT__us33.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__u0__DOT__u0.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__u0__DOT__u1.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__u0__DOT__u2.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__u0__DOT__u3.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us00.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us01.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us02.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us03.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us10.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us11.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us12.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us13.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us20.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us21.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us22.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us23.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us30.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us31.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us32.__Vconfigure(false);
    TOP__tb__DOT__top_module1__DOT__us33.__Vconfigure(false);
}
