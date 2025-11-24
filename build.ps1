# LaTeX Build Script for TexCore Repository
# Usage: .\build.ps1 [project] [options]
# Examples:
#   .\build.ps1 HOL           # Build HOL/main.tex
#   .\build.ps1 FHZ           # Build FHZ/main.tex
#   .\build.ps1 MST           # Build MST/mass.tex
#   .\build.ps1 HOL -clean    # Clean HOL build artifacts

param(
    [Parameter(Position=0)]
    [string]$Project = "",
    
    [switch]$Clean,
    [switch]$Watch,
    [switch]$Help
)

function Show-Help {
    Write-Host @"
LaTeX Build Script for TexCore
==============================

Usage: .\build.ps1 [project] [options]

Projects:
  HOL       Build HOL/main.tex
  FHZ       Build FHZ/main.tex
  MST       Build MST/mass.tex
  Test1     Build Test1/test.tex

Options:
  -Clean    Clean build artifacts (aux, log, bbl, etc.)
  -Watch    Watch mode (requires latexmk)
  -Help     Show this help message

Examples:
  .\build.ps1 HOL              # Build HOL project
  .\build.ps1 FHZ -Clean       # Clean FHZ build artifacts
  .\build.ps1 HOL -Watch       # Watch and rebuild on changes

"@
}

function Get-ProjectConfig {
    param([string]$ProjectName)
    
    $configs = @{
        "HOL" = @{
            "Path" = "HOL"
            "MainFile" = "main.tex"
            "UsesBiber" = $true
        }
        "FHZ" = @{
            "Path" = "FHZ"
            "MainFile" = "main.tex"
            "UsesBiber" = $true
        }
        "MST" = @{
            "Path" = "MST"
            "MainFile" = "mass.tex"
            "UsesBiber" = $true
        }
        "Test1" = @{
            "Path" = "Test1"
            "MainFile" = "test.tex"
            "UsesBiber" = $false
        }
    }
    
    return $configs[$ProjectName]
}

function Clear-Project {
    param([hashtable]$Config)
    
    $path = $Config.Path
    Write-Host "Cleaning build artifacts in $path..." -ForegroundColor Cyan
    
    Push-Location $path
    
    $extensions = @(
        "*.aux", "*.log", "*.out", "*.toc", "*.lof", "*.lot",
        "*.bbl", "*.blg", "*.bcf", "*.run.xml", "*.fls",
        "*.fdb_latexmk", "*.synctex.gz", "*.nav", "*.snm",
        "*.vrb", "*.idx", "*.ind", "*.ilg", "*.glo", "*.gls"
    )
    
    foreach ($ext in $extensions) {
        $files = Get-ChildItem -Filter $ext -ErrorAction SilentlyContinue
        if ($files) {
            Remove-Item $ext -Force
            Write-Host "  Removed $ext" -ForegroundColor Gray
        }
    }
    
    Pop-Location
    Write-Host "Clear complete!" -ForegroundColor Green
}

function Build-Project {
    param([hashtable]$Config)
    
    $path = $Config.Path
    $mainFile = $Config.MainFile
    $mainFileBase = [System.IO.Path]::GetFileNameWithoutExtension($mainFile)
    
    Write-Host "Building $path/$mainFile..." -ForegroundColor Cyan
    
    Push-Location $path
    
    try {
        # First pass
        Write-Host "  [1/4] Running pdflatex (first pass)..." -ForegroundColor Yellow
        $output = pdflatex -interaction=nonstopmode $mainFile 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  Error in first pdflatex pass" -ForegroundColor Red
            Write-Host $output -ForegroundColor Red
            Pop-Location
            return $false
        }
        
        # Run biber if needed
        if ($Config.UsesBiber) {
            Write-Host "  [2/4] Running biber..." -ForegroundColor Yellow
            $output = biber $mainFileBase 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Host "  Warning: biber failed (bibliography may not update)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  [2/4] Skipping biber (not used by this project)" -ForegroundColor Gray
        }
        
        # Second pass
        Write-Host "  [3/4] Running pdflatex (second pass)..." -ForegroundColor Yellow
        $output = pdflatex -interaction=nonstopmode $mainFile 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  Error in second pdflatex pass" -ForegroundColor Red
            Pop-Location
            return $false
        }
        
        # Third pass
        Write-Host "  [4/4] Running pdflatex (final pass)..." -ForegroundColor Yellow
        $output = pdflatex -interaction=nonstopmode $mainFile 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  Error in final pdflatex pass" -ForegroundColor Red
            Pop-Location
            return $false
        }
        
        Write-Host "`nBuild successful! PDF: $path/$mainFileBase.pdf" -ForegroundColor Green
        Pop-Location
        return $true
        
    } catch {
        Write-Host "  Build failed: $_" -ForegroundColor Red
        Pop-Location
        return $false
    }
}

function Watch-Project {
    param([hashtable]$Config)
    
    $path = $Config.Path
    $mainFile = $Config.MainFile
    
    # Check if latexmk is available
    $latexmkAvailable = Get-Command latexmk -ErrorAction SilentlyContinue
    if (-not $latexmkAvailable) {
        Write-Host "Error: latexmk is required for watch mode" -ForegroundColor Red
        Write-Host "Install it as part of your TeX distribution or run: choco install miktex" -ForegroundColor Yellow
        return
    }
    
    Write-Host "Starting watch mode for $path/$mainFile..." -ForegroundColor Cyan
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Gray
    
    Push-Location $path
    latexmk -pdflatex="pdflatex -interaction=nonstopmode" -pdf -pvc $mainFile
    Pop-Location
}

# Main script logic
if ($Help) {
    Show-Help
    exit 0
}

if (-not $Project) {
    Write-Host "Error: Project name required" -ForegroundColor Red
    Write-Host "Available projects: HOL, FHZ, MST, Test1" -ForegroundColor Yellow
    Write-Host "Run '.\build.ps1 -Help' for more information" -ForegroundColor Gray
    exit 1
}

$config = Get-ProjectConfig -ProjectName $Project
if (-not $config) {
    Write-Host "Error: Unknown project '$Project'" -ForegroundColor Red
    Write-Host "Available projects: HOL, FHZ, MST, Test1" -ForegroundColor Yellow
    exit 1
}

# Execute requested action
if ($Clean) {
    Clear-Project -Config $config
} elseif ($Watch) {
    Watch-Project -Config $config
} else {
    $success = Build-Project -Config $config
    if (-not $success) {
        exit 1
    }
}
