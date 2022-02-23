Write-Host "Generating Build Number"

#Get the version from the csproj file
#$xml = [Xml] (Get-Content .\MercuryHealth.Web\MercuryHealth.Web.csproj)
#$initialVersion = [Version] $xml.Project.PropertyGroup.Version # Cannot convert the "System.Object[]" value of type "System.Object[]" to type "System.Version".

# Test ONLY
#$spliteVersionTemp = $initialVersion.split(".") #ERROR: Method invocation failed because [System.Version] does not contain a method named 'split'.
#Write-Host "Split Version Test Only: " $spliteVersionTemp

$initialVersion ="1.3.0.0"

Write-Host "Initial Version from *.csproj file:" $initialVersion

$spliteVersion = $initialVersion.split(".")
Write-Host "Split Version: " $spliteVersion

#Get the build number (number of days since January 1, 2022)
$baseDate = [datetime]"01/01/2022"
$currentDate = $(Get-Date)
$interval = (NEW-TIMESPAN -Start $baseDate -End $currentDate)
$buildNumber = $interval.Days

#Get the revision number (number seconds (divided by two) into the day on which the compilation was performed)
$StartDate=[datetime]::Today
$EndDate=(GET-DATE)
$revisionNumber = [math]::Round((New-TimeSpan -Start $StartDate -End $EndDate).TotalSeconds / 2,0)

#Final version number
Write-Host "Major.Minor.Build.Revision"
$finalBuildVersion = "$($spliteVersion[0]).$($spliteVersion[1]).$($buildNumber).$($revisionNumber)"

Write-Host "Final build number: " $finalBuildVersion

#Writing final version number back to pipeline
# Yes there are!!!
echo “::set-output name=BuildNumber::$finalBuildVersion“
#echo ::set-output name=BuildNumber::$( $finalBuildVersion)

#echo "buildAssemblyVersion=$finalBuildVersion" >> $GITHUB_ENV
#echo "$Env:buildAssemblyVersion=$finalBuildVersion" | Out-File -FilePath $Env:GITHUB_ENV -Encoding utf-8 -Append
#$Env:buildAssemblyVersion = $finalBuildVersion

#Writing final version number back to Azure DevOps variable
#Write-Host "##vso[task.setvariable variable=buildNumber]$finalBuildVersion"
