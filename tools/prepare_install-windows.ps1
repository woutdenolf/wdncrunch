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
    [ValidateSet(-1,32,64)]
    [int]$arch = -1
)

$global:ErrorActionPreference = "Stop"
$global:PYTHONVREQUEST = $v
$global:FORCECHOICE = $y
$global:TIMELIMITED = $t
$global:INSTALL_SYSTEMWIDE = !$u
$global:NOTDRY = !$d
$global:ARCHREQUEST = $arch

if ($h) {
  echo "
        Usage: prepare_install-windows.bat [-v version] [-y] [-u] [-t] [-d] [-arch 32|64]

        -v version      Python version to be used (2, 3, 2.7, 3.5, ...).
        -y              Answer yes to everything.
        -t              Time limited build.
        -d              Dry run.
        -u              Install for user only.
        -arch 32|64     Target architecture for installation (system architecture by default)

        For Example: prepare_install-windows.bat -v 3 -d

        -h              Help
       "
  exit
}

# ============Initialize environment============
. $PSScriptRoot\funcs.ps1
resetEnv

# ============Continue?============
cprint "System architecture: $global:SYSTEM_ARCH"
cprint "Target architecture: $global:TARGET_ARCH"
cprint "System wide installation: $INSTALL_SYSTEMWIDE"
cprint "Root priviliges: $SYSTEM_PRIVILIGES"
if (!(YesNoQuestion "Continue installation?")) {
    exit
}

# ============Build essentials============
cprint "Install essentials ..."
. $PSScriptRoot\install-essentials.ps1

# ============Continue?============
cprint "Python: $PYTHONBIN"
cprint "Python version: $PYTHONFULLV"
cprint "Python architecture: $global:PYTHON_ARCH"
cprint "Python location: $PYTHON_EXECUTABLE"
cprint "Python include: $PYTHON_INCLUDE_DIR"
cprint "Python library: $PYTHON_LIBRARY"
cprint "Pip: $PIPFULLV" 
if (!(YesNoQuestion "Continue installation?")) {
    exit
}

# ============Install system dependencies============
cprint "Install system dependencies ..."
. $PSScriptRoot\install-system.ps1

# ============Install python packages from PyPi============
cprint "Install python packages from PyPi..."
if ($NOTDRY) {
    invoke-expression "$PIPBIN install --upgrade pip"
    invoke-expression "$PIPBIN install --upgrade setuptools"
    invoke-expression "$PIPBIN install --upgrade wheel"
    invoke-expression "$PIPBIN install --upgrade -r $PSScriptRoot/../requirements.txt"
}

# ============Install python packages not available on PyPi============
cprint "Install python packages not available on PyPi..."
. $PSScriptRoot\install-custom.ps1

# ============Cleanup============
cprint "Cleaning up ..."
if ($NOTDRY) {
    if ($TIMELEFT) {
        cprint "All done ($BUILDSTEP/$BUILDSTEPS)! You should now be able to install the project."
    } else {
        cprint "Not everything has been build due to time restrictions. Run the script again ($BUILDSTEP/$BUILDSTEPS)."
    }
} else {
    cprint "Dry build $BUILDSTEP/$BUILDSTEPS."
}

$global:START_TIME.Stop()
$elapsed = $global:START_TIME.Elapsed.TotalMinutes
cprint "Total execution time = $elapsed min"
