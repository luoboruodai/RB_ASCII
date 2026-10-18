param([Parameter(Mandatory=$true)][string]$PluginPath)
$ErrorActionPreference='Stop'
Add-Type @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
public static class RB_ASCIILoader {
  [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
  public static extern IntPtr LoadLibrary(string path);
  [DllImport("kernel32.dll", SetLastError=true)]
  public static extern bool FreeLibrary(IntPtr handle);
  [DllImport("kernel32.dll", SetLastError=true, CharSet=CharSet.Ansi)]
  public static extern IntPtr GetProcAddress(IntPtr handle, string name);
  public static string Error() { return new Win32Exception(Marshal.GetLastWin32Error()).Message; }
}
'@
$path=(Resolve-Path -LiteralPath $PluginPath).ProviderPath
$h=[RB_ASCIILoader]::LoadLibrary($path)
if($h -eq [IntPtr]::Zero){throw "LoadLibrary failed for $path : $([RB_ASCIILoader]::Error())"}
try {
  $effect=[RB_ASCIILoader]::GetProcAddress($h,'EffectMain')
  if($effect -eq [IntPtr]::Zero){throw "EffectMain export missing: $([RB_ASCIILoader]::Error())"}
  Write-Host "PASS: LoadLibrary + EffectMain export resolved"
  Write-Host "Path: $path"
  Write-Host ("Module handle: 0x{0:X}" -f $h.ToInt64())
} finally {[void][RB_ASCIILoader]::FreeLibrary($h)}
