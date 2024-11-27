**Este módulo tem como objetivo criar um bucket S3 e uma role IAM para acesso a esse bucket, configurada para ser utilizada com OIDC no EKS por meio de uma ServiceAccount.**

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.9 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.7 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.7 |

## Modules

```hcl
module "s3" {

  source = "github.com/Emerson89/s3-iam-oidc-terraform.git?ref=main"

  cluster_name = "<CLUSTER-NAME>"

  s3 = [
    {
      bucket        = "tempo"
      force_destroy = true
    },
    {
      bucket        = "loki"
      force_destroy = true
    }
  ]

  lifecycle_s3 = [
    {
      rule_id         = "tempo"
      bucket_name_key = "tempo"

      expiration = [
        {
          days = 7
        }
      ]
      abort_incomplete_multipart_upload = [
        {
          days_after_initiation = 7
        }
      ]
      status_lifecycle = "Enabled"
    },
    {
      rule_id         = "loki"
      bucket_name_key = "loki"

      expiration = [
        {
          days = 7
        }
      ]
      abort_incomplete_multipart_upload = [
        {
          days_after_initiation = 7
        }
      ]
      status_lifecycle = "Enabled"
    }
  ]

  roles = [
    {
      role_name       = "tempo"
      string          = "StringEquals"
      namespace       = "monitoring" ## Namespace k8s
      serviceaccount  = "tempo" ## Nome service account 
      bucket_name_key = "tempo"
    },
    {
      role_name       = "loki"
      string          = "StringEquals"
      namespace       = "monitoring" ## Namespace k8s
      serviceaccount  = "loki" ## Nome service account 
      bucket_name_key = "loki"
    }
  ]

  environment = "prd"

  tags = {
    Environment = "prd"
  }

}
```

- Usage prefix

```hcl
module "s3" {

  source = "github.com/Emerson89/s3-iam-oidc-terraform.git?ref=main"

  cluster_name = "<CLUSTER-NAME>"

  s3 = [
    {
      bucket        = "example"
      force_destroy = true
    }
  ]

  lifecycle_s3 = [
    {
      rule_id         = "example"
      bucket_name_key = "example" ## é o nome do bucket
      
      filter = [
        {
          prefix = "log/"
        }
      ]

      expiration = [
        {
          days = 7
        }
      ]
      abort_incomplete_multipart_upload = [
        {
          days_after_initiation = 7
        }
      ]
      status_lifecycle = "Enabled"
    }
  ]

  roles = [
    {
      role_name       = "example"
      string          = "StringEquals"
      namespace       = "monitoring" ## Namespace k8s
      serviceaccount  = "example" ## Nome service account 
      bucket_name_key = "example" ## é o nome do bucket
    }
  ]

  environment = "prd"

  tags = {
    Environment = "prd"
  }

}
```

- Usage transition

```hcl
module "s3" {

  source = "github.com/Emerson89/s3-iam-oidc-terraform.git?ref=main"

  cluster_name = "<CLUSTER-NAME>"

  s3 = [
    {
      bucket        = "example"
      force_destroy = true
    }
  ]

  lifecycle_s3 = [
    {
      rule_id         = "example"
      bucket_name_key = "example" ## é o nome do bucket
      
      filter = [
        {
          prefix = "log/"
        }
      ]

      expiration = [
        {
          days = 16
        }
      ]
      transition = [
        {
          days          = 10
          storage_class = "STANDARD_IA"
        },
        {
          days          = 15
          storage_class = "GLACIER"
        }
      ]
      status_lifecycle = "Enabled"
    }
  ]

  roles = [
    {
      role_name       = "example"
      string          = "StringEquals"
      namespace       = "monitoring" ## Namespace k8s
      serviceaccount  = "example" ## Nome service account 
      bucket_name_key = "example" ## é o nome do bucket
    }
  ]

  environment = "prd"

  tags = {
    Environment = "prd"
  }

}
```

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_openid_connect_provider) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster Name para inclusao de oidc nas roles | `string` | `""` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Env tags | `string` | `""` | no |
| <a name="input_lifecycle_s3"></a> [lifecycle\_s3](#input\_lifecycle\_s3) | Lista de regras de ciclo de vida para os buckets S3 | <pre>list(object({<br>    rule_id          = string<br>    bucket_name_key  = string<br>    status_lifecycle = string<br>    abort_incomplete_multipart_upload = list(object({<br>      days_after_initiation = number<br>    }))<br>    expiration = list(object({<br>      days = number<br>      date = optional(string)<br>    }))<br>    transition = optional(list(object({<br>      days          = number<br>      storage_class = string<br>    })))<br>    noncurrent_version_transition = optional(list(object({<br>      noncurrent_days = number<br>      storage_class   = string<br>    })))<br>    filter = optional(list(object({<br>      prefix                   = string<br>      object_size_greater_than = number<br>      object_size_less_than    = number<br>    })))<br>    noncurrent_version_expiration = optional(list(object({<br>      noncurrent_days = number<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_roles"></a> [roles](#input\_roles) | Lista de roles para acesso aos buckets S3 | <pre>list(object({<br>    role_name       = string<br>    bucket_name_key = string<br>    string          = string<br>    namespace       = string<br>    serviceaccount  = string<br>  }))</pre> | `[]` | no |
| <a name="input_s3"></a> [s3](#input\_s3) | Lista de buckets S3 | <pre>list(object({<br>    bucket        = string<br>    force_destroy = bool<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket-arn"></a> [bucket-arn](#output\_bucket-arn) | The ARN of the bucket |
| <a name="output_bucket-name"></a> [bucket-name](#output\_bucket-name) | The name bucket |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | Output IAM role ARNs |
