# Kubernetes Skill Test

This project is a zero-cost local lab for testing the `kubernetes-diagnostic` skill from scratch on Windows.

Everything here is designed to run on your own machine with:

- Docker Desktop
- `kubectl`
- `kind`

No cloud account is required.

## What This Project Includes

- A bundled local copy of the `kubernetes-diagnostic` skill
- A local Kubernetes lab using `kind`
- One healthy sample app
- Four intentionally broken scenarios for diagnosis
- Sample prompts for testing the skill
- A PowerShell setup script for repeatable lab setup and cleanup

## Recreate The Skill From `general-skill`

If a new user only has the `general-skill` meta-skill and wants to recreate `kubernetes-diagnostic` from scratch, they can use the prompt below.

This is useful when:

- the bundled skill file is missing
- the user wants to regenerate the skill independently
- the user wants to verify that the meta-skill can produce a usable Kubernetes diagnostic skill

Prompt:

```text
Hãy kế thừa General Skill như đúng hướng dẫn, để tôi có thể sử dụng skill làm công việc Kubernetes diagnostic. 
```

## Folder Structure

```text
Kubernetes Skill Test/
  .codex/
    skills/
      kubernetes-diagnostic/
        SKILL.md
  manifests/
    00-namespace.yaml
    10-good-nginx.yaml
    20-bad-image.yaml
    30-crash-app.yaml
    40-huge-request.yaml
    50-wrong-selector.yaml
  notes/
    sample-prompts.md
    troubleshooting-checklist.md
  install-in-conda.ps1
  setup.ps1
```

## Independence From This Workspace

This folder is designed to be copied anywhere and used on its own.

The skill is bundled here:

- [SKILL.md](.codex/skills/kubernetes-diagnostic/SKILL.md)

That means after you copy this folder to a new location, Codex can still discover and use the skill from the copied `.codex/skills` directory.

If you want to test with no dependency on this current conversation, you can read this file once, follow the setup, and then delete `README.md`. The skill itself will still exist and remain usable.

## Prerequisites

Install these tools on Windows:

1. Docker Desktop
2. `kubectl`
3. `kind`

If you want to install `kubectl` and `kind` into your current conda environment, use:

- [install-in-conda.ps1](install-in-conda.ps1)

Important:

- `Docker Desktop` still must be installed outside conda because it is a Windows application and service
- `kubectl` can be installed into the current conda environment
- `kind` can be downloaded into the current conda environment's `Scripts` directory

If you use `winget`, you can try:

```powershell
winget install Docker.DockerDesktop
winget install Kubernetes.kubectl
winget install Kubernetes.kind
```

After installation, open a new terminal and verify:

```powershell
docker version
kubectl version --client
kind version
```

Make sure Docker Desktop is running before creating the cluster.

## From Scratch With Conda

If you are starting from zero and want the CLI tools in your current conda environment:

1. Activate your conda environment.
2. Open `Command Prompt` in this folder.
3. Run:

```bat
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\install-in-conda.ps1
```

This script:

- checks that a conda environment is active
- installs `kubectl` into the current conda environment
- downloads `kind.exe` into the current conda environment's `Scripts` directory
- verifies `conda`, `kubectl`, `kind`, and `docker`

After that:

1. Install and start Docker Desktop if you have not already done so.
2. If Docker Desktop says your WSL version is too old, open an Administrator terminal and run:

```bat
C:\Windows\System32\wsl.exe --update
```

3. Restart Docker Desktop if you had to update WSL.
4. Continue with the setup script:

```bat
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\setup.ps1 -Action full -CondaPrefix "C:\path\to\your\conda\env"
```

## Quick Start

If `kubectl` and `kind` are already installed globally in Windows `PATH`, open `Command Prompt` inside this folder and run:

```bat
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\setup.ps1 -Action full
```

This will:

- verify that `docker`, `kubectl`, and `kind` are available
- create a local `kind` cluster named `diag-lab` if it does not already exist
- create the `skill-lab` namespace
- deploy the healthy app
- deploy all broken scenarios

Useful actions:

```bat
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\setup.ps1 -Action status
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\setup.ps1 -Action healthy
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\setup.ps1 -Action broken
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\setup.ps1 -Action cleanup
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\setup.ps1 -Action destroy
```

If `kubectl` and `kind` were installed into conda instead of global Windows `PATH`, always add `-CondaPrefix`:

```bat
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\setup.ps1 -Action status -CondaPrefix "C:\path\to\your\conda\env"
```

## Windows Notes

This project was tested on a Windows setup where:

- `Command Prompt` was more reliable than calling `powershell` by name
- `powershell` was not available in `PATH`, so the absolute executable path was used
- `kind` and `kubectl` were installed inside a conda environment, so `-CondaPrefix` was required
- Docker Desktop needed WSL to be updated before `kind` could create a cluster

If you see:

- `wsl is not recognized`: run `C:\Windows\System32\wsl.exe --update`
- `powershell is not recognized`: use `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`
- `kind not found`: rerun with `-CondaPrefix`
- `failed to connect to docker API`: start Docker Desktop and wait until it reports `is running`

## Known Good Command Sequence

Use this exact sequence if you want the shortest verified path from zero to a working lab on a Windows machine similar to the one used during testing.

Assumptions:

- your conda environment is already created
- Docker Desktop is installed
- you want `kubectl` and `kind` inside the conda environment

Commands:

```bat
conda activate <your\conda\env>
cd "C:\path\to\Kubernetes\Skill\Test\project"
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\install-in-conda.ps1
C:\Windows\System32\wsl.exe --update
```

Then:

1. Start Docker Desktop
2. Wait until Docker reports `is running`
3. Run:

```bat
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\setup.ps1 -Action full -CondaPrefix "C:\path\to\your\conda\env"
```

Then verify:

```bat
kubectl get pods -n skill-lab
```

Expected working state after a short wait:

- `good-nginx` becomes `Running`
- `bad-image` becomes `ErrImagePull` or `ImagePullBackOff`
- `crash-app` becomes `Error` first, then `CrashLoopBackOff`
- `huge-request` stays `Pending`
- `wrong-selector-app` becomes `Running`

## What Good Skill Output Looks Like

Use these expectations to judge whether `kubernetes-diagnostic` is performing well.

The skill should:

- identify the incident correctly
- scope the blast radius correctly
- separate observed facts from inference
- consider more than one hypothesis when appropriate
- choose the most likely root cause based on evidence
- give a confidence level that matches the evidence quality
- propose a safe immediate mitigation
- propose a longer-term fix
- request `Next Checks` when evidence is incomplete

The skill should not:

- guess a root cause without citing evidence
- confuse a secondary symptom with the primary cause
- recommend destructive cluster actions without clearly marking them as proposed actions
- invent cloud, control plane, or node facts that were not observed

## Evaluation Checklist

When you test the skill, grade the output against this checklist:

- `Incident`: names the correct object and symptom
- `Scope`: identifies whether the issue is one workload, one service, one node, one namespace, or broader
- `Observed Evidence`: includes specific events, conditions, logs, or selectors
- `Hypotheses Considered`: includes at least one rejected or competing hypothesis when relevant
- `Root Cause`: explains the primary cause, not just the visible status
- `Confidence`: matches how strong the evidence really is
- `Immediate Mitigation`: is safe and practical
- `Long-Term Fix`: addresses the underlying cause, not just the symptom
- `Next Checks`: appears when the diagnosis is not fully confirmed

## Expected Skill Performance By Scenario

### `bad-image`

A good result should:

- identify image pull failure as the incident
- cite image pull events or registry/tag errors
- reject unrelated causes such as scheduling or PVC issues
- recommend fixing image name, tag, or registry credentials

### `crash-app`

A good result should:

- identify repeated container exit as the incident
- cite logs, previous logs, or exit behavior
- distinguish app crash from image pull or scheduling problems
- recommend fixing the startup command or application behavior

### `huge-request`

A good result should:

- identify unschedulable resource requests as the incident
- cite `Pending` state plus scheduler events
- mention resource requests versus available capacity
- recommend reducing requests or increasing schedulable capacity

### `wrong-selector-svc`

A good result should:

- identify service routing failure due to selector mismatch
- cite empty endpoints and label mismatch
- distinguish this from pod crash or network policy failure
- recommend aligning service selectors with pod labels

## Step 1: Create A Free Local Cluster Manually

```powershell
kind create cluster --name diag-lab
```

Verify:

```powershell
kubectl cluster-info
kubectl get nodes
```

Expected result:

- The cluster responds successfully
- At least one node is in `Ready` state

## Step 2: Create The Test Namespace

Apply:

```powershell
kubectl apply -f manifests/00-namespace.yaml
```

Verify:

```powershell
kubectl get ns
```

## Step 3: Deploy The Healthy Example

Apply:

```powershell
kubectl apply -f manifests/10-good-nginx.yaml
```

Verify:

```powershell
kubectl get pods -n skill-lab
kubectl get svc -n skill-lab
```

The `good-nginx` pod should eventually become `Running`.

## Step 4: Create Broken Scenarios

Apply each broken manifest one by one:

```powershell
kubectl apply -f manifests/20-bad-image.yaml
kubectl apply -f manifests/30-crash-app.yaml
kubectl apply -f manifests/40-huge-request.yaml
kubectl apply -f manifests/50-wrong-selector.yaml
```

These scenarios simulate:

- `20-bad-image.yaml`: `ImagePullBackOff`
- `30-crash-app.yaml`: `CrashLoopBackOff`
- `40-huge-request.yaml`: `Pending` because resource requests are too large
- `50-wrong-selector.yaml`: Service exists but has no matching endpoints

## Step 5: Collect Evidence For Diagnosis

Use these commands while testing the skill:

```powershell
kubectl get pods -n skill-lab
kubectl get svc -n skill-lab
kubectl get endpoints -n skill-lab
kubectl get events -n skill-lab --sort-by=.metadata.creationTimestamp
kubectl describe deployment good-nginx -n skill-lab
kubectl describe deployment bad-image -n skill-lab
kubectl describe deployment crash-app -n skill-lab
kubectl describe deployment huge-request -n skill-lab
kubectl describe service wrong-selector-svc -n skill-lab
```

For a specific pod:

```powershell
kubectl describe pod <pod-name> -n skill-lab
kubectl logs <pod-name> -n skill-lab
kubectl logs <pod-name> -n skill-lab --previous
```

## Step 6: Test The Skill

This project already contains the skill in `.codex/skills/kubernetes-diagnostic/SKILL.md`.

To test independently:

1. Copy the entire `Kubernetes Skill Test` folder to a new location.
2. Open that copied folder as the active workspace.
3. Run the setup commands from this README or use the `setup.ps1` command shown above.
4. Ask Codex to use `kubernetes-diagnostic`.

Example prompts are stored in:

- [sample-prompts.md](notes/sample-prompts.md)

Minimal example:

```text
Use `kubernetes-diagnostic` to diagnose why deployment `bad-image` in namespace `skill-lab` is failing.
I will provide:
- kubectl get pods -n skill-lab
- kubectl describe deployment bad-image -n skill-lab
- kubectl get events -n skill-lab --sort-by=.metadata.creationTimestamp
```

Good starting options:

- Diagnose the `bad-image` deployment
- Diagnose the `crash-app` deployment
- Diagnose why the `wrong-selector-svc` service is not routing traffic

## Cleanup

Delete the broken resources:

```powershell
kubectl delete -f manifests/50-wrong-selector.yaml
kubectl delete -f manifests/40-huge-request.yaml
kubectl delete -f manifests/30-crash-app.yaml
kubectl delete -f manifests/20-bad-image.yaml
kubectl delete -f manifests/10-good-nginx.yaml
kubectl delete -f manifests/00-namespace.yaml
```

Delete the local cluster:

```powershell
kind delete cluster --name diag-lab
```

Or use:

```bat
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\setup.ps1 -Action cleanup
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File .\setup.ps1 -Action destroy
```

## Notes For First-Time Learners

- Start with `20-bad-image.yaml` because the error is easy to spot in events
- Then try `30-crash-app.yaml` to learn `kubectl logs` and `--previous`
- Then try `40-huge-request.yaml` to learn scheduler diagnostics
- Then try `50-wrong-selector.yaml` to learn the relationship between labels, services, and endpoints

## Success Criteria

You have set up the lab correctly if:

- `good-nginx` is `Running`
- `bad-image` shows image pull failures
- `crash-app` shows restart loops
- `huge-request` stays `Pending`
- `wrong-selector-svc` has no endpoints
