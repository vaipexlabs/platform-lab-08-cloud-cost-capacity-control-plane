# Contributing

Thank you for helping improve the Vaipex Cloud Cost & Capacity Control Plane.
Contributions should preserve the project's transparent, reliability-aware,
and developer-centred approach to Kubernetes FinOps.

## Before opening a change

1. Open an issue before proposing a substantial architectural or behavioral
   change so its intent and trade-offs can be discussed.
2. Keep each pull request focused on one concern.
3. Never commit cloud credentials, kubeconfig files, tokens, billing exports,
   or private workload data.

## Expectations

Changes to cost calculations must disclose their pricing assumptions. Changes
to capacity-review signals must explain the formula, evaluation window,
threshold, reliability considerations, and expected result.

Every pull request should describe:

- the platform or developer problem being addressed;
- the behavior before and after the change;
- how the change was validated;
- rollout and rollback considerations; and
- any limitations that remain outside this local reference implementation.

Validation commands will be added alongside the relevant implementation
milestones. Until then, verify Markdown links, SVG rendering, and repository
whitespace before submitting documentation changes.

By contributing, you agree that your contribution is licensed under the
[Apache License 2.0](LICENSE).
