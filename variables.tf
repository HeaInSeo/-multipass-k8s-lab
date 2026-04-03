variable "name_prefix" {
  description = "Multipass VM name prefix"
  type        = string
  default     = "lab"
  validation {
    condition     = can(regex("^[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?$", var.name_prefix))
    error_message = "name_prefix must contain only alphanumeric or '-', and must not start or end with '-'."
  }
}

variable "multipass_image" {
  description = "Multipass image name for the baseline guest image"
  type        = string
  default     = "24.04"
}

variable "masters" {
  description = "Number of control-plane nodes"
  type        = number
  default     = 1
  validation {
    condition     = var.masters >= 1 && floor(var.masters) == var.masters
    error_message = "masters must be an integer >= 1."
  }
}

variable "workers" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
  validation {
    condition     = var.workers >= 0 && floor(var.workers) == var.workers
    error_message = "workers must be an integer >= 0."
  }
}

variable "master_memory" {
  description = "Memory for control-plane nodes"
  type        = string
  default     = "4G"
  validation {
    condition     = can(regex("^[1-9][0-9]*[MG]$", var.master_memory))
    error_message = "master_memory must look like 4G or 4096M."
  }
}

variable "worker_memory" {
  description = "Memory for worker nodes"
  type        = string
  default     = "4G"
  validation {
    condition     = can(regex("^[1-9][0-9]*[MG]$", var.worker_memory))
    error_message = "worker_memory must look like 4G or 4096M."
  }
}

variable "master_cpus" {
  description = "vCPU count for control-plane nodes"
  type        = number
  default     = 2
  validation {
    condition     = var.master_cpus >= 1 && floor(var.master_cpus) == var.master_cpus
    error_message = "master_cpus must be an integer >= 1."
  }
}

variable "worker_cpus" {
  description = "vCPU count for worker nodes"
  type        = number
  default     = 2
  validation {
    condition     = var.worker_cpus >= 1 && floor(var.worker_cpus) == var.worker_cpus
    error_message = "worker_cpus must be an integer >= 1."
  }
}

variable "master_disk" {
  description = "Disk size for control-plane nodes"
  type        = string
  default     = "40G"
  validation {
    condition     = can(regex("^[1-9][0-9]*[MG]$", var.master_disk))
    error_message = "master_disk must look like 40G or 40960M."
  }
}

variable "worker_disk" {
  description = "Disk size for worker nodes"
  type        = string
  default     = "50G"
  validation {
    condition     = can(regex("^[1-9][0-9]*[MG]$", var.worker_disk))
    error_message = "worker_disk must look like 50G or 51200M."
  }
}

variable "kubeconfig_path" {
  description = "Local kubeconfig export path"
  type        = string
  default     = "./kubeconfig"
}

variable "recreate_on_diff" {
  description = "Recreate an existing VM when spec differs"
  type        = bool
  default     = true
}

variable "vm_user" {
  description = "Default guest user"
  type        = string
  default     = "ubuntu"
  validation {
    condition     = can(regex("^[a-z_][a-z0-9_-]*$", var.vm_user))
    error_message = "vm_user must be a valid Linux username."
  }
}
