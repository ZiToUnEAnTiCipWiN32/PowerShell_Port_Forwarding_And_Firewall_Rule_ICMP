<#
.SYNOPSIS
This PowerShell script allows you to search for and display detailed information about Windows Firewall rules that match a specified name.

.DESCRIPTION
The script searches for Windows Firewall rules based on the name specified by the user. It provides detailed information about the found rules, including their properties such as name, description, status, action, direction, and more. Users can select a rule to view its details. It offers a user-friendly interface for exploring Windows Firewall rules.

.NOTES

This script requires the prior import of the 'NetSecurity' module.
To use this script, run it in a Windows environment with Windows Firewall and administrative privileges and the 'Main.ps1' script.
STRUCTURE:

Show-Colored: Displays text in custom colors with names and values.
AfficherTitreCentre: Displays a centered title.
Show-FirewallRuleDetails: Provides detailed information about Firewall rule properties.
Show-AddressFilterDetails: Displays detailed information about address filters in a Firewall rule.
Show-ServiceFilterDetails: Displays detailed information about service filters in a Firewall rule.
Show-ApplicationFilterDetails: Displays detailed information about application filters in a Firewall rule.
Show-InterfaceFilterDetails: Displays detailed information about interface filters in a Firewall rule.
Show-InterfaceTypeFilterDetails: Displays detailed information about interface type filters in a Firewall rule.
Show-PortFilterDetails: Displays detailed information about port filters in a Firewall rule.
Show-SecurityFilterDetails: Displays detailed information about security filters in a Firewall rule.
EXECUTION

The script prompts the user to enter the name of the Firewall rule to search for.
It searches for matching rules and displays them with associated numbers.
Users can select a rule by its number to view its details.
Users can choose to display other rules if multiple matches are found.
The script can be exited by typing 'q'.
.LINK
GitHub Repository: [https://github.com/ZiToUnEAnTiCipWiN32]
Website: [http://zitouneanticip.free.fr]

AUTHOR:
[ZiToUnE AnTiCiP]

VERSION:
Date de création : [2023-10]
1.0

#>

# Import du module NetSecurity si ce n'est pas déjà fait
Import-Module -Name NetSecurity

# Function pour Afficher en couleurs les détails de la règle sélectionnée
function Show-Colored {
    param (
        [string]$name,
        [string]$value,
        [string]$nameColor,
        [string]$valueColor
    )

    $separator = ":"
    $formattedName = "{0}" -f $name.PadRight(24)
    $formattedValue = "$separator  $value"

    Write-Host -NoNewLine $formattedName -ForegroundColor $nameColor
    Write-Host $formattedValue -ForegroundColor $valueColor
}

# Function pour calculer un Titre centrer
function AfficherTitreCentre {
    param (
        [string]$titre
    )

    $longueurTotale = 60
    $longueurTitre = $titre.Length
    $longueurRequise = $longueurTotale - $longueurTitre
    $longueurGauche = [Math]::Floor($longueurRequise / 2)
    $longueurDroite = $longueurRequise - $longueurGauche

    $ligneTitre = ("-" * $longueurGauche) + $titre + ("-" * $longueurDroite)
    Write-Host $ligneTitre -ForegroundColor Green
}

# Fonction pour afficher les détails d'une règle ( commenter ou décommenter les éléments pour +- de sortie )
function Show-FirewallRuleDetails($rule) {
    AfficherTitreCentre ("_" * 60) 
    AfficherTitreCentre $foundRules.Iteration[$ruleNumber]
    AfficherTitreCentre "FirEwAlL Rule"
    # Show-Colored "Name" $rule.Name -nameColor Magenta -valueColor Blue
    Show-Colored "DisplayName" $rule.DisplayName -nameColor Magenta -valueColor Blue
    # Show-Colored "Description" $rule.Description -nameColor Magenta -valueColor Blue
    # Show-Colored "DisplayGroup" $rule.DisplayGroup -nameColor Magenta -valueColor Blue
    # Show-Colored "Group" $rule.Group -nameColor Magenta -valueColor Blue
    Show-Colored "Enabled" $rule.Enabled -nameColor Magenta -valueColor Blue
    # Show-Colored "Profile" $rule.Profile -nameColor Magenta -valueColor Blue
    # Show-Colored "Platform" $rule.Platform -nameColor Magenta -valueColor Blue
    Show-Colored "Direction" $rule.Direction -nameColor Magenta -valueColor Blue
    Show-Colored "Action" $rule.Action -nameColor Magenta -valueColor Blue
    # Show-Colored "EdgeTraversalPolicy" $rule.EdgeTraversalPolicy -nameColor Magenta -valueColor Blue
    # Show-Colored "LooseSourceMapping" $rule.LooseSourceMapping -nameColor Magenta -valueColor Blue
    # Show-Colored "LocalOnlyMapping" $rule.LocalOnlyMapping -nameColor Magenta -valueColor Blue
    # Show-Colored "Owner" $rule.Owner -nameColor Magenta -valueColor Blue
    Show-Colored "PrimaryStatus" $rule.PrimaryStatus -nameColor Magenta -valueColor Blue
    # Show-Colored "Status" $rule.Status -nameColor Magenta -valueColor Blue
    # Show-Colored "EnforcementStatus" $rule.EnforcementStatus -nameColor Magenta -valueColor Blue
    # Show-Colored "PolicyStoreSource" $rule.PolicyStoreSource -nameColor Magenta -valueColor Blue
    # Show-Colored "PolicyStoreSourceType" $rule.PolicyStoreSourceType -nameColor Magenta -valueColor Blue
}

# Fonction pour afficher les détails des filtres d'adresse ( commenter ou décommenter les éléments pour +- de sortie )
function Show-AddressFilterDetails($filter) {
    AfficherTitreCentre "AdDrEsS FiLtEr" 
    Show-Colored "LocalAddress" $filter.LocalAddress -nameColor Magenta -valueColor Blue
    Show-Colored "RemoteAddress" $filter.RemoteAddress -nameColor Magenta -valueColor Blue
}

# Fonction pour afficher les détails des filtres de service ( commenter ou décommenter les éléments pour +- de sortie )
function Show-ServiceFilterDetails($filter) {
    AfficherTitreCentre "SeRvIcE FiLtEr"
    Show-Colored "Service" $filter.Service -nameColor Magenta -valueColor Blue
}

# Fonction pour afficher les détails des filtres d'application ( commenter ou décommenter les éléments pour +- de sortie )
function Show-ApplicationFilterDetails($filter) {
    AfficherTitreCentre "ApPlIcAtIoN FiLtEr"
    Show-Colored "Program" $filter.Program -nameColor Magenta -valueColor Blue
    # Show-Colored "Package" $filter.Package -nameColor Magenta -valueColor Blue
}

# Fonction pour afficher les détails des filtres d'interface ( commenter ou décommenter les éléments pour +- de sortie )
function Show-InterfaceFilterDetails($filter) {
    # AfficherTitreCentre "InTeRfAcE FiLtEr"
    # Show-Colored "InterfaceAlias" $filter.InterfaceAlias -nameColor Magenta -valueColor Blue
}

# Fonction pour afficher les détails des filtres de type d'interface ( commenter ou décommenter les éléments pour +- de sortie )
function Show-InterfaceTypeFilterDetails($filter) {
    # AfficherTitreCentre "InTeRfAcE TyPe FiLtEr"
    Show-Colored "InterfaceType" $filter.InterfaceType -nameColor Magenta -valueColor Blue
}

# Fonction pour afficher les détails des filtres de port ( commenter ou décommenter les éléments pour +- de sortie )
function Show-PortFilterDetails($filter) {
    AfficherTitreCentre "PoRt FiLtEr"
    Show-Colored "Protocol" $filter.Protocol -nameColor Magenta -valueColor Blue
    Show-Colored "LocalPort" $filter.LocalPort -nameColor Magenta -valueColor Blue
    Show-Colored "RemotePort" $filter.RemotePort -nameColor Magenta -valueColor Blue
    # Show-Colored "IcmpType" $filter.IcmpType -nameColor Magenta -valueColor Blue
    # Show-Colored "DynamicTarget" $filter.DynamicTarget -nameColor Magenta -valueColor Blue
}

# Fonction pour afficher les détails des filtres de sécurité ( commenter ou décommenter les éléments pour +- de sortie )
function Show-SecurityFilterDetails($filter) {
    AfficherTitreCentre "SeCuRiTy FiLtEr"
    Show-Colored "Authentication" $filter.Authentication -nameColor Magenta -valueColor Blue
    # Show-Colored "Encryption" $filter.Encryption -nameColor Magenta -valueColor Blue
    # Show-Colored "OverrideBlockRules" $filter.OverrideBlockRules -nameColor Magenta -valueColor Blue
    Show-Colored "LocalUser" $filter.LocalUser -nameColor Magenta -valueColor Blue
    Show-Colored "RemoteUser" $filter.RemoteUser -nameColor Magenta -valueColor Blue
    Show-Colored "RemoteMachine" $filter.RemoteMachine -nameColor Magenta -valueColor Blue
}

# Boucle principal 
$ContinuerMenuSearch = $true
    while ($ContinuerMenuSearch) {

        # Demandez à l'utilisateur de saisir le nom à rechercher
        do {
            $ruleNameToSearch = Read-Host "FiReWaLl-{Search} [?] Name of Firewall Rule ? {e.g. *icmpv4*} "
        } while ([string]::IsNullOrEmpty($ruleNameToSearch))

        # Collecte des données du pare-feu
        $firewallRules = Get-NetFirewallRule

        # Crée des tableaux vides pour stocker les détails des règles
        $foundRules = @()
        $ruleDetails = @()

        # parcourt tous les indices valides du tableau $firewallRules, et à chaque itération, la variable $index contient l'indice actuel.
        foreach ($index in 0..($firewallRules.Count - 1)) {
            $rule = $firewallRules[$index]

            # Affiche l'avancement de la recherche
            Write-Host "`r" -NoNewline
            # Write-Host "[-] Search" $ruleNameToSearch "In" ($index + 1) "Of" $firewallRules.Count "Rules" -NoNewline -ForegroundColor DarkYellow
            Write-Host "[-] Search [" -ForegroundColor DarkYellow -NoNewline
            Write-Host $ruleNameToSearch -ForegroundColor Blue -NoNewline
            Write-Host "] In " -ForegroundColor DarkYellow -NoNewline
            Write-Host ($index + 1) -ForegroundColor Magenta -NoNewline
            Write-Host " Of " -ForegroundColor DarkYellow -NoNewline
            Write-Host $firewallRules.Count -ForegroundColor Magenta -NoNewline
            Write-Host " Rules" -ForegroundColor DarkYellow -NoNewline

            # La recherche correspond à une règle
            if ($rule.DisplayName -like "$ruleNameToSearch") {
                # Write-Host "`n[+] Found [ $ruleNameToSearch ] In Rule $($index + 1)" -ForegroundColor Green
                Write-Host "`n[+] Found [" -ForegroundColor Green -NoNewline
                Write-Host $ruleNameToSearch -ForegroundColor Blue -NoNewline
                Write-Host "] In Rule " -ForegroundColor Green -NoNewline
                Write-Host ($($index + 1)) -ForegroundColor Magenta

                # Stocke la règle correspondante dans le tableau $foundRules
                $foundRules += @{
                    'Rule' = $rule
                    'Iteration' = $index + 1
                }

                # Stocke les détails de la règle dans le tableau $ruleDetails
                $ruleDetails += @{
                    'Rule' = $rule
                    'Iteration' = $index + 1
                    'AddressFilter' = $rule | Get-NetFirewallAddressFilter
                    'ServiceFilter' = $rule | Get-NetFirewallServiceFilter
                    'ApplicationFilter' = $rule | Get-NetFirewallApplicationFilter
                    'InterfaceFilter' = $rule | Get-NetFirewallInterfaceFilter
                    'InterfaceTypeFilter' = $rule | Get-NetFirewallInterfaceTypeFilter
                    'PortFilter' = $rule | Get-NetFirewallPortFilter
                    'SecurityFilter' = $rule | Get-NetFirewallSecurityFilter
                }
            }
        }

        Write-Host
        Write-Host

        # Initialise la variable $continuer à $true pour entrer dans la boucle
        $continuer = $true
        do {
            if ($foundRules.Count -eq 0) {
                Write-Host "[!] No Found." -ForegroundColor DarkRed
                $continuer = $false
            } else {
                # Obtient et affiche la liste des règles avec des numéros associés
                $tab = (" " * 12)
                $inter = (" " * 9)
                Write-Host "$tab╔════════════════════════════════════════════════╗" -ForegroundColor Yellow
                Write-Host "$tab║$inter -_- FoUnD FiReWaLl-RuLeS -_- $inter║" -ForegroundColor Green
                Write-Host "$tab╚════════════════════════════════════════════════╝" -ForegroundColor Yellow

                $foundRules | ForEach-Object -Begin { $i = 0 } -Process {
                    # Write-Host ("{0} {1} [{2}] [{3}]" -f $i, $_.Rule.DisplayName, $_.Iteration, $_.Rule.Enabled)
                    $iText = "{0} " -f $i
                    $displayNameText = $_.Rule.DisplayName
                    $iterationText = "[{0}]" -f $_.Iteration
                    $enabledText = "[{0}]" -f $_.Rule.Enabled
                
                    $enabledColor = If ($_.Rule.Enabled -eq $true) { "Green" } Else { "DarkRed" }

                    Write-Host $iText -ForegroundColor White -NoNewline
                    Write-Host $displayNameText -ForegroundColor Blue -NoNewline
                    Write-Host $iterationText -ForegroundColor Magenta -NoNewline
                    Write-Host $enabledText -ForegroundColor $enabledColor
                
                    $i++
                }

                # Sélectionn de règle
                $ruleNumber = -1
                do {
                    # Demande à l'utilisateur de sélectionner un numéro de règle
                    $userInput = Read-Host "`nFiReWaLl-{Search} [?] Enter the number of the firewall rule or exit (q) "
                    
                    # Expression régulière : 
                    # ^ : Début de la chaîne. 
                    # \d : Correspond à un chiffre (0-9). 
                    # + : Correspond à un ou plusieurs chiffres.
                    # $ : Fin de la chaîne.
                    if ($userInput -match '^\d+$') { 
                        $ruleNumber = [int]$userInput

                        if ($ruleNumber -ge 0 -and $ruleNumber -lt $foundRules.Count) {
                            # Affiche les détails de la règle sélectionnée
                            # Write-Host "Détails de la règle $ruleNumber :"
                            # Write-Host "Numéro d'itération : $($SelectedFoundRule['Iteration'])"
                            $SelectedFoundRule = $foundRules[$ruleNumber]
                            $SelectedRuleDetails = $ruleDetails[$ruleNumber]

                            Show-FirewallRuleDetails $SelectedFoundRule['Rule']
                            Show-AddressFilterDetails $SelectedRuleDetails['AddressFilter']
                            Show-ServiceFilterDetails $SelectedRuleDetails['ServiceFilter']
                            Show-ApplicationFilterDetails $SelectedRuleDetails['ApplicationFilter']
                            # Show-InterfaceFilterDetails $SelectedRuleDetails['InterfaceFilter']
                            # Show-InterfaceTypeFilterDetails $SelectedRuleDetails['InterfaceTypeFilter']
                            Show-PortFilterDetails $SelectedRuleDetails['PortFilter']
                            Show-SecurityFilterDetails $SelectedRuleDetails['SecurityFilter']
                        }
                        else {
                            Write-Host "[!] Invalid rule. Please enter a valid number." -ForegroundColor DarkRed
                        }
                    } elseif ($userInput -eq "q") {
                        return
                    } else {
                        Write-Host "[!] Invalid input. Please enter a valid number." -ForegroundColor DarkRed
                    }
                } while ($ruleNumber -lt 0 -or $ruleNumber -ge $foundRules.Count)
            }    
        } while ($continuer)

    # Demande à l'utilisateur s'il souhaite Continuer
    do {
        $responseContinuerMenuSearch = Read-Host "`nFiReWaLl-{Search} [?] New Search (Y/n) "
        switch ($responseContinuerMenuSearch) {
            "Y" { $ContinuerMenuSearch = $true }
            "n" { $ContinuerMenuSearch = $false }
            default { Write-Host "[!] Invalid input." -ForegroundColor DarkRed }
        }
    } while (
        $responseContinuerMenuSearch -ne "Y" -and $responseContinuerMenuSearch -ne "n"
    )
}