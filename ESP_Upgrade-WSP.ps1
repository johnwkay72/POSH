# --------------------------------------------------------------------------- #
# ESP_Upgrade-WSP
# --------------------------------------------------------------------------- #
#region - SYNOPSIS:

<#
.SYNOPSIS

Standard method to upgrade WSP files in Exostar SharePoint Solutions.

.DESCRIPTION

Adds a file name extension to a supplied name.
Takes any strings for the file name or extension.

.PARAMETER Name
Specifies the WSP file name.

.EXAMPLE

TBD

#>

#endregion
# --------------------------------------------------------------------------- #
#region - Load PowerShell SharePoint SnapIn:

    if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null)
        {Add-PSSnapin "Microsoft.SharePoint.PowerShell"} ;

#endregion
# --------------------------------------------------------------------------- #
#region - CLEAR VARIABLES:
    $ErrorActionPreference = "SilentlyContinue" ;
    Clear-Variable FQD,domain,exoENV,smtpFROM,smtp ;
    Clear-Variable timeSTAMP,line,pad ;
    Clear-Variable outNAME,outPATH,outFILE,zipFILE,smtp_regex,baseURL,cID_regex ;
    Clear-Variable FPUSv6*,FPUKv6*,FPUSv7*,FPUKv7*,EZMv6* ;
    Clear-Variable chkTO,smtpTO,gotID,resp01,chkID,cID ;
    Clear-Variable startTIME,startDATE,start,sDATE ;
    Clear-Variable endTIME,endDATE,end,eDATE ;
    Clear-Variable sourceFILE,caCOMPAT,psvm,ok1  ;
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
    elseif ($FQD -like "uat.fp.local") 
        {
        $domain='FPX7'
        $exoENV='FPv7-UAT'
        $smtpFROM='FPv7-UAT@exostar.com'
        $smtp='10.248.3.4'
        # $baseURL = "https://mysite.mpfqa.exostartest.com"
        }
    elseif ($FQD -like "MPF.exostartest.com") 
        {
        $domain='MPFU'
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
    $baseURL = "https://mysite.${FQD}/" ;
    $outPATH = "C:\TECHOPS\SCRIPTS\OUTPUT" ;
    $TECHOPS = "C:\TECHOPS\" ;
    
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
#region - UPDATE THE SharePoint SOLUTION:

    # ----------------------------------------------------------------------- #
    #region - PRE-IMPLEMENTATION STEPS:

        # SET SCRIPT SPECIFIC VARIABLED:
            $ErrorActionPreference = "SilentlyContinue" ;
            Clear-Variable wspFILE,wspDIR,wspNAME,wspARC.wspARCPATH,wspSOURCE ;
            Clear-Variable LWT,deployed,s,chkIISRESET,promptIISRESET,doIISRESET ;
            $ErrorActionPreference = "Continue" ;
        #Param([string]$wspNAME) ;  

        # PROMPT FOR WSP Name:
            $wspDIR="C:\" ;
            $wspARCPATH="C:\WSP.ARCHIVE" ;
            $wspNAME = (Read-Host "--> Name of the WSP to deploy from ${wspDIR} ") ;
            $wspFILE="${wspDIR}${wspNAME}" ;

        # COPIES THE EXISTING WSP WITH ITS LAST MODIFIED TIME @ END:
            Write-Host $line ;
            Write-Host "Creating Backup of Current Deployed WSP File:" ;
            Write-Host "$wspNAME" ;

        # Get the Last Write Time (LWT):
            $LWT = (Get-Item $wspFILE).LastWriteTime.ToString("yyyyMMdd-HHmm") ;

        # DEFINE THE ARCHIVE FILE NAME:
            $wspARC = "${wspNAME}.${LWT}.bak" ;
            Write-Host "Archive Name: $wspARC" ;
            $a = "${wspARCPATH}\${wspARC}" ;
            Copy-Item $wspFILE -Destination $a -Force -Verbose;

        # COPY THE STAGED FILE TO THE RUNNING LOCATION:
            $wspSOURCE="${TechOPS}${wspNAME}"
            Write-Host $line
            Write-Host "Copying STAGED WSP to deployed path:" ;
            Copy-Item $wspSOURCE -Destination $wspFILE -Force ;

    #endregion
    # ----------------------------------------------------------------------- #
    #region - PROMPTE FOR DEPLOYMENT LEVEL: STATIC MENU

        # SETUP THE CHOICES
        DO {
            Write-Host $line ;
            Write-Host "# CHOOSE YOUR DEPLOYMENT LEVEL ---------------------------------------------- #" ;
            Write-Host $line ;
            Write-Host "(A) - BASIC" ;
            Write-Host "(B) - GAC DEPLOYMENT" ;
            Write-Host "(C) - GAC w/ FULL BIN ACCESS" ;
            Write-Host "(D) - FULL FORCE" ;
            Write-Host "" ;
            Write-Host "(X) - EXIT" ;
            Write-Host $line ;
            Write-Host -NoNewline "Type your choice and press Enter:" ;
                $choice = read-host ;
            Write-Host "" ;
                $ok = $choice -match '^[abcdx]+$'
                    IF (-not $ok) 
                        {Write-Host "Invalid Selection"}
            } until ($ok)
            
        Write-Host $line ;
        switch -Regex ($choice)
            { 
            "A" {Write-Host "You entered '(A) - BASIC (Simplest)'"}
            "B" {Write-Host "You entered '(B) - GAC Deployment'"}
            "C" {Write-Host "You entered '(C) - GAC with FullBin Directory'"}
            "D" {Write-Host "You entered '(D) - FULL ON FORCE'"}
            }
    # ------------------------------------------------------------------- #
    #    Write-Output "YOUR CHOICE: $choice"
    # ------------------------------------------------------------------- #
        IF ($choice -eq "A") {$result = "1"}
        IF ($choice -eq "B") {$result = "2"}
        IF ($choice -eq "C") {$result = "3"}
        IF ($choice -eq "D") {$result = "4"}
        
        IF ($choice -eq "X") {break}
    # ------------------------------------------------------------------- #
        Write-Output $result
    # ------------------------------------------------------------------- #
    #endregion
    # ----------------------------------------------------------------------- #
    #region - POWERSHELL METHOD:

        # ORGINAL IMPLEMENTATION CODE / METHOD:
        <#
        cd C:\
        "c:\program files\common files\microsoft shared\web server extensions\15\bin\stsadm" -o upgradesolution -name InformationManagerSync.wsp -filename InformationManagerSync.wsp -immediate -allowGacDeployment\
        # PS C:\Collaboration\scripts> 
        #>
        
        Update-SPSolution -Identity $wspNAME -LiteralPath $wspSOURCE -GACDeployment -Force -FullTrustBinDeployment -Verbose ;

    #endregion
    # ----------------------------------------------------------------------- #
    #region - VALIDATE THE SOLUTION DEPLOYMENT:

    # $wspname = "merckzonebprovisionpages.wsp" 
        
    # STILL NOT REALLY WORKING PROPERLY YET
    Do
        {
        $deployed = $True
        $s = Get-SPSolution -Identity $wspNAME
        if ( ($s.Deployed -eq $False) -and ($s.JobExists -eq $False) )
            {$deployed = $False ; Write-Host "DEPLOYING"}
        sleep -s 1
        }        
    while ($deployed -eq $False) 

    Write-Host $line ;
    Write-Host ">> SOLUTION IS DEPLOYED" ;
    Write-Host $line ;
    # ----------------------------------------------------------------------- #
    Get-SPSolution -Identity $wspNAME | `
        select `
            Name, `
            DeployedServers, `
            DeploymentState, `
            LastOperationResult, `
            LastOperationEndTime, `
            Status | `
            FL ;
    
    #endregion
    # ----------------------------------------------------------------------- #
    #region - PROMPT FOR IISRESET:
        $chkIISRESET =
                {switch ($promptIISRESET = (Read-Host "Do you want to Reset IIS? [Y/N] : ") )
                    {
                    Y {$doIISRESET = $true }
                    N {$doIISRESET = $false}
                    Default {Write-Warning "Please enter a valid response [Y/N] "; .$chkIISRESET}
                    }
                }
            .$chkIISRESET ;

        if ($doIISRESET -eq $True)
            {Invoke-Command -ScriptBlock {Write-Host $line ; iisreset}}
        else
            {
            Write-Host $line
            Write-Host "Thank you for playing, please come again"
            Break
            }

    #endregion
    # ----------------------------------------------------------------------- #

#endregion
# --------------------------------------------------------------------------- #
# END