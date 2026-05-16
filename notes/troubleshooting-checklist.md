# Troubleshooting Checklist

Use this checklist when you are not sure what to inspect first.

## Basic Cluster Checks

```powershell
kubectl cluster-info
kubectl get nodes
kubectl get ns
```

## Namespace Checks

```powershell
kubectl get all -n skill-lab
kubectl get events -n skill-lab --sort-by=.metadata.creationTimestamp
```

## Pod Checks

```powershell
kubectl get pods -n skill-lab -o wide
kubectl describe pod <pod-name> -n skill-lab
kubectl logs <pod-name> -n skill-lab
kubectl logs <pod-name> -n skill-lab --previous
```

## Deployment Checks

```powershell
kubectl get deploy -n skill-lab
kubectl describe deployment <deployment-name> -n skill-lab
```

## Service And Endpoint Checks

```powershell
kubectl get svc -n skill-lab
kubectl get endpoints -n skill-lab
kubectl describe service <service-name> -n skill-lab
kubectl get pods -n skill-lab --show-labels
```

## Scheduling Checks

```powershell
kubectl describe pod <pod-name> -n skill-lab
kubectl get events -n skill-lab --sort-by=.metadata.creationTimestamp
kubectl get nodes
```

## What To Look For

- `ImagePullBackOff`: image tag errors, registry auth issues, pull secret problems
- `CrashLoopBackOff`: bad startup command, application crash, missing config, failed probes
- `Pending`: insufficient CPU or memory, taints, tolerations, affinity, PVC binding issues
- Service issues: selector mismatch, empty endpoints, pods not ready

## If You Get Stuck

- Start from events first
- Then inspect `describe`
- Then inspect logs
- Keep observed facts separate from your guesses
