# Windows 10 Optimizer

This is a simple Windows 10 optimizer that can help improve the performance of your system by disabling unnecessary services and features. It is designed to be easy to use and can be run with just a few clicks.

## Features

- Disable unnecessary services
- Disable unnecessary features
- Optimize system settings for better performance
- Optimize system settings for better battery efficiency
- Creates a restore point before making any changes to your system, so you can easily revert back if needed.
- Provides a -restore option that allows you to only restore the services.
- Provides a "WindowsOptimiser.log" that shows what you selected last time you ran the optimizer, so you can easily see what changes were made to your system.

## Usage

1. Download the optimizer from the [realeses section](https://github.com/GabrielBaranello/Windows-10-Optimizer/releases).
2. Run the optimizer in powershell.
3. It will request administrative privileges, click "Yes" to allow it to make changes to your system like disableing unnecessary services and features.
4. Follow the on-screen instructions to complete the optimization process.

## Flags
- -restore: This flag allows you to only restore the services that were disabled by the optimizer. It will not restore any other settings or features that were changed by the optimizer.
- -noXbox: This flag allows you to disable the Xbox Game Bar and related features, which can help improve performance on systems that do not use these features.
- -noPrint: This flag allows you to disable the Print Spooler service, which can help improve performance on systems that do not use printers.
- -noBluetooth: This flag allows you to disable Bluetooth services, which can help improve performance on systems that do not use Bluetooth devices.
- -noVM: This flag allows you to disable virtualisasion services, which can help improve performance on systems that do not use virtual machines.
- -noTelemetry: This flag allows you to disable telemety services, which can help improve performance on systems.
- -noEdge: This flag allows you to disable Microsoft Edge services, which can help improve performance on systems that do not use this navigator.
- -noMobile: This flag allows you to disable Phone Devices Conection services, which can help improve performance on systems that do not conect to a mobile phone.
- -noRemote: This flag allows you to disable Remote Acess services, which can help improve performance on systems that do not TeamViewer and other remote desktop software.
- -gaming: This flag allows you to pick performance over energy, in laptops this is not recommended because you will run out of baterry.
- -laptop: This flag allows you to pick energy eficience over performance
- -server: This flag skips the menu to apply the server custom mode
- -ultra:  This flag skips the menu to apply the maximun optimisations
- -auto: This flag let the program decide what profile apply
## The hole kit

This optimizer is designed to be used in conjuntion whith an other proyect that I have, caled "S.O.S.B.I. Wizard" and "S.O.S.B.I. Post install" that are abailable [here](https://github.com/GabrielBaranello/SOSBI-Family), which is a tool to backup your sistem and do all the complicated stuff to install an OS 
