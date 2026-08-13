# Vaipex Cloud Cost & Capacity Control Plane

An open reference implementation for connecting Kubernetes resource
consumption, cost allocation, capacity efficiency, and service ownership.

Developed by **Vaipex Labs** for the developer and platform engineering
community.

![Status](https://img.shields.io/badge/Status-Foundation-6D5DFB)
![Focus](https://img.shields.io/badge/Focus-FinOps%20%26%20Capacity-0B5FFF)
![Kubernetes](https://img.shields.io/badge/Platform-Kubernetes-326CE5?logo=kubernetes&logoColor=white)
![OpenCost](https://img.shields.io/badge/Cost-OpenCost-7C3AED)

[Project at a Glance](#project-at-a-glance) ·
[Why This Project Exists](#why-this-project-exists) ·
[Intended Flow](#intended-flow) ·
[Project Boundaries](#project-boundaries) ·
[Delivery Roadmap](#delivery-roadmap)

## Project at a Glance

| Area | Intended capability |
| --- | --- |
| Cost allocation | Estimate Kubernetes workload cost by service, team, namespace, and environment |
| Capacity visibility | Compare requested CPU and memory with actual utilization |
| Ownership | Connect cost and optimization signals to stable service-team identities |
| Efficiency | Surface idle, over-provisioned, and under-provisioned capacity |
| Decision support | Turn cost and utilization data into explainable recommendations |
| Visualization | Present cost, capacity, and ownership signals through dashboards |
| Developer experience | Provide a repeatable local demonstration without cloud credentials |

## Why This Project Exists

Kubernetes makes it easy to request compute capacity, but the resulting cost and
efficiency signals are often separated from the teams making workload decisions.
Cloud invoices show aggregate spend, while service teams think in terms of CPU,
memory, replicas, environments, and reliability requirements.

This project demonstrates a platform-owned FinOps model that translates shared
infrastructure consumption into engineering context. It is intended to help
platform teams make cost visible without turning optimization into an opaque
finance exercise or automatically trading away service reliability.

## Intended Flow

```text
Owned Kubernetes workloads
            ↓
Resource requests, limits, and actual usage
            ↓
Prometheus and OpenCost
            ↓
Cost allocation and capacity analysis
            ↓
Dashboards and explainable recommendations
            ↓
Service teams make informed optimization decisions
```

The operating principle is:

> Make cost and capacity visible in engineering terms, attach them to service
> ownership, and support decisions without automatically sacrificing
> reliability.

## Intended Users

- Platform engineering teams operating Kubernetes.
- Service owners tuning workload capacity.
- FinOps teams seeking transparent allocation and showback.
- Engineering leaders balancing cost, reliability, and growth.

## Project Boundaries

The reference implementation will use a local kind cluster and configurable
pricing. Its results represent **cost allocation estimates**, not a cloud bill.
This keeps the project free, portable, and reproducible without AWS, Azure, or
Google Cloud credentials.

### In scope

- Two sample services with contrasting resource profiles.
- Team, service, namespace, and environment ownership metadata.
- CPU and memory requests, limits, and actual utilization.
- OpenCost-based workload allocation estimates.
- Idle and inefficient capacity signals.
- Explainable optimization recommendations.
- Prometheus metrics and Grafana dashboards.
- A short end-to-end demonstration with automatic cleanup.

### Out of scope

- Cloud invoice reconciliation.
- Financial accounting or chargeback.
- Automatic modification of workload resources.
- Cost-driven autoscaling.
- Multi-cluster or multi-cloud aggregation.
- A required public-cloud account.

## Delivery Roadmap

- [x] Define the problem, intended users, outcomes, and project boundaries.
- [ ] Select the component architecture and define each tool's responsibility.
- [ ] Establish the repository foundation, license, and contribution guidance.
- [ ] Create the local Kubernetes and metrics platform lifecycle.
- [ ] Deploy owned workloads with contrasting capacity profiles.
- [ ] Add OpenCost with explicit local pricing assumptions.
- [ ] Expose cost allocation by service, team, namespace, and environment.
- [ ] Compare requested capacity with actual utilization.
- [ ] Produce explainable optimization recommendations.
- [ ] Add dashboards and actionable cost-capacity views.
- [ ] Add automated validation and a two-minute demonstration.
- [ ] Add operational guidance and polish the community-facing project.

## Design Principles

- Cost estimates disclose their pricing assumptions.
- Ownership uses team or service identities, not individual names.
- Recommendations remain explainable and reviewable.
- Reliability context accompanies every optimization opportunity.
- The platform supports decisions; it does not make unsafe automatic changes.
- The reference implementation remains portable and replaceable by design.

## Current Status

The project foundation and boundaries are defined. Implementation will proceed
in small, independently reviewed milestones so each architectural decision and
its trade-offs remain visible.
