# Original script: https://gist.github.com/carlosfunk/9087316

# ============Check Powershell version============
function cprint() {
    Write-Host -ForegroundColor Magenta $args
}

function cprint_error() {
    Write-Host -ForegroundColor Red $args
}

function cprint_ok() {
    Write-Host -ForegroundColor Green $args
}

if ($PSVersionTable.PSVersion.Major -lt 3) {
    cprint_error "To run this script you need to download WMF 3.0 or higher:"
    cprint_error " https://docs.microsoft.com/en-us/powershell/wmf/readme"
    $global:ErrorActionPreference = "Stop"
    throw "Download WMF 3.0 or higher"
}


# ============Initialize environment============
# Check if command exists
function cmd_exists($cmdName) {
    if ($cmdName -eq $null) {
        return $false
    }
    if ($cmdName -is [String]) {
        $cmdName = $cmdName.split(' ')[0]
    }
    if (Get-Command $cmdName -errorAction SilentlyContinue) {
        return $true
    } else {
        return $false
    }
}


# Initialize python variables
function _initPythonPipEnv($reset) {

    if ($PYTHONVREQUEST -eq $null) {
        $global:PYTHONVREQUEST = -1
    }

    # Find requested version of python
    if ($reset -or !(CorrectPythonVersion)) {
        $global:PYTHONBIN = $null

        if ((cmd_exists python) -and ($PYTHONBIN -eq $null)) {
            $global:PYTHONBIN = "python"
            if (!(CorrectPythonVersion)) {
                $global:PYTHONBIN = $null
            }
        }

        if ((cmd_exists py) -and ($PYTHONBIN -eq $null)) {
            $global:PYTHONBIN = "py"
            $major,$minor,$micro = parseVersion $PYTHONVREQUEST
            if ($major -ne -1) {$global:PYTHONBIN += " -$major"}
            if ($minor -ne -1) {$global:PYTHONBIN += ".$minor"}
            if ($micro -ne -1) {$global:PYTHONBIN += ".$micro"}

            if (!(CorrectPythonVersion)) {
                $global:PYTHONBIN = $null
            }
        }
    }

    # Find requested pip
    if ($reset -or !(CorrectPipVersion)) {
        $global:PIPBIN = $null
        if (CorrectPythonVersion) {
            $global:PIPBIN = "$PYTHONBIN -m pip"
        }
    }

    # Python info
    if (cmd_exists $PYTHONBIN) {
        $global:PYTHONMAJORV = invoke-expression "$PYTHONBIN -c `"import sys;print(sys.version_info[0])`""
        $global:PYTHONV = invoke-expression "$PYTHONBIN -c `"import sys;t='{v[0]}.{v[1]}'.format(v=list(sys.version_info[:2]));print(t)`""
        $global:PYTHONFULLV = invoke-expression "$PYTHONBIN -c `"import sys;t='{v[0]}.{v[1]}.{v[2]}'.format(v=list(sys.version_info[:3]));print(t)`""

        $global:PYTHON_EXECUTABLE = (Get-Command ([string]$PYTHONBIN.split(' ')[0]) | Select-Object -ExpandProperty Definition)
    
        $global:PYTHON_INCLUDE_DIR = invoke-expression "$PYTHONBIN -c `"import distutils.sysconfig; print(distutils.sysconfig.get_python_inc());`""
        $global:PYTHON_LIBRARY = invoke-expression "$PYTHONBIN -c `"import distutils.sysconfig,os;f=distutils.sysconfig.get_config_var; a=f('LIBDIR');b=f('LDLIBRARY');print(os.path.join(a if a else '',b if b else ''));`""
        #$global:PYTHON_PKG_DIR = invoke-expression "$PYTHONBIN -c `"import distutils.sysconfig; print(distutils.sysconfig.get_python_lib());`""
        
        $global:PYTHON_COMPILER = invoke-expression "$PYTHONBIN -c `"import platform,re; print(re.search('MSC v.(\d+).+',platform.python_compiler()).groups()[0])`""
        $global:PYTHON_ARCH = invoke-expression "$PYTHONBIN -c `"import sys;print(sys.maxsize > 2**32)`""
        if ($global:PYTHON_ARCH -eq "True") {
            $global:PYTHON_ARCH = 64
        } else {
            $global:PYTHON_ARCH = 32
        }
    } else {
        $global:PYTHONMAJORV = $null
        $global:PYTHONV = $null
        $global:PYTHONFULLV = $null

        $global:PYTHON_EXECUTABLE = $null
    
        $global:PYTHON_INCLUDE_DIR = $null
        $global:PYTHON_LIBRARY = $null
        #$global:PYTHON_PKG_DIR = $null

        $global:PYTHON_COMPILER = $null
        $global:PYTHON_ARCH = $null
    }

    # Pip info
    if (cmd_exists $PIPBIN) {
        $global:PIPFULLV = (invoke-expression "$PIPBIN --version")
    } else {
        $global:PIPFULLV = $false
    }
}

# Check Python version
function CorrectPythonVersion() {
    if ($PYTHONVREQUEST -eq $null) {
        $global:PYTHONVREQUEST = -1
    }
    if (!(cmd_exists $PYTHONBIN)) {
        return $false
    }

    $versioni = invoke-expression "$PYTHONBIN -c `"import sys;t='{v[0]}.{v[1]}.{v[2]}'.format(v=list(sys.version_info[:3]));print(t)`""
    $majori,$minori,$microi = parseVersion $versioni
    $major,$minor,$micro = parseVersion $PYTHONVREQUEST
    $iscorrectmajor = ($major -eq -1) -or ($majori -eq $major)
    $iscorrectminor = ($minor -eq -1) -or ($minori -eq $minor)
    $iscorrectmicro = ($micro -eq -1) -or ($microi -eq $micro)

    $archpython = invoke-expression "$PYTHONBIN -c `"import sys,math;int(math.log(sys.maxsize,2)+1)`""
    if ($global:TARGET_ARCH -eq $null) {
        $iscorrectarch = $true
    } else {
        $iscorrectarch = $archpython -eq $global:TARGET_ARCH
    }
    return $iscorrectmajor -and $iscorrectminor -and $iscorrectmicro -and $iscorrectarch
}

# Check pip version
function CorrectPipVersion () {
    if (!(cmd_exists $PIPBIN)) {
        return $false
    }

    # Perl installations also have a pip
    foreach ($tmp in (invoke-expression "$PIPBIN -h")) {
        if ($tmp.contains("python")) {return $true}
    }
    return $false
}

# Target architecture
function _initArch() {
    if ($ARCHREQUEST -eq $null) {
        $global:ARCHREQUEST = -1
    }

    # From process: [Environment]::Is64BitProcess
    # From system: [Environment]::Is64BitOperatingSystem
    if ([Environment]::Is64BitOperatingSystem) {
        $global:SYSTEM_ARCH = 64
    } else {
        $global:SYSTEM_ARCH = 32
    }

    $archs = @{}
    $archs["x86"] = 32
    $archs["i386"] = 32
    $archs["i686"] = 32
    $archs[32] = 32
    $archs["x64"] = 64
    $archs["x86_64"] = 64
    $archs["amd64"] = 64
    $archs[64] = 64
    if ($archs.ContainsKey($ARCHREQUEST)) {
        $global:TARGET_ARCH = $archs[$ARCHREQUEST]
    } else {
        $global:TARGET_ARCH = $null
    }
}


# Initialize common variables
function _initEnv($reset) {

    $global:ErrorActionPreference = "Stop"

    # ============System properties============
    _initArch

    if ($reset -or ($SYSTEM_PRIVILIGES -eq $null)) {
        $global:SYSTEM_PRIVILIGES = [bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")
    }

    # ============Installation properties============
    if ($reset -and ($INSTALL_SYSTEMWIDE -eq $null)) {
        $global:INSTALL_SYSTEMWIDE = $SYSTEM_PRIVILIGES
    }

    if ($INSTALL_SYSTEMWIDE -and !$SYSTEM_PRIVILIGES) {
        $global:INSTALL_SYSTEMWIDE = $SYSTEM_PRIVILIGES
    }

    # ============Python/Pip============
    _initPythonPipEnv($reset)

    # ============Installation progress============
    if ($NOTDRY -eq $null) {
        $global:NOTDRY = $true
    }

    if ($reset -or $BUILDSTEP -eq $null) {
        $global:BUILDSTEP = 0
        $global:BUILDSTEPS = 0
    }

    if ($reset -or $TIMELEFT -eq $null) {
        $global:TIMELEFT = $true
    }

    if ($reset -or $TIMELIMITED -eq $null) {
        $global:TIMELIMITED = $false
    }

    if ($reset -or $START_TIME -eq $null) {
        $global:START_TIME = [Diagnostics.Stopwatch]::StartNew()
    }

}

# Initialize common variables (only overwrite the derived variables)
function initEnv() {
    _initEnv $false
}

# Reset common variables (overwrite all)
function resetEnv() {
    _initEnv $true
}


# ============Error handling============

function ThrowIfFailed() {
    if( -not $? ) {
        throw $args
    }
}


# ============Installing============

function install_64bit() {
    if ($TARGET_ARCH -eq $null) {
        return $SYSTEM_ARCH -eq 64
    } else {
        return $TARGET_ARCH -eq 64
    }
}

function install_msi($filename,$arguments) {
    # Install a Microsoft installer package
    $msiarguments = @()
    $msiarguments += "/i"
    $msiarguments += "`"$filename`""
    $msiarguments += $arguments
	Start-Process "msiexec.exe" -ArgumentList $msiarguments -Wait
    ThrowIfFailed "Failed to install $filename"
}

function install_exe($execname,$arguments) {
    # Install an executable
    if ($arguments.length -gt 0) {
	    Start-Process $execname -ArgumentList $arguments -Wait
    } else {
        Start-Process $execname -Wait
    }
    ThrowIfFailed "Failed to install $execname"
}

function install_any($filename,$argdict) {
    if ($filename.endswith(".msi")) {
        install_msi $filename $argdict["msi"]
    } elseif ($filename.endswith(".exe")) {
        install_exe $filename $argdict["exe"]
    } else {
        throw "Don't know how to install $filename"
    }
}

function _addBinPath([string]$path,[string]$target,[bool]$prepend=$false) {
    $envpath = [Environment]::GetEnvironmentVariable("Path", $target)
    if (!($envpath.contains($path))) {
        if ($prepend) {
            [Environment]::SetEnvironmentVariable("Path", "$path;$envpath", $target)
        } else {
            [Environment]::SetEnvironmentVariable("Path", "$envpath;$path", $target)
        }
    }
}

function appendBinPath($path) {
    if ($INSTALL_SYSTEMWIDE) {
        _addBinPath $path "Machine" $false
    } else {
        _addBinPath $path "User" $false
    }
    _addBinPath $path "Process" $false
}

function prependBinPath($path) {
    if ($INSTALL_SYSTEMWIDE) {
        _addBinPath $path "Machine" $true
    } else {
        _addBinPath $path "User" $true
    }
    _addBinPath $path "Process" $true
}

function updateBinPath() {
    $pathmachine = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $pathuser = [Environment]::GetEnvironmentVariable("Path", "User")
    [Environment]::SetEnvironmentVariable("Path", "$pathmachine;$pathuser;$env:path", "Process")
}

function defaultTargetDir() {
    if ($INSTALL_SYSTEMWIDE) {
        if (install_64bit){
            return $env:programfiles
        } else {
            return "$env:programfiles(x86)"
        }
    } else {
        return "$env:localappdata"
    }
}

# Convert major.minor.micro with possible missing minor and micro
function parseVersion([string]$versionin) {
    $version = $versionin.split('.')
    if ($version.length -eq 3) {
        $major,$minor,$micro = $version
        $major,$minor,$micro = [int][string]$major,[int][string]$minor,[int][string]$micro
    } elseif ($version.length -eq 2) {
        $major,$minor = $version
        $major,$minor = [int][string]$major,[int][string]$minor
        $micro = -1
    } elseif ($version.length -eq 1) {
        $major = [int][string]$version
        $minor = -1
        $micro = -1
    } else {
        throw "Invalid python version number `"$versionin`""
    }
    return $major,$minor,$micro
}


# ============Building============
function Invoke-CmdScript {
    param(
        [String] $scriptName
    )
    $cmdLine = """$scriptName"" $args & set"
    & $Env:SystemRoot\system32\cmd.exe /c $cmdLine |
    select-string '^([^=]*)=(.*)$' | foreach-object {
      $varName = $_.Matches[0].Groups[1].Value
      $varValue = $_.Matches[0].Groups[2].Value
      set-item Env:$varName $varValue
    }
}

function initMSVC($version,$arch) {
    $archs = @{}
    $archs[32] = "x86"
    $archs[64] = "x64"
    if (!($archs.ContainsKey($arch))) {
        throw "Unknown architecture $arch"
    }

    $vsarch = $archs[$global:SYSTEM_ARCH]
    if ($global:SYSTEM_ARCH -ne $arch) {
        $vsarch = "$vsarch-$archs[$arch]"
    }

    $versions = @{}
    $versions[1900] = "$env:programfiles(x86)\\Microsoft Visual Studio\\2017\\BuildTools\\VC\\Auxiliary\\Build\\vcvarsall.bat"
    $versions[1600] = "$env:programfiles(x86)\\Microsoft Visual Studio 10.0\\VC\\vcvarsall.bat"
    $versions[1500] = "$env:programfiles(x86)\\Microsoft Visual Studio 9.0\\VC\\vcvarsall.bat"
    if (!($versions.ContainsKey($version))) {
        throw "Unknown MSC version $version"
    }

    Invoke-CmdScript $versions[$version] $vsarch
}


# ============Downloading============
$webclient = New-Object System.Net.WebClient

function download_file([string]$url, [string]$output) {
	# Downloads a file if it doesn't already exist
	if (!(Test-Path $output -pathType leaf)){
		cprint "Downloading $url to $output ..."
		$webclient.DownloadFile($url, $output)
	}
}


# ============Others============
function joinPath($a,$b) {
    if ($a[-1] -eq '\') {
        return $a + $b
    } else {
        return $a + "\" + $b
    }
}

function YesNoQuestion([string]$question) {
    if ($FORCECHOICE) {
        return $true
    } else {
        $Readhost = Read-Host "$question ( Y / n ) "
        Switch ($ReadHost) { 
           Y {return $true} 
           N {return $false} 
           Default {return $true} 
        } 
    }
}


