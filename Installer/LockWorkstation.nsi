# define name of installer
!include "MUI2.nsh"

OutFile "LockWorkstation_installer.exe"
Name "Lock Workstation"
Caption "$(^Name)"


# define installation directory
#InstallDir "$PROGRAMFILES\$(^Name)"
InstallDir "$PROGRAMFILES64\$(^Name)"
 
# For removing Start Menu shortcut in Windows 7
RequestExecutionLevel admin
 
;--------------------------------
;Interface Configuration
!define MUI_PAGE_HEADER_TEXT "$(^Name) Setup"
!define MUI_DIRECTORYPAGE_TEXT_TOP "Select a Destination Folder."
!define MUI_INSTFILESPAGE_FINISHHEADER_TEXT "$(^Name) Installed"
!define MUI_FINISHPAGE_RUN "$INSTDIR\LockWorkstation.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Launch $(^Name)"
!define MUI_FINISHPAGE_TITLE "Setup Complete"
!define MUI_FINISHPAGE_TEXT "$(^Name) is now installed. Click Close to complete setup."
!define MUI_FINISHPAGE_BUTTON "Close"
!define MUI_UNCONFIRMPAGE_TEXT_TOP "Uninstalling $(^Name)"
!define MUI_UNCONFIRMPAGE_TEXT_LOCATION "Uninstalling $(^Name)"

# Pages
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

; Create the shared function.
!macro MYMACRO un
  Function ${un}killapp
	StrCpy $0 "LockWorkstation.exe"
	DetailPrint "Searching for processes called '$0'"
	KillProc::FindProcesses
	StrCmp $1 "-1" wooops
	DetailPrint "-> Found $0 processes"
 
   StrCmp $0 "0" completed
   Sleep 1500
 
   StrCpy $0 "LockWorkstation.exe"
   DetailPrint "Killing all processes called '$0'"
   KillProc::KillProcesses
   StrCmp $1 "-1" wooops
   DetailPrint "-> Killed $0 processes, failed to kill $1 processes"
   Sleep 1500
 
   Goto completed
 
   wooops:
   DetailPrint "-> Error: Something went wrong :-("
   Abort

   completed:
   DetailPrint "Everything went okay :-D"
  FunctionEnd
!macroend

Function .onInit
	DetailPrint "Checking if $(^Name) is installed."
	#ReadRegStr $R0 HKLM "SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" "UninstallString"
	ReadRegStr $R0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" "UninstallString"
	DetailPrint "Uninstall string read is $R0"
	StrCmp $R0 "" NotInstalled
	MessageBox MB_YESNO|MB_TOPMOST "$(^Name) is already installed. Uninstall?" IDYES Yes IDNO No
	No:
		DetailPrint "$(^Name) is installed. Quitting install."
		Quit
	Yes:
		DetailPrint "Uninstalling $(^Name)."
		ExecWait $R0
 	NotInstalled:
	DetailPrint "$(^Name) not installed. Continuing with installation."
	# start install
FunctionEnd

; Insert function as an installer and uninstaller function.
!insertmacro MYMACRO ""
!insertmacro MYMACRO "un."

# start default section
Section "Installation"

	# start install
	call killapp
    # set the installation directory as the destination for the following actions
	DetailPrint "Setting installation folder to $INSTDIR"
    SetOutPath $INSTDIR
 
    # create the uninstaller
	DetailPrint "Creating uninstall.exe"
    WriteUninstaller "$INSTDIR\uninstall.exe"
	
	# files to copy
	DetailPrint "Copying files."
	File /r "..\LockWorkstation\bin\Release\"
	
	# Add add/remove entry
	DetailPrint "Creating uninstall entry in registry."
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" \
		"DisplayName" "$(^Name)"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" \
		"UninstallString" "$\"$INSTDIR\uninstall.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)" \
		"DisplayIcon" "$\"$INSTDIR\LockWorkstation.exe$\""	
	

SectionEnd

Section "Start Menu Shortcuts"
	DetailPrint "Creating shortcuts."
	CreateDirectory "$SMPROGRAMS\$(^Name)"
	CreateShortCut "$SMPROGRAMS\$(^Name)\$(^Name).lnk" "$INSTDIR\LockWorkstation.exe"
    CreateShortCut "$SMPROGRAMS\$(^Name)\Uninstall.lnk" "$INSTDIR\uninstall.exe"
SectionEnd

 
# uninstaller section start
Section "uninstall"

	call un.killapp
    # first, delete the uninstaller
	DetailPrint "Delete $INSTDIR\uninstall.exe"
    Delete "$INSTDIR\uninstall.exe"

    # second, remove the link from the start menu
	DetailPrint "Deleting shortcuts."
	Delete "$SMPROGRAMS\Uninstall.lnk"
    Delete "$SMPROGRAMS\$(^Name)\$(^Name).lnk"
	RMDir "$SMPROGRAMS\$(^Name)"
	

	# fourth, delete installation folder
	DetailPrint "Installation folder and files."
	RMDir /r  "$INSTDIR"
	
	# Remove add/remove registry entry
	DetailPrint "Deleting uninstall entry from registry."
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\$(^Name)"
 
# uninstaller section end
SectionEnd