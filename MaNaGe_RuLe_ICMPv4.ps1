<#
.SYNOPSIS
Management of ICMPv4 rules in Windows firewall using NetFirewallRule.

.DESCRIPTION
This PowerShell script manages ICMPv4 rules in the Windows firewall interactively. It provides a user interface to display, edit, delete existing rules, and create new ICMPv4 rules. The script includes several functions like Show-FirewallRuleICMP to display existing rules, Prepare_Create_Rule_ICMP to create new rules, and auxiliary functions to verify and manipulate firewall rules.

SCRIPT STRUCTURE
The script is divided into several functional parts:
- Show-FirewallRuleICMP: Displays existing ICMPv4 rules, allowing actions like editing or deleting rules.
- Prepare_Create_Rule_ICMP: Creates a new ICMPv4 rule by specifying various parameters such as name, description, state, source, and destination IP addresses.
- Other auxiliary functions are included to validate IP addresses, manage firewall rules, and check for the existence of rules.

.EXAMPLE
To view existing rules, run the script and choose option 1 from the menu.

.EXAMPLE
To create a new rule, run the script and choose option 2. Follow the prompts.

.NOTES
- Prerequisite: This script requires administrative privileges to configure rules.
- Be cautious when using this script as it can have a direct impact on network configurations.
- Make sure to back up existing configurations if needed.

.LINK
GitHub Repository: [https://github.com/ZiToUnEAnTiCipWiN32]
Website: [http://zitouneanticip.free.fr]

AUTHOR:
[ZiToUnE AnTiCiP]

VERSION:
Creation Date: [2023-10]
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
function Show-CenterTitle {
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
    Show-CenterTitle ("_" * 60) 
    if ($null -ne $foundRules -and $ruleNumber -ge 0 -and $ruleNumber -lt $foundRules.Count) {
        if ($null -eq $foundRules.Iteration[$ruleNumber]) {
            Show-CenterTitle ""
        } else {
            Show-CenterTitle $foundRules.Iteration[$ruleNumber]
        }
    }
    Show-CenterTitle "FirEwAlL Rule"
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
    Show-CenterTitle "AdDrEsS FiLtEr" 
    Show-Colored "LocalAddress" $filter.LocalAddress -nameColor Magenta -valueColor Blue
    Show-Colored "RemoteAddress" $filter.RemoteAddress -nameColor Magenta -valueColor Blue
}

# Fonction pour afficher les détails des filtres de port ( commenter ou décommenter les éléments pour +- de sortie )
function Show-PortFilterDetails($filter) {
    Show-CenterTitle "PoRt FiLtEr"
    Show-Colored "Protocol" $filter.Protocol -nameColor Magenta -valueColor Blue
    Show-Colored "LocalPort" $filter.LocalPort -nameColor Magenta -valueColor Blue
    Show-Colored "RemotePort" $filter.RemotePort -nameColor Magenta -valueColor Blue
    # Show-Colored "IcmpType" $filter.IcmpType -nameColor Magenta -valueColor Blue
    # Show-Colored "DynamicTarget" $filter.DynamicTarget -nameColor Magenta -valueColor Blue
}

# Function pour récuérer l'ip du WSL
function Generate_Range_From_IP_WSL {
    # Récupération de l'adresse IP (TESTER sur Windows 10)
    $myRemoteIP = (Get-ItemPropertyValue -Path 'Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss' -Name 'NatIpAddress')

    # Convertir l'adresse IP en objet IPAddress
    $IPAddress = [System.Net.IPAddress]::Parse($myRemoteIP)

    # Masque de sous-réseau par défaut /24
    $subNetMask = "/24"

    # Trouver l'adresse réseau en effectuant un AND binaire entre l'adresse IP et le masque
    $networkAddress = $IPAddress.Address -band ([System.Net.IPAddress]::Parse("255.255.255.0").Address)

    # Convertir l'adresse réseau en format lisible
    $networkIPAddress = [System.Net.IPAddress]::new($networkAddress)

    # Concaténer et former la plage d'adresses
    $rangeIP = "$networkIPAddress$subNetMask"
    
    $result = "$myRemoteIP, $rangeIP"
    return $result
}

# Function pour que la saisi utilisateur soit alphanumérique et de 2 caractères mini
function Test-InputUser {
    param (
        [string]$InputUser  # Paramètre qui prend l'entrée utilisateur en entrée
    )

    # Vérification si l'entrée utilisateur est vide ou nulle
    if ([string]::IsNullOrEmpty($InputUser)) {
        # Si l'entrée utilisateur est vide, afficher un message d'erreur en rouge
        Write-Host "[!] User input cannot be empty." -ForegroundColor DarkRed
        return $false  # Renvoyer faux (False)
    } elseif ($InputUser -match '^[a-zA-Z0-9].*[a-zA-Z0-9]$') {
        # Vérification si le premier et le dernier caractère sont alphanumériques
        return $true  # Si l'entrée utilisateur est conforme, renvoyer vrai (True)
    } else {
        # Si le premier ou le dernier caractère ne sont pas alphanumériques, afficher un message d'erreur
        Write-Host "[!] User input should start and end with an alphanumeric character, and it should consist of at least 2 characters." -ForegroundColor DarkRed
        return $false  # Renvoyer faux (False)
    }
}

# Function pour vérifier une IP ou plage d'IP valide
function Test-IPAddress {
    param (
        [string]$IPAddress  # Paramètre qui prend l'adresse IP en entrée
    )

    # Vérification de la validité de l'adresse IP en utilisant une expression régulière
    if ($IPAddress -match '^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}(/\d{1,2})?$') {
        return $true  # Si l'adresse IP est valide, renvoyer vrai (True)
    } else {
        # Si l'adresse IP n'est pas valide, afficher un message d'erreur en rouge
        Write-Host "[!] The specified IP address is not valid. Use the CIDR format (e.g., 192.168.1.0/24) or a single IP address (e.g., 192.168.1.1)." -ForegroundColor DarkRed
        return $false  # Renvoyer faux (False)
    }
}

# Function pour afficher les règles du firewall (comprend l'édition et la suppression)
function Show-FirewallRuleICMP {

    Write-Host "[-] Collecting ..." -ForegroundColor DarkYellow 

    $Continuer_ShowRuleICMP = $true
    while ($Continuer_ShowRuleICMP) {

        $ruleNameToSearch = "*"

        # Collecte des données du pare-feu (ICMPv4) remplacer 'ICMPv4' par ICMP* pourprendre en charge 'v6'
        $firewallRules = Get-NetFirewallPortFilter -Protocol 'ICMPv4' | Get-NetFirewallRule | Where-Object -Property DisplayName -Like $ruleNameToSearch
        $numberOfCharacters = 10
        # Crée des tableaux vides pour stocker les détails des règles
        $foundRules = @()
        $ruleDetails = @()

        # parcourt tous les indices valides du tableau $firewallRules, et à chaque itération, la variable $index contient l'indice actuel.
        foreach ($index in 0..($firewallRules.Count - 1)) {
            $rule = $firewallRules[$index]

            # Vérification de la longueur de la chaîne avant d'utiliser Substring
            if ($rule.DisplayName.Length -ge $numberOfCharacters) {
                $characters = $rule.DisplayName.Substring(0, $numberOfCharacters) + "..."
            } else {
                $characters = $rule.DisplayName  # Utiliser la chaîne complète si la longueur est inférieure à $numberOfCharacters
            }

            # Affiche l'avancement de la recherche
            Write-Host "`r" -NoNewline
            # Write-Host "[-] Analyzing" $ruleNameToSearch "In" ($index) "Of" $firewallRules.Count "Rules" -NoNewline -ForegroundColor DarkYellow
            Write-Host "[+] Analyzing [" -ForegroundColor DarkYellow -NoNewline
            Write-Host $characters -ForegroundColor Blue -NoNewline
            Write-Host "] In " -ForegroundColor DarkYellow -NoNewline
            Write-Host ($index + 1) -ForegroundColor Magenta -NoNewline
            Write-Host " Of " -ForegroundColor DarkYellow -NoNewline
            Write-Host $firewallRules.Count -ForegroundColor Magenta -NoNewline
            Write-Host " Rules" -ForegroundColor DarkYellow -NoNewline

            # La recherche correspond à une règle
            if ($rule.DisplayName -like "$ruleNameToSearch") {

                # Stocke la règle correspondante dans le tableau $foundRules
                $foundRules += @{
                    'Rule' = $rule
                    'Iteration' = $index
                }

                # Stocke les détails de la règle dans le tableau $ruleDetails
                $ruleDetails += @{
                    'Rule' = $rule
                    'Iteration' = $index
                    'AddressFilter' = $rule | Get-NetFirewallAddressFilter
                    'PortFilter' = $rule | Get-NetFirewallPortFilter
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

                # Afficher le titre du menu
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
                    $userInput = Read-Host "`nMaNaGe-PiNg-{Show} [?] Enter the number of the firewall rule, or exit (q)"
                    
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
                            Show-PortFilterDetails $SelectedRuleDetails['PortFilter']
# sous menu edition / SUppression
                            # Boucle principale pour afficher le menu et gérer les actions de l'utilisateur
                            do {
                                $pattern = (" " * 18)

                                # Afficher les options
                                Write-Host "`n$pattern  1. Edit Rule ICMPv4" -ForegroundColor Cyan
                                Write-Host "$pattern  2. Delete Rule ICMPv4" -ForegroundColor DarkYellow
                                Write-Host "$pattern  3. Back" -ForegroundColor DarkRed
                                
                                # Demander à l'utilisateur de choisir une option
                                $choice = Read-Host "MaNaGe-PiNg-{Show} [?] "

                                # Utiliser une instruction switch pour gérer les choix de l'utilisateur
                                switch ($choice) {
# edition
                                    "1" { 
                                        
                                        while ($true) {
                                            if ($SelectedFoundRule['Rule'].Enabled -eq "True") {
                                                $choix = Read-Host "MaNaGe-PiNg-{EdIt} [?] (D) Disable the rule (q) Exit"
                                            } elseif ($SelectedFoundRule['Rule'].Enabled -eq "False") {
                                                $choix = Read-Host "MaNaGe-PiNg-{EdIt} [?] (E) Enable the rule E, (q) Exit"
                                            }
                                            switch ($choix) {
                                                "D" {
                                                    try {
                                                        Disable-NetFirewallRule -DisplayName $SelectedFoundRule['Rule'].DisplayName
                                                        # on vérifie
                                                        $test = Get-NetFirewallRule | Where-Object { $_.DisplayName -eq $SelectedFoundRule['Rule'].DisplayName } | Select-Object -ExpandProperty Enabled
                                                        # Vérifiez la valeur de l'attribut Enabled pour la règle spécifique
                                                        if ($test -eq "True") {
                                                            Write-Host "[+] MaNaGe-PiNg-{EdIt} The rule has been Enabled" -ForegroundColor Green
                                                        } elseif ($test -eq "False") {
                                                            Write-Host "[+] MaNaGe-PiNg-{EdIt} The rule has been Disabled" -ForegroundColor Green
                                                        }
                                                    }
                                                    catch {
                                                        Write-Host "[!] Error while executing the 'New-NetFirewallRule' : $_" -ForegroundColor DarkRed
                                                    }
                                                    return
                                                }
                                                "E" {
                                                    try {
                                                        Enable-NetFirewallRule -DisplayName $SelectedFoundRule['Rule'].DisplayName
                                                        # on vérifie
                                                        $test = Get-NetFirewallRule | Where-Object { $_.DisplayName -eq $SelectedFoundRule['Rule'].DisplayName } | Select-Object -ExpandProperty Enabled
                                                        # Vérifiez la valeur de l'attribut Enabled pour la règle spécifique
                                                        if ($test -eq "True") {
                                                            Write-Host "[+] MaNaGe-PiNg-{EdIt} The rule has been Enabled" -ForegroundColor Green
                                                        } elseif ($test -eq "False") {
                                                            Write-Host "[+] MaNaGe-PiNg-{EdIt} The rule has been Disabled" -ForegroundColor Green
                                                        }
                                                    }
                                                    catch {
                                                        Write-Host "[!] Error while executing the 'New-NetFirewallRule' : $_" -ForegroundColor DarkRed
                                                    }
                                                    return
                                                }
                                                "q" {
                                                    return
                                                }
                                                default {
                                                    Write-Host "[!] Invalid input." -ForegroundColor DarkRed
                                                }
                                            }
                                        }
                                    }         
# Supprimer une autorisation
                                    "2" {  
                                        do {
                                            $response = Read-Host "MaNaGe-PiNg-{Delete} [?] Are you sure to remove this configurations now (Y/n) "
                                            switch ($response) {
                                                "Y" {
                                                    $test = Remove-NetFirewallRule -DisplayName $SelectedFoundRule['Rule'].DisplayName 

                                                    if (-not $test) {
                                                        Write-Host "[+] MaNaGe-PiNg-{Delete} The rule has been Deleted" -ForegroundColor Green
                                                    } else {
                                                        Write-Host "[+] MaNaGe-PiNg-{Delete} The rule has not Deleted" -ForegroundColor Green
                                                    }
                                                    return
                                                }
                                                "n" { return }
                                                default { Write-Host "[!] Invalid input." -ForegroundColor DarkRed }
                                            }
                                        } while ($response -ne "Y" -and $response -ne "n")
                                    }                     
                                    # Retour à la liste des rule(s)
                                    "3" { continue }             
                                    default { Write-Host "[!] Invalid input. Please enter a valid number." -ForegroundColor DarkRed }
                                }
                            } while ($choice -ne "3")

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
    }
}

# Function pour préparer la création d'une règle
function Prepare_Create_Rule_ICMP {

    Write-Host "`n[+] Options auto-configured :" -ForegroundColor DarkYellow
    # Protocol ICMPv4
    $Protocol = "ICMPv4"
    Write-Host "[+] Set Protocol 'ICMPv4' " -ForegroundColor Green

    # Direction
    $Direction = "InBound"
    Write-Host "[+] Set Direction 'InBound' " -ForegroundColor Green

    # Enabled
    $Enabled = $True
    Write-Host "[+] Set Enabled 'True' " -ForegroundColor Green

    $Action = ""
    do {
        # Demander à l'utilisateur l'action
        $choix = Read-Host "MaNaGe-PiNg-{Creating} [?] Action Of rule (A) Allow, (B) Block "

        switch ($choix) {
            "A" { 
                $Action = "Allow"
            }
            "B" { 
                $Action = "Block"
            }
            default { 
                Write-Host "[!] Invalid input." -ForegroundColor DarkRed
            }
        }
    } while ($Action -eq "")

    # Demander à l'utilisateur de saisir le nom de la règle
    do {
        $InputUser = Read-Host "MaNaGe-PiNg-{Creating} [?] Name Of rule "
    } until (Test-InputUser $InputUser)
    $Name = $InputUser

    # le DisplaName de la règle sera le Name
    $DisplayName = $Name

    # Demander à l'utilisateur de saisir la description
    do {
        $InputUser = Read-Host "MaNaGe-PiNg-{Creating} [?] Description Of rule "
    } until (Test-InputUser $InputUser)
    $Description = $InputUser

    # affiche les IP des interfaces Ethernet
    try {
        # Obtenir l'exemple d'adresse IP associée à l'interface "Ethernet"
        $exemple = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -like "Ethernet" }
        
        # Si une adresse IP est trouvée pour l'interface "Ethernet", la stocker dans $hostEthernet
        if ($exemple) {
            $hostEthernet = $exemple | Select-Object -ExpandProperty IPAddress
        }

        # Obtenir les données d'adresse IP pour les interfaces "Ethernet*"
        $NetIPAddressData = Get-NetIPAddress -AddressFamily IPV4 | Where-Object { $_.InterfaceAlias -like "Ethernet*" }
    
        if ($NetIPAddressData) {
            # Afficher la liste des interfaces Ethernet avec leurs adresses IP
            Write-Host "[+] List of Ethernet interfaces." -ForegroundColor DarkYellow
            $NetIPAddressData | Select-Object InterfaceAlias, IPAddress | Format-Table -AutoSize
        } else {
            Write-Host "[!] No IP address found for Ethernet interfaces." -ForegroundColor DarkRed
        }
    } catch {
        # En cas d'erreur lors de la récupération des adresses IP, afficher un message d'erreur en rouge
        Write-Host "[!] Error while retrieving IP addresses : $_" -ForegroundColor DarkRed
    }

    # Demander à l'utilisateur de saisir l'adresse IP d'écoute jusqu'à ce qu'elle soit valide
    do {
        $ip = Read-Host "MaNaGe-PiNg-{Creating} [?] Local IP address (e.g. $hostEthernet) "
    } until (Test-IPAddress $ip)
    $ListenIp = $ip

    # Demander à l'utilisateur de saisir l'adresse IP de destination jusqu'à ce qu'elle soit valide
    do {
        
        # Appel de la fonction pour récupérer l'IP si WSL est utiliser et qui est configurer par défaut (tester sur Windows 10)
        $IPrangeIP = Generate_Range_From_IP_WSL

        # Vérification si la plage d'adresses IP existe (n'est pas vide ou null)
        if ($IPrangeIP) {
            $ip = Read-Host "MaNaGe-PiNg-{Creating} [?] From IP address (e.g. $IPrangeIP) "  # Affichage IP et plage IP WSL
        } else {
            $ip = Read-Host "MaNaGe-PiNg-{Creating} [?] From IP address "
        }
    } until (Test-IPAddress $ip)
    $RemoteIp = $ip

    # Appeler la fonction Create_Rule_ICMP avec les argments
    Create_Rule_ICMP -Name $Name -DisplayName $DisplayName -Description $Description -Enabled $Enabled -Direction $Direction -Protocol $Protocol -Action $Action -ListenIp  $ListenIp -RemoteIp $RemoteIp
}

# Function pour vérifier une règle
function Check_FirewallRule {
    param (
        [string]$rule
    )
    # Write-Host "[-] DEBUG checking rule =  $rule" -ForegroundColor Cyan
    $foundRule = Get-NetFirewallRule | Where-Object { $_.Name -eq "$rule" }

    if ($null -ne $foundRule) {
        # Write-Host "[-] DEBUG result = "$foundRule.DisplayName -ForegroundColor Cyan
        return $foundRule.DisplayName
    } else { 
        return $false 
    }
}

# Function pour créer une règle
function Create_Rule_ICMP {
    param (
        [string]$Name,          # Nom de la règle
        [string]$DisplayName,   # Nom d'affichage
        [string]$Description,   # La description
        [bool]$Enabled,         # L'état True / False
        [string]$Direction,     # La direction Inbound / OutBound
        [string]$Protocol,      # Le protocol ICMPv4
        [string]$Action,        # Autorisation Allow / Block
        [string]$ListenIp,      # Adresse IP d'écoute locale
        [string]$RemoteIp       # Adresse IP de destination
    )
    
    # Write-Host "[-] DEBUG Name = $Name" -ForegroundColor Cyan
    $result = Check_FirewallRule -rule $Name
    
    # Si la règle existe 
    if ($result -eq $Name) {
        Write-Host "[!] The Rule already exist " -ForegroundColor DarkYellow
        $ruleDetails = @()                              # Définition un tableau vide
        $rule = Get-NetFirewallRule -DisplayName $Name  # Récupère les données de la règle
        $ruleDetails += @{ 'Rule' = $rule }             # Stocke les données dans le tableau
        Show-FirewallRuleDetails $rule                  # Apel la function d'affichage

    } else {
        Write-Host "[+] No existing rule detected, creating..." -ForegroundColor DarkYellow

        # La règle existe pas donc on la créer
        try {
            $command = "New-NetFirewallRule -Name '$Name' -DisplayName '$DisplayName' -Description '$Description' -Enabled '$Enabled' -Direction '$Direction' -Protocol '$Protocol' -Action '$Action' -LocalAddress '$ListenIp' -RemoteAddress '$RemoteIp'"
            Invoke-Expression $command
            # Write-Host $command

            # on vérifie
            $result = Check_FirewallRule -rule $Name
            if ($result -eq $Name) {
                Write-Host "[+] The rule was created successfully." -ForegroundColor Green
            }
        } catch {
            Write-Host "[!] Error while executing the 'New-NetFirewallRule' command.: $_" -ForegroundColor DarkRed
        }
        
    }
}

# Boucle principale pour afficher le menu et gérer les actions de l'utilisateur
do {
    $tab = (" " * 12)
    $inter = (" " * 9)
    $pattern = (" " * 15)
    # Afficher le titre du menu
    Write-Host "$tab/-_-_-_-_-_-_-_-_-_-_-_-__-_-_-_-_-_-_-_-_-_-_-_-\" -ForegroundColor Yellow
    Write-Host "$tab|$inter -MaNaGe RuLe ICMPv4 [PING].- $inter|" -ForegroundColor Yellow
    Write-Host "$tab\-_-_-_-_-_-_-_-_-_-_-_-__-_-_-_-_-_-_-_-_-_-_-_-/" -ForegroundColor Yellow

    # Afficher les options
    Write-Host "`n$pattern  1. Show Rule ICMPv4 (you can edit or delete the rule) " -ForegroundColor Cyan
    Write-Host "$pattern  2. Create Rule ICMPv4" -ForegroundColor Green
    Write-Host "$pattern  3. Back" -ForegroundColor DarkRed
    
    # Demander à l'utilisateur de choisir une option
    $choice = Read-Host "MaNaGe-PiNg [?] "

    # Utiliser une instruction switch pour gérer les choix de l'utilisateur
    switch ($choice) {
        "1" { Show-FirewallRuleICMP }                         # Affiche les rule et permet les editions
        "2" { Prepare_Create_Rule_ICMP }                      # Créer une rule
        "3" { return }                                        # Retour à la liste des rule(s)
        default { Write-Host "MaNaGe-PiNg [!] Invalid input. Please enter a valid number." -ForegroundColor DarkRed }
    }
} while ($choice -ne "3")