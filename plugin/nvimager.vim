" https://dev.to/2nit/how-to-write-neovim-plugins-in-lua-5cca
if exists('g:loaded_nvimager') | finish | endif " prevent loading file twice

" set options to user derfined/default values
let g:loaded_nvimager = 1
let g:nvimager#autostart = get(g:, 'nvimager#autostart', 0)
let g:nvimager#title = get(g:, 'nvimager#title', 0)
let g:nvimager#dynamic_scaler = get(g:, 'nvimager#dynamic_scaler', 'fit_contain')
let g:nvimager#static_scaler = get(g:, 'nvimager#static_scaler', 'forced_cover')
let g:plugindir = expand('<sfile>:p:h:h') " TODO: should be s: instead of g: ?

" temporarily set coptions to default to call fucntion
let s:save_cpo = &cpo
set cpo&vim
command! NvimagerToggle lua require'nvimager'.toggle()
command! NvimagerRefresh lua require'nvimager'.refresh()
let &cpo = s:save_cpo
unlet s:save_cpo

nnoremap <Plug>NvimageToggle :<C-u>NvimagerToggle<CR>
nnoremap <Plug>NvimageRefresh :<C-u>NvimagerToggle<CR>
" nnoremap <space>qq :<C-u>NvimagerToggle<CR>
" nnoremap <space>qr :<C-u>NvimagerRefresh<CR>
