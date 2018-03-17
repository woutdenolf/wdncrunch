# ============Initialize environment============
. $PSScriptRoot\..\funcs.ps1
initEnv

cprint "Checking Git ..."

if (cmd_exists git) {
    cprint_ok "Git is installed."
    exit
}

# Get download link for target
if (install_64bit){
    $extension = "64-bit.exe"
    $affix = ""
    $name = "Git (64-bit)"
} else {
    $extension = "32-bit.exe"
    $affix = "-32"
    $name = "Git (32-bit)"
}

$url = "https://api.github.com/repos/git-for-windows/git/releases/latest"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$response = Invoke-RestMethod -Method 'Get' -ContentType 'application/json' -Uri $url

$filename = ""
foreach ($asset in $response.assets) {
    if ( $asset.name.endswith($extension) )
    {
        $filename = $asset.name
        break
    }
}

if (!$filename) {
    throw "No Git distribution found with extension $extension"
}

# Download
$filename = "$PSScriptRoot\$filename"
if ($NOTDRY) {
    download_file $asset.browser_download_url $filename
}

# Install (exe generated by InnoSetup)
$path = joinPath (defaultTargetDir) "Git$affix"
cprint "Installing $name in $path ..."
if ($NOTDRY) {
    $arguments = @()
    $arguments += "/silent"
    $arguments += "/dir=`"$path`""
    install_exe $filename $arguments
    prependBinPath (joinPath $path "bin")

    initEnv
    if (cmd_exists git) {
        cprint_ok "Git is installed."
    } else {
        throw "Git was not installed."
    }
}

$global:BUILDSTEP += 1
$global:BUILDSTEPS += 1