---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Remove-UserProfile

## SYNOPSIS
Connects to a server and renames a user profile folder, and delete the key from Profilelist in the registry

## SYNTAX

```
Remove-UserProfile [-TargetServer] <String> [-UserName] <String> [<CommonParameters>]
```

## DESCRIPTION
Connects to a server and renames a user profile folder, and delete the key from Profilelist in the registry

## EXAMPLES

### EXAMPLE 1
```
Remove-UserProfile -TargetServer AD01 -UserName ps
```

## PARAMETERS

### -TargetServer
Server to connect to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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
