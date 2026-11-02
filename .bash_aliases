#
# Moxter-specific shell commands, to be sourced by the current dev machine's 
# global alias file.
#

# DIR_MOXTER lets each machine point these commands at its own checkout location.
if [ -z "${DIR_MOXTER:-}" ]; then
	printf '%s\n' 'Moxter aliases: DIR_MOXTER must be defined in ~/.bash_aliases or ~/.bashrc before this file is sourced.' >&2
	return 1 2>/dev/null || exit 1
fi

# Jump to this machine's Moxter checkout.
alias fhimoxtercd='cd "$DIR_MOXTER"'

# Find the virtualenv interpreter using the layout for the current dev machine.
_moxter_venv_python() {
	if [ -x "$DIR_MOXTER/.venv313/Scripts/python.exe" ]; then
		printf '%s\n' "$DIR_MOXTER/.venv313/Scripts/python.exe"
	elif [ -x "$DIR_MOXTER/.venv313/bin/python" ]; then
		printf '%s\n' "$DIR_MOXTER/.venv313/bin/python"
	else
		printf '%s\n' 'Moxter docs environment not found. Run fhimoxterdocsetup first.' >&2
		return 1
	fi
}

 # Create the local docs virtualenv if needed, then install its dependencies.
 fhimoxterdocsetup() {
 	cd "$DIR_MOXTER" || return
 	if [ ! -x .venv313/Scripts/python.exe ] && [ ! -x .venv313/bin/python ]; then
 		local bootstrap_python
 		if command -v python3 >/dev/null 2>&1; then
 			bootstrap_python=$(command -v python3)
 		elif command -v python >/dev/null 2>&1; then
 			bootstrap_python=$(command -v python)
 		else
 			printf '%s\n' 'Python 3 is required to create the Moxter docs environment.' >&2
 			return 1
 		fi
 		"$bootstrap_python" -m venv .venv313 || return
 	fi
 	local venv_python
 	venv_python=$(_moxter_venv_python) || return
 	"$venv_python" -m pip install -r mkdocs.dependencies.txt
 }

  # Start MkDocs' local server with live rebuilds.
  fhimoxterdocserve() {
  	cd "$DIR_MOXTER" || return
  	local venv_python
  	venv_python=$(_moxter_venv_python) || return
  	"$venv_python" -m mkdocs serve
  }

# # Build the docs and treat warnings as errors; do not start a server.
# fhimoxterdocbuild() {
# 	cd "$DIR_MOXTER" || return
# 	local venv_python
# 	venv_python=$(_moxter_venv_python) || return
# 	"$venv_python" -m mkdocs build --strict
# }

# # AI agent testing on my personal moxter (trying to see if AI can come up with the "include" feature)
# # amend and force-push main, then rebase and force-push the feature branch.
# alias fhitestai='git add .github/workflows && git commit --amend --no-edit && git push origin main --force-with-lease && git rebase --onto main Support_for_include~1 Support_for_include && git push origin Support_for_include --force-with-lease'