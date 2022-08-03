
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
        [Switch]$OpenProfilePage,
        [switch]$ASObject
    )

    if ($OpenProfilePage) {Start-Process 'https://www.powershellgallery.com/profiles/smitpi'}
    else {
        $ModLists = @('CTXCloudApi', 'PSConfigFile', 'PSLauncher', 'XDHealthCheck', 'PSSysTray', 'PWSHModule')

        [System.Collections.ArrayList]$newObject = @()
        $TotalDownloads = 0

        foreach ($Mod in $ModLists) {
            Write-Color '[Collecting]', ' data for ', $($mod) -Color yellow, Green, Cyan
            $ResultModule = Find-Module $mod -Repository PSGallery
            $TotalDownloads = $TotalDownloads + [int]$ResultModule.AdditionalMetadata.downloadCount
            [void]$newObject.Add([PSCustomObject]@{
                    Sum            = [PSCustomObject]@{
                        Name            = $ResultModule.Name
                        Version         = $ResultModule.Version
                        PublishedDate   = [datetime]$ResultModule.AdditionalMetadata.published
                        TotalDownload   = [Int]$ResultModule.AdditionalMetadata.downloadCount
                        VersionDownload = [Int]$ResultModule.AdditionalMetadata.versionDownloadCount
                    }
                    All            = $ResultModule
                    TotalDownloads = $TotalDownloads
                    DateCollected  = [datetime](Get-Date -Format U)
                })
        }
        if ($ASObject) {$newObject}
        else {
            Write-Color 'Total Downloads: ', "$(($newObject.TotalDownloads | Sort-Object -Descending)[0])" -Color Cyan, yellow -LinesBefore 1
            $newObject.Sum | Sort-Object -Property PublishedDate -Descending | Format-Table -AutoSize -Wrap
        }
    }

    if (-not([string]::IsNullOrEmpty($GitHubUserID)) -and -not([string]::IsNullOrEmpty($GitHubToken)) ) {
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
        } catch {Write-Error "Can't connect to gist:`n $($_.Exception.Message)"}

        try {
            Write-Verbose "[$(Get-Date -Format HH:mm:ss) Checking Config File"
            $Content = (Invoke-WebRequest -Uri ($PRGist.files.'PSGalleryStats.json').raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop
        } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
   

        [System.Collections.generic.List[PSObject]]$GalStats = @()
        try {
            $Content | ForEach-Object {$GalStats.Add($_)}
        } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)`nCreating new file"}

        $GalStats.Add(
            [PSCustomObject]@{
                Date    = $newObject[0].DateCollected
                Total   = ($newObject.TotalDownloads | Sort-Object -Descending)[0]
                Details = [PSCustomObject]@{
                    Sum = $newObject.Sum
                    All = $newObject.All
                }   
            }
        )

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
            Write-Host '[Uploaded]' -NoNewline -ForegroundColor Yellow; Write-Host ' GalleryStats' -NoNewline -ForegroundColor Cyan; Write-Host ' to Github Gist' -ForegroundColor Green
        } catch {Write-Error "Can't connect to gist:`n $($_.Exception.Message)"}


        if ($History) {
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
            } catch {Write-Error "Can't connect to gist:`n $($_.Exception.Message)"}

            try {
                Write-Verbose "[$(Get-Date -Format HH:mm:ss) Checking Config File"
                $Content = (Invoke-WebRequest -Uri ($PRGist.files.'PSGalleryStats.json').raw_url -Headers $headers).content | ConvertFrom-Json -ErrorAction Stop
            } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)"}
       
            [System.Collections.generic.List[PSObject]]$GalHistory = @()
            try {
                $Content | ForEach-Object {$GalHistory.Add($_)}
            } catch {Write-Warning "Error: `n`tMessage:$($_.Exception.Message)`nCreating new file"}

            [System.Collections.generic.List[PSObject]]$GalTotals = @()
            $span = New-TimeSpan -Start $GalHistory[0].date -End $GalHistory[-1].Date
            $allNames = $GalHistory.details.Sum | Select-Object Name | Sort-Object -Property Name -Unique

            foreach ($All in $allNames) {
                $sum = $GalHistory.details.Sum | Where-Object {$_.Name -like $all.Name}
                if ($Sum[0].version -eq $Sum[-1].version) {$VerDown = ($Sum[-1].VersionDownload - $Sum[0].VersionDownload) }
                else {$VerDown = 'Different_Versions'}
                $GalTotals.Add(
                    [PSCustomObject]@{
                        Days            = $span.TotalDays
                        Hours           = $span.TotalHours
                        ModuleName      = $Sum[0].Name
                        BeginVer        = $Sum[0].version
                        EndVer          = $Sum[-1].version
                        TotalDownloads  = [int]($Sum[-1].TotalDownload - $Sum[0].TotalDownload)
                        VersoinDownload = $VerDown
                    })
            }
            $GalTotals | Format-Table -AutoSize -Wrap
        }
    }
} #end Function


