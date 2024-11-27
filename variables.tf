variable "environment" {
  description = "Env tags"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "cluster_name" {
  description = "Cluster Name para inclusao de oidc nas roles"
  type        = string
  default     = ""
}

variable "s3" {
  description = "Lista de buckets S3"
  type = list(object({
    bucket        = string
    force_destroy = bool
  }))
  default = []
}

variable "roles" {
  description = "Lista de roles para acesso aos buckets S3"
  type = list(object({
    role_name       = string
    bucket_name_key = string
    string          = string
    namespace       = string
    serviceaccount  = string
  }))
  default = []
}

variable "lifecycle_s3" {
  description = "Lista de regras de ciclo de vida para os buckets S3"
  type = list(object({
    rule_id          = string
    bucket_name_key  = string
    status_lifecycle = string
    abort_incomplete_multipart_upload = optional(list(object({
      days_after_initiation = number
    })))
    expiration = list(object({
      days = number
      date = optional(string)
    }))
    transition = optional(list(object({
      days          = number
      storage_class = string
    })))
    noncurrent_version_transition = optional(list(object({
      noncurrent_days = number
      storage_class   = string
    })))
    filter = optional(list(object({
      prefix                   = string
      object_size_greater_than = number
      object_size_less_than    = number
    })))
    noncurrent_version_expiration = optional(list(object({
      noncurrent_days = number
    })))
  }))
  default = []
}
