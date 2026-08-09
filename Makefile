WORKFLOW_DIR ?= spec/.shared
include $(WORKFLOW_DIR)/neovim-plugin.mk

spec/.shared/neovim-plugin.mk:
	git clone https://github.com/notomo/workflow.git --depth 1 spec/.shared
