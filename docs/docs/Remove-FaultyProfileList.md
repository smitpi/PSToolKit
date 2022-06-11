---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Install-LocalPSRepository
schema: 2.0.0
---

# Remove-FaultyProfileList

## SYNOPSIS
Fixes Profilelist in the registry.
To fix user logon with temp profile.

## SYNTAX

```
Remove-FaultyProfileList [-TargetServer] <String> [<CommonParameters>]
```

## DESCRIPTION
Connects to a server, Compare Profilelist in registry to what is on disk, and deletes registry if needed.
The next time a user logs on, new profile will be created, and not a temp profile.

## EXAMPLES

### EXAMPLE 1
```
Remove-FaultyProfileList -TargetServer AD01
```

## PARAMETERS

### -TargetServer
ServerName to connect to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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
