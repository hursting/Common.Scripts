param(
    [string]$DownloadDirectory="C:\Home\download",
    [bool]$ConfirmSort=$false
)

#$DownloadDirectory = "E:\Downloads"
$zipDirectory = $DownloadDirectory + "\zip"
$ExeDirectory =$DownloadDirectory + "\exe"
$TextDirectory = $DownloadDirectory + "\text"
$IsoDirectory =$DownloadDirectory + "\iso"
$MiscDirectory =$DownloadDirectory + "\misc"
$imageDirectory =$DownloadDirectory + "\image"
$logDirectory = $DownloadDirectory + "\log"
$scriptsDirectory = $DownloadDirectory + "\scripts"


function VerifyRun (){
    Add-Type -AssemblyName PresentationCore,PresentationFramework
    $ButtonType = [System.Windows.MessageBoxButton]::YesNo
    $MessageIcon = [System.Windows.MessageBoxImage]::Warning
    $MessageBody = "Are you sure you want to Sort the download directory"
    $MessageTitle = "Confirm Sort"

    $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)

    return $Result
}

function RemoveEmptyDirectories([string] $path){
    If ([string]::IsNullOrEmpty($path) -eq $true)
    {
        Throw "The path must be specified."
    }
    
    [bool] $pathExists = Test-Path $path
    
    If ($pathExists -eq $false)
    {
        Throw "File does not exist (" + $path + ")"
    }

    $numberOfFiles = Get-ChildItem -Path $path -Recurse | Measure-Object

    if ($numberOfFiles.Count -eq 0){
        Write-Host "The path " + $path +" has files no files so deleting "
        
        Remove-Item -Recurse -Force some_dir
    }
}


If ((Test-Path $DownloadDirectory) -eq $false) {
    New-Item -ItemType Directory -Path $DownloadDirectory -Force
} 


if ($ConfirmSort -eq $True){
    $Result = VerifyRun

    if($Result -eq "No"){
     Exit
    }    
}

#Ensure the directories are created. If not then create them.
If ((Test-Path $logDirectory ) -eq $false) {
    New-Item -ItemType Directory -Path $logDirectory  -Force
}

RemoveEmptyDirectories $logDirectory



If ((Test-Path $scriptsDirectory ) -eq $false) {
    New-Item -ItemType Directory -Path $scriptsDirectory  -Force
} 

If ((Test-Path $zipDirectory ) -eq $false) {
    New-Item -ItemType Directory -Path $zipDirectory  -Force
} 

If ((Test-Path $ExeDirectory ) -eq $false) {
    New-Item -ItemType Directory -Path $ExeDirectory  -Force
}

If ((Test-Path $TextDirectory ) -eq $false) {
    New-Item -ItemType Directory -Path $TextDirectory  -Force
} 

If ((Test-Path $IsoDirectory ) -eq $false) {
    New-Item -ItemType Directory -Path $IsoDirectory  -Force
} 

If ((Test-Path $MiscDirectory ) -eq $false) {
    New-Item -ItemType Directory -Path $MiscDirectory  -Force
} 

If ((Test-Path $imageDirectory ) -eq $false) {
    New-Item -ItemType Directory -Path $imageDirectory  -Force
} 


$IncludeIsoFiles = ("*.iso")
Get-ChildItem "$DownloadDirectory\*" -Include $IncludeIsoFiles  | Move-Item -Destination $IsoDirectory -verbose

$IncludeScriptFiles = ("*.ps1","*.sql","*.bat")
Get-ChildItem "$DownloadDirectory\*" -Include $IncludeScriptFiles  | Move-Item -Destination $scriptsDirectory -verbose


$IncludeLogFiles = ("*.log")
Get-ChildItem "$DownloadDirectory\*" -Include $IncludeLogFiles  | Move-Item -Destination $logDirectory -verbose


$IncludeTxtFiles = ("*.txt","*.doc","*.docx","*.pdf","*.xlsx","*.csv","*.rtf")
Get-ChildItem "$DownloadDirectory\*" -Include $IncludeTxtFiles  | Move-Item -Force -Destination $TextDirectory -verbose

$IncludeZipFiles = ("*.zip","*.tar","*.7zip", "*.rar","*.7z")
Get-ChildItem "$DownloadDirectory\*" -Include $IncludeZipFiles  | Move-Item -Force -Destination $zipDirectory -verbose


$IncludeExeFiles = ("*.EXE","*.exe", "*.msi","*.vsix")
Get-ChildItem "$DownloadDirectory\*" -Include $IncludeExeFiles  | Move-Item -Force -Destination $ExeDirectory -verbose

$IncludeImageFiles = ("*.png","*.jpg","*.JPG","*.JFIF","*.jfif")
Get-ChildItem "$DownloadDirectory\*" -Include $IncludeImageFiles  | Move-Item -Destination $imageDirectory -verbose


#Move everything elese into the miscellaneous directory and compress them while you do it. 
Add-Type -assembly "system.io.compression.filesystem"

$ExcludesDirectory =($zipDirectory,$ExeDirectory,$TextDirectory,$IsoDirectory,$imageDirectory,$MiscDirectory,$logDirectory,$scriptsDirectory)

$PickupDirectoryPath = Get-ChildItem "$DownloadDirectory" -Exclude $ExcludesDirectory | Where-Object {($_.Attributes -match 'Directory')}

foreach ($Path in $PickupDirectoryPath)
{
    if (($ExcludesDirectory.Contains($Path.FullName) -eq $false) ){
    write-host $Path
    Move-Item $path  -Destination $MiscDirectory -verbose
    }
 }

 #compress the stuff in the misc diretory.
 Add-Type -Assembly System.IO.Compression.FileSystem
 $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal

 $FilestoZip = Get-ChildItem "$MiscDirectory" | Where-Object {($_.Attributes -notmatch 'compressed') -and ($_.Attributes -match 'Directory')   }

 foreach ($Path in $FilestoZip)
{  
    $processingFile = $Path.FullName +".zip"
    If ((Test-Path $processingFile ) -eq $True) {
        Remove-Item $Path.FullName -Recurse -Force
    }  
 
    [System.IO.Compression.ZipFile]::CreateFromDirectory($Path.FullName, 
                                                          $Path.FullName +".zip",
                                                          $compressionLevel, 
                                                          $true)
 }

#$ExcludesDirectory =($zipDirectory,$ExeDirectory,$TextDirectory,$IsoDirectory,$imageDirectory)
#Get-ChildItem "$DownloadDirectory\*" -Exclude $ExcludesDirectory | where {$_.Attributes -match 'Directory' -and ($_.Parent -eq $DownloadDirectory ) } |  Move-Item -Destination $MiscDirectory -verbose
