---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Get-ServerInventory

## SYNOPSIS
Connect to remote host and collect server details.

## SYNTAX

```
Get-ServerInventory [-ComputerName] <String[]> [[-Credentials] <PSCredential>] [-Export <String[]>]
 [-ReportPath <DirectoryInfo>] [<CommonParameters>]
```

## DESCRIPTION
Connect to remote host and collect server details.

## EXAMPLES

### EXAMPLE 1
```
Get-ServerInventory -ComputerName '172.16.72.198', '172.16.72.200' -Export Excel,HTML -ReportPath C:\temp\reports
```

## PARAMETERS

### -ComputerName
Computer to scan.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: CN, host

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Credentials
Credentials used for the connection.

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
Export the report to html or excel.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
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

### System.Object[]
## NOTES

## RELATED LINKS
