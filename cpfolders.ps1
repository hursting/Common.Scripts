[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $path
)

# is the path empty
IF([string]::IsNullOrEmpty($path)) {  
    Write-Host "You must pass a value for the path to process"
    return;
 }

function GetSize
{
    param([string]$pth)
    $thesize = ((gci -path $pth -recurse | measure-object -property length -sum).sum /1kb)
    "{0:n2}" -f ((gci -path $pth -recurse | measure-object -property length -sum).sum /1kb) + " kb"
}



if (Test-Path -Path $path){
    Write-Output "The path is not empty"
    $subFolders = Get-ChildItem -Path $path -Directory
    foreach ($subfolder in $subFolders) {
        Write-Output $subfolder.Fullname
    }    
}else {
    Write-Output "Ops the path is empty"
}


Write-Output ""
Write-Output "processing compressing  path: $path"
$fSize = GetSize($file)
Write-Output "The size of hte directory is $fSize "