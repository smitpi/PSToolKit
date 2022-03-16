---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Find-ChocolateyApps

## SYNOPSIS
Search the online repo for software

## SYNTAX

```
Find-ChocolateyApps [-SearchString] <String> [[-SelectTop] <Int32>] [-GridView] [-TableView]
 [<CommonParameters>]
```

## DESCRIPTION
Search the online repo for software

## EXAMPLES

### EXAMPLE 1
```
Find-ChocolateyApps -SearchString Citrix
```

## PARAMETERS

### -SearchString
What to search for.

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

### -SelectTop
Limit the results

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 25
Accept pipeline input: False
Accept wildcard characters: False
```

### -GridView
Open in grid view.

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

### -TableView
Open in table view.

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
