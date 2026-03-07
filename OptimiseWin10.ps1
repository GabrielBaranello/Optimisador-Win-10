# ================================
# OPTIMIZADOR WINDOWS
# ================================

param(

[switch]$gaming,
[switch]$laptop,
[switch]$server,
[switch]$ultra,
[switch]$auto,
[switch]$restore,

[switch]$noXbox,
[switch]$noPrint,
[switch]$noBluetooth,
[switch]$noVM,
[switch]$noTelemetry,
[switch]$noEdge,
[switch]$noMobile,
[switch]$noRemote
)

# ================================
# REABRIR COMO ADMIN
# ================================

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host "Reabriendo como administrador..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}
# ==========
# LISTAS
# ==========

# -------- SEGURAS --------

$Servicios_Xbox = @(
    "XblAuthManager",
    "XblGameSave",
    "XboxGipSvc",
    "XboxNetApiSvc"
)

$Servicios_Diagnostico = @(
    "DiagTrack",
    "DPS",
    "WdiSystemHost",
    "WdiServiceHost"
)

$Servicios_Edge = @(
    "MicrosoftEdgeElevationService",
    "edgeupdate",
    "edgeupdateem"
)

$Servicios_Mapas = @(
    "MapsBroker"
)

$Servicios_Telefonia = @(
    "PhoneSvc",
    "TapiSrv"
)

$Servicios_Sync = @(
    "OneSyncSvc*",
    "PimIndexMaintenanceSvc*",
    "MessagingService*",
    "UnistoreSvc*",
    "UserDataSvc*",
    "DevicesFlowUserSvc*"
)

$Servicios_Demo = @(
    "RetailDemo"
)

# -------- OPCIONALES --------

$Servicios_Print = @(
    "Spooler",
    "PrintNotify",
    "PrintWorkflowUserSvc*",
    "Fax"
)

$Servicios_Bluetooth = @(
    "bthserv",
    "BTAGService"
)

$Servicios_Sensores = @(
    "SensorDataService",
    "SensorService",
    "SensrSvc",
    "TabletInputService"
)

$Servicios_Display = @(
    "WFDConMgrSvc"
)

$Servicios_Red = @(
    "icssvc",
    "NcdService",
    "LanmanServer",
    "NetApiSvc"
)

$Servicios_Remote = @(
    "RemoteAccess",
    "WinRM",
    "SessionEnv",
    "UmRdpService",
    "RpcLocator"
)

$Servicios_SmartCard = @(
    "SCardSvc",
    "SCPolicySvc",
    "CertPropSvc",
    "WbioSrvc"
)

$Servicios_App = @(
    "AppXSvc",
    "wisvc",
    "FrameServer",
    "RmSvc"
)

$Servicios_Instalacion = @(
    "InstallService",
    "PushToInstall"
)

# -------- AGRESIVOS --------

$Servicios_Busqueda = @(
    "WSearch"
)

$Servicios_Prefetch = @(
    "SysMain"
)

$Servicios_UpdateDistrib = @(
    "DoSvc"
)

$Servicios_Media = @(
    "WMPNetworkSvc"
)

$Servicios_Tracking = @(
    "TrkWks"
)

$Servicios_VM = @(
    "vmicguestinterface",
    "vmicshutdown",
    "vmickvpexchange",
    "vmicheartbeat",
    "vmcompute",
    "vmictimesync",
    "vmicrdv",
    "vmicvss",
    "vmicvmsession",
    "HvHost"
)

#==================================
# APLICAR FLAGS
# =================================
function Aplicar-Flags {
    if ($noXbox) { Desactivar-Categoria "Xbox" $Servicios_Xbox }
    if ($noPrint) { Desactivar-Categoria "Impresion" $Servicios_Print }
    if ($noBluetooth) { Desactivar-Categoria "Bluetooth" $Servicios_Bluetooth }
    if ($noVM) { Desactivar-Categoria "Virtualizacion" $Servicios_VM }


    if ($noTelemetry) { Desactivar-Categoria "Diagnostico" $Servicios_Diagnostico }

    if ($noEdge) { Desactivar-Categoria "Edge" $Servicios_Edge }

    if ($noMobile) { Desactivar-Categoria "Movil" $Servicios_Movil }

    if ($noRemote) { Desactivar-Categoria "Remote" $Servicios_Remote }

}

# ================================
# BACKUP REGISTRO
# ================================

function Backup-Registro {

    log "Creando backup del registro..."

    $ruta = "$env:USERPROFILE\Desktop\backup_registro.reg"

    reg export HKLM $ruta /y
}

# ================================
# PUNTO DE RESTAURACION
# ================================

function Crear-RestorePoint {

    log "Creando punto de restauración..."

    Checkpoint-Computer -Description "Optimización Windows" -RestorePointType MODIFY_SETTINGS
}

# ================================
# SFC
# ================================

function Ejecutar-SFC {

    log "Ejecutando SFC..."

    sfc /scannow
}

# =================================
# MANEJO DE CATEGORIAS
# =================================
function Desactivar-Categoria {
    param(
        $Nombre,
        $Lista
    )

    Write-Host ""
    log "Desactivando categoria: $Nombre"
    Write-Host ""

    foreach ($servicio in $Lista) {

        $found = Get-Service -Name $servicio -ErrorAction SilentlyContinue

        foreach ($svc in $found) {

            log " - $($svc.Name)"

            Guardar-EstadoServicio $svc.Name

            Stop-Service $svc.Name -ErrorAction SilentlyContinue
            Set-Service $svc.Name -StartupType Disabled -ErrorAction SilentlyContinue
        }
    }
}
function Activar-Categoria {
    param(
        $Nombre,
        $Lista
    )

    Log "Activando categoria: $Nombre"

    foreach ($servicio in $Lista) {

        $found = Get-Service -Name $servicio -ErrorAction SilentlyContinue

        foreach ($svc in $found) {

            Guardar-EstadoServicio $svc.Name

            Log "Activando servicio $($svc.Name)"

            Set-Service $svc.Name -StartupType Automatic -ErrorAction SilentlyContinue
            Start-Service $svc.Name -ErrorAction SilentlyContinue
        }
    }
}
function Preguntar-Categoria($Pregunta, $Nombre, $Lista) {
    $resp = Read-Host "$Pregunta (s/n)"

    if ($resp -eq "n") {
        Desactivar-Categoria $Nombre $Lista
    }

    if ($resp -eq "s") {
        Activar-Categoria $Nombre $Lista
    }
}
# ================================
# OPTIMIZACIONES REGISTRO
# ================================

function Tweaks-Registro {
    
    log "Aplicando tweaks de registro..."
    
    Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
    -Name "SystemResponsiveness" `
    -Type DWord `
    -Value 1
    
    
    Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" `
    -Name "NetworkThrottlingIndex" `
    -Type DWord `
    -Value 0xffffffff
    
    
    Set-ItemProperty `
    -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
    -Name "AllowTelemetry" `
    -Type DWord `
    -Value 0
}
# ================================
# DESACTIVAR TAREAS
# ================================

function Desactivar-Tareas {
    
    log "Desactivando tareas..."
    
    $tasks = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Application Experience\StartupAppTask",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    )
    
    foreach ($t in $tasks)
    {
        schtasks /Change /TN $t /Disable
    }
    
}
# ==================
# Log
# ==================
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$logFile = "$DesktopPath\WindowsOptimizer.log"
$null > $logFile
function log {
    
    param($mensaje)
    
    $time = [datetime]::Now.ToString("yyyy-MM-dd HH:mm:ss")
    $line = "$time - $mensaje"
    
    Write-Host $mensaje
    [System.IO.File]::AppendAllText($LogFile, "$line`n")
    
}
# ==================
# RESPALO
# ==================
$BackupFile = "$DesktopPath\WindowsOptimizer_Backup.json"
$BackupServicios = @{}
function Guardar-EstadoServicio {
    param($nombre)
    $svc = Get-Service $nombre -ErrorAction SilentlyContinue
    if ($svc){
            $BackupServicios[$nombre] = $svc.StartType
    }
    else {
        write-host "servicio no encontrado"
    }
}
function Guardar-Backup {
    if ($BackupServicios.Count -gt 0){
        $BackupServicios | ConvertTo-Json | Set-Content $BackupFile
        Log "Backup guardado en $BackupFile"
    }
}
function Restaurar-Servicios {
    if (!(Test-Path $BackupFile)){
        Write-Host "No existe backup"
        return
    }
    $datos = Get-Content $BackupFile | ConvertFrom-Json
    foreach ($servicio in $datos.PSObject.Properties){
        Set-Service $servicio.Name -StartupType $servicio.Value -ErrorAction SilentlyContinue
        Write-Host "Restaurando $($servicio.Name)"
    }
    Write-Host ""
    Write-Host "Restauracion completada"
}
# ================================
# PERFIL GAMING
# ================================
function Perfil-Gaming {
    
    log "Aplicando perfil GAMING"
    
    Desactivar-Categoria "Xbox" $Servicios_Xbox
    Desactivar-Categoria "Diagnostico" $Servicios_Diagnostico
    Desactivar-Categoria "EdgeUpdate" $Servicios_Edge
    
}

# ================================
# PERFIL LAPTOP
# ================================
function Perfil-Laptop {
    log "Aplicando perfil LAPTOP"
    
    Desactivar-Categoria "Diagnostico" $Servicios_Diagnostico
    Desactivar-Categoria "Xbox" $Servicios_Xbox
}

# ================================
# PERFIL SERVER
# ================================
function Perfil-Server {

    log "Aplicando perfil SERVER"

    Desactivar-Categoria "Xbox" $Servicios_Xbox
    Desactivar-Categoria "Bluetooth" $Servicios_Bluetooth
    Desactivar-Categoria "Movil" $Servicios_Movil
    Desactivar-Categoria "Diagnostico" $Servicios_Diagnostico

}

# =======================
# PERFIL ULTRA
# =======================

function Perfil-Ultra {

    log "Aplicando perfil ULTRA"
    
    Desactivar-Categoria "Xbox" $Servicios_Xbox
    Desactivar-Categoria "Impresion" $Servicios_Print
    Desactivar-Categoria "Bluetooth" $Servicios_Bluetooth
    Desactivar-Categoria "Movil" $Servicios_Movil
    Desactivar-Categoria "Diagnostico" $Servicios_Diagnostico
    Desactivar-Categoria "Edge" $Servicios_Edge
    Desactivar-Categoria "Remote" $Servicios_Remote
    Desactivar-Categoria "Virtualizacion" $Servicios_VM

}

# ================================
# AUTO DETECT
# ================================
function Detectar-GPU {

    $gpu = Get-CimInstance Win32_VideoController

    foreach ($g in $gpu)
    {   

    if ($g.Name -match   "NVIDIA|AMD|Radeon|RTX|GTX")
    {   
    return "Gaming" 
    }   

    }   


    return "Integrada"  
}   
function Detectar-RAM { 
    $ram = (Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory
    $ramGB = [math]::Round($ram  / 1GB)

    return $ramGB   
} 
function Detectar-Bateria {     
    $bateria = Get-CimInstance Win32_Battery -ErrorAction SilentlyContinue
    if ($bateria){
        return $true
    }
    return $false
}   
function Detectar-Disco {       

    $discos = Get-PhysicalDisk
    foreach ($d in $discos){
        if ($d.MediaType -eq "SSD"){
            return "SSD"
        }
    }

    return "HDD"    
}

function Detectar-Hardware {
    Write-Host ""
    log "Detectando hardware..."
    Write-Host ""

    $gpu = Detectar-GPU
    $ram = Detectar-RAM
    $cpu = Get-CimInstance Win32_Processor
    $pc = Detectar-Bateria
    $disk = Detectar-Disco

    log "CPU: $($cpu.Name)"
    log "GPU tipo: $gpu"
    log "RAM: $ram GB"
    log "Es a bateria: $pc"
    log "Tipo de disco:  $disk"

    if ($ram -le 4)
    {
    log "Tipo: PC de bajos recursos"
    return "LowSpec"
    }

    if ($gpu.Name -match "NVIDIA|AMD|Radeon|RTX|GTX")
    {
    log "Tipo: Gaming"
    return "Gaming"
    }

    if ($pc)
    {
    log "Tipo: Laptop"
    return "Laptop"
    }

    return "Gaming"
}

function Perfil-Auto {

    $tipo = Detectar-Hardware

    switch ($tipo)
    {

    "Laptop" { Perfil-Laptop }

    "LowSpec" { Perfil-Ultra }

    "Gaming" { Perfil-Gaming }

    default { Perfil-Gaming }

    }

}

# ================================
# MENU
# ================================

function Mostrar-Menu {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════╗"
    Write-Host "║        WINDOWS OPTIMIZER             ║"
    Write-Host "╠══════════════════════════════════════╣"
    Write-Host "║ 1 ► Gaming                           ║"
    Write-Host "║ 2 ► Laptop                           ║"
    Write-Host "║ 3 ► Server                           ║"
    Write-Host "║ 4 ► Ultra                            ║"
    Write-Host "║ 5 ► Auto Detect Hardware             ║"
    Write-Host "║ 6 ► Personalizado                    ║"
    Write-Host "║                                      ║"
    Write-Host "║ 0 ► Salir                            ║"
    Write-Host "╚══════════════════════════════════════╝"
    Write-Host ""
    
    $op = Read-Host "Seleccione una opción"
    
    switch ($op){
        
        "1" { Perfil-Gaming }
        "2" { Perfil-Laptop }
        "3" { Perfil-Server }
        "4" { Perfil-Ultra }
        "5" { Perfil-Auto }
        "6" { Perfil-Personalizado }
        "0" { exit }
        
        default {
        Write-Host "Opcion invalida"
        Start-Sleep -Milliseconds 1500 # Pausa por medio segundo #esperar 1.5 segundos
        for($i = 0; $i -lt 16; $i++){
            Write-Host "$([char]27)[A$([char]27)[K" -NoNewline
        }
        Mostrar-Menu
        }
    }
}

# ================================
# PERSONALIZADO
# ================================
function Perfil-Personalizado {

    $resp = Read-Host "¿Configurar servicios manualmente? (s/n)"

    if ($resp -eq "s") {

        Preguntar-Categoria "¿Usas Xbox o GamePass?" "Xbox" $Servicios_Xbox

        Preguntar-Categoria "¿Usas impresora?" "Impresion" $Servicios_Print

        Preguntar-Categoria "¿Usas Bluetooth?" "Bluetooth" $Servicios_Bluetooth

        Preguntar-Categoria "¿Usas sensores o pantalla tactil?" "Sensores" $Servicios_Sensores

        Preguntar-Categoria "¿Usas sincronizacion de cuenta Microsoft?" "SyncUsuario" $Servicios_Sync

        Preguntar-Categoria "¿Usas telefono o apps moviles?" "Telefonia" $Servicios_Telefonia

        Preguntar-Categoria "¿Usas escritorio remoto?" "Remote" $Servicios_Remote

        Preguntar-Categoria "¿Usas Hyper-V o maquinas virtuales?" "Virtualizacion" $Servicios_VM

        Preguntar-Categoria "¿Usas Bluetooth o dispositivos inalambricos?" "Bluetooth" $Servicios_Bluetooth

        Preguntar-Categoria "¿Desactivar telemetria y diagnostico?" "Diagnostico" $Servicios_Diagnostico

    }

    $resp = Read-Host "¿Aplicar tweaks de rendimiento?" 

    if ($resp -eq "s") {
        Tweaks-Registro
    }

}

# ================================
# PARAMETROS
# ================================
if ($restore){
Restaurar-Servicios
exit
}
if ($gaming) { Perfil-Gaming }
if ($laptop) { Perfil-Laptop }
if ($server) { Perfil-Server }
if ($ultra) { Perfil-Ultra }
if ($auto) { Perfil-Auto }

Aplicar-Flags

if (!$gaming -and !$laptop -and !$server -and !$ultra -and !$auto)
{
Mostrar-Menu
}
Guardar-Backup
Read-Host "Optimización completada. Presione Enter para salir..."# ================================