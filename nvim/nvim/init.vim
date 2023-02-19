" ------------------------------ PLUGINS ------------------------------
lua require('config.plug')
" ---------------------------------------------------------------------

" ------------------------------ GENERAL ------------------------------
set mouse=a                                                           "Enable mouse
set backspace=indent,eol,start                                        "Make backspace normal
set nocompatible                                                      "Disable vi compatibility. Because we're not in 1995
set tw=0                                                              "Disable automactic line wrapping
set list                                                              "Display whitespace characters
set listchars=tab:▸\ ,trail:~,extends:>,precedes:<,space:·            "Specify whitespace characters visualization
set noerrorbells                                                      "Disable beeping
set encoding=utf8                                                     "Encoding
set ffs=unix,dos                                                      "File formats that will be tried (in order) when vim reads and writes to a file
set splitbelow                                                        "Set preview window position to bottom of the page
set scrolloff=5                                                       "Show at least N lines above/below the cursor.
set hidden                                                            "Opening a new file when the current buffer has unsaved changes causes files to be hidden instead of closed
set undolevels=1000                                                   "Undo many times
set undofile                                                          "Undo across vim sessions
set noshowmode                                                        "Do not show message on last line when in Insert, Replace or Visual mode
set termguicolors                                                     "Enable TrueColor
set inccommand=nosplit                                                "Shows the effects of a command incrementally, as you type

if !has('nvim')
  set ttymouse=sgr                                                    "Make the mouse work even in columns beyond 223
endif

let mapleader=' '
let maplocalleader='\'

"Replace escape with jk
inoremap jk <esc>

"Convert current word to uppercase
inoremap <C-u> <esc>mzgUiw`za

command! WQ wq
command! Wq wq
command! W w
command! Q q

" restore file cursor position
autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   execute "normal! g`\"" |
    \ endif

" Increase the maximum amount of memory to use for pattern matching
set maxmempattern=2000

"show the changes after the last save
function! s:DiffWithSaved()
  let filetype=&ft
  diffthis
  vnew | r # | normal! 1Gdd
  diffthis
  exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction

com! DiffSaved call s:DiffWithSaved()

" Maximize current window
command Foc execute "winc | | winc _"
" Show all windows
command Unfoc execute "winc ="

" vimrc key mappings
nmap <silent> <leader>ve :edit ~/.config/nvim/init.vim<CR>
nmap <silent> <leader>vs :source ~/.config/nvim/init.vim<CR>

" Read *.pl files as prolog files
augroup ft_prolog
    au!
    au BufNewFile,BufRead *.pl set filetype=prolog
augroup END

" save on enter
nnoremap <silent> <expr> <cr> empty(&buftype) ? ':w<cr>' : '<cr>'

" search mappings
nnoremap <silent> <leader>ss :Telescope grep_string<cr>
nnoremap <leader>sr :Telescope live_grep<cr>

function! s:search_term_under_cursor()
  execute "Rg " expand("<cword>")
endfunction
nnoremap <leader>st :call <SID>search_term_under_cursor()<CR>

" autoremove trailing whitespace
autocmd BufWritePre * :%s/\s\+$//e

" shell-like navigation while in normal mode
inoremap <c-b> <c-\><c-o>h
inoremap <c-f> <c-\><c-o>l
" ---------------------------------------------------------------------

" ------------------------------ COLORS ------------------------------
"Enable syntax processing
syntax enable

" This colorscheme
colorscheme jellybeans

" ---------------------------------------------------------------------

" ------------------------------ SPACES & TABS -----------------------------
set tabstop=4               "Number of visual spaces per TAB
set softtabstop=4           "Number of spaces in tab when editing
set expandtab               "Tabs are spaces
set shiftwidth=4            "Indent with 2 spaces

autocmd Filetype yaml,json setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd Filetype ruby setlocal tabstop=2 softtabstop=2 shiftwidth=2
autocmd Filetype go setlocal tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab
" ---------------------------------------------------------------------

" ------------------------------ UI CONFIG ------------------------------
set number                              "Show line numbers
filetype indent on                      "Load filetype-specific indent files
set wildmenu                            "Visual autocomplete for command menu
set wildmode=longest,full               "Complete till longest common string && Complete the next full match
set lazyredraw                          "Redraw only when we need to.
set showmatch                           "Highlight matching [{()}]
set fillchars+=vert:│                   "Solid vertical split line
set cursorline                          "Highlight current line

set updatetime=500
augroup HLWord
    au!
    au CursorHold * silent! lua vim.lsp.buf.document_highlight()
    au CursorHoldI * silent! lua vim.lsp.buf.document_highlight()
    au CursorMoved * silent! lua vim.lsp.buf.clear_references()
augroup END

" diagnostic symbols
sign define DiagnosticSignError text=  linehl= texthl=DiagnosticSignError numhl=
sign define DiagnosticSignWarn text=  linehl= texthl=DiagnosticSignWarn numhl=
sign define DiagnosticSignInfo text=  linehl= texthl=DiagnosticSignInfo numhl=
sign define DiagnosticSignHint text=  linehl= texthl=DiagnosticSignHint numhl=

augroup CursorLine
    au!
    au VimEnter * setlocal cursorline
    au WinEnter * setlocal cursorline
    au BufWinEnter * setlocal cursorline
    au WinLeave * setlocal nocursorline
augroup END
" ---------------------------------------------------------------------

" ------------------------------ SEARCHING ------------------------------
set incsearch               "Incremental search
set hlsearch                "Highlight matches
set ignorecase              "Ignore case on search
set smartcase               "Override ignorecase if search contains caps
" ---------------------------------------------------------------------

" ------------------------ LUA MODULES SETUP --------------------------
" load LSP
" must be called *after* updating colorscheme, else errors aren't highlighted
lua require('config.lsp')
lua require('config.cmp')
" ---------------------------------------------------------------------

" ---------------------- LEFT MARGIN ----------------------------------
"  keep the left margin open always
set signcolumn=yes:1
" show diagnostics in preference to git modification symbols
let signify_priority=5
" ---------------------------------------------------------------------

" --------------------- COMPLETION ------------------------------------
set completeopt=menuone,noinsert,noselect
" inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
set shortmess+=c
" ---------------------------------------------------------------------

" ------------------------------ FOLDING ------------------------------
set foldenable
set foldexpr=nvim_treesitter#foldexpr()
set foldlevelstart=99
set foldmethod=expr
" ---------------------------------------------------------------------

" -------------------------- AUTO FORMAT ------------------------------
augroup AutoFormat
    autocmd!
    autocmd BufWritePre *.go lua vim.lsp.buf.format({timeout_ms=3000})
	autocmd BufWritePre *.json PrettierAsync
augroup END
" ---------------------------------------------------------------------

" ------------------------------ MOVEMENT ------------------------------
"Move vertically (down) by visual line
nnoremap j gj
"Move vertically (up) by visual line
nnoremap k gk

" ---------------------------------------------------------------------


" ------------------------------ SANE PASTING---------------------------
function! RestoreRegister()
  let @" = s:restore_reg
  return ''
endfunction

function! s:Repl()
    let s:restore_reg = @"
    return "p@=RestoreRegister()\<cr>"
endfunction

" NB: this supports "rp that replaces the selection by the contents of @r
xnoremap <silent> <expr> p <sid>Repl()
" ---------------------------------------------------------------------

" ------------------------------ CONTINUE INDENTING---------------------
xnoremap > >gv
xnoremap < <gv
" ---------------------------------------------------------------------

" =======================================================================================
" =============================== PLUGIN CONFIGURATIONS =================================
" =======================================================================================

" --------------------------------- NERDTree -------------------------------

function! NERDTreeToggleAndFind()
  if (exists('t:NERDTreeBufName') && bufwinnr(t:NERDTreeBufName) != -1)
    execute ':NERDTreeClose'
  else
    if (expand("%:t") != '')
        execute ':NERDTreeFind'
    else
        execute ':NERDTreeToggle'
    endif
  endif
endfunction

" Toggle NERDTree
nnoremap <C-n> :call NERDTreeToggleAndFind()<CR>
nnoremap <silent> \ :NERDTreeToggle<CR>
nnoremap <silent> \| :NERDTreeFind<cr>

" Single mouse click will open any node
let g:NERDTreeMouseMode=3

" Close vim if the only window left open is a NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Automatically delete the buffer of the file you just deleted with NerdTree
let NERDTreeAutoDeleteBuffer = 1

" Hide 'Press ? for help' and bookmarks
let NERDTreeMinimalUI = 1

" Expand directory symbols
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

" Unmap C-j and C-k from NERDTree.
" This breaks vim-tmux integration otherwise.
let g:NERDTreeMapJumpNextSibling = ''
let g:NERDTreeMapJumpPrevSibling = ''

" Do not show whitespace characters in NERDTree window
autocmd FileType nerdtree setlocal nolist

" Show hidden files
let NERDTreeShowHidden=1

" --------------------------------------------------------------------------

" --------------------------------- Lualine --------------------------------

" Show statusline
set laststatus=2

" --------------------------------------------------------------------------

" Toggle comment with ctrl + /
nmap <C-_> gc$
xmap <C-_> gc

" --------------------------------- Vim-Markdown-Preview --------------------------------

" Use Chrome
let vim_markdown_preview_browser='Google Chrome'

" Use github syntax
let vim_markdown_preview_github=1

" Leave Ctrl-P alone
let vim_markdown_preview_hotkey='<Leader>mp'

" --------------------------------------------------------------------------

" --------------------------- Cool Matching  -------------------------------
" Show number of matches in the command-line
let g:CoolTotalMatches = 1
" --------------------------------------------------------------------------

" --------------------------------- Shfmt  -------------------------------
" Use 2 spaces instead of tabs and indent switch cases
let g:shfmt_extra_args = '-i 2 -ci'
let g:shfmt_fmt_on_save = 1
" --------------------------------------------------------------------------

nnoremap <silent> <c-p> :lua require'telescope.builtin'.find_files {hidden= true}<cr>
nnoremap <silent> <leader>fo :Telescope buffers<cr>
nnoremap <silent> <leader>fm :Telescope oldfiles<cr>
nnoremap <silent> <leader>fa :A<cr>
nnoremap <silent> <leader>m `

" -------------------------------- Startify --------------------------------
let g:startify_custom_header = map(systemlist('fortune | cowsay -f $HOME/cows/eirini.cow'), '"               ". v:val')
let g:startify_change_to_dir = 0
let g:startify_change_to_vcs_root = 1
let g:startify_lists = [
                  \ { 'type': 'dir',       'header': [   'MRU ' . getcwd()] },
                  \ { 'type': 'files',     'header': [   'MRU']             },
                  \ { 'type': 'sessions',  'header': [   'Sessions']        },
                  \ { 'type': 'bookmarks', 'header': [   'Bookmarks']       },
                  \ { 'type': 'commands',  'header': [   'Commands']        },
                  \ ]
" --------------------------------------------------------------------------

" ------------------Toggle showing whitespaces------------------------------
nnoremap <F3> :set list!<CR>
" --------------------------------------------------------------------------

" ------------------Toggle showing outline view ----------------------------
nmap <F8> :TagbarToggle<CR>
" --------------------------------------------------------------------------
"
" ------------------ Testing -----------------------------------------------
if empty($TMUX)
  let g:test#strategy = 'neoterm'
else
  let g:test#strategy = 'vimux'
endif

"" We can customise tests requiring setup as below...
function! ScriptTestTransform(cmd) abort
  let l:command = a:cmd

  let l:commandTail = split(a:cmd)[-1]
  if &filetype == 'go'
    if filereadable('scripts/test')
      let l:command = 'scripts/test ' . l:commandTail
    end
  end

  return l:command
endfunction

let g:test#custom_transformations = {'scripttest': function('ScriptTestTransform')}
let g:test#transformation = 'scripttest'
nnoremap <silent> <leader>tt :TestNearest<cr>
nnoremap <silent> <leader>t. :TestLast<cr>
nnoremap <silent> <leader>tf :TestFile<cr>
nnoremap <silent> <leader>ts :TestSuite<cr>
nnoremap <silent> <leader>tg :TestVisit<cr>
" --------------------------------------------------------------------------
"
" -------------------------------- vim-rhubarb -----------------------------
" open in github
nmap <silent> <leader>gh :GBrowse<cr>
xmap <silent> <leader>gh :GBrowse<cr>
" --------------------------------------------------------------------------
"
set nolist


" --------------------- GO ALTERNATIVE FILE --------------------------------
" copied from https://github.com/fatih/vim-go

" Test alternates between the implementation of code and the test code.
function! GoAlternateSwitch(bang, cmd) abort
  let file = expand('%')
  if empty(file)
    echo "no buffer name"
    return
  elseif file =~# '^\f\+_test\.go$'
    let l:root = split(file, '_test.go$')[0]
    let l:alt_file = l:root . ".go"
  elseif file =~# '^\f\+\.go$'
    let l:root = split(file, ".go$")[0]
    let l:alt_file = l:root . '_test.go'
  else
    echo "not a go file"
    return
  endif
  if !filereadable(alt_file) && !bufexists(alt_file) && !a:bang
    echo "couldn't find ".alt_file
    return
  elseif empty(a:cmd)
    execute ":edit " .  alt_file
  else
    execute ":" . a:cmd . " " . alt_file
  endif
endfunction

command! -bang A  call GoAlternateSwitch(<bang>0, '')
command! -bang AS call GoAlternateSwitch(<bang>0, 'split')
command! -bang AV call GoAlternateSwitch(<bang>0, 'vsplit')
command! -bang AT call GoAlternateSwitch(<bang>0, 'tabe')

" --------------------------------------------------------------------------

" ----------------------- JSON / YAML TAGS ---------------------------------
" snakecase converts a string to snake case. i.e: FooBar -> foo_bar
" Copied from tpope/vim-abolish
" Used in go.snippets for json and yaml expansions
function! Snakecase(word) abort
  let word = substitute(a:word, '::', '/', 'g')
  let word = substitute(word, '\(\u\+\)\(\u\l\)', '\1_\2', 'g')
  let word = substitute(word, '\(\l\|\d\)\(\u\)', '\1_\2', 'g')
  let word = substitute(word, '[.-]', '_', 'g')
  let word = tolower(word)
  return word
endfunction
" --------------------------------------------------------------------------

" --------------------- :GoGenerate ----------------------------------------
" Copied and adapted from various places in vim-go
function SetGoCompilerOptions()
    setlocal errorformat =%-G#\ %.%#                                 " Ignore lines beginning with '#' ('# command-line-arguments' line sometimes appears?)
    setlocal errorformat+=%-G%.%#panic:\ %m                          " Ignore lines containing 'panic: message'
    setlocal errorformat+=%Ecan\'t\ load\ package:\ %m               " Start of multiline error string is 'can\'t load package'
    setlocal errorformat+=%A%\\%%(%[%^:]%\\+:\ %\\)%\\?%f:%l:%c:\ %m " Start of multiline unspecified string is 'filename:linenumber:columnnumber:'
    setlocal errorformat+=%A%\\%%(%[%^:]%\\+:\ %\\)%\\?%f:%l:\ %m    " Start of multiline unspecified string is 'filename:linenumber:'
    setlocal errorformat+=%C%*\\s%m                                  " Continuation of multiline error message is indented
    setlocal errorformat+=%-G%.%#                                    " All lines not matching any of the above patterns are ignored
endfunction

augroup GoGenerate
  autocmd!
  autocmd FileType go call SetGoCompilerOptions()
augroup END

function! RunInQFList(bang, cmd) abort
  let default_makeprg = &makeprg
  let &makeprg = a:cmd

  try
    silent! exe 'make!'
  finally
    redraw!
    let &makeprg = default_makeprg
  endtry

  let errors = getqflist()
  if !empty(errors)
      let height = 10
      if len(errors) < 10
          let height = len(errors)
      endif
      exe 'copen ' . height
    if !a:bang
        cc 1
    endif
  else
    cclose
  endif
endfunction

command! -bang GoGenerate call RunInQFList(<bang>0, "go generate " . shellescape(expand("%:p:h")))
command! -bang GolangCILint  call RunInQFList(<bang>0, "golangci-lint run")
nnoremap <leader>el :GolangCILint<CR>
" --------------------------------------------------------------------------
