# Directory for the specific example you are building
EG ?= Fixed-Point-

# Directory containing the Bluespec Training distribution directory
DISTRO ?= ..

# Set this to the command that invokes your Verilog simulator
# VSIM ?= iverilog
VSIM ?= cvc
# VSIM ?= cver
# VSIM ?= vcsi
# VSIM ?= vcs
# VSIM ?= modelsim
# VSIM ?= ncsim
# VSIM ?= ncverilog

# ================================================================
# You should not have to change anything below this line

TOPFILE   ?= $(DISTRO)/$(EG)/src_BSV/Testbench.bsv
TOPMODULE ?= mkTestbench

BSC_COMP_FLAGS = -elab -keep-fires -aggressive-conditions -no-warn-action-shadowing
BSC_LINK_FLAGS = -keep-fires
BSC_PATHS = -p $(DISTRO)/$(EG)/src_BSV:$(DISTRO)/Common:%/Prelude:%/Libraries

.PHONY: help
help:
	@echo "Current settings"
	@echo "    BLUESPEC_LICENSE_FILE = " $(BLUESPEC_LICENSE_FILE)
	@echo "    BLUESPEC_HOME         = " $(BLUESPEC_HOME)
	@echo "    BLUESPECDIR           = " $(BLUESPECDIR)
	@echo ""
	@echo "    EG                    = " $(EG) " (redefine EG for another example)"
	@echo ""
	@echo "Targets for 'make':"
	@echo "    help                Print this information"
	@echo ""
	@echo "    Bluesim:"
	@echo "        compile         Compile for Bluesim"
	@echo "        link            Link a Bluesim executable"
	@echo "        simulate        Run the Bluesim simulation executable"
	@echo "                            (generates VCD file; remove -V flag to suppress VCD gen)"
	@echo "        all_bsim        Convenience for make compile link simulate"
	@echo ""
	@echo "    Verilog generation and Verilog sim:"
	@echo "        verilog         Compile for Verilog (Verilog files generated in verilog_dir/)"
	@echo "        v_link          Link a Verilog simulation executable"
	@echo "                            (current simulator:" $(VSIM) " (redefine VSIM for other Verilog simulators)"
	@echo "        v_simulate      Run the Verilog simulation executable"
	@echo "        all_vsim        Convenience for make verilog v_link v_simulate"
	@echo "                            (generates VCD file; remove +bscvcd flag to suppress VCD gen)"
	@echo ""
	@echo "    clean               Delete intermediate files in build_bsim/ and build_v/ dirs"
	@echo "    full_clean          Delete all but this Makefile"

# ----------------------------------------------------------------
# Bluesim compile/link/simulate

BSIM_DIRS = -simdir build_bsim -bdir build_bsim -info-dir build_bsim
BSIM_EXE = $(TOPMODULE)_bsim

.PHONY: all_bsim
all_bsim: full_clean  compile  link    simulate

build_bsim:
	mkdir  build_bsim

.PHONY: compile
compile: build_bsim
	@echo Compiling for Bluesim ...
	bsc -u -sim -show-schedule $(BSIM_DIRS) $(BSC_COMP_FLAGS) $(BSC_PATHS) -g $(TOPMODULE)  $(TOPFILE) 
	@echo Compiling for Bluesim finished

.PHONY: link
link:
	@echo Linking for Bluesim ...
	bsc -e $(TOPMODULE) -sim -o $(BSIM_EXE) $(BSIM_DIRS) $(BSC_LINK_FLAGS) $(BSC_PATHS) \
		$(DISTRO)/Common/C_imports.c
	@echo Linking for Bluesim finished

.PHONY: simulate
simulate:
	@echo Bluesim simulation ...
	./$(BSIM_EXE) > op.txt
	@echo Bluesim simulation finished

# ----------------------------------------------------------------
# Verilog compile/link/sim

V_DIRS = -vdir verilog_dir -bdir build_v -info-dir build_v
VSIM_EXE = $(TOPMODULE)_vsim

.PHONY: all_vsim
all_vsim: full_clean  verilog  v_link  v_simulate

build_v:
	mkdir  build_v
verilog_dir:
	mkdir  verilog_dir

.PHONY: verilog
verilog: build_v  verilog_dir
	@echo Compiling for Verilog ...
	bsc -u -verilog $(V_DIRS) $(BSC_COMP_FLAGS) $(BSC_PATHS) -g $(TOPMODULE)  $(TOPFILE)
	@echo Compiling for Verilog finished

.PHONY: v_link
v_link:  build_v  verilog_dir
	@echo Linking for Verilog sim ...
	bsc -e $(TOPMODULE) -verilog -o ./$(VSIM_EXE) $(V_DIRS) -vsim $(VSIM)  verilog_dir/$(TOPMODULE).v \
		$(DISTRO)/Common/C_imports.c
	@echo Linking for Verilog sim finished

.PHONY: v_simulate
v_simulate:
	@echo Verilog simulation...
	./$(VSIM_EXE)  +bscvcd
	@echo Verilog simulation finished

# ----------------------------------------------------------------

.PHONY: clean
clean:
	rm -f  build_bsim/*  build_v/*    *~

.PHONY: full_clean
full_clean:
	rm -r -f  build_bsim  build_v  verilog_dir  *~
	rm -f  *$(TOPMODULE)*  *.vcd
