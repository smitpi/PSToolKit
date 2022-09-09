---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# New-SuggestedInfraName

## SYNOPSIS

Generates a list of usernames and server names, that can be used as test / demo data.

## SYNTAX

### Set1 (Default)

```
New-SuggestedInfraName [[-OS <String>]] [[-Export <String>]] [[-ReportPath <DirectoryInfo>]] [<CommonParameters>]
```

## DESCRIPTION

Generates a list of usernames and server names, that can be used as test / demo data.


## EXAMPLES

### Example 1: EXAMPLE 1

```
New-SuggestedInfraNames -OS VDI -Export Excel -ReportPath C:\temp
```








## PARAMETERS

### -Export

Export the results.

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

### -OS

The Type of server names to generate.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 0
Default value: SVR
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ReportPath

Where to save the data.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: C:\Temp
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

