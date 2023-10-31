<#
.SYNOPSIS
Interactively manages port forwarding and firewall rules through an ASCII-based menu.

.DESCRIPTION
The script presents an interactive menu to manage port forwarding and firewall rules. The ASCII art adds an aesthetic visual element to the script. The menu offers options for managing port forwarding rules, ICMPv4 (PING) rules, searching firewall rules by DisplayName, and an option to exit. Each menu option triggers the execution of separate PowerShell scripts responsible for carrying out the specific functionalities.

SCRIPT STRUCTURE
The script contains:
- An ASCII art function 'Show-Ascii' for aesthetic presentation.
- 'Show-Menu' function that displays an ASCII-based interactive menu for users to navigate and choose options.
- A looping construct to display the menu until the user chooses to exit.

.EXAMPLE
Run the script using PowerShell:
PS> powershell -ExecutionPolicy Bypass -File .\main.ps1

.NOTES
- The script requires accompanying PowerShell scripts for options 1, 2, and 3 to execute properly.
- ASCII art is used to enhance the visual appeal of the menu interface.
- The user is prompted to choose one of the menu options to trigger corresponding functionalities.

.LINK
GitHub Repository: [https://github.com/ZiToUnEAnTiCipWiN32]
WebSite: [http://zitouneanticip.free.fr]

AUTHOR:
[ZiToUnE AnTiCiP]

VERSION:
Created Date: [2023-10]
1.0
#>


# Import du module NetSecurity
Import-Module -Name NetSecurity

# Installation du module PSReadLine s'il n'est pas déjà installé
if (-not (Get-Module -ListAvailable -Name PSReadLine)) {
    Install-Module -Name PSReadLine -Force -Scope CurrentUser
}

# Importation du module PSReadLine
Import-Module PSReadLine
function Show-Ascii {
Clear-Host
Write-Host @"
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣴⣶⠶⠶⠖⠚⠛⠛⠛⠛⠒⠶⠶⣶⣶⣤⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣴⡾⠟⠛⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠙⠛⠷⣶⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⡾⠟⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⣶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⡾⠟⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠙⢿⣦⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣷⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⢀⣴⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣷⣄⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⣰⣿⠋⠀⠀⠀⠀⢀⣠⣴⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠴⣒⡽⠟⣩⠏⢩⠉⢏⠙⠯⣑⠲⠦⣄⡀⠀⠀⠀⠀⠀⠀⠙⢶⣤⡀⠀⠀⠀⠀⠈⢿⣦⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⢀⣴⡟⠁⠀⠀⣠⢄⣶⣿⠟⠁⠀⠀⠀⠀⢀⣴⠞⠋⠀⣠⠞⠁⠀⣰⠋⠀⣼⠀⠀⢧⡀⠈⠙⢦⡀⠉⠓⠦⣀⡀⠀⠀⠀⠀⠹⣿⣷⣤⢤⡀⠀⠀⠹⣷⡀⠀⠀⠀⠀
    ⠀⠀⠀⢀⣾⠟⠀⠀⣴⡟⢠⣿⡿⢋⡄⠀⠀⠀⣠⠞⠃⠤⢄⣀⠞⠁⠀⠀⢰⡏⠀⠀⠿⠀⠀⠘⣧⠀⠀⠀⠙⣆⣀⠤⠄⠛⢦⡀⠀⠀⠐⡜⢿⣿⣆⢻⣦⡀⠀⠘⣿⡄⠀⠀⠀
    ⠀⠀⢀⣾⠏⠀⡠⣸⣿⠇⡾⢋⣴⡟⠀⠀⢠⠞⠃⠀⠀⠀⢠⠟⠙⠒⠒⠤⡞⠀⣤⣤⠶⣤⣤⡀⠘⠀⠐⠒⠊⠙⣧⠀⠀⠀⠀⠙⣄⠀⠀⠹⣶⣝⠻⡄⣿⣷⢠⡀⠘⣿⡄⠀⠀
    ⠀⠀⣼⠟⠀⣼⠁⣿⡟⣠⣾⣿⠟⠁⠀⡴⠋⠀⠀⠀⠀⢠⠏⠀⠀⠀⠀⠀⡇⠀⢻⣿⢶⢸⣿⡇⠀⠀⠀⠀⠀⠀⠘⣧⠀⠀⠀⠀⠈⢳⡀⠀⠙⢿⣷⣄⢸⣿⡇⣷⡀⠘⣿⡄⠀
    ⠀⣸⡿⠀⢸⣿⠀⣿⣽⡿⢋⡵⠀⢀⡾⠁⠀⠀⠀⠀⠀⠟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⡾⠛⠁⠀⠀⠀⠀⠀⠀⠀⠸⡆⠀⠀⠀⠀⠀⠹⡄⠀⠸⣏⠿⣷⣿⠃⣿⣷⠀⢹⣧⠀
    ⠀⣿⠇⠀⣼⣿⡇⣼⢋⣴⡿⠁⠀⡼⠀⠉⠒⠶⠦⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠹⡀⠤⠴⠂⠈⠀⢹⡀⠀⢹⣷⣌⢻⡄⣿⣿⠀⠀⢿⡄
    ⢸⡟⠀⣴⢹⣿⡇⣱⣿⡿⠁⠀⣰⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⢴⣿⡷⠤⠀⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣷⠀⠀⣻⣿⣷⡀⣿⣿⠀⠀⢸⡇
    ⢸⡇⠀⣿⠘⣿⣿⣿⠏⣰⠀⠀⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡆⠀⢻⠙⢿⣧⣿⡇⢠⡇⠀⣿
    ⣾⠁⠸⣿⡄⠹⡿⠃⣴⡟⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⣾⣯⣿⣭⣥⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⢸⣧⠈⢻⡿⠀⣾⡇⠀⣿
    ⣿⠀⠀⣿⣷⡀⠇⣼⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣴⣿⡇⠀⢨⣿⣇⠀⠀⣿⣶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡁⠀⠸⣿⣷⡈⠇⣼⣿⠇⠀⣿
    ⢿⡄⢀⢻⣿⣷⢸⣿⡟⢀⠀⠀⡄⠀⠀⠀⠀⠀⠀⠀⢠⣶⣶⣾⣿⣿⣿⣿⡿⠀⠀⠉⣿⡈⠀⠀⢹⣿⣿⣿⣿⣿⣶⣶⡄⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⢠⠸⣿⡇⣰⣿⡿⠀⠀⣿
    ⢸⡇⢸⡄⠻⣿⣼⣿⠁⣸⠀⠀⣷⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⢰⣿⡇⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⢸⠇⠀⣼⡀⢿⡇⣿⡟⢁⡇⠀⣿
    ⢸⣧⠀⣿⣄⠘⢿⡟⢠⣿⡇⠀⠹⡆⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⢸⣿⡇⠀⢀⣿⣿⣿⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⢀⡿⠀⢀⣿⡇⢸⣿⠟⢠⣾⠇⢸⡇
    ⠀⣿⡄⠙⣿⣷⣌⠓⢸⣿⡗⢄⠀⢱⡀⣀⣤⠴⠖⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣄⢸⣿⡇⢀⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⡏⠓⠶⢤⣄⣀⣼⠁⢠⣾⣿⣧⠸⢁⣶⣿⠟⠀⣾⠃
    ⠀⢹⣷⠀⠈⢿⣿⣷⡸⣿⡇⠘⣦⡀⢣⡀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⣷⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⣸⠃⣰⡏⢸⣿⡏⣴⣿⣿⠋⠀⣸⡿⠀
    ⠀⠀⢻⣦⠘⣦⠙⠿⣷⣿⣿⠀⣿⣧⠀⠳⡄⠀⠀⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⢀⡼⠁⣰⣿⠁⢸⣟⣼⡿⠛⣁⠇⢠⣿⠃⠀
    ⠀⠀⠈⢿⣆⠘⢿⣦⣈⠙⠿⣇⢸⣿⣧⢀⠈⠂⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡀⠠⠋⢀⣠⣿⡿⢠⠿⠛⢁⣠⣶⠏⢠⣿⠃⠀⠀
    ⠀⠀⠀⠈⢿⣆⠈⠻⣿⣷⣶⣬⡀⢻⣿⡎⢳⣄⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣠⡶⢋⣿⣿⢁⣡⣴⣶⣿⠿⠃⢠⣾⠋⠀⠀⠀
    ⠀⠀⠀⠀⠈⢻⣧⡀⠈⢙⠿⣿⣿⣷⣿⣷⡄⢿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⢁⣼⣿⣵⣿⣿⠿⢟⠁⠀⣰⣿⠃⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠹⣷⣄⠈⢳⣤⣈⣉⠉⠙⠛⠆⠻⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠟⠱⠞⠛⠉⣉⣁⣠⡴⠃⢀⣴⡟⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠈⠻⣦⡀⠈⠛⠿⣿⣿⣿⣿⣿⣿⣶⡿⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⢿⣷⣾⣿⣿⣿⣿⣿⠿⠟⠋⢀⣴⡿⠋⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠻⣦⣄⠀⠰⣬⣉⣉⣉⣉⣀⣤⣴⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣤⣀⣉⣉⣉⣉⣩⠴⠀⢀⣴⡿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠻⣷⣤⡈⠙⠛⠿⠿⢿⠿⠿⠻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡟⠻⠿⠿⠿⠿⠟⠛⠁⣠⣶⠿⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠿⣷⣦⣀⠀⠀⠀⠀⢠⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠀⠀⠀⠀⢀⣠⣶⠿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⠿⢶⣤⣄⣸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣀⣤⣴⠾⠟⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠛⠿⠿⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠿⠟⠛⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
                      🅗🅣🅣🅟://🅩🅘🅣🅞🅤🅝🅔🅐🅝🅣🅘🅒🅘🅟.🅕🅡🅔🅔.🅕🅡
          66 121 90 105 84 111 85 110 69 65 110 84 105 67 105 80
"@
}
function Show-Menu {
    $tab = (" " * 12)
    $inter = (" " * 9)
    $pattern = (" " * 15)
    Write-Host "$tab╔════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "$tab║$inter PoRt-FoRWaRd & FiReWaLl-RuLeS$inter║" -ForegroundColor Yellow
    Write-Host "$tab╚════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host "$pattern  1. MaNaGe PoRt FoRwArDiNg" -ForegroundColor Green
    Write-Host "$pattern  2. MaNaGe RuLe ICMPv4 [PING] (By Protocol)" -ForegroundColor Blue
    Write-Host "$pattern  3. SeArCh FiReWaLl RuLe (By DisplayName)" -ForegroundColor DarkYellow
    Write-Host "$pattern  4. Exit" -ForegroundColor DarkRed
}

do {
    Show-Ascii
    Show-Menu

    $choice = Read-Host "Main [?]"

    switch ($choice) {
        1 {
            .\MaNaGe_PoRt_FoRwArDiNg.ps1
        }
        2 {
            .\MaNaGe_RuLe_ICMPv4.ps1
        }
        # 
        3 {
            .\SeArCh_FiReWaLl_RuLe.ps1
        }
        # Exit
        4 {
            Write-Host "Crédit:
_____         _      ___ _  _  
 /o| _ | |._ |_ /\ ._ |o/ o|_) 
/_||(_)|_|| ||_/--\| |||\_||   
" -ForegroundColor DarkCyan

            exit
        }
        default { Write-Host "[!] Invalid input." -ForegroundColor DarkRed }
    }
} while ($choice -ne 4)

