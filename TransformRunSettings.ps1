#Get the new Website URL
param($website_url)

Write-Host "Start-Transforming Website URL"

#Get the version from the csproj file
#$xml = [Xml] (Get-Content .\MercuryHealth.Web\MercuryHealth.Web.csproj)
#$initialVersion = [Version] $xml.Project.PropertyGroup.Version # Cannot convert the "System.Object[]" value of type "System.Object[]" to type "System.Version".

# Test ONLY
#$spliteVersionTemp = $initialVersion.split(".") #ERROR: Method invocation failed because [System.Version] does not contain a method named 'split'.
#Write-Host "Split Version Test Only: " $spliteVersionTemp
#$initialVersion ="1.3.0.0"

#Get the runsettings file
$Content = Get-Content .\MercuryHealth.UITests\MercuryHealthTests.runsettings
$Content.replace(‘WebSiteUrlHere’,’$website_url’) | Set-Content .\MercuryHealth.UITests\MercuryHealthTests.runsettings
$Get-Content .\MercuryHealth.UITests\MercuryHealthTests.runsettings

Write-Host "End-Transforming Website URL"
