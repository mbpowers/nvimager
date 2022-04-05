# Nvimager
Inline markdown image/gif/video/pdf/LaTeX previewer for nvim using ueberzug.
Designed for use with vimwiki using markdown syntax.
--------------------------------------------------------------------------------

## Installation
Download using your preffered package manager, but you probably have some of them.
<details>
  <summary>Dependencies</summary>
1. (Üeberzug)[https://github.com/seebye/ueberzug]
2. (pdftoppm)[https://linux.die.net/man/1/pdftoppm]
3. (ffmpeg)[https://ffmpeg.org/]
4. (imagemagick)[https://imagemagick.org/index.php]
5. (pdfTex)[https://tug.org/applications/pdftex/]
</details>
You can use your preffered plugin manager, otherwise here are instructions for Vim-Plug.
<details>
  <summary>Nvimager</summary>
1. Install [junegunn/vim-plug](https://github.com/junegunn/vim-plug).
2. Add plugin to vim-plug block in `vimrc`.
```vim
call plug#begin()
  Plug 'mbpowers/nvimager'
call plug#end()
```
3. Add keybinding in `vimrc`.

`nmap <leader>qq <Plug>NvimagerToggle`

4. Restart nvim, and run `:PlugInstall`.
</details>
--------------------------------------------------------------------------------
## Use
Nvimager matches text in the buffer to
* Dynamic Previews
    `[name](file:path)`
    `$ equation $`
    Height is determined by number empty lines below (excluding EOF). Width is the width of the terminal.
* Static Previews
    `[name](file:path)<!--widthxheight-->`
    TODO: Static Tex Previews `$ equation $<!--widthxheight-->`
    Width and height are measured in terminal cells. The html comment `<!--comment-->` is allowed either two or three hyphens.
--------------------------------------------------------------------------------
## Configuration

| option                  | default       |
|-------------------------|---------------|
| nvimager#autostart      | 0             |
| nvimager#title          | 1             |
| nvimager#dynamic_scaler | 'fit_contain' |
| nvimager#static_scaler  | 'forced_cover'|

You can set these in your `init.vim`:

```vim
let g:nvimager#autostart = 0
let g:nvimager#title = 1
let g:nvimager#dynamic_scaler = 'fit_contain'
let g:nvimager#static_scaler = 'forced_cover'
  ```
--------------------------------------------------------------------------------
## Credit/Inspiration
(ueberzug)[https://github.com/seebye/ueberzug]
(example.mp4)[https://www.youtube.com/watch?v=Faow3SKIzq0]
ueberzug-fifo.sh modified from this (gist)["https://github.com/nvim-telescope/telescope-media-files.nvim/blob/master/scripts/vimg"].
thumbnailer.sh modified from (this)[https://gist.github.com/Voldrix/84a01b602e5d6c53c2b67e156bf26a10].
(neovim-plugins-in-lua)[https://dev.to/2nit/how-to-write-neovim-plugins-in-lua-5cca]
