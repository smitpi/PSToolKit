---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Test-CitrixCloudConnector

## SYNOPSIS

Perform basic connection tests to Citrix cloud.

## SYNTAX

### Set1 (Default)

```
Test-CitrixCloudConnector [[-CustomerID <String>]] [[-Export <String>]] [[-ReportPath <DirectoryInfo>]] [<CommonParameters>]
```

## DESCRIPTION

Perform basic connection tests to Citrix cloud.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Test-CitrixCloudConnector -CustomerID yourID
```








## PARAMETERS

### -CustomerID

get from Citrix cloud.

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

### -Export

Export the results

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ReportPath

Where report will be saved.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: "$env:TEMP"
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

