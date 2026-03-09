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

if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent() `
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    $script = $MyInvocation.MyCommand.Path

    # reconstruir argumentos originales
    $argumentos = $MyInvocation.Line.Replace($MyInvocation.InvocationName, "").Trim()

    Start-Process powershell `
    -Verb RunAs `
    -ArgumentList "-ExecutionPolicy Bypass -File `"$script`" $argumentos"

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
# ==========
# NIVELES
# ==========

$Nivel_Seguro = @(
    @{ Nombre="Xbox"; Lista=$Servicios_Xbox }
    @{ Nombre="Diagnostico"; Lista=$Servicios_Diagnostico }
    @{ Nombre="Edge"; Lista=$Servicios_Edge }
    @{ Nombre="Mapas"; Lista=$Servicios_Mapas }
    @{ Nombre="Telefonia"; Lista=$Servicios_Telefonia }
    @{ Nombre="Sync"; Lista=$Servicios_Sync }
    @{ Nombre="Demo"; Lista=$Servicios_Demo }
)

$Nivel_Medio = @(
    @{ Nombre="Print"; Lista=$Servicios_Print }
    @{ Nombre="Bluetooth"; Lista=$Servicios_Bluetooth }
    @{ Nombre="Sensores"; Lista=$Servicios_Sensores }
    @{ Nombre="Display"; Lista=$Servicios_Display }
    @{ Nombre="RedCompartida"; Lista=$Servicios_Red }
    @{ Nombre="Remote"; Lista=$Servicios_Remote }
    @{ Nombre="SmartCard"; Lista=$Servicios_SmartCard }
    @{ Nombre="Apps"; Lista=$Servicios_App }
    @{ Nombre="Instalacion"; Lista=$Servicios_Instalacion }
)

$Nivel_Peligroso = @(
    @{ Nombre="Busqueda"; Lista=$Servicios_Busqueda }
    @{ Nombre="Prefetch"; Lista=$Servicios_Prefetch }
    @{ Nombre="UpdateDistrib"; Lista=$Servicios_UpdateDistrib }
    @{ Nombre="Media"; Lista=$Servicios_Media }
    @{ Nombre="Tracking"; Lista=$Servicios_Tracking }
    @{ Nombre="Virtualizacion"; Lista=$Servicios_VM }
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
$logFile = "$PSScriptRoot\WindowsOptimizer.log"
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
$BackupFile = "$PSScriptRoot\WindowsOptimizer_Backup.json"
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
        $r = Read-Host "Guardar backup de servicios? (s/n)"
        if ($r -ne "s"){
            return
        }
        $null > $logFile
        $BackupServicios | ConvertTo-Json | Set-Content $BackupFile
        Log "Backup guardado en $BackupFile"
        return
    }
    log "No se cambio ningun servicio, no se guarda backup"
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
# ==================
# PERFIL GAMING
# ==================
function Perfil-Gaming {

    log "Activando modo esports"

    if (-not (Advertencia-Latencia)) {

        return

    }

    Modo-FPS
    Modo-BajaLatencia
    Modo-TimerResolution

    Desactivar-PowerThrottling
    Optimizar-Scheduler
    Optimizar-NIC
    Optimizar-USB
    Optimizar-Timers
    Optimizar-PrioridadCPU

}

function Optimizar-PrioridadCPU {

    log "Optimizando prioridad CPU"

    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" `
        /v Win32PrioritySeparation `
        /t REG_DWORD `
        /d 26 `
        /f

}
function Optimizar-Timers {

    log "Desactivando dynamic tick"

    bcdedit /set disabledynamictick yes

}

function Optimizar-USB {

    log "Desactivando ahorro energia USB"

    powercfg -setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    powercfg -setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    powercfg -setactive SCHEME_CURRENT

}

function Optimizar-NIC {

    log "Optimizando tarjeta de red"

    $nics = Get-NetAdapter | Where-Object {$_.Status -eq "Up"}

    foreach ($nic in $nics) {

        try {

            Set-NetAdapterAdvancedProperty `
                -Name $nic.Name `
                -DisplayName "Interrupt Moderation" `
                -DisplayValue "Disabled" `
                -ErrorAction SilentlyContinue

        } catch {}

    }

}

function Optimizar-Scheduler {

    log "Optimizando scheduler multimedia"

    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f

    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f
}

function Desactivar-PowerThrottling {

    log "Desactivando power throttling"

    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" /v PowerThrottlingOff /t REG_DWORD /d 1 /f

}

function Modo-TimerResolution {

    log "Aplicando timer resolution optimizado"

    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v GlobalTimerResolutionRequests /t REG_DWORD /d 1 /f

}

function Modo-FPS {

    log "Aplicando modo FPS"

    # plan de energia alto rendimiento
    powercfg /setactive SCHEME_MIN

    # desactivar ahorro USB
    powercfg -setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    powercfg -setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
    powercfg -setactive SCHEME_CURRENT

    # evitar throttling CPU
    powercfg -setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 893dee8e-2bef-41e0-89c6-b55d0929964c 100
    powercfg -setacvalueindex SCHEME_CURRENT 54533251-82be-4824-96c1-47b60b740d00 bc5038f7-23e0-4960-96da-33abaf5935ec 100
    powercfg -setactive SCHEME_CURRENT

    # prioridad de procesos en primer plano
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 26 /f

}

function Modo-BajaLatencia {

    log "Aplicando modo baja latencia"

    # Prioridad de procesos en primer plano
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 26 /f

    # Desactivar Nagle (reduce delay en paquetes pequeños)
    $interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"

    foreach ($iface in $interfaces) {

        New-ItemProperty -Path $iface.PSPath -Name "TcpAckFrequency" -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $iface.PSPath -Name "TCPNoDelay" -Value 1 -PropertyType DWORD -Force | Out-Null
        New-ItemProperty -Path $iface.PSPath -Name "TcpDelAckTicks" -Value 0 -PropertyType DWORD -Force | Out-Null

    }

    # Reducir latencia del scheduler multimedia
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f

    # Mejor prioridad multimedia
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f

}
# =====================================
# ADVERTIR DEL MODO DE BAJA LATENCIA
# =====================================
function Advertencia-Latencia {

    Write-Host ""
    Write-Host "=========================================" -ForegroundColor Yellow
    Write-Host " ADVERTENCIA - MODO BAJA LATENCIA"
    Write-Host "=========================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Estos tweaks reducen latencia para gaming,"
    Write-Host "pero pueden afectar algunos sistemas:"
    Write-Host ""
    Write-Host " - audio con cortes o crackling"
    Write-Host " - video con stuttering"
    Write-Host " - problemas con software de streaming"
    Write-Host ""
    Write-Host "Si ocurre alguno de estos problemas,"
    Write-Host "puedes restaurar el backup del script con
    $(Split-Path -Leaf $PSCommandPath) -restore"
    Write-Host ""
    Detectar-Audio
    Detectar-GPU
    Detectar-Streaming
    Write-Host ""

    $resp = Read-Host "¿Continuar de todas formas? (s/n)"

    if ($resp -ne "s") {

        log "Modo baja latencia cancelado por usuario"
        return $false

    }

    return $true
}
function Detectar-Audio {

    $audio = Get-CimInstance Win32_SoundDevice

    if ($audio) {

        log "Dispositivo de audio detectado"

        foreach ($a in $audio) {

            log "Audio: $($a.Name)"

        }

        return $true

    }

    return $false
}
function Detectar-GPU {

    $gpu = Get-CimInstance Win32_VideoController

    foreach ($g in $gpu) {

        log "GPU detectada: $($g.Name)"

    }

}
function Detectar-Streaming {
    $procesos = Get-Process -ErrorAction SilentlyContinue

    $streaming = $procesos | Where-Object {

        $_.Name -match "obs|stream|shadowplay|xsplit|discord"

    }

    if ($streaming) {

        log "Software de streaming detectado"

        foreach ($p in $streaming) {

            log "Proceso: $($p.Name)"

        }

        return $true

    }

    return $false
}
# ================================
# MENU
# ================================
function Aplicar-Nivel {
    param(
        $Nivel,
        $nivelNumero
    )

    if ($nivelNumero -eq "1") { $nivelNombre = "SEGURO" }
    if ($nivelNumero -eq "2") { $nivelNombre = "MEDIO" }
    if ($nivelNumero -eq "3") { $nivelNombre = "PELIGROSO" }
    
    Write-Host "============================" -ForegroundColor Cyan
    log        "Aplicando nivel: $nivelNombre"
    Write-Host "============================" -ForegroundColor Cyan

    foreach ($categoria in $Nivel) {

        $nombre = $categoria.Nombre
        $lista = $categoria.Lista

        Desactivar-Categoria $nombre $lista
    }
}
function Mostrar-Menu {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════╗"
    Write-Host "║        WINDOWS OPTIMIZER             ║"
    Write-Host "╠══════════════════════════════════════╣"
    Write-Host "║ 1 ► Gaming (Alto rendimiento)        ║"
    Write-Host "║ 2 ► Laptop (Bajo consumo)            ║"
    Write-Host "║ 3 ► Server                           ║"
    Write-Host "║ 4 ► Personalizado                    ║"
    Write-Host "║ 5 ► Auto Detect Hardware             ║"
    Write-Host "║ 6 ► Ultra                            ║"
    Write-Host "║ 7 ► Medio                            ║"
    Write-Host "║ 8 ► Bajo                             ║"
    Write-Host "║                                      ║"
    Write-Host "║ 0 ► Salir                            ║"
    Write-Host "╚══════════════════════════════════════╝"
    Write-Host ""
    
    $op = Read-Host "Seleccione una opción"
    
    switch ($op){
        
        "1" { Perfil-Gaming }
        "2" { Perfil-Laptop }
        "3" { Perfil-Server }
        "4" { Perfil-Personalizado }
        "5" { Perfil-Auto }
        "6" {
            Aplicar-nivel $Nivel_Seguro "1"
            Aplicar-nivel $Nivel_Medio "2"
            Aplicar-Nivel $Nivel_Peligroso "3"
        }
        "7" {
            Aplicar-nivel $Nivel_Seguro "1"
            Aplicar-nivel $Nivel_Medio "2"
        }
        "8" {
            Aplicar-nivel $Nivel_Seguro "1"
        }
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

        Preguntar-Categoria "¿Usas sensores o pantalla tactil?" "Sensores" $Servicios_Sensores

        Preguntar-Categoria "¿Usas sincronizacion de cuenta Microsoft?" "SyncUsuario" $Servicios_Sync

        Preguntar-Categoria "¿Usas telefono o apps moviles?" "Telefonia" $Servicios_Telefonia

        Preguntar-Categoria "¿Usas escritorio remoto?" "Remote" $Servicios_Remote

        Preguntar-Categoria "¿Usas Hyper-V o maquinas virtuales?" "Virtualizacion" $Servicios_VM

        Preguntar-Categoria "¿Usas Bluetooth o dispositivos inalambricos?" "Bluetooth" $Servicios_Bluetooth

        Preguntar-Categoria "¿Deseas tener la telemetria y diagnostico?" "Diagnostico" $Servicios_Diagnostico

    }

    $resp = Read-Host "¿Aplicar tweaks de rendimiento?" 

    if ($resp -eq "s") {
        Tweaks-Registro
    }
    $resp = Read-Host "¿Priorizar FPS o energia? (fps/eco)"

    if ($resp -eq "fps") {

        Perfil-Gaming

    }

    if ($resp -eq "eco") {

        Modo-Energia

    }
}

# ================================
# PARAMETROS
# ================================
if ($restore){
Restaurar-Servicios
Read-Host "Restauración completada. Presione Enter para salir..."
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