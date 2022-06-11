---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Install-LocalPSRepository
schema: 2.0.0
---

# New-SuggestedInfraName

## SYNOPSIS
Generates a list of usernames and server names, that can be used as test / demo data.

## SYNTAX

```
New-SuggestedInfraName [[-OS] <String>] [[-Export] <String>] [[-ReportPath] <DirectoryInfo>]
 [<CommonParameters>]
```

## DESCRIPTION
Generates a list of usernames and server names, that can be used as test / demo data.

## EXAMPLES

### EXAMPLE 1
```
New-SuggestedInfraNames -OS VDI -Export Excel -ReportPath C:\temp
```

## PARAMETERS

### -OS
The Type of server names to generate.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: SVR
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
Export the results.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportPath
Where to save the data.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: C:\Temp
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
