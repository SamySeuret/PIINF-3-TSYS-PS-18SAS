# Ce script est un menu de projet PowerShell qui permet aux utilisateurs de sélectionner une option pour éteindre ou redémarrer des ordinateurs à distance à l'aide de l'Active Directory.

# La fonction DisplayMenu affiche un menu à l'utilisateur avec quatre options:
# 1) Eteindre PC - Eteint les ordinateurs à distance en utilisant le nom AD
# 2) Redémarrer PC - Sélectionne une OU de l'Active Directory et redémarre les ordinateurs de cette OU
# 3) Eteindre class - Sélectionne une classe de l'Active Directory et éteint les ordinateurs de cette classe
# 4) Wake on LAN - Allume les ordinateurs qui sont dans le même réseau
# 5) Exit - Quitte le script

# Eteindre les PC à distance avec le nom AD
# Création de la fonction ShutDown PC
function shutdown_pc {
  Import-Module ActiveDirectory
  [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  $chemin = "C:\Users\$env:username\Desktop\pc.csv"
  $pcToShutDown = Read-Host "Entrer le debut du nom des PC a eteindre "
  Get-ADComputer -Filter * | Where-Object { $_.name -match $pcToShutDown } | Select-Object Name | Export-Csv $chemin
  [System.Windows.Forms.MessageBox]::Show("Fichier pc.csv cree sur le Bureau", "Information" , 0, 64)
  $liste = Import-Csv "C:\Users\$env:username\Desktop\pc.csv"
  $credential = Get-Credential -Credential "projet.local\administrator" #Mettre le nom de notre domaine
  ForEach ($item in $liste) { 
      Stop-Computer -ComputerName $item.Name -Force $credential 
  }
}

# Création de la fonction Restart PC
 function restart_pc {
  # Sélectionnez une OU à partir de l'Active Directory
  $OU = Get-ADOrganizationalUnit -Filter * | Out-GridView -Title 'Sélectionnez une OU' -PassThru
  # Récupérez tous les ordinateurs de l'OU sélectionnée
  $Computers = Get-ADComputer -SearchBase $OU.DistinguishedName -Filter * | Select-Object -ExpandProperty Name
  # Affichez la liste des ordinateurs de l'OU sélectionnée
  $ComputerToReboot = $Computers | Out-GridView -Title 'Sélectionnez l''ordinateur à redémarrer' -PassThru
  # Redémarrez l'ordinateur sélectionné à distance
  Restart-Computer -ComputerName $ComputerToReboot -Force
}


# Création de la fonction Shuwdown de la classe
function shutdown_classroom {
  # Eteindre class 
  Write-Host "Choisir une classe : "
  Write-Host "1) Class1"
  Write-Host "2) Class2"
  $choix = Read-Host "Entrez le numéro de la classe : "
  Switch ($choix) {
      1 {
          $Computers = Get-ADComputer -SearchBase "OU=class1,DC=projet,DC=local" -Filter * 
          Invoke-Command -ComputerName $Computers.Name -ScriptBlock { shutdown /s /t 0 }
      }
      2 {
          $Computers = Get-ADComputer -SearchBase "OU=class2,DC=projet,DC=local" -Filter * 
          Invoke-Command -ComputerName $Computers.Name -ScriptBlock { shutdown /s /t 0 }
      }
      default {
          Write-Host "Option non valide"
      }
  }
}

# Création de la fonction Carte réseau
function Carte_reseau {
  #wake on lan pour un pc dans le meme réseau ne marche pas avec le VM
  Get-CimInstance -Query 'Select * From Win32_NetworkAdapter Where NetConnectionStatus=2' | Select-Object -Property Name, Manufacturer, MacAddress
}

# Création de la fonction du WakeOnLan
function Invoke-WakeOnLan {
  param (
      # one or more MACAddresses
      [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
      # mac address must be a following this regex pattern:
      [ValidatePattern('^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$')]
      [string[]]
      $MacAddress 
  )
  begin {
      # instantiate a UDP client:
      $UDPclient = [System.Net.Sockets.UdpClient]::new()
  }
  process {
      foreach ($_ in $MacAddress) {
          try {
              $currentMacAddress = $_
      
              # get byte array from mac address:
              $mac = $currentMacAddress -split '[:-]' |
              # convert the hex number into byte:
              ForEach-Object {
                  [System.Convert]::ToByte($_, 16)
              }

              #region compose the "magic packet"
      
              # create a byte array with 102 bytes initialized to 255 each:
              $packet = [byte[]](, 0xFF * 102)
      
              # leave the first 6 bytes untouched, and
              # repeat the target mac address bytes in bytes 7 through 102:
              6..101 | Foreach-Object { 
                  # $_ is indexing in the byte array,
                  # $_ % 6 produces repeating indices between 0 and 5
                  # (modulo operator)
                  $packet[$_] = $mac[($_ % 6)]
              }
              #endregion

              # connect to port 400 on broadcast address:
              $UDPclient.Connect(([System.Net.IPAddress]::Broadcast), 4000)
      
              # send the magic packet to the broadcast address:
              $null = $UDPclient.Send($packet, $packet.Length)
              Write-Verbose "sent magic packet to $currentMacAddress..."
          }
          catch {
              Write-Warning "Unable to send ${mac}: $_"
          }
      }
  }
  end {
      # release the UDF client and free its memory:
      $UDPclient.Close()
      $UDPclient.Dispose()
  }
}
#menu
$continue = $true 
while ($continue) {
  Write-Host "--------------- Projet POWERSHELL MENU ---------------"
  Write-Host "1. Eteindre PC" 
  Write-Host "2. Redemarrer PC" 
  Write-Host "3. Eteindre classe" 
  Write-Host "4. Wake on Lan" 
  Write-Host "5. Exit" 
  Write-Host "-------------------------------------------------------"
  $MENU = Read-Host "OPTION "
  switch ($MENU) {
      1 { shutdown_pc }
      2 { restart_pc }
      3 { shutdown_classroom }
      4 {
          $MacAddressShutDown = Read-Host -Prompt "Entrer l'adresse mac"
          carte_reseau
          Invoke-WakeOnLan -MacAddress "$MacAddressShutDown"
          #Invoke-WakeOnLan -MacAddress '40:8D:5C:71:11:D8'
      }
      5 { $continue = $false }
      Default { Write-Host "Option non valide" -ForegroundColor Red -BackgroundColor Black }
  }
}