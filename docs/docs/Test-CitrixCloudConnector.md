---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: https://smitpi.github.io/PSToolKit/Edit-HostsFile
schema: 2.0.0
---

# Test-CitrixCloudConnector

## SYNOPSIS
Perform basic connection tests to Citrix cloud.

## SYNTAX

```
Test-CitrixCloudConnector [[-CustomerID] <String>] [[-Export] <String>] [[-ReportPath] <DirectoryInfo>]
 [<CommonParameters>]
```

## DESCRIPTION
Perform basic connection tests to Citrix cloud.

## EXAMPLES

### EXAMPLE 1
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

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
Export the results

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
Where report will be saved.

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: "$env:TEMP"
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
