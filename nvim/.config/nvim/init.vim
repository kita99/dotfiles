set nocompatible              " be iMproved, required

set encoding=UTF-8
filetype plugin indent on
filetype on                  " required


call plug#begin('~/.config/nvim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'unblevable/quick-scope'
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-startify'
Plug 'junegunn/fzf.vim'
Plug 'stsewd/fzf-checkout.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline-themes'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdtree'
Plug 'vim-syntastic/syntastic'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'lilydjwg/colorizer'
call plug#end()            " required
"
" Brief help
" :PlugList       - lists configured plugins
" :PlugInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PlugClean      - confirms removal of unused plugins; append `!` to auto-approve removal

let mapleader = ','

" Useful mappings
nmap <F1> :NERDTreeToggle <CR>
nmap <C-h> :bp<CR>
nmap <C-l> :bn<CR>
nmap <C-x> :Bclose<CR>
nmap <C-p> :Files<CR>
nnoremap <CR> :noh<CR><CR>


" Aesthetic
syntax enable
set number

colorscheme solarized
set background=dark
let g:solarized_termcolors=16

let g:airline_theme='murmur'
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

highlight SignColumn guibg=black ctermbg=black
highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline


" Misc
set autoindent
set mouse=a
set nowrap           " do not automatically wrap on load
set formatoptions-=t " do not automatically wrap text when typing

let g:NERDTreeIgnore = ['^__pycache__$']
let g:NERDTreeGitStatusWithFlags = 1
let g:python3_host_prog = '/usr/bin/python'
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

" CoC configs
source $HOME/.config/nvim/coc.vim

if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif
