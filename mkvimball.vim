#!/usr/bin/vim -nNesc:let&verbose=1|let&viminfo=''|source%|echo""|qall!
"
" Build a vimball archive with the files given in VIMBALL_FILES
" environment variable or on the command line.
"   vim: ts=8:sts=4:ft=vim:norl
"
"      Author: Timothy Madden <terminatorul <at> gmail.com>
"  Maintainer: Timothy Madden <terminaotrul <at> gmail.com>
"       Usage:
"		<sfile> VimballName srcfiles...
"		    or
"		vim \
"		    -V1 -i NONE -u NORC \
"		    -NesS <sfile> -c"qall!" \
"			VimballName srcfiles...
"		    or
"		VIMBALL_FILES="srcfiles..." <sfile>
"
"		That is, files to be included in the vimball can
"		be listed on the command line or in the SOURCE
"		environment variable.
" Last Change: sep 13, 2012
"     Licence: This file is placed in the public domain
"	 File: mkvimball.vim
"     Version: 0.1
"
" GetLatestVimScripts: 0 0 :AutoInstall: mkvimball.vim
"   
" Command line options are passed to vim, then script can use the Vim
" arglist to process given files.
"
"
function { (exists('s:') ? 's:' : '') . 'MkVimball_Vim_Main'}(script_name) abort
    " read path prefix
    if exists('g:mkvimball_src_path_prefix')
	let l:mkvimball_src_path_prefix = g:mkvimball_src_path_prefix

	if g:mkvimball_src_path_prefix == ''
	    " an empty src_path_prefix disables the use of the current directory
	    " as g:vimball_home
	    let l:mkvimball_use_runtimepath = 1
	endif
    else
	if exists('$SRC_PATH_PREFIX')
	    let l:mkvimball_src_path_prefix = expand('$SRC_PATH_PREFIX')
	else
	    let l:mkvimball_src_path_prefix = ''
	endif
    endif

    if l:mkvimball_src_path_prefix != ''
	let l:trailing_sep = l:mkvimball_src_path_prefix[len(l:mkvimball_src_path_prefix)-1]
	if l:trailing_sep != '\' && l:trailing_sep != '/'
	    if filereadable('NUL')
		let l:mkvimball_src_path_prefix .= '\'
	    else
		let l:mkvimball_src_path_prefix .= '/'
	    endif
	endif
    endif

    " get command name
    let l:script_name = fnamemodify(a:script_name, ':t')
    if l:script_name == ''
	let l:cmd_name = 'vim -V1 -i NONE -nNesS mkvimball.vim'
    else
	let l:cmd_name = l:script_name
    endif

    " get first file name from the command line
    if argc() < 1
	echoerr "Usage: " . l:cmd_name . " Vimball srcfiles..."
	if l:script_name == ''
	    echo ""
	endif
	return
    else
	" check if arg(0) exists and is the same as this script
	" escape the file name, for use with glob():
	"   escape backslashes with another backslash
	"   escape pattern characters [, * and ? as [[], [*] and [?]
	"	the pattern character ] no longer needs an escape now
	if fnameescape('\') == '\\'
	    let l:first_arg = substitute(argv(0), '\m\\', '\\\\', 'g')
	endif
	let l:first_arg = substitute(l:first_arg, '\m\[', '[[]', 'g')
	let l:first_arg = substitute(l:first_arg, '\m(\*|\?)', '[\1]', 'g')

	" check if given file exists with glob()
	if glob(l:first_arg) == ''
	    let l:first_arg_idx = 0
	else
	    " file exists, compare with current script file name
	    let l:abs_file_path = fnamemodify(l:first_arg, ':p')
	    let l:abs_script_path = a:script_name == '' ? '' : fnamemodify(a:script_name, ':p')

	    if l:abs_file_path == l:abs_script_path
		" script is being sourced from the shebang line
		let l:first_arg_idx = 1
	    else
		let l:first_arg_idx = 0
	    endif
	endif
    endif

    " create new buffer with file names list
    new
    setlocal fileformat=unix

    if exists('$VIMBALL_FILES')
	if exists('g:mkvimball_delimiter_regexp')
	    let l:mkvimball_delimiter_regexp = g:mkvimball_delimiter_regexp
	else
	    let l:mkvimball_delimiter_regexp = '\v\s+'
	endif

	let l:files_list = split(expand("$VIMBALL_FILES"), l:mkvimball_delimiter_regexp) 

	if len(l:files_list) && l:files_list != ['-'] && l:files_list != ['$VIMBALL_FILES']
	    call append("$", l:files_list)
	else
	    " $VIMBALL_FILES is empty, read files from standard input
	    augroup mkvimcmd
		" return an error exit code if Vim exists after input()
		" reaches end-of-file. This may happen if script is run with
		" vim -e ..
		au VimLeave * cquit
	    augroup END
	    while 1
		let l:input_file = input('Vimball archive member file: ', '', 'file')
		echo "\n"
		if l:input_file != '' && l:input_file != '.'
		    call append("$", l:input_file)
		else
		    break
		endif
	    endwhile
	    augroup! mkvimcmd
	endif
	unlet l:files_list  " may be large
    else
	if l:first_arg_idx + 1 >= argc()
	    " no files to archive
	    if l:first_arg_idx >= argc()
		" no archive file given
		echoerr "Usage: " . l:cmd_name . " Vimball srcfiles..."
		if l:script_name == ''
		    echo ""
		endif
	    else
		" use the newly opened buffer
		execute "silent edit " . fnameescape(argv(l:first_arg_idx))
		VimballList
		close
	    endif
	    return
	else
	    echo "Creating vimball archive"

	    for l:fname_arg in range(l:first_arg_idx + 1, argc() - 1)
		call append("$", fnamemodify(argv(l:fname_arg), ':.'))
	    endfor
	endif
    endif

    " trim initial empty line
    if getline(1) == ''
	normal ggdd
    endif

    " remove the src path prefix from file names
    if l:mkvimball_src_path_prefix != ''
	execute "%substitute#^\\V" . substitute(substitute(l:mkvimball_src_path_prefix, '\v\\', '\\\\', 'g'), '\V#', '\#', 'g') . '##'
    endif

    " set-up g:vimball_home
    if !exists('g:vimball_home')
	if l:mkvimball_src_path_prefix != ''
	    let g:vimball_home = l:mkvimball_src_path_prefix
	    let l:unlet_vimball_home = 1
	else
	    if exists('l:mkvimball_use_runtimepath') && l:mkvimball_use_runtimepath
		:
	    else
		let g:vimball_home = '.'
		let l:unlet_vimball_home = 1
	    endif
	endif
    endif

    " ensure canoncal file names are used by Vimball plugin
    " Vim might change a file name upon file open, to match an existing buffer name
    let l:list_buf_no = bufnr('%')
    let l:n_lines = line('$')
    new
    if exists('g:vimball_home') && g:vimball_home != ''
	execute "lcd " . fnameescape(g:vimball_home)
    else
	" find first path in &runtimepath
	let l:vimball_dir = [ ] 
	for l:path in split(&runtimepath, ',')
	    call append(l:vimball_dir, path)
	    if l:path[len(l:path)-1] == '\'
		continue
	    endif
	    break
	endfor

	let l:vimball_dir = join(l:vimball_dir, ',')
	" replace '\,' with ','
	let l:vimball_dir = substitute(l:vimball_dir, '\V\\,', ',', 'g')
	" replace '\\' with '\', but not on Windows
	if fnameescape('\') == '\\'
	    let l:vimball_dir = substitute(l:vimball_dir, '\V\\\\,', '\\', 'g')
	endif

	execute "lcd " . fnameescape(l:vimball_dir)
    endif

    for l:ln in range(1, l:n_lines)
	let l:archive_member_file = getbufline(l:list_buf_no, l:ln)[0]
	execute "edit " . fnameescape(l:archive_member_file)
	if bufname('%') != l:archive_member_file
	    echomsg "Buffer " . bufname('%') . " overrides archive member " . l:archive_member_file . ', wipping out.'
	    let l:wipe_bufname = bufname('%')
	    enew
	    execute "bwipeout " . fnameescape(l:wipe_bufname)
	endif
    endfor
    close

    " unload a buffer named by the vimball file
    let l:vimball_buffnr = bufloaded(argv(l:first_arg_idx))
    if l:vimball_buffnr
	ls!
	echo "Unloading buffer " . string(bufnr(argv(l:first_arg_idx))) . " " .bufname(bufnr(argv(l:first_arg_idx)))
        " it might be nice to also restore the buffer after mkvimball
        let l:vimball_buffwin = bufwinnr(l:vimball_buffnr)
        execute "bunload " . bufnr(argv(l:first_arg_idx))
    endif

    " invoke :%MkVimball!
    execute "%MkVimball! " . argv(l:first_arg_idx)
    echomsg ""

    if exists('l:unlet_vimball_home') && l:unlet_vimball_home
	unlet g:vimball_home
    endif

    for l:k in keys(l:)
	unlet l:[l:k]
    endfor

    if exists('l:script_buffer') && l:script_buffer != -1
	execute "edit! " . fnameescape(argv(0))
    else
	if exists('l:vimball_buffwin') && l:vimball_buffwin != -1
	    " try to restore the closed buffer, but only works if buffer
	    " window was in the current tab page
	    execute "edit! " . fnameescape(argv(l:first_arg_idx))
	else
	    quit!	" close the new buffer
	endif
    endif
endfunction
"
call {(exists('s:') ? 's:' : '') . 'MkVimball_Vim_Main'}(expand('<sfile>'))
delfunction {(exists('s:') ? 's:' : '') . 'MkVimball_Vim_Main'}
