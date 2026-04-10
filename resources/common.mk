SHELL := /bin/bash
.SHELLFLAGS := -c

work:
	mkdir -p work

sim: work
	@if [ -z "$(MODULE_NAME)" ]; then echo "Error: MODULE_NAME not set"; exit 1; fi
	@if [ -z "$(SV_FILES)" ]; then echo "Error: SV_FILES not set"; exit 1; fi
	@if [ ! -f sim.tcl ]; then echo "Error: sim.tcl not found in $(CURDIR). Use make sim_tb if this module is testbench-driven."; exit 1; fi
	cd work; \
	. ../$(REPO_PATH)/resources/vivado_env.sh; \
	xvlog $(addprefix ../,$(SV_FILES)) -sv > xvlog_sim.log 2>&1; \
	cat xvlog_sim.log; \
	if grep -q '^ERROR:' xvlog_sim.log; then exit 1; fi; \
	xvlog ../$(REPO_PATH)/resources/cells_sim.v > xvlog_cells.log 2>&1; \
	cat xvlog_cells.log; \
	if grep -q '^ERROR:' xvlog_cells.log; then exit 1; fi; \
	xelab $(MODULE_NAME) -debug typical --timescale 1ns/1ps $(foreach PARAM,$(SIM_PARAMS),--generic_top '$(PARAM)') > xelab.log 2>&1; \
	cat xelab.log; \
	if grep -q '^ERROR:' xelab.log; then exit 1; fi; \
	xsim $(MODULE_NAME) -tclbatch ../sim.tcl -log sim.log $(if $(filter 1,$(NOGUI)),,-gui)

sim_nogui:
	$(MAKE) NOGUI=1 sim

sim_tb: work
	@if [ -z "$(SV_FILES)" ]; then echo "Error: SV_FILES not set"; exit 1; fi
	@if [ ! -f tb.sv ]; then echo "Error: tb.sv not found in $(CURDIR). Use make sim if this module is sim.tcl-driven."; exit 1; fi
	cd work; \
	. ../../../resources/vivado_env.sh; \
	xvlog ../tb.sv $(addprefix ../,$(SV_FILES)) -sv > xvlog_tb.log 2>&1; \
	cat xvlog_tb.log; \
	if grep -q '^ERROR:' xvlog_tb.log; then exit 1; fi; \
	xvlog ../../../resources/cells_sim.v > xvlog_cells.log 2>&1; \
	cat xvlog_cells.log; \
	if grep -q '^ERROR:' xvlog_cells.log; then exit 1; fi; \
	xelab tb -debug typical --timescale 1ns/1ps > xelab.log 2>&1; \
	cat xelab.log; \
	if grep -q '^ERROR:' xelab.log; then exit 1; fi; \
	xsim tb -log sim_tb.log --runall

sim_tb_gui:
	$(MAKE) GUI=1 sim_tb

pre_synth_schematic: work
	@if [ -z "$(MODULE_NAME)" ]; then echo "Error: MODULE_NAME not set"; exit 1; fi
	@if [ -z "$(SV_FILES)" ]; then echo "Error: SV_FILES not set"; exit 1; fi
	cd work && \
	. ../$(REPO_PATH)/resources/vivado_env.sh && \
	export MODULE_NAME=$(MODULE_NAME) && \
	export SV_FILES="$(addprefix ../,$(SV_FILES))" && \
	vivado -source ../$(REPO_PATH)/resources/presynth_schematic.tcl -notrace -nojournal

synth: work work/synth.dcp

work/synth.dcp: $(SV_FILES) basys3.xdc
	@if [ -z "$(REPO_PATH)" ]; then echo "Error: REPO_PATH not set"; exit 1; fi
	@if [ -z "$(MODULE_NAME)" ]; then echo "Error: MODULE_NAME not set"; exit 1; fi
	@if [ -z "$(SV_FILES)" ]; then echo "Error: SV_FILES not set"; exit 1; fi
	cd work && \
	. ../$(REPO_PATH)/resources/vivado_env.sh && \
	export REPO_PATH=$(REPO_PATH) && \
	export MODULE_NAME=$(MODULE_NAME) && \
	export SV_FILES="$(addprefix ../,$(SV_FILES))" && \
	export XDC_PATH="../basys3.xdc" && \
	export SYNTH_PARAMS="$(foreach PARAM,$(SYNTH_PARAMS),-generic $(PARAM))" && \
	vivado -mode batch -source ../$(REPO_PATH)/resources/synth.tcl -log synth.log -nojournal -notrace

open_synth_checkpoint: work/synth.dcp
	cd work && \
	. ../$(REPO_PATH)/resources/vivado_env.sh && \
	vivado synth.dcp -notrace -nojournal

implement: work work/implement.dcp

work/implement.dcp: work/synth.dcp
	cd work && \
	. ../$(REPO_PATH)/resources/vivado_env.sh && \
	vivado -mode batch -source ../$(REPO_PATH)/resources/implement.tcl -log implement.log -nojournal -notrace

open_implement_checkpoint: work/implement.dcp
	cd work && \
	. ../$(REPO_PATH)/resources/vivado_env.sh && \
	vivado implement.dcp -notrace -nojournal

download: work work/implement.dcp
	cd work && \
	python3 ../$(REPO_PATH)/resources/openocd.py design.bit

clean:
	rm -rf work