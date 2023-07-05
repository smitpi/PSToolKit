---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Get-CommandFiltered

## SYNOPSIS
Finds commands on the system and sort it according to module

## SYNTAX

```
Get-CommandFiltered [[-Filter] <String>] [-PSToolKit] [-PrettyAnswer] [<CommonParameters>]
```

## DESCRIPTION
Finds commands on the system and sort it according to module

## EXAMPLES

### EXAMPLE 1
```
Get-CommandFiltered -Filter help
```

## PARAMETERS

### -Filter
Limit search

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PSToolKit
Limit search to the PSToolKit Module

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

### -PrettyAnswer
Display results with color, but runs slow.

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

## NOTES
General notes

## RELATED LINKS
