#
# This file is placed in the public domain
#
# Used by the mkvimball vim script
# (www.vim.org/scripts/script.php?script_id=4219).
#
# Sends update notifications to the Windows Shell

# input file contents marker: a7ec181d243150b7e40823f224174a281f46e986
#   ps refresh script marker: 1503407dcdac31e607788c18ba2590eead425d61

# Explicitly separate instructions with the semi-colon.
# All code will be concatenated on a single command line, as
# PowerShell will not run any script files by default, but will run
# commands passed as arguments to the shell.

# $cs_file should be set on the command line, otherwise we want to
# trigger some error.
function Refresh-Explorer
{
	$code = [IO.File]::ReadAllText($cs_file);

	Add-Type -MemberDefinition $code -Namespace MyWinAPI -Name Explorer;
	[MyWinAPI.Explorer]::Refresh();
};

Refresh-Explorer
