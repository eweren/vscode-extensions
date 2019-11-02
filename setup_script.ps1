# Set some envs.
Write-Host "Setup envs and paths."
$WebClient = New-Object System.Net.WebClient
$desktop = $env:USERPROFILE + '\Desktop'
$regFile = $desktop + '\reged.reg'
$choco = $desktop + '\choco.config'
$codeExt = $desktop + '\extension.vsix'

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator


if(Test-Path $choco) 
{
Write-Host "Removing files."
Remove-Item $choco
Remove-Item $regFile
Remove-Item $codeExt

#### Install VSCode extension pack #### 
Write-Host  "Install VSCode extension pack."
$codeCmd = "--verbose --install-extension " + $codeExt
"code " + $codeCmd | cmd

Write-Host  "Congrats. Everything's set up!"
Read-Host -Prompt "Press Enter to exit"

} 
else 
{

    # Check to see if we are currently running "as Administrator"
    if ($myWindowsPrincipal.IsInRole($adminRole))
       {
        #### Download all nessecary files ####
        Write-Host "Download files to Desktop."
        $WebClient.DownloadFile("https://www.tenforums.com/attachments/tutorials/102357d1474400469-run-administrator-add-ps1-file-context-menu-windows-10-a-add_ps1_run_as_administrator.reg", $regFile)
        $WebClient.DownloadFile("https://raw.githubusercontent.com/eweren/vscode-extensions/master/app_setup.config", $choco)
        $WebClient.DownloadFile("https://raw.githubusercontent.com/eweren/vscode-extensions/master/ewerens-extensions-0.0.1.vsix", $codeExt)


        #### Add 'Run as admin' to powershell files ####
        Write-Host "Add 'Run as admin' to powershell files."
        reg import $regFile


        #### Install chocolatey ####
        Write-Host "Install chocolatey."
        #Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))


        #### Install programs ####
        Write-Host "Install applications."
        choco install $choco -y

        
        #### Restart as admin to gain access to code as cmdlet ####
        $arguments = "Start-Process powershell.exe -Verb runAs -File " + $desktop + "\setup_script.ps1"
        Start-Process Powershell -NoNewWindow -ArgumentList $arguments
       }

       else 
       {
        #### Restart as admin ####
        $arguments = "Start-Process powershell.exe -Verb runAs -File " + $desktop + "\setup_script.ps1"
        Start-Process Powershell -NoNewWindow -ArgumentList $arguments
       }
}
 
