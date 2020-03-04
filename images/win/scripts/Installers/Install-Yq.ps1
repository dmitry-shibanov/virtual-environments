Import-Module -Name ImageHelpers -Force

$latestReleaseJson = Invoke-RestMethod "https://api.github.com/repos/mikefarah/yq/releases/latest"
$latestReleaseAsset = $latestReleaseJson.assets | Where-Object { $_.name -Match "windows_amd64" } | Select-Object -First 1

$yqDownloadUrl = $latestReleaseAsset.browser_download_url
Write-Host "Yq download url is $yqDownloadUrl"

$nameYq = $latestReleaseAsset.name
Write-Host "Yq $nameYq"

Install-EXE -Url $yqDownloadUrl -Name $nameYq -ArgumentList ("/silent", "/install", "/AddToPath=0")
