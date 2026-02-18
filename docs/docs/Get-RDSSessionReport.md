---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Get-RDSSessionReport

## SYNOPSIS
Reports on Connects and Disconnects on a RDS Farm.

## SYNTAX

```
Get-RDSSessionReport [-Gateway] <String> [[-UserName] <String>] [[-Credential] <PSCredential>]
 [-Export <String[]>] [-ReportPath <DirectoryInfo>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Reports on Connects and Disconnects on a RDS Farm.

## EXAMPLES

### EXAMPLE 1
```
Get-RDSSessionReport -Gateway TXGATE01 -Credential $admin -Export Excel,HTML -ReportPath C:\Temp\rds
```

## PARAMETERS

### -Gateway
Gateway server name for RDS Farm.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserName
Filter to report only on this user.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Account with RDS Admin Access.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
Export the results to a report.

```yaml
Type: String[]
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

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

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
