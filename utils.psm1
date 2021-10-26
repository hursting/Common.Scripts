
$myhome = 'C:\home\'
function Get-Info
    {
        param($ComputerName)
        Get-WmiObject -ComputerName $ComputerName -Class Win32_BIOS
    }

Function cguid { [Guid]::NewGuid().guid | Set-Clipboard }
Function cwd { $PWD.Path | Set-Clipboard }


Function mkdir {
    param([string]$path)
    if (-not $path) { return }
    New-Item -Path $path -ItemType Directory -EA SilentlyContinue | Out-Null
    if (Test-Path -Path $path) { Set-Location -Path $path }
}

Function ewd {
    param([string] $path = $PWD.Path)
    if ($path.EndsWith("\")) {
        $path = $path.Substring(0, $path.Length - 1)
    }
    explorer $path 
}

function touch {set-content -Path ($args[0]) -Value ($null)} 

function repo {
    $location = Join-Path $myhome 'repo'
    Set-Location $location    
}


function ~ {
    Set-Location  $myhome
}

