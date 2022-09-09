---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Find-OnlineScript

## SYNOPSIS
Creates reports based on PSGallery.
Filtered by scripts

## SYNTAX

```
Find-OnlineScript [[-Keyword] <String>] [-NoAzureAWS] [-MaxCount <Int32>] [-Offline] [-UpdateCache]
 [-SortOrder <String>] [-Export <String>] [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION
Creates reports based on PSGallery.
You can search for a keyword, and also exclude azure and aws scripts.

## EXAMPLES

### EXAMPLE 1
```
Find-OnlineScript -Keyword Citrix -Offline -SortOrder Downloads -Export Excel -ReportPath C:\temp
```

## PARAMETERS

### -Keyword
Limit the search to a keyword.

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

### -NoAzureAWS
This will exclude scripts with AWS and Azure in the name.

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

### -MaxCount
Limit the amount of scripts to report, default is 250.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 250
Accept pipeline input: False
Accept wildcard characters: False
```

### -Offline
Uses a previously downloaded cache for the search.
If the cache doesn't exists, it will be created.

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

### -UpdateCache
Update the local cache.

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

### -SortOrder
Determines if the report will be sorted on the amount of downloads or the newest scripts.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Downloads
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
Export the result to a file.
(Excel or markdown)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportPath
Where to save the report.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
