---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Get-DotNetVersions

## SYNOPSIS
List all the installed versions of .net.

## SYNTAX

```
Get-DotNetVersions [-ComputerName] <String[]> [[-Credential] <PSCredential>] [[-Export] <String[]>]
 [[-ReportPath] <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION
List all the installed versions of .net.

## EXAMPLES

### EXAMPLE 1
```
Get-DotNetVersions -ComputerName RDS01 -Export HTML -ReportPath C:\temp
```

## PARAMETERS

### -ComputerName
The computer to query.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Credential
Credentials to use.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
Export results

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Host
Accept pipeline input: False
Accept wildcard characters: False
```

### -ReportPath
Path where report will be saved

```yaml
Type: DirectoryInfo
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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
