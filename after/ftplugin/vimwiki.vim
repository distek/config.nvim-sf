set cc=
let g:vimwiki_list = [{'path': '~/wiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]
autocmd FileType vimwiki nnoremap <C-n> <ESC>:VimwikiNextLink<CR>
autocmd FileType vimwiki nnoremap <C-N> <ESC>:VimwikiPrevLink<CR>
autocmd FileType vimwiki nnoremap <CR> <ESC>:VimwikiFollowLink<CR>

runtime after/ftplugin/markdown.lua
