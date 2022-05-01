---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Update-AllPSModule

## SYNOPSIS
This script will update all locally installed PowerShell modules to the newest ones if can find online.

## SYNTAX

```
Update-AllPSModule [-NoPreviews] [<CommonParameters>]
```

## DESCRIPTION
The script will search the usual PowerShell module profile paths for all modules and update them to the newest versions available online.

Updating modules depends on 'PackageManagement' and 'PowerShellGet', which are updated to the newest versions before upgrading any modules.
By default, it searches for beta, nightly, preview versions, etc., but you can exclude those with the "-NoPreviews" switch.

The script presents you with a list of all modules it finds and shows you if a newer version is detected and when that new version was published.

PowerShell comes with a similar "Update-Module" command, but that does not try to update 'PackageManagement' and 'PowerShellGet'.
It shows no data while operating, so you are left with an empty screen unless you use the "-verbose" switch, which displays too much information.
You can use the "-AllowPrerelease", but only with a named module.
This script will install Prerelease versions of all modules if they exist.

## EXAMPLES

### EXAMPLE 1
```
Update-AllPSModules
```

This will update all locally installed modules .

### EXAMPLE 2
```
Update-AllPSModules -NoPreviews
```

This will update all locally installed modules but not to versions that include 'beta', 'preview', 'nightly', etc.

## PARAMETERS

### -NoPreviews
If you want to avoid versions that include 'beta', 'preview', 'nightly', etc.,  and only upgrade to fully released versions of the modules, use this switch.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String
## NOTES
Filename:       Update-AllPSModules.ps1
Contributors:   Kieran Walsh
Created:        2021-01-09
Last Updated:   2022-02-17
Version:        1.45.00

## RELATED LINKS
