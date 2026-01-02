# Final comprehensive import fix script

$libPath = "e:\Projects\smart_store\lib"

# Get all Dart files
$dartFiles = Get-ChildItem -Path $libPath -Filter "*.dart" -Recurse

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    
    # Fix relative imports that are wrong
    $content = $content -replace "import '\.\.\/\.\.\/core\/", "import 'package:smart_store/core/"
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/core\/", "import 'package:smart_store/core/"
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/\.\.\/core\/", "import 'package:smart_store/core/"
    
    # Fix domain imports within features
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/products\/domain\/", "import '../domain/"
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/prices\/domain\/", "import '../domain/"
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/alerts\/domain\/", "import '../domain/"
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/settings\/domain\/", "import '../domain/"
    $content = $content -replace "import '\.\.\/\.\.\/\.\.\/backup\/domain\/", "import '../domain/"
    
    # Fix data imports within features
    $content = $content -replace "import '\.\.\/models\/", "import '"
    $content = $content -replace "import '\.\.\/database\/", "import 'package:smart_store/core/data/"
    
    # Write back if modified
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Fixed: $($file.FullName)"
    }
}

Write-Host "`nAll imports fixed!"
