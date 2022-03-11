# Get the new Website URL
param($website_url)

Write-Host "Start-Transforming Website URL"

Write-Host "Open runsettings file"
# Get the runsettings file
$Content = Get-Content .\MercuryHealth.UITests\MercuryHealthTests.runsettings

Write-Host "Replace Text in runsettings file"
# Replace Text
$Content.replace(‘WebSiteUrlHere’,’$website_url’)

Write-Host "Updated the runsettings file"
# Updated the runsettings file
Set-Content .\MercuryHealth.UITests\MercuryHealthTests.runsettings

Write-Host "Open runsettings file"
# Get the runsettings file
Get-Content .\MercuryHealth.UITests\MercuryHealthTests.runsettings

Write-Host "End-Transforming Website URL"

