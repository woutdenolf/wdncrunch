# ============Initialize environment============
. $PSScriptRoot\..\funcs.ps1
initEnv

function main() {
    cprint "Checking Pandoc ..."

    if (cmd_exists pandoc) {
        cprint_ok "Pandoc is installed."
        return
    }

    # Get download link for target
    $extension = "windows.msi"
    $name = "Pandoc"

    $url = "https://api.github.com/repos/jgm/pandoc/releases/latest"
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
        throw "No Pandoc distribution found with extension $extension"
    }

    # Download
    $filename = "$PSScriptRoot\$filename"
    if ($NOTDRY) {
        download_file $asset.browser_download_url $filename
    }

    # Install (exe generated by InnoSetup)
    $path = joinPath (defaultTargetDir) $name
    cprint "Installing $name in $path ..."
    if ($NOTDRY) {
        $arguments = @()
        $arguments += "/passive"

        # ALLUSERS=0 only works when completely omitting it
        if ($INSTALL_SYSTEMWIDE) {
            $arguments += "ALLUSERS=1"
        }

        install_msi $filename $arguments
        updateBinPath

        initEnv
        if (cmd_exists pandoc) {
            cprint_ok "Pandoc is installed."
        } else {
            throw "Pandoc was not installed."
        }
    }

    $global:BUILDSTEP += 1
    $global:BUILDSTEPS += 1
}

main