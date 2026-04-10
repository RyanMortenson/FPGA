SHELL := /bin/bash

.PHONY: help mods doctor sim sim_tb sim_tb_gui pre_synth_schematic synth open_synth_checkpoint implement open_implement_checkpoint download clean passoff_check passoff_submit

help:
	@echo 'ECEN 320 root workflow'
	@echo ''
	@echo 'List modules:'
	@echo '  make mods'
	@echo ''
	@echo 'Run checks:'
	@echo '  make doctor'
	@echo ''
	@echo 'Run a target inside a module directory:'
	@echo '  make sim MOD=demo/pong'
	@echo '  make sim_tb MOD=common_modules/multi_segment/seven_segment4'
	@echo '  make synth MOD=demo/graphics_project/project_top'
	@echo '  make implement MOD=demo/graphics_project/project_top'
	@echo '  make clean MOD=demo/graphics_project/project_top'
	@echo '  make passoff_check MOD=demo/graphics_project'
	@echo ''
	@echo 'Optional environment overrides:'
	@echo '  VIVADO_SETTINGS=/abs/path/to/settings64.sh'
	@echo '  VIVADO_VERSION=2025.2'

mods:
	@find . -mindepth 2 -maxdepth 3 -name Makefile | sed 's#^\./##; s#/Makefile##' | sort

doctor:
	@./resources/doctor.sh

define RUN_IN_MOD
	@if [[ -z "$(MOD)" ]]; then \
		echo 'Error: MOD is required. Example: make sim MOD=demo/pong'; \
		exit 1; \
	fi
	@if [[ ! -f "$(MOD)/Makefile" ]]; then \
		echo "Error: $(MOD)/Makefile not found"; \
		exit 1; \
	fi
	@$(MAKE) -C "$(MOD)" $(1)
endef

sim:
	$(call RUN_IN_MOD,sim)

sim_tb:
	$(call RUN_IN_MOD,sim_tb)

sim_tb_gui:
	$(call RUN_IN_MOD,sim_tb_gui)

pre_synth_schematic:
	$(call RUN_IN_MOD,pre_synth_schematic)

synth:
	$(call RUN_IN_MOD,synth)

open_synth_checkpoint:
	$(call RUN_IN_MOD,open_synth_checkpoint)

implement:
	$(call RUN_IN_MOD,implement)

open_implement_checkpoint:
	$(call RUN_IN_MOD,open_implement_checkpoint)

download:
	$(call RUN_IN_MOD,download)

clean:
	$(call RUN_IN_MOD,clean)

passoff_check:
	$(call RUN_IN_MOD,passoff_check)

passoff_submit:
	$(call RUN_IN_MOD,passoff_submit)
