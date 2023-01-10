function DisplayMenu {
    Clear-Host
    Write-host @"
    +==============================+
    |  PROJET POWERSHELL MENU      |
    +==============================+
    |                              |
    |        1) Eteindre PC        |
    |        2) Redémarrer PC      |
    |        3) Wake on LAN        |
    |        4) Exit               |
    |                              |
    +==============================+
    
"@
    
    $MENU = Read-Host "OPTION"
    Switch ($MENU)
    {
    
    1{
    #éteindre les PC à distance avec le nom AD
    #-------------------------------------------------------------------------------------------------------------------------
    Import-Module ActiveDirectory
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    
    $chemin = "C:\Users\Administrator\Desktop\pc.csv"
    
    Get-ADComputer -Filter * | Where-Object {$_.name -match "CEFF"} | Select -Property Name | Export-Csv $chemin
    
    [System.Windows.Forms.MessageBox]::Show("Fichier pc.csv crée sur le Bureau", "Information" , 0, 64)
    
    $liste = Import-Csv "C:\Users\Administrator\Desktop\pc.csv"
    
    $credential = Get-Credential -Credential "projet.local\administrator"
    
    ForEach ($item in $liste) {Stop-Computer -ComputerName $item.name -Force $credential }
    
    DisplayMenu
    }
    
    2{
    Import-Module ActiveDirectory
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    
    $chemin = "C:\Users\Administrator\Desktop\pc.csv"
    
    Get-ADComputer -Filter * | Where-Object {$_.name -match "CEFF"} | Select -Property Name | Export-Csv $chemin
    
    [System.Windows.Forms.MessageBox]::Show("Fichier pc.csv crée sur le Bureau", "Information" , 0, 64)
    
    $liste = Import-Csv "C:\Users\Administrator\Desktop\pc.csv"
    
    $credential = Get-Credential -Credential "projet.local\administrator"
    
    ForEach ($item in $liste) {Restart-Computer -ComputerName $item.name -Force $credential }
    }
    
    3{
    Write-Host "choisire une OU à arreter"
    Write-Host "1) class1"
    Write-Host "2) class2"
    
    $choix = Read-Host "choisir une OU : "
    
    Switch($choix)
    {
    1{
    $Computers = Get-ADComputer -SearchBase "OU=class1,DC=projet,DC=local" -Filter * #doit etre loguer pour éteindre le pc
    Invoke-Command -ComputerName $computers.Name -ScriptBlock {shutdown /s /t 0}
    }
    
    2{
    $Computers = Get-ADComputer -SearchBase "OU=class2,DC=projet,DC=local" -Filter *
    Invoke-Command -ComputerName $computers.Name -ScriptBlock {shutdown /s /t 0}
    }
    }
    }
    4{
    Write-Host "Bye"
    break
    }
    
    default{
    Write-Host "Option non valide"
    Start-Sleep -Seconds 2
    displayMenu
    }
    }
    }
    DisplayMenu