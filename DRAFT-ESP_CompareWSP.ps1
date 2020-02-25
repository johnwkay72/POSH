# --------------------------------------------------------------------------- #
# DRAFT-ESP_Compare-WSP
# --------------------------------------------------------------------------- #
#region - SYNOPSIS:

<#
.SYNOPSIS

Adds a file name extension to a supplied name.

.DESCRIPTION

Adds a file name extension to a supplied name.
Takes any strings for the file name or extension.

.PARAMETER Name
Specifies the file name.

.PARAMETER Extension
Specifies the extension. "Txt" is the default.

.INPUTS

None. You cannot pipe objects to Add-Extension.

.OUTPUTS

System.String. Add-Extension returns a string with the extension
or file name.

.EXAMPLE

PS> extension -name "File"
File.txt

.EXAMPLE

PS> extension -name "File" -extension "doc"
File.doc

.EXAMPLE

PS> extension "File" "doc"
File.doc

.LINK

http://www.fabrikam.com/extension.html

.LINK

Set-Item
#>


#endregion
# --------------------------------------------------------------------------- #
#region - LOAD MODULES:
    
    if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null)
        {Add-PSSnapin "Microsoft.SharePoint.PowerShell"} ;

#endregion
# --------------------------------------------------------------------------- #
#region - CLEAR VARIABLES:
    $ErrorActionPreference = "SilentlyContinue" ;
    Clear-Variable FQD,domain,exoENV,smtpFROM,smtp,baseURL ;
    Clear-Variable timeSTAMP,line,pad,smtp_regex,outpath ;

    Clear-Variable outNAME,outFILE,zipFILE,cID_regex ;
    Clear-Variable chkTO,smtpTO,gotID,resp01,chkID,cID ;
    Clear-Variable startTIME,startDATE,start,sDATE ;
    Clear-Variable endTIME,endDATE,end,eDATE ;
    Clear-Variable sourceFILE,caCOMPAT,psvm,ok1  ;

    Clear-Variable SiteCollections,site,web  ;
    $ErrorActionPreference = "Continue" ;
#endregion
# --------------------------------------------------------------------------- #
#region - SET THE ENVIRONMENT / SMTP SERVER.
    $FQD = (Get-WmiObject win32_computersystem).Domain ;
    
    if ($FQD -like 'dev.com') 
        {
        $domain='DEV'
        $exoENV='DEV'
        # $smtpFROM='APP-DEV@domain.com'
        # $smtp='10.10.1.x'
        $baseURL = "https://SPsite.dev.domain.com"
        }
    if ($FQD -like 'site01.domain.com') 
        {
        $domain='site01'
        $exoENV='APP-ENV'
        $exoDC='TBD'
        $smtpFROM='APP-ENV@domain.com'
        $smtp='10.10.1.x'
        $baseURL = "https://SPsite.ENV.domain.com"
        }
    
#endregion
# --------------------------------------------------------------------------- #
#region - SET VARIABLES & ARRAYS:
    
    $timestamp = (Get-Date -Format "yyyyMMdd-HHmm") ;
    $line = "# --------------------------------------------------------------------------- #" ;
    $pad = "60" ;
    $smtp_regex = "(^[A-Za-z0-9]+)(.)([A-Za-z0-9]+)(@)(exostar.com)" ;
    $outPATH = "C:\path\SCRIPTS\OUTPUT" ;
   
    # CORRELATIONID REGEX:
    #   SAMPLE: F0BB0790-4323-A153-096F-ABCDC80E24D4
        $cID_regex = "(^[A-z0-9]{8})(-)([A-z0-9]{4})(-)([A-z0-9]{4})(-)([A-z0-9]{4})(-)([A-z0-9]{12})" ;
    
    # SET ARRAY(S):
        # TBD

#endregion
# --------------------------------------------------------------------------- #
#region - SCRENN OUTPUT:
    Write-Host $line ;
    Write-Host "Environment detected was ...: " -NoNewLine ; Write-Host -F Green "$domain ";
    Write-Host "Base URL is ................: " -NoNewLine ; Write-Host -F Green "$baseUrl " ;
    Write-Host "SMTP FROM ..................: " -NoNewLine ; Write-Host -F Green "$smtpFROM " ;
    Write-Host "SMTP Server is .............: " -NoNewLine ; Write-Host -F Green "$smtp " ;
    Write-Host $line ;
#endregion
# --------------------------------------------------------------------------- #

$farm = Get-SPFarm

$file = $farm.Solutions.Item("documentencryption.wsp").SolutionFile

$file.SaveAs("c:\path\extract.wsp")

Compare-Object -ReferenceObject (Get-Content -Path C:\path\DocumentEncryption.wsp.CAB) -DifferenceObject (Get-Content C:\path\extract.CAB) -IncludeEqual

# --------------------------------------------------------------------------- #
# END
