# Get the new Website URL
param($website_url)

Write-Host "Start-Transforming Website URL to " $website_url

Write-Host "Open JMX file"
# Get the JMX file
$Content = Get-Content .\MercuryHealth.LoadTests\LoadTest_HomePage.jmx

Write-Host "Replace Text in JMX file"
# Replace Text
$Content.replace(‘WebSiteUrlHere’, $website_url) | Set-Content .\MercuryHealth.LoadTests\LoadTest_HomePage.jmx

Write-Host "Open JMX file"
# Get the JMX file
Get-Content .\MercuryHealth.LoadTests\LoadTest_HomePage.jmx

Write-Host "End-Transforming Website URL"
