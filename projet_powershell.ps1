# Ce script est un menu de projet PowerShell qui permet aux utilisateurs de sélectionner une option pour éteindre ou redémarrer des ordinateurs à distance à l'aide de l'Active Directory.

# La fonction DisplayMenu affiche un menu à l'utilisateur avec quatre options:
# 1) Eteindre PC - Eteint les ordinateurs à distance en utilisant le nom AD
# 2) Redémarrer PC - Sélectionne une OU de l'Active Directory et redémarre les ordinateurs de cette OU
# 3) Eteindre class - Sélectionne une classe de l'Active Directory et éteint les ordinateurs de cette classe
# 4) Exit - Quitte le script

function DisplayMenu {
    Clear-Host
    Write-host @"
    +==============================+
    |    PROJET POWERSHELL MENU    |
    +==============================+
    |                              |
    |        1) Eteindre PC        |
    |        2) Redémarrer PC      |
    |        3) Eteindre class     |
    |        4) Exit               |
    |                              |
    +==============================+
    
"@
    
    $MENU = Read-Host "OPTION"
    Switch ($MENU) {
    
        1 {
            # Eteindre les PC à distance avec le nom AD
            
            Import-Module ActiveDirectory
            [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    
            $chemin = "C:\Users\Administrator\Desktop\pc.csv"
    
            Get-ADComputer -Filter * | Where-Object { $_.name -match "CEFF" } | Select-Object Name | Export-Csv $chemin
    
            [System.Windows.Forms.MessageBox]::Show("Fichier pc.csv crée sur le Bureau", "Information" , 0, 64)
    
            $liste = Import-Csv "C:\Users\Administrator\Desktop\pc.csv"
    
            $credential = Get-Credential -Credential "projet.local\administrator"
    
            ForEach ($item in $liste) { Stop-Computer -ComputerName $item.Name -Force $credential }
        }
    
        2 {
            # Sélectionnez une OU à partir de l'Active Directory
            $OU = Get-ADOrganizationalUnit -Filter * | Out-GridView -Title 'Sélectionnez une OU' -PassThru
    
            # Récupérez tous les ordinateurs de l'OU sélectionnée
            $Computers = Get-ADComputer -SearchBase $OU.DistinguishedName -Filter * | Select-Object -ExpandProperty Name
    
            # Affichez la liste des ordinateurs de l'OU sélectionnée
            $ComputerToReboot = $Computers | Out-GridView -Title 'Sélectionnez l''ordinateur à redémarrer' -PassThru
	        # Redémarrez l'ordinateur sélectionné à distance
            Restart-Computer -ComputerName $ComputerToReboot -Force
        }
    
        3 {
            # Eteindre class
            Write-Host "Choisir une classe : "
            Write-Host "1) Class1"
            Write-Host "2) Class2"
    
            $choix = Read-Host "Entrez le numéro de la classe : "
    
            Switch($choix) {
                1 {
                    $Computers = Get-ADComputer -SearchBase "OU=class1,DC=projet,DC=local" -Filter * 
                    Invoke-Command -ComputerName $Computers.Name -ScriptBlock {shutdown /s /t 0}
                }
                2 {
                    $Computers = Get-ADComputer -SearchBase "OU=class2,DC=projet,DC=local" -Filter * 
                    Invoke-Command -ComputerName $Computers.Name -ScriptBlock {shutdown /s /t 0}
                }
                default {
                    Write-Host "Option non valide"
                }
            }
        }
    
        4 {
            # Exit
            Exit
        }
    
        default {
            Write-Host "Option non valide"
        }
    }
}

# Appel de la fonction DisplayMenu pour afficher le menu
DisplayMenu