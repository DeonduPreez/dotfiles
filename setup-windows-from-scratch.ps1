# PowerShell script to setup symlinks
# Requires Administrator privileges

function New-Symlink
{
  param(
    [Parameter(Mandatory=$true)]
    [string]$SubDirectory,

    [Parameter(Mandatory=$true)]
    [string]$Target
  )

  $Source = Join-Path -Path $PSScriptRoot -ChildPath $SubDirectory

  Write-Host "Linking $SubDirectory"
  # Check if target already exists
  if (Test-Path $Target)
  {
    # Check if it's already a symlink pointing to our source
    $item = Get-Item $Target -Force
    if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)
    {
      $linkTarget = $item.Target
      if ($linkTarget -eq $Source)
      {
        Write-Host "Symlink for $SubDirectory already exists and points to the correct location." -ForegroundColor Green
        return
      } else
      {
        Write-Host "A symlink already exists for $SubDirectory but points to: $linkTarget. Removing existing link" -ForegroundColor Yellow
        Remove-Item $Target -Force
      }
    } else
    {
      Write-Host "Directory $Target already exists and is not a symlink." -ForegroundColor Yellow
      $confirm = Read-Host "Remove existing directory and create symlink? (y/n)"
      if ($confirm -ne 'y')
      {
        Write-Host "Aborting." -ForegroundColor Yellow
        return
      }
      Remove-Item $Target -Recurse -Force
    }
  }

  # Create the symlink
  Write-Host "Creating symlink from $Target to $Source" -ForegroundColor Cyan
  New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null

  if (Test-Path $Target)
  {
    Write-Host "Symlink created successfully!" -ForegroundColor Green
    Write-Host "  Source: $Source" -ForegroundColor Gray
    Write-Host "  Target: $Target" -ForegroundColor Gray
  } else
  {
    Write-Host "Failed to create symlink." -ForegroundColor Red
  }
}

# Check if running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin)
{
  Write-Host "This script requires administrator privileges to create symlinks." -ForegroundColor Red
  Write-Host "Please run PowerShell as Administrator and try again." -ForegroundColor Yellow
  exit 1
}

# Create symlinks
New-Symlink -SubDirectory "nvim-from-scratch" -Target "$env:LOCALAPPDATA\nvim"
New-Symlink -SubDirectory "wezterm" -Target "$env:USERPROFILE\.config\wezterm"
