---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Import-XamlConfigFile

## SYNOPSIS

Import the wpf xaml file and create variables from objects

## SYNTAX

### __AllParameterSets

```
Import-XamlConfigFile [[-XamlFile <FileInfo>]] [[-FormName <String>]] [-ShowExample] [<CommonParameters>]
```

## DESCRIPTION

Import the wpf xaml file and create variables from objects


## EXAMPLES

### Example 1: EXAMPLE 1

```
Import-XamlConfigFile -XamlFile D:\MainWindow.xaml -FormName SMainForm
```








## PARAMETERS

### -FormName

The form name variable to be created.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ShowExample

Show example to open the form.

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

### -XamlFile

Path to the xaml file to import

```yaml
Type: FileInfo
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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

