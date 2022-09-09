---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Get-MyPSGalleryStat

## SYNOPSIS

Show stats about my published modules.

## SYNTAX

### __AllParameterSets

```
Get-MyPSGalleryStat [[-GitHubUserID <String>]] [[-GitHubToken <String>]] [[-daysToReport <Int32>]] [<CommonParameters>]
```

## DESCRIPTION

Show stats about my published modules.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Get-MyPSGalleryStats
```








## PARAMETERS

### -daysToReport

Report on this amount of days.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -GitHubToken

GitHub Token with access to the Users' Gist.

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

### -GitHubUserID

The GitHub User ID.

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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.Object[]


## NOTES



## RELATED LINKS

Fill Related Links Here

