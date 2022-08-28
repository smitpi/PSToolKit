---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Edit-HostsFile
schema: 2.0.0
---

# Import-XamlConfigFile

## SYNOPSIS
Import the wpf xaml file and create variables from objects

## SYNTAX

```
Import-XamlConfigFile [[-XamlFile] <FileInfo>] [[-FormName] <String>] [-ShowExample] [<CommonParameters>]
```

## DESCRIPTION
Import the wpf xaml file and create variables from objects

## EXAMPLES

### EXAMPLE 1
```
Import-XamlConfigFile -XamlFile D:\MainWindow.xaml -FormName SMainForm
```

## PARAMETERS

### -XamlFile
Path to the xaml file to import

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FormName
The form name variable to be created.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ShowExample
Show example to open the form.

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

## RELATED LINKS
