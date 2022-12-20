Import-Module ActiveDirectory
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$chemin = "C:\Users\Administrator\Desktop\pc.csv"

Get-ADComputer -Filter * | Where-Object {$_.name -match "CEFF"} | Select -Property Name | Export-Csv $chemin

[System.Windows.Forms.MessageBox]::Show("Fichier pc.csv crée sur le Bureau", "Information" , 0, 64)

$liste = Import-Csv "C:\Users\Administrator\Desktop\pc.csv"
ForEach ($item in $liste) {Stop-Computer -ComputerName $item.name -Force -Credential "projet.local\"}