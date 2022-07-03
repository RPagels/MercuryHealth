param(
    [parameter(Mandatory = $true)][string]$aiResourceId,
    [parameter(Mandatory = $true)][string]$releaseName,
    [parameter(Mandatory = $false)]$releaseProperties = @()
)

$annotation = @{
    Id = [GUID]::NewGuid();
    AnnotationName = $releaseName;
    EventTime = (Get-Date).ToUniversalTime().GetDateTimeFormats("s")[0];
    Category = "Deployment"; #Application Insights only displays annotations from the "Deployment" Category
    Properties = ConvertTo-Json $releaseProperties -Compress
}

$body = (ConvertTo-Json $annotation -Compress) -replace '(\\+)"', '$1$1"' -replace "`"", "`"`""
az rest --method put --uri "$($aiResourceId)/Annotations?api-version=2015-05-01" --body "$($body) "

# Use the following command for Linux Azure DevOps Hosts or other PowerShell scenarios
# Invoke-AzRestMethod -Path "$aiResourceId/Annotations?api-version=2015-05-01" -Method PUT -Payload $body