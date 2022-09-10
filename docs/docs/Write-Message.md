---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Write-Message

## SYNOPSIS
Writes the given into to screen

## SYNTAX

```
Write-Message [[-Action] <String>] [[-Severity] <String>] [[-BeforeMessage] <String[]>]
 [[-BeforeMessageColor] <String[]>] [[-Object] <String[]>] [[-AfterMessage] <String[]>]
 [[-AfterMessageColor] <String[]>] [[-InsertTabs] <Int32>] [[-LinesBefore] <Int32>] [[-LinesAfter] <Int32>]
 [-NoNewLine] [<CommonParameters>]
```

## DESCRIPTION
Writes the given into to screen

## EXAMPLES

### EXAMPLE 1
```
Write-Message -Action Getting -Severity Information -Object (get-item .) -Message "This is","the directory","you are in." -MessageColor Cyan,DarkGreen,DarkRed
```

## PARAMETERS

### -Action
Action for the object.

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

### -Severity
Severity of the entry.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Information
Accept pipeline input: False
Accept wildcard characters: False
```

### -BeforeMessage
{{ Fill BeforeMessage Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BeforeMessageColor
{{ Fill BeforeMessageColor Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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

Required: False
Position: 5
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -AfterMessage
{{ Fill AfterMessage Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Message

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AfterMessageColor
{{ Fill AfterMessageColor Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: MessageColor

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InsertTabs
Insert tabs before writing the text.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -LinesBefore
Insert Blank Lines before Output.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -LinesAfter
Insert Blank Lines After Output.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 10
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoNewLine
Wont add a new line after writing to screen.

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

### System.String[]
## NOTES

## RELATED LINKS
