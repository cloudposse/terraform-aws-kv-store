variable "key_prefix" {
  description = "The prefix to use for the key path. This is useful for storing all keys for a module under a common prefix."
  type        = string
  nullable    = false
  default     = ""
}

variable "get" {
  description = <<-EOT
    A map of keys to read from the key/value store. The key_path, namespace,
    tenant, stage, environment, and name are derived from context by default,
    but can be overridden by specifying a value in the map.
    EOT
  type = map(object(
    {
      key_path    = optional(string),
      namespace   = optional(string),
      tenant      = optional(string),
      stage       = optional(string),
      environment = optional(string),
      name        = optional(string),
      attributes  = optional(list(string))
    }
    )
  )
  default = {
    myval = { stage = "root" }
  }
  nullable = false
}

variable "get_by_path" {
  description = <<-EOT
    A map of keys to read from the key/value store. The key_path, namespace,
    tenant, stage, environment, and name are derived from context by default,
    but can be overridden by specifying a value in the map.
    EOT
  type = map(object(
    {
      key_path    = optional(string),
      namespace   = optional(string),
      tenant      = optional(string),
      stage       = optional(string),
      environment = optional(string),
      name        = optional(string),
      attributes  = optional(list(string))
    }
    )
  )
  default  = {}
  nullable = false
}

variable "ssm_enabled" {
  description = "Whether to enable the SSM backend for the key/value store."
  type        = bool
  default     = true
}

variable "set" {
  description = <<-EOT
  A map of key-value pairs to write to the key/value store. The key_path,
  namespace, tenant, stage, environment, and name are derived from context by
  default, but can be overridden by specifying a value in the map.
  EOT
  type = map(object(
    {
      key_path    = optional(string),
      value       = string,
      sensitive   = bool,
      namespace   = optional(string),
      tenant      = optional(string),
      stage       = optional(string),
      environment = optional(string),
      name        = optional(string),
      attributes  = optional(list(string))
    }
    )
  )
  default  = {}
  nullable = false
}


variable "key_label_order" {
  type        = list(string)
  default     = ["namespace", "tenant", "stage", "environment", "name", "attributes"]
  description = <<-EOT
    The order in which the labels (ID elements) appear in the full key path.
    Defaults to ["namespace", "tenant", "stage", "environment", "name", "attributes"].
    You can omit any of the 6 labels, but at least one must be present.
    EOT
}
