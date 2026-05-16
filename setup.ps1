param(
    [ValidateSet("full", "healthy", "broken", "status", "cleanup", "destroy")]
    [string]$Action = "full",
    [string]$ClusterName = "diag-lab",
    [string]$Namespace = "skill-lab",
    [string]$CondaPrefix = ""
)

$ErrorActionPreference = "Stop"

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ManifestRoot = Join-Path $ProjectRoot "manifests"

if ($CondaPrefix) {
    $condaScripts = Join-Path $CondaPrefix "Scripts"
    $env:PATH = "$CondaPrefix;$condaScripts;$env:PATH"
}

function Require-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        $guidance = switch ($Name) {
            "docker" { "Install Docker Desktop and make sure it is available in PATH, then restart PowerShell." }
            "kubectl" { "Install kubectl and make sure it is available in PATH, then restart PowerShell." }
            "kind" { "Install kind and make sure it is available in PATH, then restart PowerShell." }
            default { "Install the missing command and retry." }
        }

        throw "Required command not found: $Name. $guidance"
    }
}

function Invoke-KubectlApply {
    param([string]$FileName)

    $path = Join-Path $ManifestRoot $FileName
    Write-Host "Applying $FileName"
    kubectl apply -f $path
}

function Invoke-KubectlDelete {
    param([string]$FileName)

    $path = Join-Path $ManifestRoot $FileName
    Write-Host "Deleting $FileName"
    kubectl delete -f $path --ignore-not-found
}

function Test-KindClusterExists {
    $cmdExe = Join-Path $env:SystemRoot "System32\cmd.exe"
    $clusters = & $cmdExe /c "kind get clusters 2>nul"

    if ($LASTEXITCODE -ne 0) {
        return $false
    }

    return @($clusters) -contains $ClusterName
}

function Ensure-Prerequisites {
    Require-Command "docker"
    Require-Command "kubectl"
    Require-Command "kind"
}

function Ensure-Cluster {
    if (Test-KindClusterExists) {
        Write-Host "kind cluster '$ClusterName' already exists"
        return
    }

    Write-Host "Creating kind cluster '$ClusterName'"
    kind create cluster --name $ClusterName
}

function Show-Status {
    Write-Host "Cluster info"
    kubectl cluster-info
    Write-Host ""
    Write-Host "Nodes"
    kubectl get nodes
    Write-Host ""
    Write-Host "Namespace resources"
    kubectl get all -n $Namespace
    Write-Host ""
    Write-Host "Endpoints"
    kubectl get endpoints -n $Namespace
}

function Deploy-Healthy {
    Invoke-KubectlApply "00-namespace.yaml"
    Invoke-KubectlApply "10-good-nginx.yaml"
}

function Deploy-Broken {
    Invoke-KubectlApply "20-bad-image.yaml"
    Invoke-KubectlApply "30-crash-app.yaml"
    Invoke-KubectlApply "40-huge-request.yaml"
    Invoke-KubectlApply "50-wrong-selector.yaml"
}

function Cleanup-Manifests {
    Invoke-KubectlDelete "50-wrong-selector.yaml"
    Invoke-KubectlDelete "40-huge-request.yaml"
    Invoke-KubectlDelete "30-crash-app.yaml"
    Invoke-KubectlDelete "20-bad-image.yaml"
    Invoke-KubectlDelete "10-good-nginx.yaml"
    Invoke-KubectlDelete "00-namespace.yaml"
}

Ensure-Prerequisites

switch ($Action) {
    "full" {
        Ensure-Cluster
        Deploy-Healthy
        Deploy-Broken
        Show-Status
    }
    "healthy" {
        Ensure-Cluster
        Deploy-Healthy
        Show-Status
    }
    "broken" {
        Ensure-Cluster
        Invoke-KubectlApply "00-namespace.yaml"
        Deploy-Broken
        Show-Status
    }
    "status" {
        Show-Status
    }
    "cleanup" {
        Cleanup-Manifests
    }
    "destroy" {
        if (Test-KindClusterExists) {
            Write-Host "Deleting kind cluster '$ClusterName'"
            kind delete cluster --name $ClusterName
        } else {
            Write-Host "kind cluster '$ClusterName' does not exist"
        }
    }
}
