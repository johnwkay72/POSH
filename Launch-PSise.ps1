# ---------------------------------------------------------------------------- #
# Lauch-PSise (Launches an ISE session under MPFQA\sp_admin running as Administrator
# ---------------------------------------------------------------------------- #
#region - VARIABLES:
    # ----------------------------------------------------------------------- #
    #region - CLEAR VARIABLES:

        $ErrorActionPreference = "SilentlyContinue" ;
        Clear-Variable domain,user,creds,acct;
        Clear-Variable stdCMD,elvCMD,stdPOSH,elvPOSH,stdPISE,elvPISE ;
        $ErrorActionPreference = "Continue" ;

    #endregion
    # ----------------------------------------------------------------------- #
    #region - SET THE ENVIRONMENT / SMTP SERVER:

        $FQD = (Get-WmiObject win32_computersystem).Domain ;
        
        if ($FQD -like 'site01.domain.com') 
            {$domain='domain';$domENV='APP-ENV';$smtpFROM='APP-ENV@exostar.com';$smtp='10.10.1.x'}
        if ($FQD -like "site02.domain.com") 
            {$domain = 'domain';$domENV='APP-ENV';$smtpFROM = 'APP-ENV@exostar.com';$smtp = '10.10.2.x'}
        
    # SET COMMON ENVIRONMENTAL VARIABLES:
        $baseURL = "https://SPsite.${FQD}/"

    # SCRENN OUTPUT:
        Write-Host $line ;
        Write-Host "Environment detected was ...: " -NoNewLine ; Write-Host -F Green "$exoENV ";
        Write-Host "Base URL is ................: " -NoNewLine ; Write-Host -F Green "$baseUrl " ;
        Write-Host "SMTP FROM ..................: " -NoNewLine ; Write-Host -F Green "$smtpFROM " ;
        Write-Host "SMTP Server is .............: " -NoNewLine ; Write-Host -F Green "$smtp " ;
        Write-Host $line ;

    #endregion
    # ----------------------------------------------------------------------- #
    #region - SET THE LOGON:

        $user = "sp_admin"
        $acct = "${domain}\${user}"

    #endregion
    # ----------------------------------------------------------------------- #
#endregion
# ------------------------------------------------------------------- #
#region - MENU:

        DO {
            Write-Host "***************************************"
            Write-Host "----------- Run as sp_admin -----------"
            Write-Host ""
            Write-Host "(A) - CMD under sp_admin"
            Write-Host "(B) - POSH under sp_admin"
            Write-Host "(C) - POSH ISE under sp_admin"
            Write-Host ""
            Write-Host "------- Run as sp_admin AS ADMIN -------"
            Write-Host ""
            Write-Host "(D) - CMD under sp_admin AS ADMIN"
            Write-Host "(E) - POSH under sp_admin AS ADMIN"
            Write-Host "(F) - POSH ISE under sp_admin AS ADMIN"
            Write-Host ""
            Write-Host "(X) - EXIT"
            Write-Host "***************************************"
            Write-Host "Type your choice and press Enter:" -NoNewline  ;
                $choice = read-host
            Write-Host ""
                $ok = $choice -match '^[abcdefx]+$'
                    IF (-not $ok) 
                        {Write-Host "Invalid Selection"}
            } until ($ok)
            
        switch -Regex ($choice)
            { 
            "A" {Write-Host "You entered '(A) - CMD under sp_admin'"}
            "B" {Write-Host "You entered '(B) - POSH under sp_admin'"}
            "C" {Write-Host "You entered '(C) - POSH ISE under sp_admin'"}
            "D" {Write-Host "You entered '(D) - CMD under sp_admin AS ADMIN'"}
            "E" {Write-Host "You entered '(E) - POSH under sp_admin AS ADMIN'"}
            "F" {Write-Host "You entered '(F) - POSH ISE under sp_admin AS ADMIN'"}
            "X" {Write-Host "You entered '(X) - EXITING'"}
            }
#endregion
# ------------------------------------------------------------------- #
#region - SET COMMANDS:
    # RUN UNDER sp_admin:
        $stdCMD = {Start-Process powershell.exe -Credential $creds -NoNewWindow -ArgumentList "Start-Process cmd.exe -Verb runAs"}
        $stdPOSH = {Start-Process powershell.exe -Credential $creds -NoNewWindow -ArgumentList "Start-Process powershell.exe -Verb runAs"}
        $stdPISE = {Start-Process powershell.exe -Credential $creds -NoNewWindow -ArgumentList "Start-Process powershell_ise.exe -Verb runAs"}
    # RUN AS sp_admin AS ADMIN:
        $elvCMD = {Start-Process powershell.exe -Credential $creds -NoNewWindow -ArgumentList "Start-Process cmd.exe -Verb runAs"}
        $elvPOSH = {Start-Process powershell.exe -Credential $creds -NoNewWindow -ArgumentList "Start-Process powershell.exe -Verb runAs"}
        $elvPISE = {Start-Process powershell.exe -Credential $creds -NoNewWindow -ArgumentList "Start-Process powershell_ise.exe -Verb runAs"}

#endregion
# ------------------------------------------------------------------- #
#region - SET THE CHOICE:
    IF ($choice -eq "A") {$result = "$stdCMD"}
    IF ($choice -eq "B") {$result = "$stdPOSH"}
    IF ($choice -eq "C") {$result = "$stdPISE"}
    IF ($choice -eq "D") {$result = "$elvCMD"}
    IF ($choice -eq "E") {$result = "$elvPOSH"}
    IF ($choice -eq "F") {$result = "$elvPISE"}
    IF ($choice -eq "X") {BREAK}
#endregion
# ------------------------------------------------------------------- #
#region - PROMT FOR CREDENTIALS:

   $creds = (Get-Credential -UserName $acct -Message "Please provide the Password")

#endregion
# ------------------------------------------------------------------- #
#region - INVOKE THE COMMAND:

    Invoke-Expression $result

#endregion
# ---------------------------------------------------------------------------- #
# END
