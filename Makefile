include spec/.shared/neovim-plugin.mk

spec/.shared/neovim-plugin.mk:
	git clone https://github.com/notomo/workflow.git --depth 1 spec/.shared

VIRTES_DIR := ${SPEC_DIR}/virtes
COMPARE_HASH := HEAD^
RESULT_DIR := ${VIRTES_DIR}/screenshot
diff_screenshot:
	nvim --clean -n +"lua dofile('${VIRTES_DIR}/scenario.lua')('${COMPARE_HASH}', '${RESULT_DIR}')" +"quitall!"
	cat ${RESULT_DIR}/replay.vim
	test ! -s ${RESULT_DIR}/replay.vim
.PHONY: diff_screenshot
