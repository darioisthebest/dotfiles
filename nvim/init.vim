""--------------------------------------------------------------------------""
""                                     MYVIMRC                              ""
""--------------------------------------------------------------------------""

" My sets
set noswapfile
set noerrorbells

set tabstop=4
set shiftwidth=4
set smartindent
set expandtab

set nowrap
set number relativenumber
set foldcolumn=1
set noshowmode

set completeopt=menuone,noinsert,noselect

let mapleader=" "
set guicursor=

" Plugins
call plug#begin()
    " Web dev
    Plug 'mattn/emmet-vim'
    Plug 'ap/vim-css-color'
    Plug 'alvan/vim-closetag'

    " Writing code faster
    Plug 'jiangmiao/auto-pairs'
    Plug 'tpope/vim-commentary'
    Plug 'tpope/vim-surround'

    " Tmux
    Plug 'edkolev/tmuxline.vim'

    " Autocompletition
    Plug 'nvim-lua/completion-nvim'

    " Code Formatting
    Plug 'sbdchd/neoformat'

    " Telescope
    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'

    " Multi cursor
    Plug 'terryma/vim-multiple-cursors'

    " Syntax highlighting
    Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
    Plug 'nvim-treesitter/playground'
    Plug 'sheerun/vim-polyglot'

    " Neovim LSP
    Plug 'neovim/nvim-lspconfig'

    " Better UI
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'Yggdroot/indentLine'

    " Git integration
    Plug 'tpope/vim-fugitive'
    Plug 'airblade/vim-gitgutter'

    " Color Schemes
    Plug 'chriskempson/base16-vim'
call plug#end()

" Key Bindings
nnoremap <silent> <C-l> :bnext<CR>
nnoremap <silent> <C-h> :bprevious<CR>

nnoremap <silent> <leader>ir :echo "Reloaded init.vim"<CR>:source $MYVIMRC<CR>

nnoremap <silent> <leader>xh :nohl<CR>


nnoremap <silent> <leader>c :Commentary<CR>
vnoremap <silent> <leader>c :Commentary<CR>
nnoremap <silent> <leader>g :Git<CR>
nnoremap <silent> <leader>gp :Git push<CR>

nnoremap <silent> gd :lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD :lua vim.lsp.buf.declaration()<CR>

nnoremap <silent> <leader>ft :retab<CR>

nnoremap <silent> <C-p> :Telescope find_files<CR>
nnoremap <silent> <leader>p :Telescope live_grep<CR>

nnoremap <M-k> :resize +2<CR>
nnoremap <M-j> :resize -2<CR>
nnoremap <M-l> :vertical resize +2<CR>
nnoremap <M-h> :vertical resize -2<CR>

" Airline
let g:airline_powerline_fonts=1
let g:airline#extensions#whitespace#enabled=1
let g:airline#extensions#tabline#enabled=0

" Color Schemes
let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors

colorscheme base16-default-dark

hi Comment cterm=italic gui=italic

" Neovim LSP
lua << EOF
-- TypeScript
require'lspconfig'.tsserver.setup{}
-- Vim
require'lspconfig'.vimls.setup{}
-- C/C++
require'lspconfig'.clangd.setup{}
EOF

" Indent line
let g:indentLine_setColors = 0
let g:indentLine_char = '┊'
let g:indentLine_color_term = 202

" Auto close tag
let g:closetag_filenames = '*.xml,*.html,*.xhtml,*.phtml,*.php'
filetype plugin indent on

" Emmet
let g:user_emmet_expandabbr_key='<C-z>'
let g:user_emmet_install_global = 0

fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

" Autocommands
augroup DARIO_GROUP
    " Remove all autocommands
    autocmd!

    " Enable emmet
    autocmd FileType html,css EmmetInstall

    " Trim spaces
    autocmd BufWritePre * :call TrimWhitespace()

    " Formatting
    autocmd BufWritePre *.js Neoformat
    autocmd BufWritePre *.ts Neoformat
    autocmd BufWritePre *.html Neoformat
    autocmd BufWritePre *.css Neoformat

    " Better syntax highlighting
    autocmd BufWritePre *.js TSBufEnable javascript
    autocmd BufWritePre *.ts TSBufEnable typescript
    autocmd BufWritePre *.json TSBufEnable json

    " Autocompletition
    autocmd BufEnter * lua require'completion'.on_attach()

    " xml/html autoclose tag
    autocmd StdinReadPre * let s:std_in=1
augroup END
