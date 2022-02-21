
<#PSScriptInfo

.VERSION 0.1.0

.GUID 4dbcd647-f11e-4940-a216-06c30da7e44b

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
Find all Nested members of a group

#>

<#
.SYNOPSIS
Find all Nested members of a group

.DESCRIPTION
Find all Nested members of a group

.PARAMETER GroupName
Specify one or more GroupName to audit

.PARAMETER RelationShipPath
Specify one or more GroupName to audit

.PARAMETER MaxDepth
How deep to search.

.EXAMPLE
Get-NestedMember -GroupName TESTGROUP,TESTGROUP2

#>
function Get-NestedMember {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Get-NestedMember')]

    PARAM(
        [String[]]$GroupName,
        [String]$RelationShipPath,
        [Int]$MaxDepth
    )
    BEGIN {
        $DepthCount = 1

        TRY {
            if (-not(Get-Module Activedirectory -ErrorAction Stop)) {
                Write-Verbose -Message '[BEGIN] Loading ActiveDirectory Module'
                Import-Module ActiveDirectory -ErrorAction Stop
            }
        }
        CATCH {
            Write-Warning -Message '[BEGIN] An Error occured'
            Write-Warning -Message $error[0].exception.message
        }
    }
    PROCESS {
        TRY {
            FOREACH ($Group in $GroupName) {
                # Get the Group Information
                $GroupObject = Get-ADGroup -Identity $Group -ErrorAction Stop

                IF ($GroupObject) {
                    # Get the Members of the group
                    $GroupObject | Get-ADGroupMember -ErrorAction Stop | ForEach-Object -Process {

                        # Get the name of the current group (to reuse in output)
                        $ParentGroup = $GroupObject.Name


                        # Avoid circular
                        IF ($RelationShipPath -notlike ".\ $($GroupObject.samaccountname) \*") {
                            if ($PSBoundParameters['RelationShipPath']) {

                                $RelationShipPath = "$RelationShipPath \ $($GroupObject.samaccountname)"

                            }
                            Else { $RelationShipPath = ".\ $($GroupObject.samaccountname)" }

                            Write-Verbose -Message "[PROCESS] Name:$($_.name) | ObjectClass:$($_.ObjectClass)"
                            $CurrentObject = $_
                            switch ($_.ObjectClass) {
                                'group' {
                                    # Output Object
                                    $CurrentObject | Select-Object Name, SamAccountName, ObjectClass, DistinguishedName, @{Label = 'ParentGroup'; Expression = { $ParentGroup } }, @{Label = 'RelationShipPath'; Expression = { $RelationShipPath } }

                                    if (-not($DepthCount -lt $MaxDepth)) {
                                        # Find Child
                                        Get-NestedMember -GroupName $CurrentObject.Name -RelationShipPath $RelationShipPath
                                        $DepthCount++
                                    }
                                }#Group
                                default {
                                    $CurrentObject | Select-Object Name, SamAccountName, ObjectClass, DistinguishedName, @{Label = 'ParentGroup'; Expression = { $ParentGroup } }, @{Label = 'RelationShipPath'; Expression = { $RelationShipPath } }
                                }
                            }#Switch
                        }#IF($RelationShipPath -notmatch $($GroupObject.samaccountname))
                        ELSE { Write-Warning -Message "[PROCESS] Circular group membership detected with $($GroupObject.samaccountname)" }
                    }#ForeachObject
                }#IF($GroupObject)
                ELSE {
                    Write-Warning -Message "[PROCESS] Can't find the group $Group"
                }#ELSE
            }#FOREACH ($Group in $GroupName)
        }#TRY
        CATCH {
            Write-Warning -Message '[PROCESS] An Error occured'
            Write-Warning -Message $error[0].exception.message
        }
    }#PROCESS
    END {
        Write-Verbose -Message '[END] Get-NestedMember'
    }
}
