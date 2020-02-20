param(
    [String] [Parameter (Mandatory = $True)] $BuildId,
    [String] [Parameter (Mandatory = $True)] $Organization,
    [String] [Parameter (Mandatory = $True)] $Project,
    [String] [Parameter (Mandatory = $True)] $ImageName,
    [String] [Parameter (Mandatory = $True)] $DefinitionId,
    [String] [Parameter (Mandatory = $True)] $AccessToken
)

$Body = @"
{
    "definitionId" : "$DefinitionId",
    "variables" : {
        "ImageBuildId" : {
            "value" : "$BuildId"
        },
        "ImageName" : {
            "value" : "$ImageName"
        }
    },
    "isDraft" : "false"
}
"@

$URL = "https://vsrm.dev.azure.com/$Organization/$Project/_apis/release/releases?api-version=5.1"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("'':${AccessToken}"))
$headers = @{
    Authorization = "Basic ${base64AuthInfo}"
}

$NewRelease = Invoke-RestMethod $URL -Body $Body -Method "POST" -Headers $headers -ContentType "application/json"

Write-Host "Created release: $($NewRelease.release._links.web.refs)"
