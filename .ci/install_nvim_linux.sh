sudo modprobe fuse
user="$(whoami)"
sudo usermod -a -G fuse $user
wget -nv https://github.com/neovim/neovim/releases/download/${NEOVIM_VERSION_TAG}/nvim.appimage
mkdir -p ~/neovim/bin
cp nvim.appimage ~/neovim/bin/nvim
chmod u+x ~/neovim/bin/nvim
