test:
	vusted --shuffle -v
.PHONY: test

COMPARE_HASH := HEAD^
RESULT_DIR := ./spec/lua/gesture/virtes/screenshot
diff_screenshot:
	nvim --clean -n +"lua dofile('./spec/lua/gesture/virtes/scenario.lua')('${COMPARE_HASH}', '${RESULT_DIR}')" +"quitall!"
	cat ${RESULT_DIR}/replay.vim
	test ! -s ${RESULT_DIR}/replay.vim
.PHONY: diff_screenshot
