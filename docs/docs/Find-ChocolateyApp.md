---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Find-ChocolateyApp

## SYNOPSIS

Search the online repo for software

## SYNTAX

### Set1 (Default)

```
Find-ChocolateyApp [-SearchString] <String> [[-SelectTop <Int32>]] [-GridView] [-TableView] [<CommonParameters>]
```

## DESCRIPTION

Search the online repo for software


## EXAMPLES

### Example 1: EXAMPLE 1

```
Find-ChocolateyApps -SearchString Citrix
```








## PARAMETERS

### -GridView

Open in grid view.

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

### -SearchString

What to search for.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -SelectTop

Limit the results

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: 25
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -TableView

Open in table view.

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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.Object[]


## NOTES



## RELATED LINKS

Fill Related Links Here

