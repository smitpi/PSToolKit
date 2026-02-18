---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version:
schema: 2.0.0
---

# Start-DomainControllerReplication

## SYNOPSIS
Start replication between Domain Controllers.

## SYNTAX

```
Start-DomainControllerReplication [-Credential] <PSCredential> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Start replication between Domain Controllers.

## EXAMPLES

### EXAMPLE 1
```
Start-DomainControllerReplication -Credential $Admin
```

## PARAMETERS

### -Credential
AD Domain Admin Credentials.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
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
