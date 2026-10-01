" Fallback for machines without Neovim: mirrors ~/.config/nvim (options and
" core keymaps) using only what ships with Vim 9.1 — no plugin manager.

let mapleader = " "

" === System ===
set autoread                   " reload files changed outside Vim
set lazyredraw
set noswapfile
set updatetime=250
set confirm
set undofile                   " keep undo history in ~/.vim/undo, not next to files
let s:undodir = expand("~/.vim/undo")
if !isdirectory(s:undodir)
  call mkdir(s:undodir, "p")
endif
let &undodir = s:undodir

" === Line numbers ===
set number
set relativenumber

" === Scrolling and tabs ===
set scrolloff=5
set expandtab
set shiftwidth=2
set tabstop=2
set softtabstop=2
set autoindent
set smartindent
set colorcolumn=80
set nowrap

" === UI ===
set termguicolors
set background=dark
silent! colorscheme habamax    " closest bundled scheme to catppuccin-mocha
set cursorline
set signcolumn=yes
set laststatus=2               " Vim has no global statusline (Neovim's 3)
set showcmd
set list
set listchars=eol:↲,tab:»\ ,space:.,nbsp:␣
set fillchars=vert:┃
set wildmenu
set wildoptions=pum

" === Search ===
set hlsearch
set incsearch
set ignorecase
set smartcase
if executable("rg")
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden\ --glob\ '!.git/*'
  set grepformat=%f:%l:%c:%m
endif

" === Backspace, clipboard, mouse ===
set backspace=indent,eol,start
if has("clipboard")
  set clipboard=unnamed,unnamedplus
endif
set mouse=a

" === Window splitting ===
set splitright
set splitbelow
silent! set splitkeep=screen

" === Spelling ===
set spell
set spelllang=en              " all English regions, like Neovim's "en_us,en"

syntax enable
filetype plugin indent on

" === Built-in packages (Vim 9.1) ===
silent! packadd comment        " gc / gcc, like Neovim's built-in commenting
silent! packadd hlyank         " highlight yanked text
let g:hlyank_duration = 200
silent! packadd nohlsearch     " clear search highlight after moving (Neovim: <Esc>)

" fzf ships a minimal :FZF command with the binary (Homebrew or apt)
for s:fzf_dir in ["/opt/homebrew/opt/fzf", "/usr/local/opt/fzf", "/usr/share/doc/fzf/examples"]
  if isdirectory(s:fzf_dir)
    execute "set runtimepath+=" . s:fzf_dir
    break
  endif
endfor

" === Keymaps (same as lua/keymaps.lua) ===
" Tabs (prev/next: built-in gT / gt)
nnoremap <silent> <leader>tn <Cmd>tabnew<CR>
nnoremap <silent> <leader>tq <Cmd>tabclose<CR>

" Windows
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Resize (Alt needs a terminal that reports it, e.g. WezTerm)
nnoremap <silent> <M-Up> <Cmd>resize +2<CR>
nnoremap <silent> <M-Down> <Cmd>resize -2<CR>
nnoremap <silent> <M-Left> <Cmd>vertical resize -2<CR>
nnoremap <silent> <M-Right> <Cmd>vertical resize +2<CR>

" Scroll + center
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz

" Search: keep centered
nnoremap <expr> n 'Nn'[v:searchforward] . 'zzzv'
nnoremap <expr> N 'nN'[v:searchforward] . 'zzzv'

" Edit (move lines / indent)
xnoremap <silent> <M-j> :m '>+1<CR>gv=gv
xnoremap <silent> <M-k> :m '<-2<CR>gv=gv
xnoremap < <gv
xnoremap > >gv

" Files: "-" opens the parent directory (Neovim: oil.nvim)
nnoremap <silent> - <Cmd>Explore<CR>

" Find (Neovim: fzf-lua)
nnoremap <silent> <leader>ff <Cmd>FZF<CR>
nnoremap <leader>fg :silent grep!<Space>
nnoremap <silent> <leader>fc <Cmd>silent grep! <cword> <Bar> copen<CR>
nnoremap <leader>fb :ls<CR>:buffer<Space>

" Quickfix
function! s:QuickfixToggle() abort
  if getqflist({"winid": 0}).winid != 0
    cclose
  else
    copen
  endif
endfunction

function! s:QuickfixRename() abort
  let l:title = input("QF title: ", getqflist({"title": 1}).title)
  if l:title !=# ""
    call setqflist([], "a", {"title": l:title})
  endif
endfunction

nnoremap <silent> <leader>qq <Cmd>call <SID>QuickfixToggle()<CR>
nnoremap <silent> <leader>qb <Cmd>colder<CR><Cmd>copen<CR>
nnoremap <silent> <leader>qf <Cmd>cnewer<CR><Cmd>copen<CR>
nnoremap <silent> <leader>qt <Cmd>call setqflist([], "a", {"title": "REF: " . expand("<cword>")})<CR>
nnoremap <silent> <leader>qr <Cmd>call <SID>QuickfixRename()<CR>
