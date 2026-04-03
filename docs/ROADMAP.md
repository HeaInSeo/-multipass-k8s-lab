# ROADMAP

## Near Term

- validate the first baseline on Rocky Linux 8 host
- keep `1 master + 2 workers` as the default practical shape
- keep Flannel as the fast bootstrap default
- improve add-on verification output

## Future Profiles

- `profiles/cilium`
- `profiles/storage-lab`
- `profiles/node-agent-lab`
- `profiles/operator-dev`

## Future Add-on Candidates

- ingress or gateway support
- local PV helpers
- CSI experiments
- observability baseline for troubleshooting

## Guardrails

- do not turn the baseline into a project workload repo
- do not add a profile until there is a concrete use case
- keep the default path small enough to use immediately
