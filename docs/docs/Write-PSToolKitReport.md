---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Write-PSToolKitReport

## SYNOPSIS

Creates a excel or html report

## SYNTAX

### Set1 (Default)

```
Write-PSToolKitReport [[-InputObject <PSObject>]] [[-ReportTitle <String>]] [[-Export <String>]] [[-ReportPath <DirectoryInfo>]] [<CommonParameters>]
```

## DESCRIPTION

Creates a excel or html report


## EXAMPLES

### Example 1: EXAMPLE 1

```
Write-PSToolKitReport -InputObject $data -ReportTitle "Temp Data" -Export HTML -ReportPath C:\temp
```








## PARAMETERS

### -Export

Export the result to a report file.
(Excel or html).
Or select Host to display the object on screen.

```yaml
Type: String
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

### -InputObject

Data  for the report.

```yaml
Type: PSObject
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

### -ReportPath

Where to save the report.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 3
Default value: C:\Temp
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ReportTitle

Title of the report.

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


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## OUTPUTS

### System.Object[]


## NOTES



## RELATED LINKS

Fill Related Links Here

