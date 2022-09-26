---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Test-IsFileOpen

## SYNOPSIS
Checks if a file is open

## SYNTAX

```
Test-IsFileOpen [-Path] <String[]> [<CommonParameters>]
```

## DESCRIPTION
Checks if a file is open

## EXAMPLES

### EXAMPLE 1
```
dir | Test-IsFileOpen
```

## PARAMETERS

### -Path
Path to the file to check.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: FullName

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object[]
## NOTES

## RELATED LINKS
