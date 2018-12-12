
test:
	NVIM_RPLUGIN_MANIFEST=$(HOME)/rplugin.vim nvim -u ./update_remote_plugins.vim -i NONE -n --headless +q
	THEMIS_ARGS="-e --headless" NVIM_RPLUGIN_MANIFEST=$(HOME)/rplugin.vim themis
	npm run test

.PHONY: test
