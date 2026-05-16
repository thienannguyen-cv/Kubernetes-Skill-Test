---
name: kubernetes-diagnostic
description: Diagnose Kubernetes cluster and workload issues through a structured evidence-first workflow that identifies symptoms, narrows plausible causes, validates them with cluster data, and returns root cause plus remediation.
---

# Kubernetes Diagnostic Skill

## PURPOSE

Provide a repeatable, evidence-first procedure for diagnosing Kubernetes cluster, node, networking, storage, and workload problems, then returning the most likely root cause, supporting evidence, confidence, and safe remediation steps.

## TRIGGERS

Activate this skill when the task is to diagnose or triage a Kubernetes issue such as:

- Pods stuck in `Pending`, `CrashLoopBackOff`, `ImagePullBackOff`, `ContainerCreating`, or `Terminating`
- Deployments, StatefulSets, DaemonSets, Jobs, or CronJobs not becoming healthy
- Services unreachable from inside or outside the cluster
- Ingress, DNS, or service discovery failures
- Node pressure, scheduling failures, taints, readiness problems, or evictions
- PVC, PV, CSI, or storage mount / attach failures
- Resource exhaustion, throttling, OOM kills, or abnormal restarts
- Control plane or add-on symptoms when the environment exposes enough evidence to inspect them
- Requests to find root cause, determine blast radius, or recommend the next diagnostic step for Kubernetes

## ANTI-TRIGGERS

Do not activate this skill when:

- The task is to deploy, upgrade, or reconfigure Kubernetes resources without a diagnostic goal
- The task is generic cloud architecture advice with no live Kubernetes symptoms
- The environment lacks Kubernetes access, logs, manifests, or any concrete evidence to inspect
- The request is primarily about authoring YAML, Helm charts, or Terraform rather than diagnosing a failure
- The issue is already proven to be outside Kubernetes and another domain skill would be more specific

## INPUTS / CONTEXT

Gather or confirm as many of these as possible before concluding:

- Cluster access method and permissions, especially whether read-only `kubectl` access is available
- Cluster scope: namespace, workload name, pod name, node name, service name, ingress name, or label selectors
- Symptom details: error messages, failing command, time window, frequency, recent changes, and user impact
- Diagnostic artifacts: `kubectl get`, `kubectl describe`, logs, events, manifests, metrics, and previous incident notes
- Environment details: Kubernetes distribution, cloud provider, CNI, CSI, ingress controller, service mesh, and autoscaling components when relevant
- Safety boundaries: whether only inspection is allowed, whether changes require confirmation, and whether production access has extra restrictions

Assumptions:

- Prefer read-only inspection first
- Treat user-provided timestamps and events as hypotheses until validated
- If evidence is incomplete, narrow to plausible causes instead of overstating certainty

## PROCESS

Use this branching diagnostic tree. Do not skip evidence collection.

1. Frame the incident.
   - Identify the failing object, namespace, impact, and symptom state.
   - Record whether the failure is workload, scheduling, networking, storage, configuration, or platform-adjacent.
   - Note recent changes if available, but do not assume causality yet.

2. Establish current state from Kubernetes.
   - Inspect object status, conditions, restart counts, events, and age.
   - Check whether the issue is isolated to one pod, one workload, one node, one namespace, or cluster-wide.
   - Prefer the narrowest scope that still explains the symptom.

3. Branch by primary symptom.
   - If pods are `Pending`, inspect scheduling events, node capacity, taints, affinities, tolerations, quotas, PVC binding, and image pull prerequisites.
   - If pods are restarting or `CrashLoopBackOff`, inspect current and previous container logs, termination reason, probes, config dependencies, and OOM / exit code evidence.
   - If pods are `ImagePullBackOff` or `ErrImagePull`, verify image name, tag, registry reachability, image pull secrets, and authorization failures.
   - If traffic fails, inspect Service selectors, endpoint population, pod readiness, NetworkPolicy, DNS resolution, ingress rules, TLS, and controller events.
   - If storage fails, inspect PVC / PV status, storage class behavior, attachment or mount events, access modes, node affinity, and CSI driver errors.
   - If nodes are unhealthy, inspect node conditions, pressure states, taints, kubelet-related events, and the blast radius across workloads on those nodes.
   - If the symptom does not fit one branch cleanly, track the top two plausible branches in parallel and explicitly compare evidence.

4. Generate hypotheses from evidence.
   - For each plausible cause, list the exact evidence that supports it and the evidence that weakens it.
   - Reject hypotheses that require assumptions not backed by observed data.
   - Keep multiple hypotheses only if the available evidence cannot yet discriminate between them.

5. Validate the leading hypothesis.
   - Request or inspect the next highest-signal artifact that can confirm or falsify it.
   - Prefer artifacts with direct failure evidence: events, describe output, prior-container logs, readiness / liveness failures, scheduler messages, and endpoint state.
   - If validation fails, return to the branch step and re-rank hypotheses.

6. Determine root cause and blast radius.
   - State the most likely root cause in one sentence.
   - Identify affected workloads, namespaces, nodes, or traffic paths.
   - Distinguish primary cause from secondary symptoms.

7. Produce remediation guidance.
   - Start with the safest corrective action or next operator step.
   - Separate immediate mitigation from long-term prevention.
   - If the remediation would mutate cluster state, mark it as a proposed action and require human confirmation before execution.

8. Handle insufficient evidence explicitly.
   - If no root cause can be proven, return the top plausible causes with confidence levels and the next diagnostic commands or artifacts needed.
   - Do not fabricate control plane, cloud, or node-level facts that were not observed.

## OUTPUT SPEC

Return a concise diagnostic report with these fields in plain text or structured markdown:

- `Incident`: short statement of the failing Kubernetes object and symptom
- `Scope`: namespace and affected resources, plus estimated blast radius
- `Observed Evidence`: bullet list of concrete facts from logs, events, conditions, or manifests
- `Hypotheses Considered`: each candidate cause with supporting or contradicting evidence
- `Root Cause`: the most likely cause, or `Unconfirmed`
- `Confidence`: `High`, `Medium`, or `Low`
- `Immediate Mitigation`: safest near-term action
- `Long-Term Fix`: durable remediation or preventive change
- `Next Checks`: only include when root cause is unconfirmed or confidence is below `High`

Sample output:

```md
Incident: Deployment `payments-api` pods in namespace `prod-payments` are stuck in `Pending`.
Scope: 3 replicas affected in one namespace; no evidence of cluster-wide impact.
Observed Evidence:
- Pod events show `0/6 nodes are available: 3 Insufficient memory, 3 node(s) had untolerated taint {dedicated=batch: NoSchedule}`.
- Deployment requests `4Gi` memory per pod.
- Matching nodes with the required toleration are not available.
Hypotheses Considered:
- Unschedulable due to memory pressure and taint mismatch. Supported by scheduler events.
- PVC binding issue. Rejected because PVCs are already `Bound`.
Root Cause: Workload requests exceed available schedulable capacity and the pod spec lacks the toleration needed for batch-dedicated nodes.
Confidence: High
Immediate Mitigation: Reduce replica count or memory requests, or deploy to nodes with available capacity after confirming policy.
Long-Term Fix: Align requests, tolerations, and node pool capacity planning for this workload class.
```

## EXAMPLES

Positive example:

- User asks: "Why are my pods in `ImagePullBackOff` in namespace `staging`?"
- Use this skill because the request is a Kubernetes failure diagnosis with a concrete symptom, inspect pod events and image pull errors, then return the validated cause and remediation.

Anti-example:

- User asks: "Write a Helm chart for Redis with ingress and autoscaling."
- Do not use this skill because the task is resource authoring, not diagnosis.

## EDGE CASES

- Multiple plausible causes exist, such as failed readiness probes plus intermittent DNS errors
- Symptoms are transient and disappear before inspection, requiring reliance on events or prior logs
- The user only provides screenshots or partial logs without cluster access
- Cluster access is read-only and cannot validate remediation by applying changes
- Managed Kubernetes hides control plane internals, so conclusions must rely on workload and event evidence
- Sidecars, service meshes, mutating webhooks, or admission policies alter behavior not visible in the main manifest alone
- Pods are rescheduled, recreated, or garbage-collected before previous logs are collected
- Resource symptoms are caused by namespace quota or limit range constraints rather than node shortage
- Service failure is actually due to empty endpoints from failing readiness, not networking
- Persistent volume symptoms originate from zone affinity, attachment timing, or CSI driver behavior

## SELF-CHECK

Before returning the diagnosis, verify that:

- The reported root cause is tied to explicit evidence, not intuition alone
- Competing hypotheses were considered when the symptom could have multiple explanations
- Secondary symptoms are not mislabeled as the primary cause
- The output clearly separates observed facts from inference
- Confidence reflects evidence quality and not just familiarity with the pattern
- Any proposed mutable action is clearly marked as requiring operator confirmation
- If evidence is insufficient, the report says `Unconfirmed` and lists the next highest-signal checks

## RISK PROFILE

`R2 EXTERNAL / IRREVERSIBLE`

Obligations:

- Default to read-only inspection first
- Require explicit human confirmation before deleting, restarting, patching, scaling, draining, or otherwise mutating cluster state
- Prefer dry-run, proposed commands, or remediation guidance over direct execution when diagnosing production environments
- Avoid exposing secrets, tokens, or sensitive workload data in the returned report

## ARCHETYPE

`A4 DIAGNOSTIC`

This skill uses a branching decision tree, requires explicit hypotheses, and must return root cause, evidence, confidence, and remediation.
