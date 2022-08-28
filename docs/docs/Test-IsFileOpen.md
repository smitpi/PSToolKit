---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Edit-HostsFile
schema: 2.0.0
---

# Test-IsFileOpen

## SYNOPSIS
Checks if a file is open

## SYNTAX

```
Test-IsFileOpen [-Path] <String[]> [-FilterOpen] [<CommonParameters>]
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

### -FilterOpen
Only show open files.

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

### System.Object[]
## NOTES

## RELATED LINKS
