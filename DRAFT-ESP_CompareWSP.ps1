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
    
    if ($FQD -like 'tws.com') 
        {
        $domain='DEV'
        $exoENV='DEV'
        # $smtpFROM='EZM-PROD@exostar.com'
        # $smtp='10.36.9.9'
        $baseURL = "https://mysite.dcapp23.tws.com"
        }
    elseif ($FQD -like 'MPF.exostar.com') 
        {
        $domain='MPF'
        $exoENV='EZM-PROD'
        $exoDC=''
        $smtpFROM='EZM-PROD@exostar.com'
        $smtp='10.36.9.9'
        $baseURL = "https://mysite.mpfqa.exostartest.com"
        }
    elseif ($FQD -like "FPX.exostar.com") 
        {
        $domain='FPX'
        $exoENV='FPv6-US'
        $smtpFROM='FPv6-US@exostar.com'
        $smtp='10.36.9.9'
        # $baseURL = "https://mysite.mpfqa.exostartest.com"
        }
    elseif ($FQD -like "fpx-mpi.exostar.com") 
        {
        $domain='FPK-MPI'
        $exoENV='FPv6-UK'
        $smtpFROM='FPv6UK@exostar.com'
        $smtp='10.38.19.6'
        # $baseURL = "https://mysite.mpfqa.exostartest.com"
        }
    elseif ($FQD -like "FPX1.exostartest.com") 
        {
        $domain='FPX1'
        $exoENV='FPv6-UAT'
        $smtpFROM='FPv6-UAT@exostar.com'
        $smtp='10.248.3.4'
        # $baseURL = "https://mysite.mpfqa.exostartest.com"
        }
    elseif ($FQD -like "test.fp.local") 
        {
        $domain='TEST'
        $exoENV='FPv7-QA'
        $smtpFROM='FPv7-QA@exostar.com'
        $smtp='10.248.3.4'
        $baseURL = "https://main.fpqa.exostartest.com"
        }
    elseif ($FQD -like "uat.fp.local") 
        {
        $domain='UAT'
        $exoENV='FPv7-UAT'
        $smtpFROM='FPv7-UAT@exostar.com'
        $smtp='ns1.exostartest.com'
        $baseURL = "https://main.fpuat.exostartest.com"
        }
    elseif ($FQD -like "fpx.exostar.com") 
        {
        $domain='FPX'
        $exoENV='FPv7-PROD'
        $smtpFROM='FPv7-PRD@exostar.com'
        $smtp='10.36.9.9'
        $baseURL = "https://main.fp7s.exostar.com"
        }
    elseif ($FQD -like "MPF.exostartest.com") 
        {
        $domain='MPF'
        $exoENV='EZM-UAT'
        $smtpFROM='EZM-UAT@exostar.com'
        $smtp='10.248.3.4'
        $baseURL = "https://mysite.mpf.exostartest.com"
        }
    elseif ($FQD -like "MPFQA.exostartest.com") 
        {
        $domain='MPFQA'
        $exoENV='EZM-QA'
        $smtpFROM='EZM-QA@exostar.com'
        $smtp='10.248.3.4'
        $baseURL="https://mysite.mpfqa.exostartest.com"
        }

#endregion
# --------------------------------------------------------------------------- #
#region - SET VARIABLES & ARRAYS:
    
    $timestamp = (Get-Date -Format "yyyyMMdd-HHmm") ;
    $line = "# --------------------------------------------------------------------------- #" ;
    $pad = "60" ;
    $smtp_regex = "(^[A-Za-z0-9]+)(.)([A-Za-z0-9]+)(@)(exostar.com)" ;
    $outPATH = "C:\TECHOPS\SCRIPTS\OUTPUT" ;
   
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

$file.SaveAs("c:\TECHOPS\extract.wsp")

Compare-Object -ReferenceObject (Get-Content -Path C:\TECHOPS\DocumentEncryption.wsp.CAB) -DifferenceObject (Get-Content C:\TECHOPS\extract.CAB) -IncludeEqual

# --------------------------------------------------------------------------- #
# END