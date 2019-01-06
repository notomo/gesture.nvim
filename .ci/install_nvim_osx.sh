wget https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION_TAG}/nvim-macos.tar.gz -O ~/neovim.tar.gz
mkdir -p ~/neovim
tar -zxf ~/neovim.tar.gz -C ~/neovim --strip-components 1
