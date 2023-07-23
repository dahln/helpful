<#
.SYNOPSIS
This script recursively finds all *.csproj files in a specified folder and its subdirectories. For each *.csproj file, it examines the PackageReference elements and generates dotnet CLI commands to update the packages listed in those elements.

.DESCRIPTION
The script takes two parameters:
1. -folderPath: The path to the folder containing the *.csproj files to be processed.
2. -update: A switch parameter. If included, the script will execute the dotnet CLI commands to update the packages. If not included, it will only display the commands without executing them.

If the -update parameter is not included, the script will list the dotnet CLI commands that can be manually executed to update the packages. Additionally, it will display a message suggesting the user run each command as necessary, adding an optional --version parameter if they want to update to a specific version of a package. Or they can include '-update' to update all packages to the latest versions.

Please use the -update parameter with caution, as it will modify the *.csproj files by updating the packages.

.EXAMPLE
.\update_packages.ps1 -folderPath "C:\path\to\your\folder"

This example will display the dotnet CLI commands for updating the packages found in the *.csproj files in the specified folder and its subdirectories without actually executing them.

.EXAMPLE
.\update_packages.ps1 -folderPath "C:\path\to\your\folder" -update

This example will execute the dotnet CLI commands to update the packages found in the *.csproj files in the specified folder and its subdirectories.

#>

param(
    [string]$folderPath,
    [switch]$update
)

function Show-Help {
    Write-Host @"
Usage: update_packages.ps1 -folderPath <folder_path> [-update]

Description:
This script recursively finds all *.csproj files in the specified folder and its subdirectories.
For each *.csproj file, it examines the PackageReference elements and generates dotnet CLI commands to update the packages listed in those elements.

Parameters:
  -folderPath <folder_path> : The path to the folder containing the *.csproj files to be processed.
  -update                   : If included, the script will execute the dotnet CLI commands to update the packages. If not included, it will only display the commands without executing them.
"@ -ForegroundColor Green
}

function Get-CsprojFiles {
    param([string]$folder)

    Get-ChildItem -Path $folder -Filter "*.csproj" -File -Recurse
}

function Generate-DotnetCliCommands {
    param([string]$csprojFile)

    [xml]$xml = Get-Content $csprojFile
    $packageReferences = $xml.Project.ItemGroup.PackageReference

    foreach ($packageRef in $packageReferences) {
        $packageName = $packageRef.Include
        if (![string]::IsNullOrEmpty($packageName)) {
            $command = "dotnet add `"$csprojFile`" package `"$packageName`""
            if ($update) {
                Invoke-Expression $command
            } else {
                Write-Host $command
            }
        }
    }
}

# Main script
if (-not $folderPath) {
    Show-Help
    Exit
}

$csprojFiles = Get-CsprojFiles -folder $folderPath

if ($csprojFiles.Count -eq 0) {
    Write-Host "No *.csproj files found in the specified folder and its subdirectories." -ForegroundColor Yellow
    Exit
}

foreach ($csprojFile in $csprojFiles) {
    Generate-DotnetCliCommands -csprojFile $csprojFile.FullName
}

if (-not $update) {
    Write-Host "`nRun each command as necessary, add an optional --version parameter if you want to update to a specific version of a package. Or include '-update' to update all packages to the latest versions."
}
