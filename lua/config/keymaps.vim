" =============================================================================
"   KEY MAPPING
" =============================================================================
" map jj to esc
imap jj <Esc>


" Jump to start and end of line using the home row keys
map H ^
map L $

" <leader><leader> toggles between buffers
nnoremap <leader><leader> <C-^>

" cmd+v works on neovide
if exists("g:neovide")

  let g:neovide_input_use_logo=v:true
  map <D-v> "+p<CR>
  map! <D-v> <C-R>+
  tmap <D-v> <C-R>+
  vmap <D-c> "+y<CR>

endif

