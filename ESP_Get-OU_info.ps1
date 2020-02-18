# --------------------------------------------------------------------------- #
# GET ADSI Information
# --------------------------------------------------------------------------- #
# --------------------------------------------------------------------------- #
#region - LOAD MODULES:
    
    Import-Module -Name ActiveDirectory ;

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

    Clear-Variable select,user,PDCe,chkUSER  ;
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
#region - ACTIONS:

    # SET SELECTION ARRAY:
        $line = "# --------------------------------------------------------------------------- #" ;
        $select =@()
        $select += "SamAccountName"
        $select += "mail"
        $select += "UserPrincipalName"
        $select += "employeeID"
        $select += "exostarExternalInfo"
        $select += "exostarStatus"
        $select += "exostarSyncPending"
        $select += "whenCreated"
        $select += "whenChanged"
        $select += "distinguishedName"

    # PROMPT FOR USER:
        Write-Host $line ;
        $user = (Read-Host "Please provide the user you want information on (user_####) ") ;
        Write-Host $line ;
        Write-Host ">> Checking for ${user} on ${PDCe}" ;
        Write-Host $line ;

    # DO THE ACTUAL CHECKING:
        $chkUSER = $(try {Get-ADUser -Identity $user} catch {$null}) ;
        if ($chkUSER -ne $null)
            {Get-ADUser -Identity $user -Properties * | select $select | FL}
        else 
            {Write-Warning "User cannot be found"}

# --------------------------------------------------------------------------- #
# END