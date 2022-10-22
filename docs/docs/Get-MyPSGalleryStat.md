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

### InLastDays (Default)
```
Get-MyPSGalleryStat [-GitHubUserID <String>] [-GitHubToken <String>] [-daysToReport <Int32>]
 [<CommonParameters>]
```

### DateRange
```
Get-MyPSGalleryStat [-GitHubUserID <String>] [-GitHubToken <String>] [-Startdate <DateTime>]
 [-EndDate <DateTime>] [<CommonParameters>]
```

## DESCRIPTION
Show stats about my published modules.

## EXAMPLES

### EXAMPLE 1
```
Get-MyPSGalleryStats
```

## PARAMETERS

### -GitHubUserID
The GitHub User ID.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GitHubToken
GitHub Token with access to the Users' Gist.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -daysToReport
Report on this amount of days.

```yaml
Type: Int32
Parameter Sets: InLastDays
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -Startdate
A custom start date for the report.

```yaml
Type: DateTime
Parameter Sets: DateRange
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -EndDate
A custom end date for the report.

```yaml
Type: DateTime
Parameter Sets: DateRange
Aliases:

Required: False
Position: Named
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
