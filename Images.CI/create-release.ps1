param(
    [String] [Parameter (Mandatory = $True)] $ArtifactUrl,
    [String] [Parameter (Mandatory = $True)] $BuildArtifactsPath,
    [String] [Parameter (Mandatory = $True)] $Organization,
    [String] [Parameter (Mandatory = $True)] $Project
)

$Body = @{
    definitionId = "3851"
    variables = {
        ImageBuildArtifactUrl = $ArtifactUrl
        ImageName = "test-name"
    }
    isDraft = "false"
}

$NewRelease = Invoke-WebRequest "https://vsrm.dev.azure.com/$Organization/$Project/_apis/release/releases?api-version=5.1" -Body $Body -Method "POST"

Write-Host "Create new release at $($NewRelease.release._links.web.refs)"