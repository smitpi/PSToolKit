---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Write-PSToolKitMessage

## SYNOPSIS
Writes the given into to screen

## SYNTAX

```
Write-PSToolKitMessage [-Action] <String> [-Severity] <String> [-Object] <String[]> [-Message] <String[]>
 [<CommonParameters>]
```

## DESCRIPTION
Writes the given into to screen

## EXAMPLES

### EXAMPLE 1
```
dir | Write-PSToolKitMessage -Action Exists -Severity Information -Message 'its already there'
```

## PARAMETERS

### -Action
Action for the object.

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

### -Severity
Severity of the entry.

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

### -Object
The object to be reported on.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Message
The Details.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
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
