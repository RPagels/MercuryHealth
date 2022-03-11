# Get the new Website URL
param($website_url)

Write-Host "Start-Transforming Website URL"

# Get the runsettings file
$Content = Get-Content .\MercuryHealth.UITests\MercuryHealthTests.runsettings

# Replace Text
$Content.replace(‘WebSiteUrlHere’,’$website_url’) | Set-Content .\MercuryHealth.UITests\MercuryHealthTests.runsettings

# Update File
Get-Content .\MercuryHealth.UITests\MercuryHealthTests.runsettings

#Write-Host "Website URL: " $Content

Write-Host "End-Transforming Website URL"

