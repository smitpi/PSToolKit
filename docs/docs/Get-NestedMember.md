---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Get-NestedMember

## SYNOPSIS
Find all Nested members of a group

## SYNTAX

```
Get-NestedMember [[-GroupName] <String[]>] [[-RelationShipPath] <String>] [[-MaxDepth] <Int32>]
 [<CommonParameters>]
```

## DESCRIPTION
Find all Nested members of a group

## EXAMPLES

### EXAMPLE 1
```
Get-NestedMember -GroupName TESTGROUP,TESTGROUP2
```

## PARAMETERS

### -GroupName
Specify one or more GroupName to audit

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RelationShipPath
Specify one or more GroupName to audit

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

### -MaxDepth
How deep to search.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
