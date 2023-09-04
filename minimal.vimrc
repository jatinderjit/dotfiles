set nocompatible

" let g:python3_host_prog=$PYENV_ROOT.'/versions/generic/bin/python'
let g:python3_host_prog='/opt/pyenv/versions/generic/bin/python'
let g:loaded_ruby_provider = 0
let g:loaded_node_provider = 0
let g:loaded_perl_provider = 0

" unmanaged plugins {{{
" SearchComplete.vim  http://www.vim.org/scripts/script.php?script_id=474
runtime macros/matchit.vim  " 3  for jumping between tags with %
" }}}

" General {{{
" With a map leader it's possible to do extra key combinations
let mapleader = "\\"
let g:mapleader = "\\"
set tm=1000                                   " Set leader key timeout
nnoremap <leader>w :w!<cr>                    " Fast saving
nnoremap <leader>q :q<cr>                     " Fast quit
" nnoremap <leader>c :bdelete<CR>               " Close buffer and quit window
nnoremap <leader>c :Bdelete<CR>               " Close buffer and maintain window
nnoremap <leader>x :x<cr>                     " Fast save & quit
set noerrorbells                              " No annoying sound on errors
set vb t_vb=                                  " No annoying sound on errors
set backspace=indent,eol,start                " allow backspacing over everything in insert mode
set autoindent                                " always set autoindenting on
set copyindent                                " copy the previous indentation on autoindenting
set smartindent
set shiftwidth=4                              " number of spaces to use for autoindenting
set expandtab                                 " use appropriate number of spaces when tabbing
set tabstop=4                                 " a tab is four spaces
set shiftround                                " use multiple of shiftwidth when indenting with '<' and '>'
set showmatch                                 " set show matching parenthesis
set mat=2                                     " How many tenths of a second to blink when matching brackets
set ignorecase                                " ignore case when searching
set smartcase                                 " ignore case if search pattern is all lowercase, case-sensitive otherwise
set smarttab                                  " insert tabs on the start of a line according to shiftwidth, not tabstop
set hlsearch                                  " highlight search terms
set incsearch                                 " show search matches as you type
set history=1000                              " remember more commands and search history
set undolevels=1000                           " use many muchos levels of undo
set wildignore=*.swp,*.bak,*.pyc,*.class,*.o
" set autoread                                  " Set to auto read when a file is changed from the outside
set title                                     " change the terminal's title
set ruler                                     " show the cursor position all the time
set pastetoggle=<F2>                          " toggle paste mode
set magic                                     " For regular expressions turn magic on
set lazyredraw                                " Don't redraw while executing macros (good performance config)
set so=7                                      " ScrollOff - set 7 lines to the cursor - when moving vertically using j/k
set colorcolumn=80                            " Highlight column 81 to help keep lines of code 80 characters or less
" set cursorline                                " Highlight current line
set mouse=a
set number
nmap <f3> :set number! number?<cr>            " toggle showing line numbers
set list
set listchars=tab:>\ ,trail:-,extends:#,precedes:<,nbsp:+ " highlight whitespace
noremap <silent> <leader>= :nohlsearch <CR>      " unhighlight search
set viminfo='20,\"50
                  " Tell vim to remember certain things when we exit
"set autochdir    " automatically changes directory to file in buffer

" Completion
set wildmenu
set wildmode=list:longest,full

"save files if you forgot to sudo
cmap w!! %!sudo tee > /dev/null %

" Font ligatures
" set macligatures
set guifont=Fira\ Code:h12

" }}}

" {{{ Folds and wraps

set foldmethod=indent  " Use indentation for folds
set foldnestmax=5      " Deepest fold level
set foldlevelstart=99
set foldcolumn=0
" set foldlevel=1
" set nofoldenable    " dont fold by default

augroup vimrcFold
  " fold vimrc itself by categories
  autocmd!
  autocmd FileType vim set foldmethod=marker
  autocmd FileType vim set foldlevel=0
augroup END

" Wrap text at 80 characters. To wrap existing lines: `gq`
autocmd BufRead,BufNewFile *.md setlocal textwidth=80

" }}}

" Files, backups and undo {{{

" Turn backup off, since most stuff is in git etc anyway...
set nobackup
set nowritebackup
set nowb
set noswapfile
" store backup and swp files in these dirs to not clutter working dir
set backupdir=~/.vim/backup
set directory=~/.vim/tmp

" restore undo/redo tree
" set undofile
" set undodir=~/.vim/undodir

" }}}

" Open file prompt with current path
nmap <leader>e :e <C-R>=expand("%:p:h") . '/'<CR>
" Location List
nmap <Leader>n :lnext<CR>
" nmap <Leader>p :lprevious<CR>

" make < > shifts keep selection
vnoremap < <gv
vnoremap > >gv

" replace within selection only
vnoremap :s :s/\%V

" Ctrl+V (block select) is hijacked by windows terminal for paste
nnoremap cv <C-v>

" Panic Button
nnoremap <f9> mZggg?G`Z

" Keep the cursor in place while joining lines
" nnoremap J mZJ`Z
inoremap jk <ESC>

" Select (charwise) the contents of the current line, excluding indentation.
nnoremap vv ^vg_

" Heresy
inoremap <c-a> <esc>I
inoremap <c-e> <esc>A

" Insert blank line before/after cursor
nnoremap [<space> mXO<ESC>`X
nnoremap ]<space> mXo<ESC>`X

" gi already moves to 'last place you exited insert mode', so we'll map gI to
" something similar: move to last change
nnoremap gI `.

" Cut/Copy/Paste from last copy/selection in/out of vim
" inoremap <C-v> <ESC>mXo<ESC>mYk"+P'YddmY
nnoremap <leader>y "+y
nnoremap <leader>Y "+Y
nnoremap <leader>d "+d
nnoremap <leader>D "+D
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>y "+y
vnoremap <leader>Y "+Y
vnoremap <leader>d "+d
vnoremap <leader>D "+D

" Easy window navigation
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Navigating in wrapped lines
:nnoremap j gj
:vnoremap j gj
:nnoremap k gk
:vnoremap k gk
:nnoremap <C-j> j
:nnoremap <C-k> k
:vnoremap <C-j> j
:vnoremap <C-k> k

" Buffer Navigation
nnoremap <c-j> :bp<CR>
nnoremap <c-k> :bn<CR>
nmap <leader>i <c-p><CR>    " Go to previous tab (using CtrlP)

"fix syntax highlighting for long files
autocmd BufEnter * :syntax sync minlines=200

"show current command in bottom line
set showcmd
set cmdheight=2
set laststatus=2

" Search mappings: These will make it so that going to the next one in a
" search will center on the line it's found in.
nmap N Nzz
nmap n nzz

set grepprg=grep\ -nH\ $*


" Python {{{
autocmd Filetype python nmap <c-f10> o.frontend.terminal.embed import InteractiveShellEmbed<ESC>Ifrom IPython<ESC>oInteractiveShellEmbed()()<ESC>
autocmd Filetype python nmap <f10> o.set_trace()<ESC>Iipdb<ESC>Iipdb; <ESC>Iimport <ESC>
autocmd Filetype python setlocal colorcolumn=80
" autocmd BufWritePost *.py !autopep8 -i expand("%")
" au FileType python setlocal formatprg=autopep8\ -
" }}}
"
" Ruby {{{
autocmd FileType ruby setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType eruby setlocal expandtab shiftwidth=2 tabstop=2
" }}}

" Clisp {{{
autocmd Filetype lisp setlocal ts=2 sts=2 sw=2
" }}}

" asciidoctor {{{
autocmd Filetype asciidoctor setlocal spell spelllang=en_gb
autocmd Filetype asciidoctor setlocal colorcolumn=80
autocmd Filetype asciidoc setlocal spell spelllang=en_gb
autocmd Filetype asciidoc setlocal colorcolumn=80
" }}}

" Errors (for error type quickfix)
map <C-n> :cnext<CR>
map <C-m> :cprevious<CR>
" nnoremap <leader>a :cclose<CR>

" Elm {{{
" autocmd Filetype elm nnoremap <leader>el :ElmEvalLine<CR>
" autocmd Filetype elm vnoremap <leader>es :<C-u>ElmEvalSelection<CR>
" autocmd Filetype elm nnoremap <leader>em :ElmMakeCurrentFile<CR>
" :au BufWritePost *.elm ElmMakeCurrentFile         " Compile current file on write
" }}}

" Javascript {{{
"autocmd Filetype javascript setlocal ts=2 sts=2 sw=2
" }}}

if has("autocmd")
  " When editing a file, always jump to the last cursor position
  autocmd BufReadPost *
  \ if line("'\"") > 0 && line ("'\"") <= line("$") |
  \   exe "normal! g'\"" |
  \ endif
endif

" Use system clipboard (only works if compiled with +x)
" set clipboard=unnamed


" Colors and Fonts {{{

" set t_Co=256
set background=dark
let g:one_allow_italics = 1  " For colorscheme one
" }}}

" Don't blink normal mode cursor
set guicursor=n-v-c:block-Cursor
set guicursor+=n-v-c:blinkon0

" Change cursor shape between insert and normal mode in iTerm2.app
if $TERM_PROGRAM =~ "iTerm"
  let &t_SI = "\<Esc>]50;CursorShape=1\x7" " Vertical bar in insert mode
  let &t_EI = "\<Esc>]50;CursorShape=0\x7" " Block in normal mode
endif

" Set utf8 as standard encoding and en_US as the standard language
if !has('nvim')
  " Only set this for vim, since neovim is utf8 as default and setting it
  " causes problems when reloading the .vimrc configuration
  set encoding=utf8
endif

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Use large font by default in MacVim
set gfn=Monaco:h19

" }}}

" Spell check {{{

" Pressing <leader>ss will toggle and untoggle spell checking
map <leader>ss :setlocal spell!<cr>

" Guide:
" set language: set spell spelllang=en_gb
" movement: ]s or [s
" spelling options: z=
" add to dictionary: zg

" Spell check }}}

syn match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" Filetype Templates
autocmd BufNewFile *.c 0r ~/.vim/filetype-templates/skeleton.c
autocmd BufNewFile *.cpp 0r ~/.vim/filetype-templates/skeleton.cpp
autocmd BufNewFile *.tex 0r ~/.vim/filetype-templates/skeleton.tex
autocmd BufNewFile *.html 0r ~/.vim/filetype-templates/skeleton.html

" Store macros
let @q='+i"f=s": '      " Convert python function keyword arguments to dictionary
let @d='f[cs])i.get'      " Change x['a'] to x.get('a')

" Formatters  {{{
au FileType javascript setlocal formatprg=prettier\ --write
au FileType javascript.jsx setlocal formatprg=prettier\ --write
au FileType typescript setlocal formatprg=prettier\ --write
au FileType typescript.tsx setlocal formatprg=prettier\ --write
au FileType html setlocal formatprg=js-beautify\ --type\ html
au FileType scss setlocal formatprg=prettier\ --parser\ css
au FileType css setlocal formatprg=prettier\ --parser\ css
au FileType rust setlocal formatprg=rustfmt
" Formatters  }}}

"Switch between buffers without saving
set hidden
map <F6> :ls<CR>:b<space>

" Need to figure tab stuff some day
"tabs
" map <C-S-tab> :tabprevious<CR>
" map <C-tab> :tabnext<CR>
"map th :tabfirst<CR>
"map <s-z> :tabnext<CR>
"map <s-a> :tabprev<CR>
"map tl :tablast<CR>
"map tt :tabfind<CR>
"map tn :tabnext<Space>
"map tm :tabm<Space>

autocmd BufReadPre *.[jt]s,*.[jt]sx set tabstop=2
autocmd BufReadPre *.[jt]s,*.[jt]sx set shiftwidth=2



" Visual mode {{{
" Visual mode pressing * or # searches for the current selection
" Super useful! From an idea by Michael Naumann
function! CmdLine(str)
    exe "menu Foo.Bar :" . a:str
    emenu Foo.Bar
    unmenu Foo
endfunction

function! VisualSelection(direction) range
    let l:saved_reg = @"
    execute "normal! vgvy"

    let l:pattern = escape(@", '\\/.*$^~[]')
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'b'
        execute "normal ?" . l:pattern . "^M"
    elseif a:direction == 'gv'
        call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    elseif a:direction == 'f'
        execute "normal /" . l:pattern . "^M"
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction
vnoremap <silent> * :call VisualSelection('f')<CR>
vnoremap <silent> # :call VisualSelection('b')<CR>
" Visual mode }}}

" Status line {{{

" Returns true if paste mode is enabled
function! HasPaste()
    if &paste
        return 'PASTE MODE  '
    en
    return ''
endfunction

" Always show the status line
set laststatus=2

" Format the status line
" set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l

" Status line }}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Editing mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Move a line of text using <Alt>+[jk]
nmap <A-j> mX:m+<cr>`X
nmap <A-k> mX:m-2<cr>`X
vmap <A-j> :m'>+<cr>`<mY`>mXgv`Yo`X
vmap <A-k> :m'<-2<cr>`>mY`<mXgv`Yo`X

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Hack to use Alt key shortcuts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let c='a'
" while c <= 'z'
"   exec "set <A-".c.">=\e".c
"   exec "imap \e".c." <A-".c.">"
"   let c = nr2char(1+char2nr(c))
" endw
"
" set timeout ttimeoutlen=50

" Settings {{{

" FileType {{{
autocmd BufNewFile,BufRead */.ssh/config.d/* setfiletype sshconfig
autocmd BufNewFile,BufRead coc-settings.json setlocal filetype=jsonc
autocmd BufNewFile,BufRead tsconfig.json setlocal filetype=jsonc
autocmd BufNewFile,BufRead .vscode/*.json setlocal filetype=jsonc
" autocmd BufNewFile,BufRead *.asm set filetype=nasm
" }}}


" Rupee character (char code: \u20B9, insert it by <C-v>U20B9<space>)
abbreviate Rs. ₹
abbreviate zrs ₹
abbreviate zstar ⭐
