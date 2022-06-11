---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Install-LocalPSRepository
schema: 2.0.0
---

# Remove-CIMUserProfile

## SYNOPSIS
Uses CimInstance to remove a user profile

## SYNTAX

```
Remove-CIMUserProfile [[-TargetServer] <String>] [-UserName] <String> [<CommonParameters>]
```

## DESCRIPTION
Uses CimInstance to remove a user profile

## EXAMPLES

### EXAMPLE 1
```
Remove-CIMUserProfiles -UserName ps
```

## PARAMETERS

### -TargetServer
Affected Server

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: $env:COMPUTERNAME
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
Affected Username

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
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
