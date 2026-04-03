name_prefix      = "lab"
masters          = 1
workers          = 2
master_memory    = "4G"
master_cpus      = 2
master_disk      = "40G"
worker_memory    = "4G"
worker_cpus      = 2
worker_disk      = "50G"
kubeconfig_path  = "./kubeconfig"
recreate_on_diff = true

multipass_image = "rocky-8"
vm_user         = "rocky"
