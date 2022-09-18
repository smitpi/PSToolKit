---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Reset-Module

## SYNOPSIS
Removes and force import a module.

## SYNTAX

```
Reset-Module [-Name] <String> [<CommonParameters>]
```

## DESCRIPTION
Removes and force import a module.

## EXAMPLES

### EXAMPLE 1
```
Reset-Module -Export HTML -ReportPath C:\temp
```

## PARAMETERS

### -Name
Specify the name of the module.

```yaml
Type: String
Parameter Sets: (All)
Aliases: ModuleName

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

### System.Object[]
## NOTES

## RELATED LINKS
