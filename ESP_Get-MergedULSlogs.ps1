# --------------------------------------------------------------------------- #
# ESP-Get-MergedULSlogs (Enterprise SharePoint)
# --------------------------------------------------------------------------- #
#region - SYNOPSIS:

<#
.SYNOPSIS

The script prompts for a Delivery E-mail address, CorrelationID, Start and End
times to collect.  Then it will process the collection and deliver the file.

.DESCRIPTION

Prompts for a Delivery E-Mail address (exostar.com only).
Prompts for a Correlation ID and validates if it might be viable.
Prompts for a START Date/Time.
Prompts for an END Date/Time.
Collects the merged logs and ZIPs it.
Then sends the ZIP file to the e-mail address defined.
* If the Server is running PowerShell v5.1 it will ZIP (Archive) the file.

.NOTES
Requires Powershell v5 or higher
Requires PowerShell Plugin for SharePoint
#>


#endregion
# --------------------------------------------------------------------------- #
#region - Load PowerShell SharePoint SnapIn:

    if ((Get-PSSnapin "Microsoft.SharePoint.PowerShell" -ErrorAction SilentlyContinue) -eq $null)
        {Add-PSSnapin "Microsoft.SharePoint.PowerShell"} ;

#endregion
# --------------------------------------------------------------------------- #
#region - SET VARIABLES:

    # CLEAR VARIABLES:
        $ErrorActionPreference = "SilentlyContinue" ;
        Clear-Variable timeSTAMP,line,pad,to ;
        Clear-Variable FQD,domain,exoENV,smtpTO,smtpFROM,smtp ;
        Clear-Variable cID_regex,smtp_regex,caCOMPAT,psvm,ok1 ;
        Clear-Variable outNAME,outPATH,outFILE,zipFILE,chkTO,sourceFILE ;
        Clear-Variable startTIME,startDATE,start,sDATE,gotID ;
        Clear-Variable endTIME,endDATE,end,eDATE,cID,resp01 ;
        $ErrorActionPreference = "Continue" ;

     # SET VARIABLES:
        $timestamp = (Get-Date -Format "yyyy.MM.dd-HHmm") ;
        $line = "# --------------------------------------------------------------------------- #" ;
        $pad = "60" ;

    # ----------------------------------------------------------------------- #
    #region - SET THE ENVIRONMENT / SMTP SERVER.
        $FQD = (Get-WmiObject win32_computersystem).Domain ;
        if ($FQD -like 'site01.dom01.com') 
            {$domain='site01';$exoENV='EMV-01';$smtpFROM='APP-ENV@domain.com';$smtp='10.10.1.5'}
        if ($FQD -like "site02.dom01.com") 
            {$domain = 'site02';$exoENV='ENV-02';$smtpFROM = 'APP-ENV@domain.com';$smtp = '10.10.2.5'}
    # SET COMMON ENVIRONMENTAL VARIABLES:
        $baseURL = "https://SPsite.${FQD}/"

    # SCRENN OUTPUT:
        Write-Host $line ;
        Write-Host "Environment detected was ...: "; Write-Host -F Green -NoNewLine "$domain ";
        Write-Host "Base URL is ................: "; Write-Host -F Green -NoNewLine "$baseUrl " ;
        Write-Host "SMTP FROM ..................: "; Write-Host -F Green -NoNewLine "$smtpFROM " ;
        Write-Host "SMTP Server is .............: "; Write-Host -F Green -NoNewLine "$smtp " ;
        Write-Host $line ;
    
    #endregion
    # ----------------------------------------------------------------------- #

    # SET VARIABLES:
        $outPATH = "C:\<path>\SCRIPTS\OUTPUT" ;
        $outNAME = "${timeSTAMP}_${domain}_MULS_logs" ;
        $outFILE = "${outPATH}\${outNAME}.log" ;
        $zipFILE = "${outPATH}\${outNAME}.zip" ;
        $smtp_regex = "(^[A-Za-z0-9]+)(.)([A-Za-z0-9]+)(@)(exostar.com)" ;

    # CORRELATIONID REGEX:
    # SAMPLE: F0BB0790-4323-A153-096F-ABCDC80E24D4
        $cID_regex = "(^[A-z0-9]{8})(-)([A-z0-9]{4})(-)([A-z0-9]{4})(-)([A-z0-9]{4})(-)([A-z0-9]{12})" ;
        smtp_regex = TBD
        

#endregion        
# --------------------------------------------------------------------------- #
#region - PROMPTS:

    # CLEAR SCREEN:
        CLS
    # ----------------------------------------------------------------------- #
    # PROMPT: USER's EMAIL
        Write-Host $line -f Cyan ;
            $chkTO =
                {switch ($smtpTO = Read-Host "> Enter the Exostar Delivery E-mail (for notification) ")
                    {
                    ({$smtpTO -match $smtp_regex})
                        {Write-Host "Looks Legit"}
                    Default {Write-Warning "Please enter a valid E-Mail address "; .$chkTO}
                    }
                }
            .$chkTO ;
    # ----------------------------------------------------------------------- #
    # PROMPT FOR CORRELATION ID:
        Write-Host $line -f Cyan ;
        $resp01 = $false ;
        $gotID =
            {switch (Read-Host "> Do you want to use a Correlation ID? (Y/N) ")
                {
                "y" {$resp01 = $True}
                "n" {$resp01 = $False}
                default { Write-Warning "Invalid entry. Enter only 'Y' or 'N'" ; .$gotID }
                }
            }
        .$gotID ;
    # ----------------------------------------------------------------------- #
    # PROMPT FOR THE CORRELATION ID: 
        Write-Host $line -f Cyan ;
        if ($resp01 -eq $True)
            {
            Write-Host "Lets get that ID then"
            $chkID =
                {switch ($cID = Read-Host "Enter Correlation ID: ")
                    {
                    ({$cID -match $cID_regex})
                        {Write-Host "Looks Legit"}
                    Default {Write-Warning "> Please enter a valid Correlation ID "; .$chkID}
                    }
                }
            .$chkID ;
            }
            
        if ($resp01 -eq $False)
            {Write-Host "> Skipping CORRELATION ID Filter"} ;
    # ----------------------------------------------------------------------- #
    # PROMPT FOR START DATE/TIME:
        Write-Host $line -f Cyan ;
        do
            {
            $sDATE = Read-Host "> Please enter START Date & Time (MM/dd/yyyy HH:mm) " ;
            $sDATE = [datetime]::ParseExact($sDATE,"MM/dd/yyyy HH:mm", $null) ;

            if (!$sDATE)
                {"Not a valid date / time"}
            }
        while ($sDATE -isnot [datetime]) ;
    # ----------------------------------------------------------------------- #
    # PROMPT FOR END DATE/TIME:
        do
            {
            $eDATE = Read-Host "> Please enter END Date & Time (MM/dd/yyyy HH:mm) " ;
            $eDATE = [datetime]::ParseExact($eDATE,"MM/dd/yyyy HH:mm", $null) ;

            if (!$eDATE)
                {"Not a valid date / time"}
            }
        while ($eDATE -isnot [datetime]) ;
    # ----------------------------------------------------------------------- #
#endregion
# --------------------------------------------------------------------------- #
#region - GET MERGED ULS LOGS:
    
    # NOTIFICATION:
        Write-Host $line -f Cyan ;
        Write-Host "# Starting ULS Log Capture Script" ;

    # CREATE MERGED ULS LOG FILE FROM SP-FARM SERVERS:
        Write-Host $line -f Cyan ;
        Write-Host "> Creating a Merged Log File: $logFILE" ;
        
    # WITH CORRELATION ID:
        if ($ok1 = $true)
            {Merge-SPLogfile -Path $outFILE -Overwrite  -Correlation $cID -StartTime $sDATE -EndTime $eDATE} ;

    # NO CORRELATION ID:      
        Merge-SPLogfile -Path $outFILE -Overwrite -StartTime $sDATE -EndTime $eDATE ;
        
    # OUTPUT:
        Write-Host "> Merged Log File created: $outFILE" ;
    
#endregion        
# --------------------------------------------------------------------------- #
#region - COMPRESS FILE:

    # DETERMINE PowerShell Version:
        $psvm = $PSVersionTable.PSVersion.Major
        if ($psvm -eq 5)
            {$caCOMPAT = $True}
        else {$caCOMPAT = $False}

    # POWERSHELL v5 METHOD: 
        if ($caCOMPAT -eq $True)    
            {
            # COMPRESS THE FILE:
                Write-Host $line -f Cyan ;
                Write-Host "> Compressing LOG File into $zipFILE" ;
                Compress-Archive -Path $outFILE -CompressionLevel Optimal -DestinationPath $zipFILE ;
                sleep 10
            }
    # POWERSHELL v3 METHOD:
        else
            {
            # COMPRESS THE FILE (Different Method):
                New-Item -ItemType "directory" -Path "${outPATH}" -Name "$timeSTAMP"
                Move-Item $outFILE -Destination "${outPATH}\$timeSTAMP"
                $sourceFILE = "${outPATH}\$timeSTAMP"
                Add-Type -assembly "system.io.compression.filesystem"
                [io.compression.zipfile]::CreateFromDirectory($sourceFILE, $zipFILE)
            }

#endregion
# --------------------------------------------------------------------------- #
#region - EMAIL FILE:

    Write-Host $line -f Cyan ;
    Write-Host "Sending Notification E-Mail" ;
    Send-MailMessage -smtpServer $smtp `
        -from $smtpFROM `
        -to $smtpTO `
        -subject "Requested ULS Log Capture - $exoENV : $timeSTAMP" `
        -body "Your requested ULS Log Capture from $exoENV is attached: $zipFILE" `
        -Attachments $zipFILE ;
    
#endregion
# --------------------------------------------------------------------------- #
#region - CLOSEOUT:

        Write-Host $line -f Cyan ;
        Write-Host ">> End of Transmission..." ;

#endregion
# --------------------------------------------------------------------------- #
# END
