
let s:plugin_dir = ''
let s:plugin_hash = {}
let s:pathogen_blacklist = []

let s:plugin_dir = expand('<sfile>:h:h:h')

function! plugins#begin()

  set nocompatible
  filetype plugin on

  if !isdirectory(s:plugin_dir)
    call mkdir(s:plugin_dir, "p")
  endif
endfunction

function! plugins#end()

  Pl 'tpope/vim-pathogen'
  Pl 'tpope/vim-dispatch'

  execute "source " . s:plugin_dir . '/vim-pathogen/autoload/pathogen.vim'

  let g:pathogen_blacklist = filter(map(split(glob(s:plugin_dir . '/*', 1), "\n"),'fnamemodify(v:val,":t")'), '!has_key(s:plugin_hash, v:val)')
  execute pathogen#infect(s:plugin_dir . '/{}')
endfunction

function! DownloadPluginIfMissing(plugin) abort
  let output_dir = s:plugin_dir . '/' . fnamemodify(a:plugin, ":t")
  if isdirectory(output_dir) || !executable('git')
    return
  endif
  let command = printf("git clone -q %s %s", "https://github.com/" . a:plugin . '.git', output_dir)
  echo "DownloadPluginIfMissing: " . command | echo system(command)
  silent! execute 'helptags ' . output_dir . '/doc'
endfunction

function! UpdatePlugin(plugin) abort
  let output_dir = s:plugin_dir . '/' . fnamemodify(a:plugin, ":t")
  if !isdirectory(output_dir) || !executable('git')
    return
  endif
  let command = printf("cd %s && git pull -q", output_dir)
  echo "UpdatePlugin: " . command | echo system(command)
endfunction

function! UpdatePluginInBackground(plugin) abort
  let output_dir = s:plugin_dir . '/' . fnamemodify(a:plugin, ":t")
  if !isdirectory(output_dir) || !executable('git')
    return
  endif
  let command = printf("cd %s && git pull -q", output_dir)
  execute "Start! -title=" . a:plugin . " " . command
endfunction

function! Pl(...) abort
  for plugin in map(copy(a:000), 'substitute(v:val, ''''''\|"'', "", "g")')
    let s:plugin_hash[ fnamemodify(plugin, ':t') ] = 1
    call DownloadPluginIfMissing(plugin)
  endfor
endfunction

command! -nargs=+ Pl call Pl(<f-args>)
command! -bang -nargs=0 UpdatePlugins if len("<bang>") == 0 | call map( keys(s:plugin_hash), 'UpdatePlugin( v:val )' ) | Helptags | else | execute "Start! vim -c UpdatePlugins -c Helptags -c qa" | endif
command! -bang -nargs=0 UpdatePluginsInBackground call map( keys(s:plugin_hash), 'UpdatePluginInBackground( v:val )' )
