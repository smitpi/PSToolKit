
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

.PARAMETER GitHubUserID
The GitHub User ID.

.PARAMETER GitHubToken
GitHub Token with access to the Users' Gist.

.PARAMETER daysToReport
Report on this amount of days.

.PARAMETER Startdate
A custom start date for the report.

.PARAMETER EndDate
A custom end date for the report.

.EXAMPLE
Get-MyPSGalleryStats

#>
Function Get-MyPSGalleryStat {
    [Cmdletbinding(DefaultParameterSetName='InLastDays',HelpURI = 'https://smitpi.github.io/PSToolKit/Get-MyPSGalleryStats')]
    [OutputType([System.Object[]])]
    PARAM(
        [string]$GitHubUserID,
        [string]$GitHubToken,

        [Parameter(ParameterSetName='InLastDays')]
        [int]$daysToReport,

        [Parameter(ParameterSetName='DateRange')]
        [datetime]$Startdate,

        [Parameter(ParameterSetName='DateRange')]
        [datetime]$EndDate
    )

    try {
        Write-Verbose "[$(Get-Date -Format HH:mm:ss) PROCESS] Connecting to Gist"
        $headers = @{}
        $auth = '{0}:{1}' -f $GitHubUserID, $GitHubToken
        $bytes = [System.Text.Encoding]::ASCII.GetBytes($auth)
        $base64 = [System.Convert]::ToBase64String($bytes)
        $headers.Authorization = 'Basic {0}' -f $base64

        $url = 'https://api.github.com/users/{0}/gists' -f $GitHubUserID
        $AllGist = Invoke-RestMethod -Uri $url -Method Get -Headers $headers -ErrorAction Stop
        $PRGist = $AllGist | Select-Object | Where-Object { $_.description -like 'smitpi-gallery-statsV2' }

        Write-Verbose "[$(Get-Date -Format HH:mm:ss) Checking Config File"
        $Content = (Invoke-WebRequest -Uri ($PRGist.files.'PSGalleryStatsV2.json').raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop

        [System.Collections.generic.List[PSObject]]$GalStats = @()
        try {
            $Content | ForEach-Object {$GalStats.Add($_)}
        } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)`nCreating new file"}

    } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}

    if ($daysToReport) {
        $EndDays = (Get-Date).AddDays(-$daysToReport)
        $filter = $GalStats | Where-Object {[datetime]$_.datecollected -gt $EndDays} | Group-Object -Property title
    } else {
        $filter = $GalStats | Where-Object {[datetime]$_.datecollected -lt $EndDate -and [datetime]$_.datecollected -gt $Startdate} | Group-Object -Property title
    }
    
    $span = New-TimeSpan -Start $filter[0].Group[0].DateCollected -End $filter[0].Group[-1].DateCollected

    [System.Collections.generic.List[PSObject]]$SumObject = @()
    foreach ($mod in $filter) {
        $SumObject.Add([PSCustomObject]@{
         Name      = $mod.name
         Span      = [math]::Round($span.TotalDays)
         Start     = (get-date([datetime]$mod.Group[0].DateCollected) -Format 'dd/MMM/yyyy')
         End       = (get-date([datetime]$mod.Group[-1].DateCollected) -Format 'dd/MMM/yyyy')
         NewDownloads = ([int]$mod.group[-1].downloadCount - [int]$mod.group[0].downloadCount)
         TotalDownloads = [int]$mod.group[-1].downloadCount
    })
    }
    $SumObject

    <#
    $GalGrouped = $GalStats | Where-Object {[datetime]$_.datecollected -gt $EndDays} | Group-Object -Property DateCollected
    $GalGrouped.Group | Select-Object datecollected, title, NormalizedVersion, updated, versionDownloadCount, downloadCount | Format-Table -AutoSize -GroupBy datecollected

    $modules = $GalGrouped.group.title | Sort-Object -Unique
    $dates = $GalGrouped.group.datecollected | Sort-Object -Unique

    [System.Collections.generic.List[PSObject]]$SumObject = @()
    foreach ($date in $dates) {
        $perdate = $GalGrouped.Group | Where-Object {$_.datecollected -like $date}
        foreach ($pd in $perdate) {
            $SumObject.Add([PSCustomObject]@{
                    Name      = $pd.title
                    Date      = $pd.datecollected
                    Downloads = $pd.versionDownloadCount
                })
        }
    }
    $SumObject | Format-Table -AutoSize -GroupBy Date

    $span = New-TimeSpan -Start $GalGrouped[0].Name -End $GalGrouped[-1].Name
    foreach ($mod in $GalGrouped[0].Group.title) {
        $GalMod = $GalGrouped.Group | Where-Object {$_.title -like $mod}
        [PSCustomObject]@{
            Name     = $mod
            Span     = [System.Math]::Round($span.TotalHours)
            Download = ($GalMod[-1].downloadCount - $GalMod[0].downloadCount)
        } 
    } 
    #>
} #end Function


