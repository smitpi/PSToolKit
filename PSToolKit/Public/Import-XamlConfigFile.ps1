
<#PSScriptInfo

.VERSION 0.1.0

.GUID 162c8d62-3261-48af-999f-bd5e515ae5ba

.AUTHOR Pierre Smit

.COMPANYNAME HTPCZA Tech

.COPYRIGHT

.TAGS wpf

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES
Created [21/01/2022_18:20] Initial Script Creating

.PRIVATEDATA

#>


<# 

.DESCRIPTION 
 Import the wpf xaml file and create variables from objects 

#> 

<#
.SYNOPSIS
Import the wpf xaml file and create variables from objects

.DESCRIPTION
Import the wpf xaml file and create variables from objects

.PARAMETER XamlFile
Path to the xaml file to import

.PARAMETER FormName
The form name variable to be created.

.PARAMETER ShowExample
Show example to open the form.


.EXAMPLE
Import-XamlConfigFile -XamlFile D:\MainWindow.xaml -FormName SMainForm

#>
Function Import-XamlConfigFile {
    [Cmdletbinding(HelpURI = 'https://smitpi.github.io/PSToolKit/Import-XamlConfigFile')]

    PARAM(
        [ValidateScript( { (Test-Path $_) -and ((Get-Item $_).Extension -eq '.xaml') })]
        [System.IO.FileInfo]$XamlFile,
        [string]$FormName,
        [switch]$ShowExample
    )

    $inputXAML = Get-Content -Path $xamlFile -Raw

    $inputXAML = $inputXAML -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '^<Win.*', '<Window'
    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    [xml]$XAML = $inputXAML

    #Check for a text changed value (which we cannot parse)
    If ($xaml.SelectNodes('//*[@Name]') | Where-Object TextChanged) {
        Write-Error "This Snippet can't convert any lines which contain a 'textChanged' property. `n please manually remove these entries"
        $xaml.SelectNodes('//*[@Name]') | Where-Object TextChanged | ForEach-Object { Write-Warning "Please remove the TextChanged property from this entry $($_.Name)" }
        return
    }

    #Read XAML

    $reader = (New-Object System.Xml.XmlNodeReader $xaml) 
    try {
        $Form = [Windows.Markup.XamlReader]::Load( $reader )
        New-Variable -Name $FormName -Value $Form -Force -Scope global
    }
    catch [System.Management.Automation.MethodInvocationException] {
        Write-Warning 'We ran into a problem with the XAML code.  Check the syntax for this control...'
        Write-Host $error[0].Exception.Message -ForegroundColor Red
        if ($error[0].Exception.Message -like '*button*') {
            Write-Warning "Ensure your &lt;button in the `$inputXML does NOT have a Click=ButtonClick property.  PS can't handle this`n`n`n`n"
        }
    }
    catch {
        #if it broke some other way :D
        Write-Host 'Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed.'
    }

    #===========================================================================
    # Store Form Objects In PowerShell
    #===========================================================================

    $xaml.SelectNodes('//*[@Name]') | ForEach-Object { New-Variable -Name "WPF_$($_.Name)" -Value $Form.FindName($_.Name) -Scope global -Force }

    Function Get-FormVariables {
        if ($global:ReadmeDisplay -ne $true) { Write-Host 'If you need to reference this display again, run Get-FormVariables' -ForegroundColor Yellow; $global:ReadmeDisplay = $true }
        Write-Host 'Found the following interactable elements from our form' -ForegroundColor Cyan
        Get-Variable WPF*
    }
    

    Get-FormVariables

    if ($ShowExample) {

        Write-Output @"
#Adding code to a button, so that when clicked, it pings a system
`$WPF_button.Add_Click({ Test-connection -count 1 -ComputerName `$WPFtextBox.Text
})
#===========================================================================
# Shows the form
#===========================================================================
write-host "To show the form, run the following" -ForegroundColor Cyan
`$$FormName.ShowDialog() | out-null
"@
    }

    #===========================================================================
    # Use this space to add code to the various form elements in your GUI
    #===========================================================================

    #Reference

    #Adding items to a dropdown/combo box
    #$vmpicklistView.items.Add([pscustomobject]@{'VMName'=($_).Name;Status=$_.Status;Other="Yes"})

    #Setting the text of a text box to the current PC name
    #$WPFtextBox.Text = $env:COMPUTERNAME

    #Adding code to a button, so that when clicked, it pings a system
    # $WPFbutton.Add_Click({ Test-connection -count 1 -ComputerName $WPTextBox.Text
    # })
    #===========================================================================
    # Shows the form
    #===========================================================================
    # write-host "To show the form, run the following" -ForegroundColor Cyan
    # '$Form.ShowDialog() | out-null'




} #end Function
