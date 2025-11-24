# TexCore

LaTeX repository for university projects.

## Projects

- **HOL/** - Hologramme und Michelson-Interferometer
- **FHZ/** - Physics experiment documentation
- **MST/** - Mass measurements project
- **Test1/** - Test project

## Prerequisites

### Required Software

1. **LaTeX Distribution** (choose one):
   - [MiKTeX](https://miktex.org/) (recommended for Windows)
   - [TeX Live](https://www.tug.org/texlive/)
   
   Install via Chocolatey:
   ```powershell
   choco install miktex
   ```

2. **Biber** - Bibliography processor (usually included with MiKTeX/TeX Live)

3. **latexmk** - Build automation (optional but recommended)

### Recommended VS Code Extensions

- [LaTeX Workshop](https://marketplace.visualstudio.com/items?itemName=James-Yu.latex-workshop) - Full LaTeX support
- [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker) - Spelling checker

## Building Projects

### Option 1: Using the Build Script (Recommended)

Build any project using PowerShell:

```powershell
# Build a specific project
.\build.ps1 HOL

# Build other projects
.\build.ps1 FHZ
.\build.ps1 MST
.\build.ps1 Test1

# Clean build artifacts
.\build.ps1 HOL -Clean

# Watch mode (auto-rebuild on file changes)
.\build.ps1 HOL -Watch

# Show help
.\build.ps1 -Help
```

### Option 2: Using latexmk

If you have latexmk installed:

```powershell
cd HOL
latexmk -pdf main.tex

# Continuous preview (watch mode)
latexmk -pdf -pvc main.tex

# Clean build files
latexmk -c

# Clean everything including PDF
latexmk -C
```

### Option 3: Manual Build

For projects using biblatex (HOL, FHZ, MST):

```powershell
cd HOL
pdflatex main.tex
biber main
pdflatex main.tex
pdflatex main.tex
```

For simple projects (Test1):

```powershell
cd Test1
pdflatex test.tex
pdflatex test.tex
```

## Project Structure

```
TexCore/
├── HOL/
│   ├── main.tex          # Main LaTeX file
│   ├── Source.bib        # Bibliography
│   ├── Plots/            # Generated plots
│   └── *.pdf, *.png      # Images and figures
├── FHZ/
│   ├── main.tex
│   └── Quellen.bib
├── MST/
│   └── mass.tex
├── Test1/
│   └── test.tex
├── build.ps1             # Build script
├── .latexmkrc            # latexmk configuration
├── .gitignore            # Git ignore rules
└── README.md             # This file
```

## Tips

### Faster Builds

- Use `latexmk` for automatic dependency tracking
- Use watch mode (`-pvc` flag) during editing
- Clean build artifacts periodically with `.\build.ps1 <project> -Clean`

### Troubleshooting

**Bibliography not showing?**
- Ensure you've run biber: `biber main`
- Check for `main.bbl` file after running biber
- Run the full build sequence (3 pdflatex passes with biber in between)

**Missing packages?**
- MiKTeX will auto-install missing packages on first use
- For TeX Live, use: `tlmgr install <package-name>`

**Build errors?**
- Check the `.log` file in the project directory
- Run with interaction mode: `pdflatex main.tex` (without `-interaction=nonstopmode`)
- Clean and rebuild: `.\build.ps1 HOL -Clean` then `.\build.ps1 HOL`

## Git Workflow

The repository uses `.gitignore` to exclude build artifacts but **keeps PDF files** versioned.

Ignored files include:
- `*.aux`, `*.log`, `*.out`, `*.toc`
- `*.bbl`, `*.blg`, `*.bcf`, `*.run.xml`
- `*.synctex.gz`, `*.fls`, `*.fdb_latexmk`

To see which files are ignored:
```powershell
git status --ignored
```

## VS Code Integration

If using LaTeX Workshop extension, it will automatically:
- Build on save
- Show PDF preview
- Provide IntelliSense for LaTeX commands
- Run biber when needed (if configured)

The `.latexmkrc` file configures build behavior for both command-line and VS Code usage.
