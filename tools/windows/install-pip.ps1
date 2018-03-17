# ============Initialize environment============
. $PSScriptRoot\..\funcs.ps1
initEnv

cprint "Checking Pip ..."
if (CorrectPipVersion) {
    cprint_ok "Pip is installed."
    exit
}

if (!(CorrectPythonVersion)) {
    throw "No valid python installation detected for pip"
}

if ($NOTDRY) {
    invoke-expression "$PYTHONBIN -m ensurepip --upgrade"
    initEnv

    if (CorrectPipVersion) {
        cprint_ok "Pip is installed."
    } else {
        throw "Pip is not installed"
    }
}

$global:BUILDSTEP += 1
$global:BUILDSTEPS += 1
