# ---------------------------------------------------------- #
# DRAFT-Multi_Domains.ps1
# ---------------------------------------------------------- #
#region - SYNOPSIS BLOCK:
<#

.SYNOPSIS
    A script SNIPPET to do a funciton on multiple Domains.

.DESCRIPTION
    This is a Script Snippet to handle Multiple Domain Situations.
    (1) The user is prompted for the number of Domains to accomodate.
    (2) The user is then prompted X times for the Domain names.
    (3) The script then takes that information and get the PDC Emulators for
         X domains.
    (4) Then the Script can loop through each of the domains for AD objects.

.PARAMETER 
    No Parameters are defined yet since the script is prompting.

.EXAMPLE    
    Not Applicable

.NOTES
    Sometimes a function needs to be run across multiple domains.  

.LINK
    Not Applicable.  I borrowed heavyily from my Google-Fu.
#>
#endregion
# ---------------------------------------------------------- #
#region - COMMON VARIABLES - CLEAR & SET:
    # CLEAR VARIABLES:
        Clear-Variable QTY_Domains
    # SET VARIABLES:
        $QTY_Domains = $null
#endregion
# ---------------------------------------------------------- #
#region - PROMPT FOR # OF DOMAINS:
    #PROMPT FOR INPUT:
        Do { $QTY_Domains = Read-host "Number of Domains [1-9]"} 
    # VALIDATE INPUT:
        while ((1..9) -notcontains $QTY_Domains)
    # NOTIFICATION:
        Write-Warning "$QTY_Domains Domains to be Checked"
#endregion
# ---------------------------------------------------------- #
#region - PROMPT X TIMES FOR DOMAIN NAMES:
    # NOTIFICATION:
        Write-Host ">> START LOOP <<"
        $domains = @()
    # LOOP Trought DOMAIN PROMPTS:
        #foreach ($i_d in 1..$QTY_Domains)
        for ($i_d=1; $i_d -le $QTY_Domains; $i_d++)
            {
            Remove-Variable -Name "domain_$i_d" -ErrorAction SilentlyContinue
            New-Variable -Name "domain_$i_d"
            $prompt = Get-Variable -Name "domain_$i_d"
            #
            #   Write-Host "Set Variable: $dom_vari"
            $prompt = Read-Host "Domain $i_d"; $domains += $prompt
            }
    # NOTIFICATION - RESULTS:
        Write-Host "-------------------------"
        Write-Host "Domain(s) that will be searched:"
        Write-Output $domains
        Write-Host "-------------------------"
#endregion
# ---------------------------------------------------------- #
#region - LOOP ACTIVE DIRECTORY PDCE
    # NOTIFICATION:
        Write-Host ">> GETTING PDC Emulators for the Domain(s):"
    # IMPORT MODULE:
        Import-Module ActiveDirectory
    # SET ARRAY:
        $PDCEs + @()
    # LOOP TO GET THE PDC EMULATORS:
    foreach ($PDCE in $domains)
        {
        $i_PDCE = 1
        Clear-Variable v_PDCE,g_PDCE -ErrorAction SilentlyContinue
        Remove-Variable -Name "PDCE_$i_PDCE" -ErrorAction SilentlyContinue
        New-Variable -Name "PDCE_$I_PDCE"
        $v_PDCE = (Get-Variable -Name "PDCE_$i_PDCE") 
        $g_PDCE = (Get-ADDomainControll -Domain $PDCE -Service "PrimaryDC" -OutVariable $v_PDCE)
        $PDCEs += $g_PDCE
        }
    # RESULTS - NOTIFICATION:
        Write-Host "-------------------------"
        Write-Host "PDC Emulators to Query:"
        Write-Host "-------------------------"
        Write-Output $PDCEs
#endregion
# ---------------------------------------------------------- #
#region - Get AD OBJECT(s) FROM ALL DOMAINS:
     # To Be Determined:
#endregion
# ---------------------------------------------------------- #

# ---------------------------------------------------------- #
# END
