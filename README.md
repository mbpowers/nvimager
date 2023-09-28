# nvimager
[![repo size](https://img.shields.io/github/repo-size/liyasthomas/banner.svg)](https://github.com/liyasthomas/banner/archive/master.zip)
[![license](https://img.shields.io/github/license/liyasthomas/banner.svg)](https://github.com/liyasthomas/banner/blob/master/LICENSE)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/liyasthomas/banner/issues)
[![standard-readme compliant](https://img.shields.io/badge/readme%20style-standard-brightgreen.svg?style=rounded)](https://github.com/RichardLitt/standard-readme)

Inline markdown image/gif/video/pdf/LaTeX previewer for nvim using ueberzug.

Designed for use with vimwiki using markdown syntax.

![nvimagerbannerlong](https://user-images.githubusercontent.com/45055485/161781452-fd634c85-57dd-431b-a41a-770185a34262.png)

## Table of Contents

- [Install](#install)
- [Usage](#usage)
- [Maintainers](#maintainers)
- [Contributing](#contributing)
- [License](#license)

## Install

<details>
  <summary>Dependencies</summary>

- [Üeberzug](https://github.com/ueber-devel/ueberzug) (Necessary)
- [pdftoppm](https://linux.die.net/man/1/pdftoppm) (PDF/LaTeX)
- [ffmpeg](https://ffmpeg.org/) (Video)
- [imagemagick](https://imagemagick.org/index.php) (GIF/Video)
- [pdfTex](https://tug.org/applications/pdftex/) (LaTeX)

</details>

<details>
  <summary>nvimager</summary>
  Download using your preffered plugin manager, otherwise here are instructions for Vim-Plug.

1. Install [junegunn/vim-plug](https://github.com/junegunn/vim-plug).

2. Add plugin to vim-plug block in `vimrc`.
```vim
call plug#begin[]
  Plug 'mbpowers/nvimager'
call plug#end[]
```

3. Add keybinding in `vimrc`.

`nmap <leader>qq <Plug>NvimagerToggle`

4. Restart nvim, and run `:PlugInstall`.
</details>

## Usage

Nvimager matches text in the buffer to the following patterns:
<details>
  <summary>Dynamic Previews</summary>

`[name](file:path)` or `$ equation $`

- Height is determined by number empty lines below (excluding line with EOF).
- Width is the width of the terminal.
- Will update on the fly on BufTextChanged.

</details>

<details>
  <summary>Static Previews</summary>

`[name](file:path)<!--widthxheight-->` or ***TODO*** ~`$ equation $<!--widthxheight-->`~

- Width and height are measured in terminal cells.
- The html comment `<!--comment-->` is allowed either two or three hyphens per side.
- On creation a static image will insert filler text, consisting of full block characters, "█", in exactly the cells of the preview.
- ***Do not delete filler text!*** Filler text will be deleted upon BufWrite, deletion of the link pattern, or when nvimager is toggled off.
- Filler text is removed `PreBufWrite` and replaced `PostBufWrite`, so you don't have to toggle to avoid writing filler lines to your file.
- ***Do not have multiple static previews on one line!***
- Must toggle nvimager to update size.

</details>

<details>
  <summary>Block Previews</summary>

- ***TODO***

</details>

![example](https://user-images.githubusercontent.com/45055485/162593883-2962d821-6566-476c-9ceb-d62ac4c4217b.gif)

## Configuration

<details>
  <summary>Options</summary>

You can set these in your `init.vim`:

| option                  | default       | description                                        |
|-------------------------|---------------|----------------------------------------------------|
| nvimager#autostart      | 0             | start on BufEnter?                                 |
| nvimager#title          | 1             | print titles?                                      |
| nvimager#dynamic_scaler | 'fit_contain' | see [Üeberzug](https://github.com/seebye/ueberzug) |
| nvimager#static_scaler  | 'forced_cover'| see [Üeberzug](https://github.com/seebye/ueberzug) |


```vim
let g:nvimager#autostart = 0
let g:nvimager#title = 1
let g:nvimager#dynamic_scaler = 'fit_contain'
let g:nvimager#static_scaler = 'forced_cover'
  ```

</details>

## Acknowledgements

<details>
  <summary>Scripts</summary>

[vimg](https://github.com/nvim-telescope/telescope-media-files.nvim/blob/master/scripts/vimg)

[animated_thumbnail_gen.sh](https://gist.github.com/Voldrix/84a01b602e5d6c53c2b67e156bf26a10)

[neovim-plugins-in-lua](https://dev.to/2nit/how-to-write-neovim-plugins-in-lua-5cca)

</details>

## Maintainers

[@mbpowers](https://github.com/mbpowers)

## Contributing

PRs, issues and feature suggestion welcomed.

If editing the README, please conform to the [standard-readme](https://github.com/RichardLitt/standard-readme) specification.

## License

MIT © 2022 mbpowers
