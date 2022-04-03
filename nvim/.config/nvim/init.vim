set nocompatible              " be iMproved, required

set encoding=UTF-8
filetype plugin indent on
filetype on                  " required


call plug#begin('~/.config/nvim/plugged')
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'unblevable/quick-scope'
Plug 'tpope/vim-fugitive'
Plug 'mhinz/vim-startify'
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make', 'branch': 'main' }
Plug 'altercation/vim-colors-solarized'
Plug 'vim-airline/vim-airline'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline-themes'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'lilydjwg/colorizer'
Plug 'wellle/targets.vim'
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
nmap <C-p> :Telescope find_files<CR>
nnoremap <C-f> :Telescope live_grep<CR>
nnoremap <C-b> :Telescope git_branches<CR>
nnoremap <CR> :noh<CR><CR>


" Aesthetic
syntax enable
set number

let g:solarized_termcolors=16
let g:solarized_contrast = "normal"
colorscheme solarized
set background=dark

let g:airline_theme='murmur'
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1

highlight SignColumn guibg=black ctermbg=black
highlight QuickScopePrimary guifg='#afff5f' gui=underline ctermfg=155 cterm=underline
highlight QuickScopeSecondary guifg='#5fffff' gui=underline ctermfg=81 cterm=underline

highlight FgCocErrorFloatBgCocFloating ctermfg=darkred ctermbg=white


" Misc
set autoindent
set mouse=a
set nowrap           " do not automatically wrap on load
set formatoptions-=t " do not automatically wrap text when typing
set undofile " Maintain undo history between sessions
set undodir=~/.config/nvim/undodir


let g:NERDTreeIgnore = ['^__pycache__$']
let g:NERDTreeGitStatusWithFlags = 1
let g:python3_host_prog = '/usr/bin/python'
let g:qs_highlight_on_keys = ['f', 'F', 't', 'T']

let &t_ti = &t_ti . "\033]10;#f6f3e8\007\033]11;#242424\007"
let &t_te = &t_te . "\033]110\007\033]111\007"

" Telescope
lua << EOF
require('telescope').setup {
  extensions = {
    fzf = {
      override_generic_sorter = false, -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
}
-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
require('telescope').load_extension('fzf')
EOF

" CoC configs
source $HOME/.config/nvim/coc.vim

if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif
