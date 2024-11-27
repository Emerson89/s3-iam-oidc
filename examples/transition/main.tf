module "s3" {

  source = "github.com/Emerson89/s3-iam-oidc-terraform.git?ref=main"

  cluster_name = "cluster-name"

  s3 = [
    {
      bucket        = "example"
      force_destroy = true
    }
  ]

  lifecycle_s3 = [
    {
      rule_id         = "example"
      bucket_name_key = "example"

      expiration = [
        {
          days = 61
        }
      ]
      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        }
      ]
      abort_incomplete_multipart_upload = [
        {
          days_after_initiation = 1
        }
      ]
      status_lifecycle = "Enabled"
    }
  ]

  roles = [
    {
      role_name       = "example"
      string          = "StringEquals"
      namespace       = "monitoring"
      serviceaccount  = "example"
      bucket_name_key = "example"
    }
  ]

  environment = "prd"

  tags = {
    Environment = "prd"
  }

}
