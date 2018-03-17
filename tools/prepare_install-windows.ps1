# 
# This script will install all Python and system dependencies.
# 

# ============Parse arguments============
param(
    [Parameter(Mandatory=$false)]
    [string]$v = -1,
    [Parameter(Mandatory=$false)]
    [switch]$y = $false,
    [Parameter(Mandatory=$false)]
    [switch]$d = $false,
    [Parameter(Mandatory=$false)]
    [switch]$t = $false,
    [Parameter(Mandatory=$false)]
    [switch]$h = $false,
    [Parameter(Mandatory=$false)]
    [switch]$u = $false,
    [Parameter(Mandatory=$false)]
    [ValidateSet(0,32,64)]
    [int]$target = 0
)

$global:ErrorActionPreference = "Stop"
$global:PYTHONVREQUEST = $v
$global:FORCECHOICE = $y
$global:TIMELIMITED = $t
$global:INSTALL_SYSTEMWIDE = !$u
$global:NOTDRY = !$d
$global:INSTALL_TARGET = $target

if ($h) {
  echo "
        Usage: prepare_install-windows.bat [-v version] [-y] [-u] [-t] [-d] [-target 32|64]

        -v version      Python version to be used (2, 3, 2.7, 3.5, ...).
        -y              Answer yes to everything.
        -t              Time limited build.
        -d              Dry run.
        -u              Install for user only.
        -target 32|64   Target architecture for installation (system architecture by default)    

        For Example: prepare_install-windows.bat -v 3 -d

        -h              Help
       "
  exit
}

# ============Initialize environment============
. $PSScriptRoot\funcs.ps1
resetEnv

cprint "System wide installation: $INSTALL_SYSTEMWIDE"
cprint "Installation target: $INSTALL_TARGET"
cprint "Root priviliges: $SYSTEM_PRIVILIGES"
if (!(YesNoQuestion "Continue installation?")) {
    exit
}

# ============Build essentials============
cprint "Install essentials ..."
. $PSScriptRoot\install-python.ps1
. $PSScriptRoot\install-pip.ps1
. $PSScriptRoot\install-git.ps1

# ============Show info and ask for continuation============
cprint "Python: $PYTHONBIN"
cprint "Python version: $PYTHONFULLV"
cprint "Python location: $PYTHON_EXECUTABLE"
cprint "Python include: $PYTHON_INCLUDE_DIR"
cprint "Python library: $PYTHON_LIBRARY"
cprint "Pip: $PIPFULLV" 
if (!(YesNoQuestion "Continue installation?")) {
    exit
}

# ============Install system dependencies============
cprint "Install system dependencies ..."
. $PSScriptRoot\install-pandoc.ps1

# ============Install modules============
cprint "Install python modules available on pypi..."
if ($NOTDRY) {
    invoke-expression "$PIPBIN install --upgrade setuptools"
    invoke-expression "$PIPBIN install --upgrade wheel"
    invoke-expression "$PIPBIN install --upgrade -r $PSScriptRoot/../requirements-dev.txt"
}

# ============Custom installation============
cprint "Install python modules not available on pypi..."

# ============Cleanup============
#Read-Host "Press any key to exit..."
