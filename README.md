## What I do
edit file `~/homebrew/Cellar/neovim/0.9.4/share/nvim/runtime/ftplugin/python.vim` to remove all ']]' and '[[' shortcut to make RRethy/vim-illuminate work

## Set up
```
git clone https://github.com/Nero5023/nero.nvim.git ~/.config/nvim
```

### keep the original config
```
git clone https://github.com/Nero5023/nero.nvim.git ~/.config/nvim-nero
```
and then put the alias into .zshrc
```
alias nvim-nero='NVIM_APPNAME="nvim-nero" nvim'
```
