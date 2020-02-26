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
    Clear-Variable FQD,domain,domENV,smtpFROM,smtp,baseURL ;
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
    
    if ($FQD -like 'dev.com') 
        {
        $domain='DEV'
        $exoENV='DEV'
        $smtpFROM='APP-ENV@domain.com'
        $smtp='10.10.1.x'
        $baseURL = "https://SPsite.ENV.domain.com"
        }
    if ($FQD -like 'site01.domain.com') 
        {
        $domain='ENV'
        $exoENV='APP-ENV'
        $exoDC='tbd'
        $smtpFROM='APP-ENV@domain.com'
        $smtp='10.10.2.x'
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
            {Write-Warning "User cannot be found"} ;

# --------------------------------------------------------------------------- #
# END
