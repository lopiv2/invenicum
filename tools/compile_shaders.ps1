# ─── Compile GLSL shaders to SPIR-V for Flutter FragmentShader ───────────────
# Requires: Vulkan SDK (glslc.exe) in PATH
# Usage:    .\tools\compile_shaders.ps1

$shadersDir = Join-Path $PSScriptRoot ".." "assets" "shaders"
$shadersDir = Resolve-Path $shadersDir

$fragFiles = Get-ChildItem -Path $shadersDir -Filter "*.frag"
if ($fragFiles.Count -eq 0) {
    Write-Host "No .frag files found in $shadersDir"
    exit 0
}

$glslc = Get-Command "glslc" -ErrorAction SilentlyContinue
if (-not $glslc) {
    Write-Host "ERROR: glslc not found in PATH."
    Write-Host "Install the Vulkan SDK from https://vulkan.lunarg.com/"
    Write-Host "and ensure glslc.exe is in your PATH."
    exit 1
}

Write-Host "Compiling shaders with glslc $($glslc.Source)..."

foreach ($frag in $fragFiles) {
    $spirv = [System.IO.Path]::ChangeExtension($frag.FullName, ".frag.spirv")
    Write-Host "  $($frag.Name) → $([System.IO.Path]::GetFileName($spirv))"
    & $glslc -c -fshader-stage=fragment $frag.FullName -o $spirv
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  FAILED: $($frag.Name)" -ForegroundColor Red
    } else {
        Write-Host "  OK" -ForegroundColor Green
    }
}

Write-Host "Done."
