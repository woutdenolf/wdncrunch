# ============Initialize environment============
. $PSScriptRoot\..\funcs.ps1
initEnv

function MSVCDownloadLink(version) {
    #https://wiki.python.org/moin/WindowsCompilers#Compilers_Installation_and_configuration

    $versions = @{}

    # ============Python 3.5, 3.6: 14.0 (2015)============
    $versions[1900] = @{}
    $tmp = @{}
    $tmp["link"] = "https://www.visualstudio.com/thank-you-downloading-visual-studio/?sku=BuildTools&rel=15#"
    $tmp["filename"] = "MSVC_1900_buildtools.exe"
    $tmp["arguments"] = @()
    $tmp["arguments"] += "--passive"
    $tmp["arguments"] += "--add Microsoft.VisualStudio.Workload.MSBuildTools"
    $tmp["arguments"] += "--add Microsoft.VisualStudio.Workload.VCTools"
    $versions[1900] += $tmp

    # ============Python 3.3, 3.4: 10.0 (2010)============
    $versions[1600] = @{}

    # Uninstall redistributables
    $tmp = @{}
    $tmp["link"] = "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe"
    $tmp["filename"] = "MSVC_1600_redist32.exe"
    $tmp["arguments"] = @()
    $versions[1600] += $tmp
    $tmp = @{}
    $tmp["link"] = "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe"
    $tmp["filename"] = "MSVC_1600_redist64.exe"
    $tmp["arguments"] = @()
    $versions[1600] += $tmp

    # Install .NET
    $tmp = @{}
    $tmp["link"] = "https://download.microsoft.com/download/5/6/2/562A10F9-C9F4-4313-A044-9C94E0A8FAC8/dotNetFx40_Client_x86_x64.exe"
    $tmp["filename"] = "MSVC_1600_dotnet.exe"
    $tmp["arguments"] = @()
    $versions[1600] += $tmp
    
    # Install SDK
    $tmp = @{}
    $tmp["link"] = "https://download.microsoft.com/download/A/6/A/A6AC035D-DA3F-4F0C-ADA4-37C8E5D34E3D/winsdk_web.exe"
    $tmp["filename"] = "MSVC_1600_sdk.exe"
    $tmp["arguments"] = @()
    $versions[1600] += $tmp
    
    # Install redistributables
    $tmp = @{}
    $tmp["link"] = "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe"
    $tmp["filename"] = "MSVC_1600_redist32.exe"
    $tmp["arguments"] = @()
    $versions[1600] += $tmp
    $tmp = @{}
    $tmp["link"] = "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe"
    $tmp["filename"] = "MSVC_1600_redist64.exe"
    $tmp["arguments"] = @()
    $versions[1600] += $tmp

    # ============Python 2.6, 2.7, 3.0, 3.1, 3.2: 9.0 (2008)============
    $versions[1500] = @{}

    # Install .NET
    $tmp = @{}
    $tmp["link"] = "https://download.microsoft.com/download/2/0/E/20E90413-712F-438C-988E-FDAA79A8AC3D/dotnetfx35.exe"
    $tmp["filename"] = "MSVC_1500_dotnet.exe"
    $tmp["arguments"] = @()
    $versions[1500] = $tmp

    # Install SDK
    $tmp = @{}
    $tmp["link"] = "https://download.microsoft.com/download/7/A/B/7ABD2203-C472-4036-8BA0-E505528CCCB7/winsdk_web.exe"
    $tmp["filename"] = "MSVC_1500_sdk.exe"
    $tmp["arguments"] = @()
    $versions[1500] = $tmp

    if (version in $versions) {
        return $versions[version]
    } else {
        return $null
    }
}
