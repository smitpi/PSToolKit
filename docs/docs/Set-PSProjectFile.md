---
external help file: PSToolKit-help.xml
Module Name: PSToolKit
online version: 
schema: 2.0.0
---

# Set-PSProjectFile

## SYNOPSIS

Creates and modify needed files for a PS project from existing module files.

## SYNTAX

### __AllParameterSets

```
Set-PSProjectFile [-ModuleScriptFile] <FileInfo> [[-VersionBump <String>]] [[-ReleaseNotes <String>]] [-BuildHelpFiles] [-CopyNestedModules] [-CopyToModulesFolder] [-DeployMKDocs] [-GitPush] [-ShowReport] [<CommonParameters>]
```

## DESCRIPTION

Creates and modify needed files for a PS project from existing module files.


## EXAMPLES

### Example 1: EXAMPLE 1

```
Set-PSProjectFiles -ModuleScriptFile blah.psm1 -VersionBump Minor -mkdocs serve
```








## PARAMETERS

### -BuildHelpFiles

Use Platyps to build markdown help files.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -CopyNestedModules

Will copy the required modules to the nested modules folder.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -CopyToModulesFolder

Copies the module to program files.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -DeployMKDocs

Create or test the mkdocs site

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -GitPush

Run Git Push when done.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ModuleScriptFile

Path to module .psm1 file.

```yaml
Type: FileInfo
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (All) False (None)
Position: 0
Default value: 
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ReleaseNotes

Add release notes to the manifest file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 2
Default value: Updated Module Online Help Files
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -ShowReport

Will open the issues report in a browser.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```

### -VersionBump

This will increase the version of the module.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 
Accepted values: 

Required: True (None) False (All)
Position: 1
Default value: Revision
Accept pipeline input: False
Accept wildcard characters: False
DontShow: False
```


### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## NOTES



## RELATED LINKS

Fill Related Links Here

