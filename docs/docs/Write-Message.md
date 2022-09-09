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

### __AllParameterSets

```
Write-Message [[-Action <String>]] [[-Severity <String>]] [[-BeforeMessage <String[]>]] [[-BeforeMessageColor <String[]>]] [[-Object <String[]>]] [[-AfterMessage <String[]>]] [[-AfterMessageColor <String[]>]] [[-InsertTabs <Int32>]] [[-LinesBefore <Int32>]] [[-LinesAfter <Int32>]] [-NoNewLine] [<CommonParameters>]
```

## DESCRIPTION

Writes the given into to screen


## EXAMPLES

### Example 1: EXAMPLE 1

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
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -AfterMessage

Message to display after object.
This can be an array of strings as well, to have different colors in the text.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: Message
Accepted values: 

Required: True (None) False (All)
Position: 5
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -AfterMessageColor

The Colour of the corresponding message in the array.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: MessageColor
Accepted values: 

Required: True (None) False (All)
Position: 6
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -BeforeMessage

Message to display before object.
This can be an array of strings as well, to have different colors in the text.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -BeforeMessageColor

The Colour of the corresponding message in the array.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 3
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -InsertTabs

Insert tabs before writing the text.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 7
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -LinesAfter

Insert Blank Lines After Output.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 9
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -LinesBefore

Insert Blank Lines before Output.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 8
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -NoNewLine

Wont add a new line after writing to screen.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Object

The object to be reported on.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 4
Default value: 
Accept pipeline input: True
Accept wildcard characters: False
DontShow: False
```

### -Severity

Severity of the entry.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: Information
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.String[]


## NOTES



## RELATED LINKS

Fill Related Links Here

