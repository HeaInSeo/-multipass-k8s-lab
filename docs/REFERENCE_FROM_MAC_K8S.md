# REFERENCE_FROM_MAC_K8S

This note records how `mac-k8s-multipass-terraform` informed this baseline.

## Kept

- Single entrypoint script pattern
- `scripts/host`, `scripts/multipass`, `scripts/cluster` split
- OpenTofu-driven local orchestration with `null_resource`
- Multipass VM launch and delete wrappers
- kubeadm init and join flow
- local kubeconfig export

## Modified

- Repository identity changed from test-oriented cluster repo to shared K8s lab baseline
- Defaults changed to a practical 3-node shape: `1 master + 2 workers`
- Add-ons changed from broad service/platform bundle to `base` and `optional` infra catalog
- Documentation rewritten around scope, ownership, and non-goals
- Commands expanded to make host setup and add-on usage first-class

## Removed

- service-specific helpers such as MySQL and Redis install scripts
- service-specific cloud-init fragments
- monitoring/logging/tracing/service-mesh bundle as the default add-on story
- docs tied to older test/service flows instead of the lab platform

## Reason

The old project proved the mechanics of Rocky 8 + Multipass + OpenTofu + kubeadm. The new repo keeps those mechanics, but narrows the responsibility to a reusable lab foundation that multiple future K8s projects can share.
