---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Set-SharedPSProfile

## SYNOPSIS
Redirects PowerShell profile to network share.

## SYNTAX

```
Set-SharedPSProfile [[-PathToSharedProfile] <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION
Redirects PowerShell profile to network share.

## EXAMPLES

### EXAMPLE 1
```
Set-SharedPSProfile PathToSharedProfile "\\nas01\profile"
```

## PARAMETERS

### -PathToSharedProfile
The new path.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
