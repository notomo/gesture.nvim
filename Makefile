test:
	vusted ./test --shuffle -v
.PHONY: test

COMPARE_HASH := HEAD^
RESULT_DIR := ./test/screenshot
diff_screenshot:
	nvim --clean -n +"lua dofile('./test/diff.lua')('${COMPARE_HASH}', '${RESULT_DIR}')" +"quitall!"
	cat ${RESULT_DIR}/replay.vim
	test ! -s ${RESULT_DIR}/replay.vim
.PHONY: diff_screenshot
