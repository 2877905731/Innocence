#ifndef MyAppVersion
  #define MyAppVersion "1.0.1"
#endif

#ifndef MySourceDir
  #error MySourceDir must point to the Flutter Windows Release directory.
#endif

#ifndef MyOutputDir
  #error MyOutputDir must point to the release artifact directory.
#endif

#define MyAppName "Innocence"
#define MyAppPublisher "Innocence"
#define MyAppExeName "innocence_flutter.exe"
#define MyProjectUrl "https://github.com/2877905731/Innocence"

[Setup]
AppId={{B81C20D9-D95E-4A18-881C-48E67F2F96F7}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyProjectUrl}
AppSupportURL={#MyProjectUrl}/issues
AppUpdatesURL={#MyProjectUrl}/releases
DefaultDirName={localappdata}\Programs\Innocence
DefaultGroupName=Innocence
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
OutputDir={#MyOutputDir}
OutputBaseFilename=Innocence-v{#MyAppVersion}-windows-x64-setup
SetupIconFile=runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0.17763
CloseApplications=yes
RestartApplications=no
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany={#MyAppPublisher}
VersionInfoDescription=Innocence Windows Installer
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "创建桌面快捷方式"; GroupDescription: "附加快捷方式："; Flags: unchecked

[Files]
Source: "{#MySourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Innocence"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"
Name: "{autodesktop}\Innocence"; Filename: "{app}\{#MyAppExeName}"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "启动 Innocence"; Flags: nowait postinstall skipifsilent
