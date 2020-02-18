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
        a) Sets the Kongberg-US array
        b) Sets the Kongberg-UK array

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
        Clear-Variable FQD,domain,exoENV,smtpFROM,smtp,baseURL ;
        $ErrorActionPreference = "Continue" ;

    # GET LOCAL DOMAIN:
        $FQD = (Get-WmiObject win32_computersystem).Domain ;
    
    # SET DOMAIN VARIABLES:
        if ($FQD -like 'tws.com') 
            {
            $domain='DEV'
            $exoENV='DEV'
            $smtpFROM='EZM-DEV@exostar.com'
            $smtp=''
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

    # CLEAR REGION VARIABLES:
        $ErrorActionPreference = "SilentlyContinue" ;
        Clear-Variable timeSTAMP,line,pad,smtp_regex,outpath,cID_regex ;
        $ErrorActionPreference = "Continue" ;

    $timestamp = (Get-Date -Format "yyyyMMdd-HHmm") ;
    $line = "# --------------------------------------------------------------------------- #" ;
    $pad = "60" ;
    $smtp_regex = "(^[A-Za-z0-9]+)(.)([A-Za-z0-9]+)(@)(exostar.com)" ;
    $outPATH = "C:\TECHOPS\SCRIPTS\OUTPUT" ;

    # <-----------------------------> 
    # 80 columns per line to the file

    # POSSIBLE NEW STANDARD VARIABLES;
    <#
        $cdBASE = "Y:\COLLAB"
        $cdSCRIPTS = "Y:\COLLAB\SCRIPTS"
        $cdOUTPUT = "Y:\COLLAB\OUTPUT"
        $cdDROPZONE = "Y:\COLLAB\DROPZONE"
        $cdDEPLOY = "Y:\COLLAB\DEPLOY"
    #>
    
    # WORKING THESE INTO PROMPTS:
    #   $outNAME = "${timeSTAMP}_${$exoENV}_MULS_logs" ;
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
            Clear-Variable FPUKv6* ;
            Clear-Variable FPUSv6* ;
            Clear-Variable EZMv6* ;
            Clear-Variable FPv7* ;
            Clear-Variable FPUSv7* ;
        $ErrorActionPreference = "Continue" ;

    #endregion
    # ----------------------------------------------------------------------- #
    #region - FPUS-UAT: (FPUSv6U)
    if ($exoENV='FPv6-UAT')
        {
        $FPUSv6U_APPS = 'https://apps.exostartest.com/'
        $FPUSv6U_BAES = 'https://baes.fpx3.exostartest.com/'
        $FPUSv6U_CP = 'https://cp.fpx3.exostartest.com/'
        $FPUSv6U_FPJ = 'https://fpj.fpx3.exostartest.com/'
        $FPUSv6U_FPO = 'https://fpo.fpx3.exostartest.com/'
        $FPUSv6U_IM = 'https://im.fpx3.exostartest.com/'
        $FPUSv6U_MAIN = 'https://main.fpx3.exostartest.com/'
        $FPUSv6U_MYSITE = 'https://mysite.fpx3.exostartest.com/'
        $FPUSv6U_RollsRoyce = 'https://rolls-royce.fpx3.exostartest.com/'
        }
    #endregion
    # ----------------------------------------------------------------------- #
    #region - FPUS-PROD: (FPUSv6P)
    if ($exoENV='FPv6-US')
        {
        $FPUSv6P_BAES = 'https://baes.fps.exostar.com/'
        $FPUSv6P_IM = 'https://im.fps.exostar.com/'
        $FPUSv6P_MAIN = 'https://main.fps.exostar.com/'
        $FPUSv6P_MYSITE = 'https://mysite.fps.exostar.com/'
        $FPUSv6P_RR = 'https://rr.fps.exostar.com/'
        # KONGSBERG SUB-SET:
            $FPUSv6P_Kongsberg = @()
            $FPUSv6P_Kongsberg += "https://rr.fps.exostar.com/customers/marinenorthamerica"
            $FPUSv6P_Kongsberg += "https://main.fps.exostar.com/kongsberg/cm001"
            $FPUSv6P_Kongsberg += "https://main.fps.exostar.com/kongsberg/cm002"
            $FPUSv6P_Kongsberg += "https://main.fps.exostar.com/kongsberg/cm003"
            $FPUSv6P_Kongsberg += "https://main.fps.exostar.com/kongsberg/cm004"
            $subscriptions = @() ;
            $subscriptions += "FPS" ;
            $subscriptions += "FPSRR" ;
        }
    #endregion
    # ----------------------------------------------------------------------- #
    #region - FPUK-PROD: (FPUKv6P)
    if ($exoENV='FPv6-UK')
        {
        $FPUKv6P_BAES = 'https://baes.fpk.exostar.com/'
        $FPUKv6P_CP = 'https://cp.fpk.exostar.com/'
        $FPUKv6P_FPO = 'https://fpo.fpk.exostar.com/'
        $FPUKv6P_MAIN = 'https://main.fpk.exostar.com/'
        $FPUKv6P_MYSITE = 'https://mysite.fpk.exostar.com/'
        $FPUKv6P_RR = 'https://rr.fpk.exostar.com/'
        # KONGSBERG SUB-SET:
            $FPUKv6P_Kongsberg = @() 
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm001"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm002"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm003"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm004"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm005"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm006"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm007"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm008"
            $FPUKv6P_Kongsberg += "https://rr.fpk.exostar.com/customers/rollsroyceplc_forumpass/msp"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm010"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm011"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm012"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm013"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm014"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm016"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm018"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm020"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm021"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm022"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm023"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm024"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm025"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm026"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm028"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm029"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm030"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm033"
            $FPUKv6P_Kongsberg += "https://main.fpk.exostar.com/kongsberg/cm034"
            $subscriptions = @() ;
            $subscriptions += "FPK" ;
            $subscriptions += "FPKRR" ;
        }
    #endregion
    # ----------------------------------------------------------------------- #
    #region - EZMv6
    # EZMv6-QA:
    if ($exoENV='EZM-QA')
        {
        $EZMv6Q_MYSITE = 'https://mysite.mpfqa.exostartest.com/'
        $EZMv6Q_ZONE1B = 'https://zone1b.mpfqa.exostartest.com/'
        }
    # EZMv6-UAT:
    if ($exoENV='EZM-UAT')
        {
        $EZMv6U_MYSITE = 'https://mysite.mpf.exostartest.com/'
        $EZMv6U_ZONE1B = 'https://zone1b.mpf.exostartest.com/'
        }
    # EZMv6-PROD: (EZMv6P)
    if ($exoENV='EZM-PROD')
        {
        $EZMv6P_MYSITE = 'https://mysite.mpf.exostar.com/'
        $EZMv6P_ZONE1B = 'https://zone1b.mpf.exostar.com/'
        }
    #endregion
    # ----------------------------------------------------------------------- #
    #region - FPv7-QA:
    if ($exoENV='FPv7-QA')
        {
        $FPUSv7Q_APPS = 'https://apps.qa.fp.exostartest.com/'
        $FPUSv7Q_BAES = 'https://baes.qa.fp.exostartest.com/'
        $FPUSv7Q_CP = 'https://cp.qa.fp.exostartest.com/'
        $FPUSv7Q_FPJ = 'https://fpj.qa.fp.exostartest.com/'
        $FPUSv7Q_FPO = 'https://fpo.qa.fp.exostartest.com/'
        $FPUSv7Q_IM = 'https://im.qa.fp.exostartest.com/'
        $FPUSv7Q_MAIN = 'https://main.qa.fp.exostartest.com/'
        $FPUSv7Q_MYSITE = 'https://mysite.qa.fp.exostartest.com/'
        $FPUSv7Q_RollsRoyce = 'https://rolls-royce.qa.fp.exostartest.com/'
        }
    #endregion
    # ----------------------------------------------------------------------- #
    #region - FPv7-UAT:
    if ($exoENV='FPv7-UAT')
        {
        $FPUSv7U_APPS = 'https://apps.uat.fp.exostartest.com/'
        $FPUSv7U_BAES = 'https://baes.uat.fp.exostartest.com/'
        $FPUSv7U_CP = 'https://cp.uat.fp.exostartest.com/'
        $FPUSv7U_FPJ = 'https://fpj.uat.fp.exostartest.com/'
        $FPUSv7U_FPO = 'https://fpo.uat.fp.exostartest.com/'
        $FPUSv7U_IM = 'https://im.uat.fp.exostartest.com/'
        $FPUSv7U_MAIN = 'https://main.uat.fp.exostartest.com/'
        $FPUSv7U_MYSITE = 'https://mysite.uat.fp.exostartest.com/'
        $FPUSv7U_RollsRoyce = 'https://rolls-royce.uat.fp.exostartest.com/'
        }
    #endregion
    # ----------------------------------------------------------------------- #
    #region - FPv7-PROD:
    if ($exoENV='FPv7-PROD')
        {
        $FPUSv7P_APPS = 'https://apps.prod.fp.exostartest.com/'
        $FPUSv7P_BAES = 'https://baes.prod.fp.exostartest.com/'
        $FPUSv7P_CP = 'https://cp.prod.fp.exostartest.com/'
        $FPUSv7P_FPJ = 'https://fpj.prod.fp.exostartest.com/'
        $FPUSv7P_FPO = 'https://fpo.prod.fp.exostartest.com/'
        $FPUSv7P_IM = 'https://im.prod.fp.exostartest.com/'
        $FPUSv7P_MAIN = 'https://main.prod.fp.exostartest.com/'
        $FPUSv7P_MYSITE = 'https://mysite.prod.fp.exostartest.com/'
        $FPUSv7P_RollsRoyce = 'https://rolls-royce.prod.fp.exostartest.com/'
        }
    #endregion
    # ----------------------------------------------------------------------- #

#endregion
# --------------------------------------------------------------------------- #
    Start-Transcript -OutputDirectory $outPATH

#endregion
# --------------------------------------------------------------------------- #
# END