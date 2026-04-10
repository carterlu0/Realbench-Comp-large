VERILATOR = verilator -Wno-fatal -Wno-TIMESCALEMOD

# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe
# build the verilator -Wno-fatal -Wno-TIMESCALEMOD model
VERILATOR_FLAGS += --binary
# Make waveforms
VERILATOR_FLAGS += --trace
# Check SystemVerilog assertions
VERILATOR_FLAGS += --assert
# Generate coverage analysis
VERILATOR_FLAGS += --coverage-line -fno-table
# ignore some warnings
VERILATOR_FLAGS += -Wno-SIDEEFFECT -Wno-CASEOVERLAP -Wno-LATCH -Wno-UNOPTFLAT -Wno-MULTIDRIVEN -Wno-ASCRANGE -Wno-COMBDLY -Wno-IMPLICIT -Wno-CASEINCOMPLETE -Wno-PINMISSING -Wno-WIDTHTRUNC -Wno-TIMESCALEMOD -Wno-INITIALDLY -Wno-EOFNEWLINE -Wno-DECLFILENAME -Wno-WIDTHEXPAND
# multi-threaded build
VERILATOR_FLAGS += -j 4
# enable timing 
VERILATOR_FLAGS += --timing
# bug fixing
VERILATOR_FLAGS += -fno-table
# set top module
VERILATOR_FLAGS += --top tb
# set include path
VERILATOR_FLAGS += -I../../config -I../../e203_defines
# Input files for Verilator
VERILATOR_INPUT = *v
# ######################################################################
default: compile
compile:
	
	@echo
	@echo "-- COMPILE ----------------"
	$(VERILATOR) $(VERILATOR_FLAGS) $(VERILATOR_INPUT)

run:
	@echo
	@echo "-- RUN ---------------------"
	@rm -rf logs
	@mkdir -p logs
	obj_dir/Vtb
	@mv coverage.dat 2>/dev/null || true 2>/dev/null || true 2>/dev/null || true wave.vcd logs/

analyze:
	@echo
	@echo "-- COVERAGE ----------------"
	$(VERILATOR_COVERAGE) logs/coverage.dat --annotate-all --annotate ./logs

all:
	@echo
	@echo "-- ALL ---------------------"
	$(MAKE) compile
	$(MAKE) run

maintainer-copy::
clean::
	-rm -rf obj_dir logs
