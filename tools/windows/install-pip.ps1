# ============Initialize environment============
. $PSScriptRoot\..\funcs.ps1
initEnv

function main() {
    cprint "Checking Pip ..."
    if (CorrectPipVersion) {
        cprint_ok "Pip is installed."
        return
    }

    if ($NOTDRY) {
        if (!(CorrectPythonVersion)) {
            throw "No valid python installation detected for pip"
        }

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
}

main