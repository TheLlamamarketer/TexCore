# latexmk configuration for TexCore repository
# This file configures latexmk for automated LaTeX builds
# Usage: latexmk -pdf main.tex

# Use pdflatex by default
$pdf_mode = 1;

# Use biber for bibliography processing (biblatex)
$biber = 'biber %O %S';
$bibtex_use = 2;

# Enable synctex for PDF synchronization
$pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1 %O %S';

# Continuous preview mode settings
$preview_continuous_mode = 1;
$pdf_previewer = 'start';  # Windows default PDF viewer

# Output directory (uncomment to use build folder)
# $out_dir = 'build';

# Files to clean with latexmk -c
$clean_ext = 'aux bbl bcf blg fdb_latexmk fls log out run.xml synctex.gz toc nav snm vrb';

# Files to clean with latexmk -C (full clean, including PDF)
$clean_full_ext = 'pdf';

# Automatically detect and rebuild when dependencies change
$recorder = 1;

# Maximum number of compilation passes
$max_repeat = 5;

# Custom dependency rules for specific file types
add_cus_dep('glo', 'gls', 0, 'run_makeglossaries');
add_cus_dep('acn', 'acr', 0, 'run_makeglossaries');

sub run_makeglossaries {
    my ($base_name, $path) = fileparse($_[0]);
    pushd $path;
    my $return = system "makeglossaries", $base_name;
    popd;
    return $return;
}

# Show warnings for missing citations
$warnings_as_errors = 0;
