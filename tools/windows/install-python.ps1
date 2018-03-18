# ============Initialize environment============
. $PSScriptRoot\..\funcs.ps1
initEnv

# Get a hashtree with download links for each version
function pythonVersions() {
    if (install_64bit){
        $extension = "[-.]amd64"
    } else {
        $extension = ""
    }

    $url = "https://www.python.org/downloads/windows/"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $content = Invoke-WebRequest $url
    
    $versions = @{}
    $pattern = "https://www.python.org/ftp/python/([.\d]+)/python-([.\d])+$extension.[exmsi]{3}"
    foreach ($link in $content.Links) {
        $m = [regex]::Match($link.href,$pattern)
        if ($m.Success) {
            $major,$minor,$micro = $m.Groups[1].Value.split('.')
            $major,$minor,$micro = [int][string]$major,[int][string]$minor,[int][string]$micro
            if (!($versions.ContainsKey($major))) {
                $versions[$major] = @{}
            }
            if (!($versions[$major].ContainsKey($minor))) {
                $versions[$major][$minor] = @{}
            }
            if (!$versions[$major][$minor].ContainsKey($micro)) {
                $versions[$major][$minor][$micro] = @{}
            }
            $versions[$major][$minor][$micro] = $link.href
        }
    }

    return $versions
}


# Find the closest version in the hash tree
function FindPythonVersion([int]$num,[hashtable]$versions) {
    if ($num -eq -1) {
        $num = ($versions.keys | measure -Maximum).Maximum
    }
    if ($versions.ContainsKey($num)) {
        return $versions[$num],$num
    } else {
        throw "Invalid Python version number"
    }
}


function main() {
    cprint "Checking Python ..."
    initEnv

    # Return when already ok
    if (CorrectPythonVersion) {
        cprint_ok "Python is installed."
        return
    }

    # Download requested version
    if ($PYTHONVREQUEST -eq -1) {
        $global:PYTHONVREQUEST = 3
    }
    $major,$minor,$micro = parseVersion $PYTHONVREQUEST

    $link = ""
    $link,$major = FindPythonVersion $major (pythonVersions)
    $link,$minor = FindPythonVersion $minor $link
    $link,$micro = FindPythonVersion $micro $link
    $filename = $link.split('/')[-1]
    $filename = "$PSScriptRoot\$filename"

    if ($NOTDRY) {
        download_file $link $filename
    }

    # Install
    if (install_64bit){
        $installname = "Python $major.$minor.$micro (64-bit)"
    } else {
        $installname = "Python $major.$minor.$micro (32-bit)"
    }
    $path = defaultTargetDir
    cprint "Installing $installname in $path ..."
    if ($NOTDRY) {
        $arguments = @{}
        $arguments["msi"] = @()
        $arguments["exe"] = @()

        $arguments["msi"] += "/passive"
        $arguments["exe"] += "/passive"

        $tmp = [int]$INSTALL_SYSTEMWIDE
        $arguments["msi"] += "ALLUSERS=`"$tmp`""
        $arguments["exe"] += "InstallAllUsers=$tmp"

        $arguments["exe"] += "Include_test=0"
        $arguments["exe"] += "PrependPath=1"
        $arguments["exe"] += "Include_launcher=1"
        $arguments["exe"] += "InstallLauncherAllUsers=$tmp"

        install_any $filename $arguments
        updateBinPath

        initEnv
        if (CorrectPythonVersion) {
            cprint_ok "Python is installed."
        } else {
            throw "$installname is not installed"
        }
    }

    $global:BUILDSTEP += 1
    $global:BUILDSTEPS += 1
}

main