set nocompatible

" set hybrid line numbers
set number relativenumber

" all tab and indentation settings
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
filetype indent plugin on

" auto read when file is updated
set autoread

" fix backspace issues
set backspace=indent,eol,start

" show previous command
set showcmd

" show taller command mode
set cmdheight=2

" show cursor position
set ruler

"show matching braces
set showmatch

syntax enable

" mouse input everywhere
set mouse=a

" search goodness & resetting
set ignorecase
set smartcase

set incsearch
set hlsearch
nnoremap <silent> <C-l> :nohl<CR><C-l>

" Map Y to act like D and C, i.e. to yank until EOL, rather than act as yy,
" which is the default
map Y y$

" Show status bar
set laststatus=2

" unset annoying noises/flashes
set noerrorbells
set novisualbell
set t_vb=
set tm=500
