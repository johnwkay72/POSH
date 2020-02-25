# --------------------------------------------------------------------------- #
# POSH ESP_Base
# --------------------------------------------------------------------------- #
#region - SYNOPSIS:

<#
.SYNOPSIS

This is the base script for all other scripts.  It is required to be on every
server so that other scripts can run.

.DESCRIPTION

This is the base script for all other scripts.  It is required to be on every
server so that other scripts can run.  It sets up the following:
    1) Variables for the DOMAIN
    2) Basic Varibles and arrays used
    3) Displays the DOMAIN information.
    4) Sets variables for all of the sites within a given Solution DOMAIN.
        a) Sets any sub-array

.INPUTS

None. You cannot pipe objects to Add-Extension.

.OUTPUTS

Transcript to an output directory.

#>

#endregion
# --------------------------------------------------------------------------- #
#region - ESP_BASE_ITEMS:
<#
To call the BASE ITEMS use one of the following methods:
    .\ESP_Base.ps1
    invoke-expression -Command .\ESP_Base.ps1
    & "<path>\ESP_Base.ps1"

#>
# --------------------------------------------------------------------------- #
#region - SET THE ENVIRONMENT / SMTP SERVER.
    
    # CLEAR REGION VARIABLES:
        $ErrorActionPreference = "SilentlyContinue" ;
        Clear-Variable FQD,domain,domENV,smtpFROM,smtp,baseURL ;
        $ErrorActionPreference = "Continue" ;

    # GET LOCAL DOMAIN:
        $FQD = (Get-WmiObject win32_computersystem).Domain ;
    
    # SET DOMAIN VARIABLES:
        if ($FQD -like 'DEVdomain.com') 
            {
            $domain='DEV'
            $domENV='DEV'
            $smtpFROM='DEV@DEVdomain.com'
            $smtp='<IP Address>'
            $baseURL = "https://URL.com"
            }
        if ($FQD -like 'dom01.domain.com') 
            {
            $domain='dom01'
            $exoENV='dom01'
            $smtpFROM='dom01@domain.com'
            $smtp='10.10.1.5'
            $baseURL = "https://site.dom01.domain.com"
            }
        # ADD AS MANY AS YOU NEED ...
        
#endregion
# --------------------------------------------------------------------------- #
#region - SET VARIABLES & ARRAYS:

    # CLEAR REGION VARIABLES:
        $ErrorActionPreference = "SilentlyContinue" ;
        Clear-Variable timeSTAMP,line,pad,smtp_regex,outpath,cID_regex ;
        $ErrorActionPreference = "Continue" ;

    $timestamp = (Get-Date -Format "yyyyMMdd-HHmm") ;
    $line = "# --------------------------------------------------------------------------- #" ;
    $pad = "60" ;
    $smtp_regex = "(^[A-Za-z0-9]+)(.)([A-Za-z0-9]+)(@)(exostar.com)" ;
    $outPATH = "C:\<path>\SCRIPTS\OUTPUT" ; # OR WHATEVER PATH YOU USE

    # WORKING THESE INTO PROMPTS:
    #   $outNAME = "${timeSTAMP}_${$domENV}_logs" ;
    #   $outFILE = "${outPATH}\${outNAME}.log" ;
    #   $zipFILE = "${outPATH}\${outNAME}.zip" ;
    
    # CORRELATIONID REGEX:
    #   SAMPLE: F0BB0790-4323-A153-096F-ABCDC80E24D4
        $cID_regex = "(^[A-z0-9]{8})(-)([A-z0-9]{4})(-)([A-z0-9]{4})(-)([A-z0-9]{4})(-)([A-z0-9]{12})" ;
    
    # SET ARRAY(S):
        # TBD

#endregion
# --------------------------------------------------------------------------- #
#region - SCREEN OUTPUT:
    Write-Host $line ;
    Write-Host "Environment detected was ...: " -NoNewLine ; Write-Host -F Green "$domain ";
    Write-Host "Base URL is ................: " -NoNewLine ; Write-Host -F Green "$baseUrl " ;
    Write-Host "SMTP FROM ..................: " -NoNewLine ; Write-Host -F Green "$smtpFROM " ;
    Write-Host "SMTP Server is .............: " -NoNewLine ; Write-Host -F Green "$smtp " ;
    Write-Host $line ;
#endregion
# --------------------------------------------------------------------------- #
#region - SiteURLS / FARM:
    # ----------------------------------------------------------------------- #
    #region - CLEAR REGION VARIABLES:
        $ErrorActionPreference = "SilentlyContinue" ;
            Clear-Variable env01* ;
            Clear-Variable env03* ;
        $ErrorActionPreference = "Continue" ;

    #endregion
    # ----------------------------------------------------------------------- #
    #region - DOMAIN 01:
    if ($dom01ENV='dom01')
        {
        $dom01_URL01 = 'https://site01.domain.com/'
        $dom01_URL02 = 'https://site01.domain.com/'
        }
    #endregion
    # ----------------------------------------------------------------------- #
    #region - DOMAIN 02
    if ($exoENV='dom02')
        {
        $dom02_URL01 = 'https://site01.dom02.com/'
        $dom02_URL02 = 'https://site02.dom02.com/'
        # SUB-SET:
            $dom02_subARRAY01 = @()
            $dom02_subARRAY01 += "https://siteA.dom02.com/subSITE01"
            $dom02_subARRAY01 += "https://siteA.dom02.com/subSITE02"
            $subscriptions = @() ;
            $subscriptions += "TBD01" ;
            $subscriptions += "TBD02" ;
        }
    #endregion
    # ----------------------------------------------------------------------- #

#endregion
# --------------------------------------------------------------------------- #
    Start-Transcript -OutputDirectory $outPATH

#endregion
# --------------------------------------------------------------------------- #
# END
