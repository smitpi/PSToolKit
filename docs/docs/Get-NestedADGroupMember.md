---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Get-NestedADGroupMember

## SYNOPSIS
Extract users from an AD group recursive, 4 levels deep.

## SYNTAX

```
Get-NestedADGroupMember [[-GroupName] <String>] [[-Export] <String>] [[-ReportPath] <DirectoryInfo>]
 [<CommonParameters>]
```

## DESCRIPTION
Extract users from an AD group recursive, 4 levels deep.

## EXAMPLES

### EXAMPLE 1
```
Get-NestedADGroupMembers -GroupName "Domain Admins"
```

## PARAMETERS

### -GroupName
Name of the group to query.

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
Export the result to a report file.
(Excel or html).
Or select Host to display the object on screen.

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
Where to save the report.

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
