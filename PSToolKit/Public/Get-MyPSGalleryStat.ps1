
<#PSScriptInfo

.VERSION 0.1.0

.GUID c4d35ac7-1b1f-48cf-81ee-f9a4ad9f5594

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS ps

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [26/10/2021_22:32] Initial Script Creating

.PRIVATEDATA

#>

<#

.DESCRIPTION
 Display detail about the modules I've uploaded

#>

<#
.SYNOPSIS
Show stats about my published modules.

.DESCRIPTION
Show stats about my published modules.

.PARAMETER OpenProfilePage
Open my profile page on psgallery

.PARAMETER ASObject
Return output as an object.

.PARAMETER GitHubUserID
The GitHub User ID.

.PARAMETER GitHubToken
GitHub Token with access to the Users' Gist.

.PARAMETER History
Downloads and calculates the history.

.PARAMETER daysToReport
Report on this amount of days.

.PARAMETER AddtoProfile
Add defaults to profile.

.EXAMPLE
Get-MyPSGalleryStats

#>
Function Get-MyPSGalleryStat {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-MyPSGalleryStats')]
    [OutputType([System.Object[]])]
    PARAM(
        [string]$GitHubUserID,
        [string]$GitHubToken,
        [switch]$History,
        [int]$daysToReport,
        [switch]$AddtoProfile,
        [Switch]$OpenProfilePage,
        [switch]$ASObject
    )

    if ($OpenProfilePage) {Start-Process 'https://www.powershellgallery.com/profiles/smitpi'}
    else {
        $ModLists = @('CTXCloudApi', 'PSConfigFile', 'PSLauncher', 'XDHealthCheck', 'PSSysTray', 'PWSHModule')
        try {
            Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Connecting to Gist"
            $headers = @{}
            $auth = '{0}:{1}' -f $GitHubUserID, $GitHubToken
            $bytes = [System.Text.Encoding]::ASCII.GetBytes($auth)
            $base64 = [System.Convert]::ToBase64String($bytes)
            $headers.Authorization = 'Basic {0}' -f $base64

            $url = 'https://api.github.com/users/{0}/gists' -f $GitHubUserID
            $AllGist = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
            $PRGist = $AllGist | Select-Object | Where-Object { $_.description -like 'smitpi-gallery-stats' }

            Write-Verbose "[$(Get-Date -Format HH:mm:ss) Checking Config File"
            $Content = (Invoke-WebRequest -Uri ($PRGist.files.'PSGalleryStats.json').raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop

            [System.Collections.generic.List[PSObject]]$GalStats = @()
            $TotalDownloads = 0
            try {
                $Content | ForEach-Object {$GalStats.Add($_)}
            } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)`nCreating new file"}

        } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

        foreach ($Mod in $ModLists) {
            Write-PSToolKitMessage -Action 'Collecting' -Object $mod -Message 'Online Data' -MessageColor Gray
            $ResultModule = Find-Module $mod -Repository PSGallery
            $YStats = ($GalStats.sum | Where-Object {$_.name -like $mod -and $_.DateCollected -gt ((Get-Date).AddDays(-1).ToUniversalTime())})[-1]
            $YSpan  = New-TimeSpan -Start $YStats.DateCollected.ToUniversalTime() -End (get-date).ToUniversalTime()
            $YTotalDownload = [Int]$ResultModule.AdditionalMetadata.downloadCount - $YStats.TotalDownload
            $YVersionDownload = [Int]$ResultModule.AdditionalMetadata.versionDownloadCount - $YStats.VersionDownload
            $TotalDownloads = $TotalDownloads + [int]$ResultModule.AdditionalMetadata.downloadCount
            [void]$GalStats.Add([PSCustomObject]@{
                    Sum            = [PSCustomObject]@{
                        DateCollected   = ([datetime](Get-Date -Format U)).ToUniversalTime()
                        Name            = $ResultModule.Name
                        Version         = $ResultModule.Version
                        PublishedDate   = ([datetime]$ResultModule.AdditionalMetadata.published).ToUniversalTime()
                        TotalDownload   = [Int]$ResultModule.AdditionalMetadata.downloadCount
                        VersionDownload = [Int]$ResultModule.AdditionalMetadata.versionDownloadCount
                    }
                    DailyStats          = [PSCustomObject]@{
                        DateCollected   = ([datetime](Get-Date -Format U)).ToUniversalTime()
                        Name            = $ResultModule.Name
                        Version         = $ResultModule.Version
                        TotalDays       = [math]::ceiling($YSpan.TotalDays)
                        TotalHours      = [math]::ceiling($YSpan.TotalHours)
                        TotalDownloads  = $YTotalDownload
                        VersionDownload = $YVersionDownload
                        PublishedDate   = ([datetime]$ResultModule.AdditionalMetadata.published).ToUniversalTime()
                    }
                    All            = $ResultModule
                    TotalDownloads = $TotalDownloads
                    DateCollected  = [datetime](Get-Date -Format U)
                })
        }
        try {
            Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Uploading to gist"
            $Body = @{}
            $files = @{}
            $Files['PSGalleryStats.json'] = @{content = ( $GalStats | ConvertTo-Json -Depth 10 | Out-String ) }
            $Body.files = $Files
            $Uri = 'https://api.github.com/gists/{0}' -f $PRGist.id
            $json = ConvertTo-Json -InputObject $Body
            $json = [System.Text.Encoding]::UTF8.GetBytes($json)
            $null = Invoke-WebRequest -Headers $headers -Uri $Uri -Method Patch -Body $json -ErrorAction Stop
            Write-PSToolKitMessage -Action 'Upload' -Object 'PSGallery Stats' -Message 'To Github Gist', 'Complete' -MessageColor Gray, Green
        } catch {Write-Error "Can't connect to gist:`n $($_.Exception.Message)"}

        if ($ASObject) {$GalStats}
        else {
            Write-Host 'Total Downloads: ', "$(($GalStats.TotalDownloads | Sort-Object -Descending)[0])" -ForegroundColor Yellow
            $GalStats[-1..-6].Sum | Sort-Object -Property PublishedDate -Descending | Format-Table -AutoSize -Wrap
        }
    }

    if ($History) {
        [System.Collections.generic.List[PSObject]]$GalTotals = @()
        $allNames = $GalStats.Sum | Select-Object Name | Sort-Object -Property Name -Unique

        foreach ($All in $allNames) {
            $sum = $GalStats.Sum | Where-Object {$_.Name -like $all.Name -and $_.DateCollected -gt $end}
            $span = New-TimeSpan -Start $sum[0].DateCollected -End $sum[-1].DateCollected
            $GalTotals.Add(
                [PSCustomObject]@{
                    Days           = [math]::ceiling($span.TotalDays)
                    Hours          = [math]::ceiling($span.TotalHours)
                    ModuleName     = $Sum[0].Name
                    Version        = $Sum[-1].version
                    TotalDownloads = [int]($Sum[-1].TotalDownload - $Sum[0].TotalDownload)
                })
        }
        $GalTotals | Format-Table -AutoSize -Wrap
    }
    if ($AddtoProfile) {
        $ToAppend = @"
		
#region MyPSGalleryStat Defaults
`$PSDefaultParameterValues['*MyPSGalleryStat*:GitHubUserID'] =  "$($GitHubUserID)"
`$PSDefaultParameterValues['*MyPSGalleryStat*:GitHubToken'] =  "$($GitHubToken)"
#endregion MyPSGalleryStat
"@

        $PersonalPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'PowerShell')
        $PersonalWindowsPowerShell = [IO.Path]::Combine("$([Environment]::GetFolderPath('MyDocuments'))", 'WindowsPowerShell')
	
        $Files = Get-ChildItem -Path "$($PersonalPowerShell)\*profile*"
        $files += Get-ChildItem -Path "$($PersonalWindowsPowerShell)\*profile*"
        foreach ($file in $files) {	
            $tmp = Get-Content -Path $file.FullName | Where-Object { $_ -notlike '*MyPSGalleryStat*'}
            $tmp | Set-Content -Path $file.FullName -Force
            Add-Content -Value $ToAppend -Path $file.FullName -Force -Encoding utf8
            Write-Host '[Updated]' -NoNewline -ForegroundColor Yellow; Write-Host ' Profile File:' -NoNewline -ForegroundColor Cyan; Write-Host " $($file.FullName)" -ForegroundColor Green
        }

    
    }
} #end Function


