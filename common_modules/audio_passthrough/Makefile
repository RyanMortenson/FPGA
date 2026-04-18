REPO_PATH=../..
include $(REPO_PATH)/resources/common.mk

MODULE_NAME = audio_passthrough_top
SV_FILES = audio_passthrough_top.sv audio_passthrough_core.sv audio_clock_mmcm.sv pmod_i2s2_engine.sv i2s_master_clocks.sv i2s_rx.sv i2s_tx.sv reset_sync.sv
BRINGUP_MODULE_NAME = bringup_top
BRINGUP_SV_FILES = bringup_top.sv
BRINGUP_XDC = bringup_basys3.xdc

define RUN_NAMED_TB
	cd work; \
	. ../$(REPO_PATH)/resources/vivado_env.sh; \
	xvlog ../$(1) $(addprefix ../,$(SV_FILES)) -sv > xvlog_$(2).log 2>&1; \
	cat xvlog_$(2).log; \
	if grep -q '^ERROR:' xvlog_$(2).log; then exit 1; fi; \
	xvlog ../$(REPO_PATH)/resources/cells_sim.v > xvlog_cells_$(2).log 2>&1; \
	cat xvlog_cells_$(2).log; \
	if grep -q '^ERROR:' xvlog_cells_$(2).log; then exit 1; fi; \
	xelab $(2) -debug typical --timescale 1ns/1ps > xelab_$(2).log 2>&1; \
	cat xelab_$(2).log; \
	if grep -q '^ERROR:' xelab_$(2).log; then exit 1; fi; \
	xsim $(2) -log sim_$(2).log --runall
endef

sim_tb_i2s_rx: work
	@$(call RUN_NAMED_TB,tb_i2s_rx.sv,tb_i2s_rx)

sim_tb_i2s_tx: work
	@$(call RUN_NAMED_TB,tb_i2s_tx.sv,tb_i2s_tx)

sim_tb_engine: work
	@$(call RUN_NAMED_TB,tb_pmod_i2s2_engine.sv,tb_pmod_i2s2_engine)

sim_tb_core: work
	@$(call RUN_NAMED_TB,tb_audio_passthrough_core.sv,tb_audio_passthrough_core)

sim_tb_top: work
	@$(call RUN_NAMED_TB,tb_audio_passthrough_top.sv,tb_audio_passthrough_top)

sim_tb_all:
	$(MAKE) sim_tb_i2s_rx
	$(MAKE) sim_tb_i2s_tx
	$(MAKE) sim_tb_engine
	$(MAKE) sim_tb_core
	$(MAKE) sim_tb_top

bringup_clean:
	rm -rf work_bringup

bringup_implement: work_bringup work_bringup/implement.dcp

work_bringup:
	mkdir -p work_bringup

work_bringup/synth.dcp: $(BRINGUP_SV_FILES) $(BRINGUP_XDC)
	cd work_bringup && \
	. ../$(REPO_PATH)/resources/vivado_env.sh && \
	export REPO_PATH=$(REPO_PATH) && \
	export MODULE_NAME=$(BRINGUP_MODULE_NAME) && \
	export SV_FILES="$(addprefix ../,$(BRINGUP_SV_FILES))" && \
	export XDC_PATH="../$(BRINGUP_XDC)" && \
	export SYNTH_PARAMS="" && \
	vivado -mode batch -source ../$(REPO_PATH)/resources/synth.tcl -log synth.log -nojournal -notrace

work_bringup/implement.dcp: work_bringup/synth.dcp
	cd work_bringup && \
	. ../$(REPO_PATH)/resources/vivado_env.sh && \
	vivado -mode batch -source ../$(REPO_PATH)/resources/implement.tcl -log implement.log -nojournal -notrace

bringup_download: work_bringup/implement.dcp
	cd work_bringup && \
	python3 ../$(REPO_PATH)/resources/openocd.py design.bit
