param(
    [switch]$SkipKubectl,
    [switch]$SkipKind
)

$ErrorActionPreference = "Stop"

function Assert-CondaEnv {
    if (-not $env:CONDA_PREFIX) {
        throw "CONDA_PREFIX is not set. Activate your conda environment first, then rerun this script."
    }
}

function Require-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command not found: $Name"
    }
}

function Install-Kubectl {
    Write-Host "Installing kubectl into the current conda environment"
    conda install -y -c conda-forge kubernetes-client
}

function Install-Kind {
    $scriptDir = Join-Path $env:CONDA_PREFIX "Scripts"
    $target = Join-Path $scriptDir "kind.exe"

    New-Item -ItemType Directory -Force -Path $scriptDir | Out-Null

    Write-Host "Downloading kind.exe into $scriptDir"
    Invoke-WebRequest -Uri "https://kind.sigs.k8s.io/dl/latest/kind-windows-amd64" -OutFile $target
}

function Show-Versions {
    Write-Host ""
    Write-Host "Verification"

    if (Get-Command conda -ErrorAction SilentlyContinue) {
        conda --version
    }

    if (Get-Command kubectl -ErrorAction SilentlyContinue) {
        kubectl version --client
    } else {
        Write-Host "kubectl not found in PATH"
    }

    if (Get-Command kind -ErrorAction SilentlyContinue) {
        kind version
    } else {
        Write-Host "kind not found in PATH"
    }

    if (Get-Command docker -ErrorAction SilentlyContinue) {
        docker version
    } else {
        Write-Host "docker not found in PATH. Install Docker Desktop separately and restart your terminal."
    }
}

Assert-CondaEnv
Require-Command "conda"

Write-Host "Using conda environment: $env:CONDA_PREFIX"

if (-not $SkipKubectl) {
    Install-Kubectl
}

if (-not $SkipKind) {
    Install-Kind
}

Show-Versions
