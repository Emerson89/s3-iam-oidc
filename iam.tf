locals {
  policy_template = {
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket", "s3:GetBucketLocation"],
        Resource = null,
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload",
        ],
        Resource = null,
      },
    ],
  }
}


data "aws_eks_cluster" "this" {
  name = var.cluster_name
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "aws_iam_policy_document" "this" {
  for_each = length(var.roles) > 0 ? { for r in var.roles : r.role_name => r } : {}

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = each.value.string
      variable = "${replace("${data.aws_iam_openid_connect_provider.this.url}", "https://", "")}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.serviceaccount}"]
    }

    condition {
      test     = each.value.string
      variable = "${replace("${data.aws_iam_openid_connect_provider.this.url}", "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = ["${data.aws_iam_openid_connect_provider.this.arn}"]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "this" {
  for_each = length(var.roles) > 0 ? { for r in var.roles : r.role_name => r } : {}

  assume_role_policy = data.aws_iam_policy_document.this[each.key].json
  name               = each.value.role_name
}

resource "aws_iam_role_policy" "this" {
  for_each = length(var.roles) > 0 ? { for r in var.roles : r.role_name => r } : {}

  name = each.key
  role = aws_iam_role.this[each.key].id
  policy = jsonencode(
    merge(local.policy_template, {
      Statement = [
        {
          Effect = "Allow",
          Action = ["s3:ListBucket", "s3:GetBucketLocation"],
          Resource = [
            aws_s3_bucket.this[each.value.bucket_name_key].arn
          ],
        },
        {
          Effect = "Allow",
          Action = [
            "s3:PutObject",
            "s3:GetObject",
            "s3:DeleteObject",
            "s3:ListMultipartUploadParts",
            "s3:AbortMultipartUpload",
          ],
          Resource = [
            "${aws_s3_bucket.this[each.value.bucket_name_key].arn}/*"
          ],
        },
      ]
    })
  )
}

