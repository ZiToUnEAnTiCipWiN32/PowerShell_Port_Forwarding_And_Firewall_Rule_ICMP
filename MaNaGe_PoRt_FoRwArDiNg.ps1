<#
.SYNOPSIS
This PowerShell script manages port forwarding configurations using netsh on your Windows machine.

.DESCRIPTION
Port forwarding is a technique that allows you to redirect network traffic from one port to another or from one IP address to another.
This script uses the 'netsh' command to manage port forwarding on Windows. It provides a user-friendly interface to interact with port forwarding rules.

Please note that this script requires administrative privileges to manage port forwarding rules.

.NOTES
- Prerequisite : This script requires administrative privileges to configure port forwarding.
- Be cautious when using this script as it can have a direct impact on network configurations.
- Make sure to back up existing configurations if needed.
- Use the 'Clear All Port Forwarding' option with caution, as it removes all existing port forwarding rules.

STRUCTURE:
- Generate_Range_From_IP_WSL Function to generate range IP if WSL used
- Test-Port: Function to validate port numbers.
- Test-IPAddress: Function to validate IP addresses.
- Test-Protocol: Function to validate protocols (TCP/UDP).
- Check_PortRedirection: Function to check existing port forwarding rules.
- Show_PortRedirections: Function to display existing port forwarding rules.
- Prepare_Create_PortRedirection: Function to prepare Create_PortRedirection Function.
- Create_PortRedirection: Function to create a new port forwarding rule.
- Prepare_Remove_PortRedirection: Function to prepare Remove_PortRedirection Function.
- Remove_PortRedirection: Function to remove an existing port forwarding rule.
- Prepare_Clear_AllPortForwarding: Function to prepare Clear_AllPortForwarding Function.
- Clear_AllPortForwarding: Function to clear all port forwarding rules.
- Main Loop: User menu for interacting with the script.

.EXAMPLE
To view existing port forwarding rules, run the script and choose option 1 from the menu.

.EXAMPLE
To create a new port forwarding rule, run the script and choose option 2. Follow the prompts to specify the local IP address, source port, destination IP address, and destination port.

.EXAMPLE
To delete a specific port forwarding rule, run the script and choose option 3. Follow the prompts to specify the IP address and port to remove.

.EXAMPLE
To clear all port forwarding configurations, run the script and choose option 4. Confirm the action when prompted.

.EXAMPLE
To exit the script, choose option 5.

.LINK
GitHub Repository: [https://github.com/ZiToUnEAnTiCipWiN32]
WebSite: [http://zitouneanticip.free.fr]

AUTHOR:
[ZiToUnE AnTiCiP]

VERSION:
Date de création : [2023-10]
1.0
#>

# Function pour récupérer IP WSl si utiliser
function Generate_Range_From_IP_WSL {
    # Récupération de l'adresse IP
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

# Functionpour vérifier si le PORT est valide
function Test-Port {
    param (
        [string]$Port  # Paramètre qui prend le numéro de port en entrée
    )

    # Vérification de la validité du numéro de port en utilisant des conditions
    if ($Port -match '^\d+$' -and [int]$Port -ge 1 -and [int]$Port -le 65535) {
        return $true  # Si le port est valide, renvoyer vrai (True)
    } else {
        # Si le numéro de port n'est pas valide, afficher un message d'erreur en rouge
        Write-Host "[!] The specified port is not valid. The port must be a number between 1 and 65535." -ForegroundColor DarkRed
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

# Function pour vérifier le Protocol 
function Test-Protocol {
    param (
        [string]$Protocol  # Paramètre qui prend le protocole en entrée
    )

    # Liste des protocoles valides
    $ValidProtocols = @("TCP", "UDP")
    
    # Vérification de la validité du protocole en vérifiant s'il est contenu dans la liste des protocoles valides (non sensible à la casse)
    if ($ValidProtocols -contains $Protocol.ToUpper()) {
        return $true  # Si le protocole est valide, renvoyer vrai (True)
    } else {
        # Si le protocole n'est pas valide, afficher un message d'erreur en rouge
        Write-Host "[!] The specified protocol is not valid. Use TCP or UDP." -ForegroundColor DarkRed
        return $false  # Renvoyer faux (False)
    }
}

# Function pour vérifier les redirection de port
function Check_PortRedirection {
    param (
        [int]$ListenPort,  # Paramètre qui prend le port d'écoute en entrée
        [string]$ListenIp  # Paramètre qui prend l'adresse IP d'écoute en entrée
    )

    try {
        # Commande pour vérifier les redirections de port à l'aide de netsh
        $checkCommand = "netsh interface portproxy show all"
        
        # Exécuter la commande et stocker la sortie (résultat) dans $checkOutput en supprimant les erreurs silencieusement
        $checkOutput = Invoke-Expression -Command $checkCommand -ErrorAction SilentlyContinue

        # Rechercher et renvoyer les lignes de sortie correspondant à l'adresse IP d'écoute et au port d'écoute spécifiés
        return $checkOutput | Where-Object {$_ -match "^\s*$ListenIp\s*\b$ListenPort\b\s*\S+\s*\d+"}
    }
    catch {
        # En cas d'erreur lors de l'exécution de la commande netsh, afficher un message d'erreur en rouge
        Write-Host "[!] Error while executing the 'Netsh show all' command : $_" -ForegroundColor DarkRed
    }
}

# Function pour afficher les redirection de port
function Show_PortRedirections {
    # Commande pour afficher toutes les redirections de port à l'aide de netsh
    $netshCommand = "netsh interface portproxy show all"
    
    try {
        
        # Exécuter la commande et stocker la sortie dans $output
        $output = Invoke-Expression $netshCommand
        
        # Afficher la sortie des redirections de port
        if ($output.Length) {
            Write-Host "[+] List of existing port forwarding." -ForegroundColor DarkYellow
            return $output
        } else {
            Write-Host "[+] No existing port forwarding." -ForegroundColor DarkYellow
        }
        
        # Renvoyer la valeur de $output
        return $output

    } catch {
        # En cas d'erreur lors de l'exécution de la commande netsh, afficher un message d'erreur en rouge
        Write-Host "[!] Error while executing the 'Netsh show all' command : $_" -ForegroundColor DarkRed
    }
}

# Function pour préparer la création de redirection de port
function Prepare_Create_PortRedirection {
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
        $ip = Read-Host "FoRWaRdInG-{Creating} [?] Local IP address (e.g. $hostEthernet) "
    } until (Test-IPAddress $ip)
    $ListenIp = $ip

    # Demander à l'utilisateur de saisir le port d'écoute jusqu'à ce qu'il soit valide
    do {
        $port = Read-Host "FoRWaRdInG-{Creating} [?] Source port "
    } until (Test-Port $port)
    $ListenPort = $port

    # Demander à l'utilisateur de saisir l'adresse IP de destination jusqu'à ce qu'elle soit valide
    do {
        # Appel de la fonction pour récupérer l'IP si WSL est utiliser et qui est configurer par défaut (tester sur Windows 10)
        $IPrangeIP = Generate_Range_From_IP_WSL

        if ($IPrangeIP) {
            $ip = Read-Host "FoRWaRdInG-{Creating} [?] Destination IP address (e.g. $IPrangeIP) "
        } else {
            $ip = Read-Host "FoRWaRdInG-{Creating} [?] Destination IP address "
        }
    } until (Test-IPAddress $ip)
    $RemoteIp = $ip

    # Demander à l'utilisateur de saisir le port de destination jusqu'à ce qu'il soit valide
    do {
        $port = Read-Host "FoRWaRdInG-{Creating} [?] Destination port "
    } until (Test-Port $port)
    $RemotePort = $port

    # Appeler la fonction Create_PortRedirection pour créer la redirection de port avec les valeurs spécifiées
    Create_PortRedirection -ListenPort $ListenPort -ListenIp $ListenIp -RemotePort $RemotePort -RemoteIp $RemoteIp
}

# Function pour la création de redirection de port
function Create_PortRedirection {
    param (
        [int]$ListenPort,    # Port d'écoute local
        [string]$ListenIp,   # Adresse IP d'écoute locale
        [int]$RemotePort,    # Port de destination
        [string]$RemoteIp    # Adresse IP de destination
    )

    # Vérifier si une redirection de port existante correspondant au port local et à l'adresse IP locale spécifiés
    $existingLocalRedirection = Check_PortRedirection -ListenPort $ListenPort -ListenIp $ListenIp

    if ($existingLocalRedirection) {
        # Si une redirection existe déjà, afficher un message d'erreur en rouge et renvoyer les détails de la redirection existante
        Write-Host "[!] The local port $ListenPort and local IP address $ListenIp are already redirected." -ForegroundColor DarkYellow
        Write-Output $existingLocalRedirection
        Write-Host
        return
    }

    # Préparer la commande netsh pour créer la redirection de port
    $netshCommand = "netsh interface portproxy add v4tov4 "
    $netshCommand += "listenport=$ListenPort "
    $netshCommand += "listenaddress=$ListenIp "
    $netshCommand += "connectport=$RemotePort "
    $netshCommand += "connectaddress=$RemoteIp "

    try {
        # Afficher un message indiquant que la redirection est en cours de création
        Write-Host "[+] No existing redirections detected, creating..." -ForegroundColor DarkYellow

        # Exécuter la commande netsh pour créer la redirection
        Invoke-Expression -Command $netshCommand -ErrorAction Stop

        # Vérifier à nouveau si la redirection a été créée avec succès
        $existingLocalRedirection = Check_PortRedirection -ListenPort $ListenPort -ListenIp $ListenIp

        if ($existingLocalRedirection) {
            # Si la redirection a été créée avec succès, afficher un message de succès en vert et renvoyer les détails de la redirection
            Write-Host "[+] The redirection was created successfully." -ForegroundColor Green
            Write-Output $existingLocalRedirection
            Write-Host
        }
    } catch {
        # En cas d'erreur lors de l'exécution de la commande netsh, afficher un message d'erreur en rouge
        Write-Host "[!] Error while executing the 'Netsh add v4tov4' command.: $_" -ForegroundColor DarkRed
    }
}

# Function pour préparer la suppression de redirection de port
function Prepare_Remove_PortRedirection {

    # Obtenir les redirections de port existantes
    $output = Show_PortRedirections

    if ($output.Length -gt 0) {
        # S'il y a des redirections de port existantes, les afficher
        $output

        # Demander à l'utilisateur de saisir l'adresse IP d'écoute à supprimer jusqu'à ce qu'elle soit valide
        do {
            $ip = Read-Host "FoRWaRdInG-{Removing} [?] IP address to remove from listening. "
        } until (Test-IPAddress $ip)
        $ListenIp = $ip

        # Demander à l'utilisateur de saisir le port d'écoute à supprimer jusqu'à ce qu'il soit valide
        do {
            $port = Read-Host "FoRWaRdInG-{Removing} [?] Listening port to remove "
        } until (Test-Port $port)
        $ListenPort = $port

        # Appeler la fonction Remove_PortRedirection pour supprimer la redirection de port spécifiée
        Remove_PortRedirection -ListenPort $ListenPort -ListenIp $ListenIp
    } else {
        # S'il n'y a aucune redirection de port existante, afficher un message d'information
        Write-Host "[+] Cannot remove without an existing Port Forwarding." -ForegroundColor DarkYellow
    }
}

# Function pour la suppression de redirection de port
function Remove_PortRedirection {
    param (
        [int]$ListenPort,    # Port d'écoute à supprimer
        [string]$ListenIp    # Adresse IP d'écoute à supprimer
    )

    # Vérifier si la redirection existe déjà
    $existingRedirection = Check_PortRedirection -ListenPort $ListenPort -ListenIp $ListenIp

    if ($existingRedirection) {

        # Si une redirection existe
        Write-Host "[+] Existing redirections detected, removing..." -ForegroundColor DarkYellow
        try {
            # Préparer et exécuter la commande pour supprimer la redirection
            $deleteCommand = "netsh interface portproxy delete v4tov4 listenport=$ListenPort listenaddress=$ListenIp"
            Invoke-Expression -Command $deleteCommand -ErrorAction Stop

            # Vérifier que la suppression a été effectuée en vérifiant à nouveau la redirection
            $existingLocalRedirection = Check_PortRedirection -ListenPort $ListenPort -ListenIp $ListenIp

            if (!$existingLocalRedirection) {
                # Si la redirection a été supprimée avec succès, afficher un message de succès en vert
                Write-Host "[+] The redirection has been successfully removed." -ForegroundColor Green
            }
        }
        catch {
            # En cas d'erreur lors de l'exécution de la commande netsh, afficher un message d'erreur en rouge
            Write-Host "[!] Error while executing the 'Netsh delete' command. : $_" -ForegroundColor DarkRed
        }
    } else {
        # Si aucune redirection n'existe, afficher un message d'information
        Write-Host "[!] No existing redirections to remove." -ForegroundColor DarkYellow
        return
    }
}

# Function pour préparer la suppression de toutes les redirections de port(s)
function Prepare_Clear_AllPortForwarding {
    do {
        # Obtenir les redirections de port existantes
        $output = Show_PortRedirections
        if ($output.Length -gt 0) {
            # S'il y a des redirections de port existantes, les afficher
            $output
        } else {
            # S'il n'y a aucune redirection de port existante, afficher un message d'information
            Write-Host "[+] No need to clear, you do not have an existing configuration. " -ForegroundColor DarkYellow
            return
        }

        $response = Read-Host "FoRWaRdInG-{clearing} [?] Are you sure to remove all port forwarding configurations now (Y/n) "
        switch ($response) {
            "Y" { Clear_AllPortForwarding }
            "n" { return }
            default { Write-Host "FoRWaRdInG-{clearing} [!] Invalid input." -ForegroundColor DarkRed }
        }
    } while ($response -ne "Y" -and $response -ne "n")
}

# Function pour supprimer toutes les redirections de port(s)
function Clear_AllPortForwarding {
    # Commande pour réinitialiser toutes les redirections de port à l'aide de netsh
    $netshCommand = "netsh interface portproxy reset"
        
    try {
        
        # Exécuter la commande netsh pour réinitialiser les redirections de port
        Invoke-Expression $netshCommand
        # Vérifier les redirections de port existantes
        $output = Show_PortRedirections
        if ($output.Length -gt 0) {
            # S'il y a des redirections de port existantes, les afficher avec un message
            Write-Host "[!] An unexplained error has occurred; can't clear this!!! " -ForegroundColor DarkRed
            $output
        } else {
            # S'il n'y a aucune redirection de port existante, afficher un message de confirmation
            Write-Host "[+] All port forwarding configurations have been deleted. " -ForegroundColor Green
        }
        
    } catch {
        # En cas d'erreur lors de la réinitialisation des redirections, afficher un message d'erreur en rouge
        Write-Host "[!] Error occurred while executing the 'Netsh reset' command. : $_" -ForegroundColor DarkRed
    }
}

# Boucle principale pour afficher le menu et gérer les actions de l'utilisateur
do {
    $tab = (" " * 12)
    $inter = (" " * 9)
    $pattern = (" " * 22)
    # Afficher le titre du menu
    Write-Host "$tab**************************************************" -ForegroundColor Yellow
    Write-Host "$tab*$inter -MaNaGe PoRt(s) FoRWaRdInG.- $inter*" -ForegroundColor Yellow
    Write-Host "$tab**************************************************" -ForegroundColor Yellow

    # Afficher les options du menu
    Write-Host "$pattern  1. Show Port Forwarding" -ForegroundColor Green
    Write-Host "$pattern  2. Create Port Forwarding" -ForegroundColor DarkCyan
    Write-Host "$pattern  3. Delete Port Forwarding" -ForegroundColor DarkYellow
    Write-Host "$pattern  4. Clear All Port Forwarding" -ForegroundColor DarkBlue
    Write-Host "$pattern  5. Back" -ForegroundColor DarkRed
    
    # Demander à l'utilisateur de choisir une option
    $choice = Read-Host "FoRWaRdInG [?] "

    # Utiliser une instruction switch pour gérer les choix de l'utilisateur
    switch ($choice) {
        "1" { Show_PortRedirections }            # Afficher les redirections de port existantes
        "2" { Prepare_Create_PortRedirection }   # Préparer et créer une nouvelle redirection de port
        "3" { Prepare_Remove_PortRedirection }   # Préparer et supprimer une redirection de port
        "4" { Prepare_Clear_AllPortForwarding }          # Réinitialiser toutes les redirections de port
        "5" { return }                           # Quitter le programme
        default { Write-Host "FoRWaRdInG [!] Invalid input. Please enter a valid number." -ForegroundColor DarkRed }
    }
} while ($choice -ne "5")
