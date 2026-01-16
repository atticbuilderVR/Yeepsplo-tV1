;--------------------------------
; Includes

  !include "MUI2.nsh"
  !include "nsDialogs.nsh"
  !include "LogicLib.nsh"
  !include "WinMessages.nsh"
  !include "FileFunc.nsh"

;--------------------------------
; General Attributes

  Name "Yeepsploit Dashboard V0.1 (beta)"
  OutFile "DashboardInstaller.exe"
  InstallDir "$PROGRAMFILES\DashboardApp"
  InstallDirRegKey HKCU "Software\DashboardApp" ""
  RequestExecutionLevel admin
  Unicode True

;--------------------------------
; Variables

  Var Dialog
  Var Label
  Var PortInput
  Var PortValue
  Var FreeMemMB

;--------------------------------
; Interface Settings (MUI)

  !define MUI_ABORTWARNING
  !define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
  !define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
  !define MUI_HEADERIMAGE
  
  ; Title for the installer
  Caption "Yeepsploit Dashboard Installer"

;--------------------------------
; Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "${NSISDIR}\Docs\Modern UI\License.txt" ; Placeholder license
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  
  ; Custom Page: Dashboard Configuration
  Page custom nsDialogsConfigPage nsDialogsConfigPageLeave
  
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  ; Uninstaller Pages
  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;--------------------------------
; Languages

  !insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Installer Sections

Section "Dashboard Core" SecCore
  SetOutPath "$INSTDIR"
  
  ; Install the main executable
  ; Ensure dashboard.exe is in the same folder as this script when compiling
  ; If testing without the file, you can comment this out or use FileOpen to create a dummy.
  File "dashboard.exe"
  
  ; Write the configured port to registry
  WriteRegDWORD HKCU "Software\DashboardApp" "ServerPort" $PortValue
  
  ; Store installation folder
  WriteRegStr HKCU "Software\DashboardApp" "" $INSTDIR
  
  ; Create Uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Start Menu Shortcuts" SecShortcuts
  CreateDirectory "$SMPROGRAMS\Dashboard App"
  CreateShortcut "$SMPROGRAMS\Dashboard App\Dashboard.lnk" "$INSTDIR\dashboard.exe"
  CreateShortcut "$SMPROGRAMS\Dashboard App\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
SectionEnd

;--------------------------------
; Uninstaller Section

Section "Uninstall"
  Delete "$INSTDIR\dashboard.exe"
  Delete "$INSTDIR\Uninstall.exe"
  Delete "$SMPROGRAMS\Dashboard App\Dashboard.lnk"
  Delete "$SMPROGRAMS\Dashboard App\Uninstall.lnk"
  RMDir "$SMPROGRAMS\Dashboard App"
  RMDir "$INSTDIR"
  DeleteRegKey HKCU "Software\DashboardApp"
SectionEnd

;--------------------------------
; Functions

Function .onInit
  ; PLUGIN: UserInfo - Check for Admin rights
  UserInfo::GetAccountType
  Pop $0
  ${If} $0 != "Admin"
    MessageBox MB_OK|MB_ICONSTOP "Administrator rights are required to install Dashboard App."
    Abort
  ${EndIf}

  ; PLUGIN: System - Check available memory (Spicing it up)
  ; Allocating MEMORYSTATUS struct (32 bytes)
  System::Call '*(&l4, &l4, &l4, &l4, &l4, &l4, &l4, &l4) i .r1'
  System::Call 'kernel32::GlobalMemoryStatus(i r1)'
  ; Reading dwAvailPhys (5th integer in struct)
  System::Call '*$1(i, i, i, i, i, i, i, i) (., ., ., ., .r2, ., ., .)'
  System::Free $1
  
  ; Calculate MB
  IntOp $FreeMemMB $2 / 1048576
  ${If} $FreeMemMB < 256
     MessageBox MB_YESNO|MB_ICONEXCLAMATION "Warning: Low available memory ($FreeMemMB MB). Dashboard might run slowly. Continue?" IDYES +2
     Abort
  ${EndIf}
FunctionEnd

Function nsDialogsConfigPage
  nsDialogs::Create 1018
  Pop $Dialog

  ${If} $Dialog == error
    Abort
  ${EndIf}

  !insertmacro MUI_HEADER_TEXT "Dashboard Configuration" "Configure the network settings for the dashboard."

  ${NSD_CreateLabel} 0 0 100% 12u "Enter the listening port for the Dashboard Service (1024 - 65535):"
  Pop $Label

  ${NSD_CreateText} 0 13u 50% 12u "8080"
  Pop $PortInput
  
  ; Limit text length to 5 characters
  SendMessage $PortInput ${EM_LIMITTEXT} 5 0

  nsDialogs::Show
FunctionEnd

Function nsDialogsConfigPageLeave
  ${NSD_GetText} $PortInput $PortValue

  ; PLUGIN: Math - Validate that the port is a valid number and within range
  ; Math::Script returns the result of the expression in the first register (usually r0 or stack)
  ; We check: (PortValue >= 1024) AND (PortValue <= 65535)
  
  Math::Script "r0 = ($PortValue >= 1024 && $PortValue <= 65535)"
  
  ; r0 is now 1 (True) or 0 (False)
  ${If} $0 == 0
    MessageBox MB_OK|MB_ICONSTOP "Invalid Port!$\nPlease enter a value between 1024 and 65535."
    Abort
  ${EndIf}
FunctionEnd
