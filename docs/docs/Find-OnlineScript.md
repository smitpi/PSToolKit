---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Find-OnlineScript

## SYNOPSIS

Creates reports based on PSGallery. Filtered by scripts

## SYNTAX

### __AllParameterSets

```
Find-OnlineScript [[-Keyword <String>]] [-Export <String>] [-MaxCount <Int32>] [-NoAzureAWS] [-Offline] [-ReportPath <DirectoryInfo>] [-SortOrder <String>] [-UpdateCache] [<CommonParameters>]
```

## DESCRIPTION

Creates reports based on PSGallery.
You can search for a keyword, and also exclude azure and aws scripts.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Find-OnlineScript -Keyword Citrix -Offline -SortOrder Downloads -Export Excel -ReportPath C:\temp
```








## PARAMETERS

### -Export

Export the result to a file.
(Excel or markdown)

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -Keyword

Limit the search to a keyword.

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

### -MaxCount

Limit the amount of scripts to report, default is 250.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: 250
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -NoAzureAWS

This will exclude scripts with AWS and Azure in the name.

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

### -Offline

Uses a previously downloaded cache for the search.
If the cache doesn't exists, it will be created.

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

### -ReportPath

Where to save the report.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -SortOrder

Determines if the report will be sorted on the amount of downloads or the newest scripts.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: Downloads
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -UpdateCache

Update the local cache.

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

## NOTES



## RELATED LINKS

Fill Related Links Here

