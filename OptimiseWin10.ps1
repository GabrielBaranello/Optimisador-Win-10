# ================================
# OPTIMIZADOR WINDOWS
# ================================

param(

[switch]$gaming,
[switch]$laptop,
[switch]$server,
[switch]$ultra,
[switch]$auto,

[switch]$noXbox,
[switch]$noPrint,
[switch]$noBluetooth,
[switch]$noVM,
[switch]$noTelemetry,
[switch]$noEdge,
[switch]$noMobile,
[switch]$noRemote

)

# =================================
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
# REABRIR COMO ADMIN
# ================================

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host "Reabriendo como administrador..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# ================================
# BACKUP REGISTRO
# ================================

function Backup-Registro {

    Write-Host "Creando backup del registro..."

    $ruta = "$env:USERPROFILE\Desktop\backup_registro.reg"

    reg export HKLM $ruta /y
}

# ================================
# PUNTO DE RESTAURACION
# ================================

function Crear-RestorePoint {

    Write-Host "Creando punto de restauración..."

    Checkpoint-Computer -Description "Optimización Windows" -RestorePointType MODIFY_SETTINGS
}

# ================================
# SFC
# ================================

function Ejecutar-SFC {

    Write-Host "Ejecutando SFC..."

    sfc /scannow
}

# =================================
# DESACTIVAR CATEGORIA
# =================================
function Desactivar-Categoria {

param(
$Nombre,
$Lista
)

Write-Host ""
Write-Host "Desactivando categoria: $Nombre"
Write-Host ""

foreach ($servicio in $Lista)
{
Write-Host " - $servicio"

Stop-Service $servicio -ErrorAction SilentlyContinue
Set-Service $servicio -StartupType Disabled -ErrorAction SilentlyContinue
}

}
# ================================
# OPTIMIZACIONES REGISTRO
# ================================

function Tweaks-Registro {

Write-Host "Aplicando tweaks de registro..."

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

Write-Host "Desactivando tareas..."

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

# ================================
# PERFIL GAMING
# ================================
function Perfil-Gaming {

Write-Host "Aplicando perfil GAMING"

Desactivar-Categoria "Xbox" $Servicios_Xbox
Desactivar-Categoria "Diagnostico" $Servicios_Diagnostico
Desactivar-Categoria "EdgeUpdate" $Servicios_Edge

}

# ================================
# PERFIL LAPTOP
# ================================
function Perfil-Laptop {

Write-Host "Aplicando perfil LAPTOP"

Desactivar-Categoria "Diagnostico" $Servicios_Diagnostico
Desactivar-Categoria "Xbox" $Servicios_Xbox

}

# ================================
# PERFIL SERVER
# ================================
function Perfil-Server {

Write-Host "Aplicando perfil SERVER"

Desactivar-Categoria "Xbox" $Servicios_Xbox
Desactivar-Categoria "Bluetooth" $Servicios_Bluetooth
Desactivar-Categoria "Movil" $Servicios_Movil
Desactivar-Categoria "Diagnostico" $Servicios_Diagnostico

}

# =======================
# PERFIL ULTRA
# =======================

function Perfil-Ultra {

Write-Host "Aplicando perfil ULTRA"

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
function Detectar-Hardware {

Write-Host ""
Write-Host "Detectando hardware..."
Write-Host ""

$cpu = Get-CimInstance Win32_Processor
$gpu = Get-CimInstance Win32_VideoController
$ram = Get-CimInstance Win32_ComputerSystem
$pc = Get-CimInstance Win32_ComputerSystem

$ramGB = [math]::Round($ram.TotalPhysicalMemory / 1GB)

Write-Host "CPU: $($cpu.Name)"
Write-Host "GPU: $($gpu.Name)"
Write-Host "RAM: $ramGB GB"

if ($pc.PCSystemType -eq 2)
{
Write-Host "Tipo: Laptop"
return "Laptop"
}

if ($ramGB -le 4)
{
Write-Host "Tipo: PC de bajos recursos"
return "LowSpec"
}

if ($gpu.Name -match "NVIDIA|AMD|Radeon|RTX|GTX")
{
Write-Host "Tipo: Gaming"
return "Gaming"
}

return "Desktop"

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
# PERFIL ALL
# ================================

function Perfil-All {

Crear-RestorePoint
Backup-Registro
Ejecutar-SFC
Perfil-Gaming

}

# ================================
# MENU
# ================================
function Mostrar-Menu {

Clear-Host

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

switch ($op)
{

"1" { Perfil-Gaming }
"2" { Perfil-Laptop }
"3" { Perfil-Server }
"4" { Perfil-Ultra }
"5" { Perfil-Auto }
"6" { Perfil-Personalizado }
"0" { exit }

default {
Write-Host "Opcion invalida"
Start-Sleep 2
Mostrar-Menu
}

}

}

# ================================
# PERSONALIZADO
# ================================

function Perfil-Personalizado {

$resp = Read-Host "¿Desactivar servicios innecesarios? (s/n)"

if ($resp -eq "s")
{
    
$resp = Read-Host "¿Usas Xbox o GamePass? (s/n)"
if ($resp -eq "n") { Desactivar-Categoria "Xbox" $Servicios_Xbox }

$resp = Read-Host "¿Usas impresora? (s/n)"
if ($resp -eq "n") { Desactivar-Categoria "Impresion" $Servicios_Print }

$resp = Read-Host "¿Usas Bluetooth? (s/n)"
if ($resp -eq "n") { Desactivar-Categoria "Bluetooth" $Servicios_Bluetooth }

$resp = Read-Host "¿Usas maquinas virtuales o Hyper-V? (s/n)"
if ($resp -eq "n") { Desactivar-Categoria "Virtualizacion" $Servicios_VM }

$resp = Read-Host "¿Usas sincronizacion con telefono? (s/n)"
if ($resp -eq "n") { Desactivar-Categoria "Movil" $Servicios_Movil }

$resp = Read-Host "¿Usas escritorio remoto? (s/n)"
if ($resp -eq "n") { Desactivar-Categoria "Remote" $Servicios_Remote }

$resp = Read-Host "¿Desactivar telemetria y diagnostico? (s/n)"
if ($resp -eq "s") { Desactivar-Categoria "Diagnostico" $Servicios_Diagnostico }
}

$resp = Read-Host "¿Aplicar tweaks de gaming? (s/n)"

if ($resp -eq "s")
{
    Tweaks-Registro
}

}

# ================================
# PARAMETROS
# ================================
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
Read-Host "Optimización completada. Presione Enter para salir..."# ================================
# OPTIMIZADOR WINDOWS
# ================================

param(

[switch]$gaming,
[switch]$laptop,
[switch]$server,
[switch]$ultra,
[switch]$auto,

[switch]$noXbox,
[switch]$noPrint,
[switch]$noBluetooth,
[switch]$noVM,
[switch]$noTelemetry,
[switch]$noEdge,
[switch]$noMobile,
[switch]$noRemote

)

# =================================
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
# REABRIR COMO ADMIN
# ================================

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Host "Reabriendo como administrador..."
    Start-Process powershell "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# ================================
# BACKUP REGISTRO
# ================================

function Backup-Registro {

    Write-Host "Creando backup del registro..."

    $ruta = "$env:USERPROFILE\Desktop\backup_registro.reg"

    reg export HKLM $ruta /y
}

# ================================
# PUNTO DE RESTAURACION
# ================================

function Crear-RestorePoint {

    Write-Host "Creando punto de restauración..."

    Checkpoint-Computer -Description "Optimización Windows" -RestorePointType MODIFY_SETTINGS
}

# ================================
# SFC
# ================================

function Ejecutar-SFC {

    Write-Host "Ejecutando SFC..."

    sfc /scannow
}

# =================================
# DESACTIVAR CATEGORIA
# =================================
function Desactivar-Categoria {

param(
$Nombre,
$Lista
)

Write-Host ""
Write-Host "Desactivando categoria: $Nombre"
Write-Host ""

foreach ($servicio in $Lista)
{
Write-Host " - $servicio"

Stop-Service $servicio -ErrorAction SilentlyContinue
Set-Service $servicio -StartupType Disabled -ErrorAction SilentlyContinue
}

}
# ================================
# OPTIMIZACIONES REGISTRO
# ================================

function Tweaks-Registro {

Write-Host "Aplicando tweaks de registro..."

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

Write-Host "Desactivando tareas..."

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

# ================================
# PERFIL GAMING
# ================================
function Perfil-Gaming {

Write-Host "Aplicando perfil GAMING"

Desactivar-Categoria "Xbox" $Servicios_Xbox
Desactivar-Categoria "Diagnostico" $Servicios_Diagnostico
Desactivar-Categoria "EdgeUpdate" $Servicios_Edge

}

# ================================
# PERFIL LAPTOP
# ================================
function Perfil-Laptop {

Write-Host "Aplicando perfil LAPTOP"

Desactivar-Categoria "Diagnostico" $Servicios_Diagnostico
Desactivar-Categoria "Xbox" $Servicios_Xbox

}

# ================================
# PERFIL SERVER
# ================================
function Perfil-Server {

Write-Host "Aplicando perfil SERVER"

Desactivar-Categoria "Xbox" $Servicios_Xbox
Desactivar-Categoria "Bluetooth" $Servicios_Bluetooth
Desactivar-Categoria "Movil" $Servicios_Movil
Desactivar-Categoria "Diagnostico" $Servicios_Diagnostico

}

# =======================
# PERFIL ULTRA
# =======================

function Perfil-Ultra {

Write-Host "Aplicando perfil ULTRA"

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
function Detectar-Hardware {

Write-Host ""
Write-Host "Detectando hardware..."
Write-Host ""

$cpu = Get-CimInstance Win32_Processor
$gpu = Get-CimInstance Win32_VideoController
$ram = Get-CimInstance Win32_ComputerSystem
$pc = Get-CimInstance Win32_ComputerSystem

$ramGB = [math]::Round($ram.TotalPhysicalMemory / 1GB)

Write-Host "CPU: $($cpu.Name)"
Write-Host "GPU: $($gpu.Name)"
Write-Host "RAM: $ramGB GB"

if ($pc.PCSystemType -eq 2)
{
Write-Host "Tipo: Laptop"
return "Laptop"
}

if ($ramGB -le 4)
{
Write-Host "Tipo: PC de bajos recursos"
return "LowSpec"
}

if ($gpu.Name -match "NVIDIA|AMD|Radeon|RTX|GTX")
{
Write-Host "Tipo: Gaming"
return "Gaming"
}

return "Desktop"

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
# PERFIL ALL
# ================================

function Perfil-All {

Crear-RestorePoint
Backup-Registro
Ejecutar-SFC
Perfil-Gaming

}

# ================================
# MENU
# ================================
function Mostrar-Menu {

Clear-Host

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

switch ($op)
{

"1" { Perfil-Gaming }
"2" { Perfil-Laptop }
"3" { Perfil-Server }
"4" { Perfil-Ultra }
"5" { Perfil-Auto }
"6" { Perfil-Personalizado }
"0" { exit }

default {
Write-Host "Opcion invalida"
Start-Sleep 2
Mostrar-Menu
}

}

}

# ================================
# PERSONALIZADO
# ================================

function Perfil-Personalizado {

$resp = Read-Host "¿Desactivar servicios innecesarios? (s/n)"

if ($resp -eq "s")
{
    
$resp = Read-Host "¿Usas Xbox o GamePass? (s/n)"
if ($resp -eq "n") { Desactivar-Categoria "Xbox" $Servicios_Xbox }

$resp = Read-Host "¿Usas impresora? (s/n)"
if ($resp -eq "n") { Desactivar-Categoria "Impresion" $Servicios_Print }

$resp = Read-Host "¿Usas Bluetooth? (s/n)"
if ($resp -eq "n") { Desactivar-Categoria "Bluetooth" $Servicios_Bluetooth }

$resp = Read-Host "¿Usas maquinas virtuales o Hyper-V? (s/n)"
if ($resp -eq "n") { Desactivar-Categoria "Virtualizacion" $Servicios_VM }

$resp = Read-Host "¿Usas sincronizacion con telefono? (s/n)"
if ($resp -eq "n") { Desactivar-Categoria "Movil" $Servicios_Movil }

$resp = Read-Host "¿Usas escritorio remoto? (s/n)"
if ($resp -eq "n") { Desactivar-Categoria "Remote" $Servicios_Remote }

$resp = Read-Host "¿Desactivar telemetria y diagnostico? (s/n)"
if ($resp -eq "s") { Desactivar-Categoria "Diagnostico" $Servicios_Diagnostico }
}

$resp = Read-Host "¿Aplicar tweaks de gaming? (s/n)"

if ($resp -eq "s")
{
    Tweaks-Registro
}

}

# ================================
# PARAMETROS
# ================================
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
Read-Host "Optimización completada. Presione Enter para salir..."