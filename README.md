## TODO:
- [] handle C-j, C-h, C-l. Since if I want to move windows by using C-j/h/l/k. I need to remap my current binding. I use C-j for esc, C-j also confict with,  move cursor for complition.  C-l for jump to next complition. I may can use <M-j> <M-h> <M-k> <M-l> for it.

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
