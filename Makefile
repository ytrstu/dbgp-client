
.POSIX:

VIM="vim"
GVIM="gvim"
GVIM_CMD=$(GVIM) --cmd "set runtimepath^=${PWD}/vim | set runtimepath+=${PWD}/vim/after" -n
VIM_CMD=$(VIM) --cmd "set runtimepath^=${PWD}/vim | set runtimepath+=${PWD}/vim/after" -n
GVIM_CMD_CLEAN=$(GVIM) --cmd "set runtimepath-=${HOME}/.vim | set runtimepath-=${HOME}/.vim/after | set runtimepath^=${PWD}/src/vim | set runtimepath+=${PWD}/src/vim/after" -u NORC -U NONE -i NONE -N -n
VIM_CMD_CLEAN=$(VIM) --cmd "set runtimepath-=${HOME}/.vim | set runtimepath-=${HOME}/.vim/after | set runtimepath^=${PWD}/src/vim | set runtimepath+=${PWD}/src/vim/after" -u NORC -U NONE -i NONE -N -n

# Parsed by commands for dist: target to retrieve list of plugin source files
PLUGIN=DBGpClient
SOURCE =  src/vim/plugin/$(PLUGIN).vim
SOURCE += src/vim/plugin/$(PLUGIN).py
# SOURCE += src/vim/plugin/$(PLUGIN)/__init__.py
# SOURCE += src/vim/plugin/$(PLUGIN)/Debugger.py
# SOURCE += src/vim/plugin/$(PLUGIN)/DebugWindow.py
# SOURCE += src/vim/plugin/$(PLUGIN)/RemoteDebug.py

# RUNTEST="$(HOME)/usr/bin/runtest"
# DEJAGNU=/dev/null

run:
	$(GVIM_CMD)

run-clean:
	# run Vim without the user plugins, .vimrc file or viminfo file
	# Other settings (like env vars) still apply
	$(GVIM_CMD_CLEAN)

# mkvimball: src/mkvimball/mkvimball.exim src/mkvimball/mkvimball.exim.cmd src/mkvimball/mkvimball.exim.js \
# 	   src/mkvimball/mkvimball.setenv.js src/mkvimball/ShellUpdateNotify.cs \
# 	   src/mkvimball/ShellUpdateNotify.ps1 mkvimball.build.exim $(MAKEFILE)
# 	vim \
# 	    -i NONE -V1 -nNesS mkvimball.build.exim -c 'echo""|qall!' -- \
# 	    src/mkvimball/mkvimball.exim \
# 	    src/mkvimball/mkvimball.exim.cmd \
# 	    src/mkvimball/mkvimball.exim.js \
# 	    src/mkvimball/mkvimball.setenv.js \
# 	    src/mkvimball/checkElevate.js \
# 	    src/mkvimball/ShellUpdateNotify.cs \
# 	    src/mkvimball/ShellUpdateNotify.ps1
# 
# 	chmod +x mkvimball

mkvimball.vba.zip: mkvimball.vim $(MAKEFILE)
	rm -rf mkvimball.vba mkvimball.vba.zip
	./mkvimball.vim -V1 "-"- mk"vimball.vba" "mk"vimball.vim || test -r mkvimball.vba
	zip -o -9 "mkvimball.vba.zip" mkvimball.vba

mkvimball.vba: mkvimball.vba.zip

mk-vimball: mkvimball.vba.zip

# check-mkvimball:
# 	cd src/mkvimball-test \
# 	    && \
# 	PWD="$${PWD}" DEJAGNU="$(DEJAGNU)" $(RUNTEST) --all --tool "mkvimball"

$(PLUGIN).vba.zip: $(SOURCE) $(MAKEFILE)
	VIMBALL_FILES="$(SOURCE)" $(VIM_CMD_CLEAN) -f -V1 -nNesS mkvimball.vim -c 'echo "" | qall!' "$(PLUGIN)"
	test -r "$(PLUGIN).vba"
	zip -9 "$(PLUGIN).vba.zip" "$(PLUGIN).vba"
	rm -f -- "$(PLUGIN).vba"

vimball: $(PLUGIN).vba.zip

# check-DBGpClient:
# 	cd src/testsuite \
# 	    && \
# 	PWD="$${PWD}" DEJAGNU="$(DEJAGNU)" $(RUNTEST) --all --tool "$(PLUGIN)" # --srcdir test

# check: check-DBGpClient

clean:
	rm -f -- "$(PLUGIN).vba"* "$(PLUGIN).log" "$(PLUGIN).sum"
	rm -f -- "mkvimball.vba"* "mkvimball-tmlp.vim"

zip: clean
	PLUGIN=$$(basename -- "$$PWD") && cd .. && zip -r -9 -u "$$PLUGIN.zip" "$$PLUGIN" -x \*.py[co] -x \*.sw[po] -x \*.bak -x \*\~ x \*.orig -x \*/.netrw\* -x \*.vba -x \*.vba.zip \*.vmb \*.log \*.sum
