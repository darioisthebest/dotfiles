" Global
set guicursor=
set termguicolors
set completeopt=menuone,noinsert,noselect
set updatetime=100
set timeoutlen=300
set noshowmode

" Local to window
set number relativenumber
set nowrap

" Local to buffer
set tabstop=4
set shiftwidth=4
set noswapfile
set expandtab

let mapleader=" "
let g:colorscheme="solarized"
let g:italic=1

call plug#begin()
    " Telescope
    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'

    " LSP & Completition
    Plug 'neovim/nvim-lspconfig'
    Plug 'nvim-lua/completion-nvim'
    Plug 'glepnir/lspsaga.nvim'

    " Surrounding utils
    Plug 'tpope/vim-surround'
    Plug 'jiangmiao/auto-pairs'
    Plug 'alvan/vim-closetag'

    " VimWiki
    Plug 'vimwiki/vimwiki'

    " WebDev
    Plug 'ap/vim-css-color'

    " Git
    Plug 'tpope/vim-fugitive'
    Plug 'airblade/vim-gitgutter'

    " Comment line
    Plug 'tpope/vim-commentary'

    " Tmux
    Plug 'preservim/vimux'

    " Polyglot (Better syntax highlighting)
    Plug 'sheerun/vim-polyglot'

    " Colorscheme
    Plug 'joshdick/onedark.vim'
    Plug 'chriskempson/base16-vim'
    Plug 'fcpg/vim-fahrenheit'

    " Formatting
    Plug 'sbdchd/neoformat'
call plug#end()

" LSP
lua <<EOF
local lspconfig = require('lspconfig')
local completion = require('completion')

local lsp_servers = {"vimls", "clangd", "phpactor", "tsserver", "pyright"}

for index, server in ipairs(lsp_servers) do
    lspconfig[server].setup{
        on_attach=completion.on_attach
    }
end
EOF

" LSP Saga
lua <<EOF
local saga = require("lspsaga")

saga.init_lsp_saga {
    debug = false,
    use_saga_diagnostic_sign = true,
    -- diagnostic sign
    error_sign = 'E',
    warn_sign = 'W',
    hint_sign = 'W',
    infor_sign = 'W',
    dianostic_header_icon = ' D  ',
    -- code action title icon
    code_action_icon = 'C ',
    code_action_prompt = {
        enable = true,
        sign = true,
        sign_priority = 40,
        virtual_text = true,
    },
    finder_definition_icon = 'F  ',
    finder_reference_icon = 'R  ',
    max_preview_lines = 10,
    finder_action_keys = {
        open = 'o', vsplit = 's',split = 'i',quit = 'q',
        scroll_down = '<C-f>',
        scroll_up = '<C-b>'
    },
    code_action_keys = {
        quit = 'q',exec = '<CR>'
    },
    rename_action_keys = {
        quit = '<C-c>',exec = '<CR>'
    },
    definition_preview_icon = 'P  ',
    border_style = "plus",
    rename_prompt_prefix = 'R',
    server_filetype_map = {}
}
EOF

" Colorscheme

function SetColorscheme(italic, colorscheme)
    if a:italic == 1
        let g:nord_italic = 1
        let g:nord_italic_comments = 1
        let g:onedark_terminal_italics = 1
        hi Comment cterm=italic gui=italic
    endif

    if a:colorscheme == "gruvbox"
        colorscheme base16-gruvbox-dark-hard
    elseif a:colorscheme == "base16"
        colorscheme base16-default-dark
    elseif a:colorscheme == "nord"
        colorscheme nord
    elseif a:colorscheme == "onedark"
        let g:onedark_color_overrides = {
            \ "black": {"gui": "#000000", "cterm": "0", "cterm16": "0" }
            \ }
        colorscheme onedark
        hi! StatusLine ctermfg=145 ctermbg=0 guifg=#ABB2BF guibg=#000000
    elseif a:colorscheme == "dark"
        colorscheme fahrenheit
    elseif a:colorscheme == "solarized"
        colorscheme solarized
    endif
endfunction

call SetColorscheme(1, "solarized")


" Git gutter
let g:gitgutter_map_keys = 0

" Statusline
let g:currentmode = {
    \ '__'     : '-',
    \ 'c'      : 'C',
    \ 'i'      : 'I',
    \ 'ic'     : 'I',
    \ 'ix'     : 'I',
    \ 'n'      : 'N',
    \ 'multi'  : 'M',
    \ 'ni'     : 'N',
    \ 'no'     : 'N',
    \ 'R'      : 'R',
    \ 'Rv'     : 'R',
    \ 's'      : 'S',
    \ 'S'      : 'S',
    \ ''     : 'S',
    \ 't'      : 'T',
    \ 'v'      : 'V',
    \ 'V'      : 'V',
    \ ''     : 'V',
    \ }

" Tabline
function BufList()
  let all = range(0, bufnr('$'))
  let res = []
  for b in all
    if buflisted(b)
      call add(res, bufname(b))
    endif
  endfor
  return res
endfunction

function TabLine()
    let bufs_string = ""
    let bufs = BufList()

    for name in bufs
        let bufs_string = bufs_string . name . " "
    endfor

    return bufs_string
endfunction

augroup TABLINE
    autocmd BufWritePre,BufEnter * set tabline=%{TabLine()}
augroup END

set statusline=%{toupper(g:currentmode[mode()])}\ %#Todo#%F%h\ %#Type#%{fugitive#statusline()}\ %=\ W\ %{LSPWarnings()}\ E\ %{LSPErrors()}\ %#Function#LN\ %l\/%L\ %#Number#C\ %c%V\ %#Indentifier#\%m%r%h%w%y

" Functions
fun! TrimSpace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

fun TmuxGitPush()
    VimuxRunCommand "clear; git push; exit"
endfun

fun TmuxMake(command)
    VimuxRunCommand "clear; make " . a:command . "; read -p \"Program finished with $?, Press enter to continue...\" && exit"
endfun

fun LSPErrors()
    let errs = luaeval('vim.lsp.diagnostic.get_count(0, "Error")')
    return errs
endfun

fun LSPWarnings()
    let errs = luaeval('vim.lsp.diagnostic.get_count(0, "Warning")')
    return errs
endfun

fun BufferAdd()
    let buffer = input("Buffer to add => ")
    if buffer == ""
        return 0
    else
        exec "badd " . buffer
        bnext
    endif
endfunction

" Mappings
nnoremap <silent> <leader>c :Commentary<CR>
vnoremap <silent> <leader>c :Commentary<CR>

nnoremap <silent> <leader>ir :source $MYVIMRC<CR>
nnoremap <silent> <leader>ie :edit $MYVIMRC<CR>

nnoremap <silent> <leader>pi :PlugInstall<CR>
nnoremap <silent> <leader>pc :PlugClean<CR>
nnoremap <silent> <leader>pu :PlugUpdate<CR>
nnoremap <silent> <leader>pU :PlugUpgrade<CR>

nnoremap <silent> <leader>gg :Git<CR>
nnoremap <silent> <leader>gp :term git push<CR>
nnoremap <silent> <leader>gb :Git blame<CR>

nnoremap <silent> <leader>ghn :GitGutterNextHunk<CR>
nnoremap <silent> <leader>ghN :GitGutterPrevHunk<CR>
nnoremap <silent> <leader>ghp :GitGutterPreviewHunk<CR>
nnoremap <silent> <leader>ghs :GitGutterStageHunk<CR>
nnoremap <silent> <leader>ghu :GitGutterUndoHunk<CR>

nnoremap <silent> <leader>mi :call TmuxMake("install")<CR>
nnoremap <silent> <leader>mt :call TmuxMake("test")<CR>
nnoremap <silent> <leader>mc :call TmuxMake("clean")<CR>
nnoremap <silent> <leader>mm :call TmuxMake("")<CR>

nnoremap <silent> <leader>ll :Lspsaga show_line_diagnostics<CR>
nnoremap <silent> <leader>ld :lua vim.lsp.buf.definition()<CR>
nnoremap <silent> <leader>lc :Lspsaga code_actions<CR>
nnoremap <silent> <leader>ln :Lspsaga diagnostics_jump_next<CR>
nnoremap <silent> <leader>lN :Lspsaga diagnostics_jump_prev<CR>

nnoremap <silent> <leader>tf :Telescope find_files<CR>
nnoremap <silent> <C-p> :Telescope find_files<CR>
nnoremap <silent> <leader>tg :Telescope git_files<CR>

nnoremap <silent> <leader>bd :bd<CR>
nnoremap <silent> <leader>ba :call BufferAdd()<CR>
nnoremap <silent> <C-h> :bprev<CR>
nnoremap <silent> <C-l> :bnext<CR>

nnoremap <silent> <leader>t :term<CR>

tnoremap <silent> <Esc> <C-\><C-n>

" Auto commands
augroup DARIO_GROUP
    autocmd!
    autocmd BufWrite,BufWritePre * :call TrimSpace()
    autocmd BufWrite,BufWritePre * :retab
augroup END

augroup FORMATTER
    " autocmd BufWritePre *.js silent! Neoformat
    " autocmd BufWritePre *.ts silent! Neoformat
    " autocmd BufWritePre *.html silent! Neoformat
    " autocmd BufWritePre *.css silent! Neoformat
    autocmd BufWritePre *.c silent! Neoformat
    autocmd BufWritePre *.h silent! Neoformat
augroup END
