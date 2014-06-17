# poor man's plugin downloader for vim

Simple, slim, mini wrapper around git clone, git pull and tpope's pathogen.vim

# What is this?

It's a piece of vimscript code which:
- allows you to keep your list of plugins in vimrc

- on vim startup, downloads any new plugins and activates them with pathogen (aka "Poor man's package manager")

- provides a `:UpdatePlugins` command

# What this isn't:

- a full blown vim package manager (whatever that is)

- a pony

# What this can't do:

- download plugins from anywhere but github

- download plugins with anything but git

# Usage

1. copy the snippet in your vimrc

2. add any plugins you want (make sure you don't remove pathogen from the list, duh..)
```vim
Pl 'tpope/vim-repeat'
Pl 'tpope/vim-sensible' 'tpope/vim-surround'
```

3. use vim; run `:UpdatePlugins` when you feel like it


```vim
let g:plugin_dir = expand('~/.vim/bundle', ':p')
let g:plugin_hash = {}
let g:pathogen_blacklist = []

" Poor man's plugin downloader {{{
if !isdirectory(g:plugin_dir) | call mkdir(g:plugin_dir, "p") | endif

function! DownloadPluginIfMissing(plugin) abort
  let output_dir = g:plugin_dir . '/' . fnamemodify(a:plugin, ":t")
  if isdirectory(output_dir) || !executable('git')
    return
  endif
  let command = printf("git clone -q %s %s", "https://github.com/" . a:plugin . '.git', output_dir)
  echo "DownloadPluginIfMissing: " . command | echo system(command)
  silent! execute 'helptags ' . output_dir . '/doc'
endfunction

function! UpdatePlugin(plugin) abort
  let output_dir = g:plugin_dir . '/' . fnamemodify(a:plugin, ":t")
  if !isdirectory(output_dir) || !executable('git')
    return
  endif
  let command = printf("cd %s && git pull -q", output_dir)
  echo "UpdatePlugin: " . command | echo system(command)
endfunction

function! Pl(...) abort
  for plugin in map(copy(a:000), 'substitute(v:val, ''''''\|"'', "", "g")')
    let g:plugin_hash[ fnamemodify(plugin, ':t') ] = 1
    call DownloadPluginIfMissing(plugin)
  endfor
endfunction

command! -nargs=+ Pl call Pl(<f-args>)
command! -nargs=0 UpdatePlugins call map( keys(g:plugin_hash), 'UpdatePlugin( v:val )' ) | Helptags
" }}}

" one line per plugin
Pl 'w0ng/vim-hybrid'
Pl 'jonathanfilip/vim-lucius'

" or many plugins per line
Pl 'tpope/vim-sensible'  'tpope/vim-commentary' 'tpope/vim-eunuch'
Pl 'tpope/vim-obsession' 'tpope/vim-tbone'      'tpope/vim-unimpaired'
Pl 'tpope/vim-git'       'tpope/vim-markdown'   'tpope/vim-fugitive'

" run pathogen
Pl 'tpope/vim-pathogen'
execute "source " . g:plugin_dir . '/vim-pathogen/autoload/pathogen.vim'
let g:pathogen_blacklist = filter(map(split(glob(g:plugin_dir . '/*', 1), "\n"),'fnamemodify(v:val,":t")'), '!has_key(g:plugin_hash, v:val)')
execute pathogen#infect(g:plugin_dir . '/{}')
```

# Alternatives

- [vim-plug][2]
- [unbndle][3]
- [Vundle][4]
- [NeoBundle][5]

# License

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE

[1]:https://github.com/tpope/vim-pathogen
[2]:https://github.com/junegunn/vim-plug
[3]:https://github.com/sunaku/vim-unbundle
[4]:https://github.com/gmarik/Vundle.vim
[5]:https://github.com/Shougo/neobundle.vim
