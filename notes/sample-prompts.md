# Sample Prompts

Use these prompts to test the `kubernetes-diagnostic` skill after you collect Kubernetes output.

## Prompt 1: Image Pull Failure

```text
Use `kubernetes-diagnostic` to diagnose why deployment `bad-image` in namespace `skill-lab` is failing.

Here is the evidence:
- output of `kubectl get pods -n skill-lab`
- output of `kubectl describe deployment bad-image -n skill-lab`
- output of `kubectl get events -n skill-lab --sort-by=.metadata.creationTimestamp`

Return:
- Incident
- Scope
- Observed Evidence
- Hypotheses Considered
- Root Cause
- Confidence
- Immediate Mitigation
- Long-Term Fix
```

## Prompt 2: Crash Loop

```text
Dùng skill `kubernetes-diagnostic` để chẩn đoán vì sao deployment `crash-app` trong namespace `skill-lab` bị lỗi.

Đây là dữ liệu:
- output của `kubectl get pods -n skill-lab`
- output của `kubectl describe pod <ten-pod> -n skill-lab`
- output của `kubectl logs <ten-pod> -n skill-lab`
- output của `kubectl logs <ten-pod> -n skill-lab --previous`

Hãy trả về:
- Incident
- Scope
- Observed Evidence
- Hypotheses Considered
- Root Cause
- Confidence
- Immediate Mitigation
- Long-Term Fix
```

## Prompt 3: Pending Pod

```text
Use `kubernetes-diagnostic` to diagnose why deployment `huge-request` in namespace `skill-lab` is stuck.

Evidence:
- `kubectl get pods -n skill-lab`
- `kubectl describe pod <pod-name> -n skill-lab`
- `kubectl get events -n skill-lab --sort-by=.metadata.creationTimestamp`

If the root cause is not fully confirmed, include `Next Checks`.
```

## Prompt 4: Service Not Routing

```text
Use `kubernetes-diagnostic` to diagnose why service `wrong-selector-svc` in namespace `skill-lab` is not routing traffic.

Evidence:
- `kubectl get svc -n skill-lab`
- `kubectl get endpoints -n skill-lab`
- `kubectl describe service wrong-selector-svc -n skill-lab`
- `kubectl get pods -n skill-lab --show-labels`

Return the likely root cause and explain which evidence supports it.
```

## Prompt 5: General Triage

```text
Dùng skill `kubernetes-diagnostic` để triage toàn bộ namespace `skill-lab`.

Tôi cung cấp:
- `kubectl get pods -n skill-lab`
- `kubectl get svc -n skill-lab`
- `kubectl get endpoints -n skill-lab`
- `kubectl get events -n skill-lab --sort-by=.metadata.creationTimestamp`

Hãy nhóm theo từng incident riêng, nêu scope, root cause, confidence và next checks nếu cần.
```
