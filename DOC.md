# Projet powershell :

### Fais avec des VM (bien faire attention au réseau utiliser sur VMWare si non pas de réseau)

## -	Faire des VM (une serveur et X clients dans le même domaine)
## -	Script : 

Import-Module ActiveDirectory
[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$chemin = "C:\Users\Administrator\Desktop\pc.csv"

Get-ADComputer -Filter * | Where-Object {$_.name -match "CEFF"} | Select -Property Name | Export-Csv $chemin

[System.Windows.Forms.MessageBox]::Show("Fichier pc.csv crée sur le Bureau", "Information" , 0, 64)

$liste = Import-Csv "C:\Users\Administrator\Desktop\pc.csv"
ForEach ($item in $liste) {Stop-Computer -ComputerName $item.name -Force -Credential "projet.local\"} 

# ----------------EXPLICATION DES COMMANDES----------------

Import-Module ActiveDirectory : La cmdlet Import-Module ajoute un ou plusieurs modules à la session en cours. 

#### [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$chemin = "C:\Users\Administrator\Desktop\pc.csv" : variable qui contient le chemin ou le fichier .CSV va être crée

Get-ADComputer -Filter * | Where-Object {$_.name -match "CEFF"} | Select -Property Name | Export-Csv $chemin : on va aller filtrer les noms de PC dans l’ActiveDirectory ou tout les PC qui on CEFF dans leur nom de PC, leur nom sera exporté dans le fichier .CSV qui se créera via la variable créée précédemment 

[System.Windows.Forms.MessageBox]::Show ("Fichier pc.csv crée sur le Bureau", "Information" , 0, 64) : un popup vient à l’écrans pour nous avertir que le fichier .CSV est bien créé sur le bureau

$liste = Import-Csv "C:\Users\Administrator\Desktop\pc.csv" : on créer une variable qui va importer le contenue du fichier .CSV

ForEach ($item in $liste) {Stop-Computer -ComputerName $item.name -Force -Credential "projet.local\"} : on créer une boucle ou tous les objets qui ont été importé depuis la liste donc les noms de PC doivent s’arrêter de force en mettant un mot de passe et un nom d’utilisateur qui a des droits administrateurs pour arrêter l’ordinateur à distance
