# The script currently requires 2 external variables to be set: XCODE_INSTALL_USER
# and XCODE_INSTALL_PASSWORD, in order to access the Apple Developer Center

$ErrorActionPreference = "Stop"

Import-Module "$env:HOME/image-generation/helpers/Common.Helpers.psm1"
Import-Module "$env:HOME/image-generation/helpers/Xcode.Installer.psm1"

if ([string]::IsNullOrEmpty($env:XCODE_INSTALL_USER) -or [string]::IsNullOrEmpty($env:XCODE_INSTALL_PASSWORD)) {
    throw "Required environment variables XCODE_INSTALL_USER and XCODE_INSTALL_PASSWORD are not set"
}

$os = Get-OSVersion
$xcodeVersions = Get-ToolsetValue "xcode.versions"
$defaultXcode = Get-ToolsetValue "xcode.default"
[Array]::Reverse($xcodeVersions)
$threadCount = [Environment]::ProcessorCount

Write-Host "ProcessorCount is $threadCount"
Write-Host "Installing Xcode versions..."
$xcodeVersions | ForEach-Object -ThrottleLimit $threadCount -Parallel {
    Import-Module "$env:HOME/image-generation/helpers/Common.Helpers.psm1"
    Import-Module "$env:HOME/image-generation/helpers/Xcode.Installer.psm1"
    $ErrorActionPreference = "Stop"
    $env:RUBYOPT="-W:no-deprecated -W:no-experimental"
    Install-XcodeVersion -Version $_.version -LinkTo $_.link
    Confirm-XcodeIntegrity -Version $_.link
    Approve-XcodeLicense -Version $_.link
}

if ($os.IsLessThanCatalina) {
    $latestXcodeVersion = $xcodeVersions | Select-Object -Last 1 -ExpandProperty link
    Install-XcodeAdditionalPackages -Version $latestXcodeVersion
}
$xcodeVersions | ForEach-Object { 
    Invoke-XcodeRunFirstLaunch -Version $_.link 
}
Invoke-XcodeRunFirstLaunch -Version $defaultXcode

Write-Host "Configuring Xcode symlinks..."
$xcodeVersions | ForEach-Object {
    Build-XcodeSymlinks -Version $_.link -Symlinks $_.symlinks
    Build-ProvisionatorSymlink -Version $_.link
}

Write-Host "Setting default Xcode to $defaultXcode"
Switch-Xcode -Version $defaultXcode
New-Item -Path "/Applications/Xcode.app" -ItemType SymbolicLink -Value (Get-XcodeRootPath -Version $defaultXcode) | Out-Null

Write-Host "Setting environment variables 'XCODE_<VERSION>_DEVELOPER_DIR'"
Set-XcodeDeveloperDirEnvironmentVariables -XcodeList $xcodeVersions.link