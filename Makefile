test:
	vusted ./test --shuffle -v
.PHONY: test

COMPARE_HASH := HEAD^
GENERATED_SCRIPT := ./test/screenshot/result.vim
diff_screenshot:
	nvim --clean -n +"lua dofile('./test/diff.lua')('${COMPARE_HASH}', '${GENERATED_SCRIPT}')" +"quitall!"
	cat ${GENERATED_SCRIPT}
	test ! -s ${GENERATED_SCRIPT}
.PHONY: diff_screenshot
