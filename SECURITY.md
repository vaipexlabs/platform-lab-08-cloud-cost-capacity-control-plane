# Security Policy

## Reporting a vulnerability

Do not disclose suspected vulnerabilities in a public issue, discussion, or
pull request.

Use GitHub's private vulnerability reporting for this repository when it is
available. Otherwise, contact **vaipex.labs@gmail.com** with:

- the affected component and version;
- reproduction steps or a proof of concept;
- the potential impact; and
- any suggested mitigation.

Do not include credentials, billing exports, or sensitive production data.
Vaipex Labs will review the report, coordinate remediation, and disclose the
issue responsibly.

## Scope

This repository is a local reference implementation, not a managed production
service. Reports concerning its automation, cost-allocation configuration,
dashboard exposure, dependency configuration, or unsafe documented behavior
are in scope. Vulnerabilities in Kubernetes, Prometheus, OpenCost, Grafana,
kind, Helm, or other third-party components should also be reported to their
respective maintainers.

The example controls and pricing model are not substitutes for an
organization's threat model, access controls, financial governance, or
production security review.
