resource "aws_s3_bucket" "this" {
  for_each = { for r in var.s3 : r.bucket => r }

  bucket_prefix = "${each.value.bucket}-"
  force_destroy = each.value.force_destroy

  tags = merge(
    {
      "Name"        = each.key
      "Platform"    = "Storage"
      "Type"        = "S3"
      "Environment" = var.environment
      "Manager"     = "terraform"
    },
    var.tags,
  )
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = length(var.lifecycle_s3) > 0 ? { for r in var.lifecycle_s3 : r.rule_id => r } : {}

  bucket = aws_s3_bucket.this[each.value.bucket_name_key].id

  rule {
    id = each.value.rule_id

    dynamic "abort_incomplete_multipart_upload" {
      for_each = lookup(each.value, "abort_incomplete_multipart_upload", []) != null ? lookup(each.value, "abort_incomplete_multipart_upload", []) : []

      content {
        days_after_initiation = lookup(abort_incomplete_multipart_upload.value, "days_after_initiation", null)
      }
    }

    dynamic "expiration" {
      for_each = each.value.expiration
      content {
        days = lookup(expiration.value, "days", null)
        date = lookup(expiration.value, "date", null)
      }

    }

    dynamic "transition" {
      for_each = lookup(each.value, "transition", []) != null ? lookup(each.value, "transition", []) : []

      content {
        days          = lookup(transition.value, "days", null)
        storage_class = lookup(transition.value, "storage_class", null)
      }
    }

    dynamic "noncurrent_version_transition" {
      for_each = lookup(each.value, "noncurrent_version_transition", []) != null ? lookup(each.value, "noncurrent_version_transition", []) : []

      content {
        noncurrent_days = lookup(noncurrent_version_transition.value, "noncurrent_days", null)
        storage_class   = lookup(noncurrent_version_transition.value, "storage_class", null)
      }
    }

    dynamic "filter" {
      for_each = lookup(each.value, "filter", []) != null ? lookup(each.value, "filter", []) : []
      content {
        prefix                   = lookup(filter.value, "prefix", "")
        object_size_greater_than = lookup(filter.value, "object_size_greater_than", null)
        object_size_less_than    = lookup(filter.value, "object_size_less_than", null)
      }

    }

    dynamic "noncurrent_version_expiration" {
      for_each = lookup(each.value, "noncurrent_version_expiration", []) != null ? lookup(each.value, "noncurrent_version_expiration", []) : []

      content {
        noncurrent_days = lookup(noncurrent_version_expiration.value, "noncurrent_days", null)
      }
    }

    status = each.value.status_lifecycle
  }
}
