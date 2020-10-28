param(
    [string]$SourceDirectory="C:\Home\download"    
)
##Add required libs
Add-Type -Assembly "System.IO.Compression.FileSystem" ;

function CheckPath([string] $path) {
    If ([string]::IsNullOrEmpty($path) -eq $true)
    {
        Throw "The path must be specified."
    }
    
    [bool] $pathExists = Test-Path $path
    
    If ($pathExists -eq $false)
    {
        Throw "File does not exist (" + $path + ")"
    }
}

function CompressSpecificFolder([string]$tocompress,[string] $targetpath){       
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tocompress, $targetpath)   
}

function DeleteFileIfExists([string]$archive){
    if (Test-Path $archive) {
        Remove-Item $archive
    }
}



CheckPath $SourceDirectory

$sourcedirectories  = Get-ChildItem $SourceDirectory | Where-Object {$_.Attributes -match'Directory'}

Clear-Host
write-host "########### SPIN THROUGH FILES #############"
foreach ($Path in $sourcedirectories)
{
    $targetArchive= [string]::Concat($Path.Parent.FullName,"\",$Path.Name) +"_"+ ((Get-Date).ToString('yyyy-MM-dd')) + ".zip"
    Write-Host $targetArchive
    Write-Host "Compressing folder  " + $Path.FullName 

    DeleteFileIfExists $targetArchive 

    CompressSpecificFolder $Path.FullName $targetArchive

 }

 