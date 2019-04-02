locals {
  common_tags = {
    Tier         = "${var.bucket_tier}"
    Organization = "${var.bucket_organization}"
    Terraform    = "true"
  }

  bucket_compose_name = "${var.bucket_organization}-${var.bucket_name}-${var.bucket_region}-${var.bucket_tier}"

  policy_json = "${var.policy_json != "" ? 1 : 0}"
}

resource "aws_s3_bucket_policy" "bucket_no_encrypt" {
  count = "${var.is_encrypted ? 0 : var.policy_json}"

  bucket = "${aws_s3_bucket.bucket_no_encrypt.id}"
  policy = "${var.policy_json}"
}

resource "aws_s3_bucket_policy" "bucket_encrypt" {
  count = "${var.is_encrypted ? local.policy_json : 0}"

  bucket = "${aws_s3_bucket.bucket_encrypt.id}"
  policy = "${var.policy_json}"
}

resource "aws_s3_bucket" "bucket_no_encrypt" {
  count = "${var.is_encrypted ? 0 : 1}"

  bucket        = "${local.bucket_compose_name}"
  region        = "${var.bucket_region}"
  acl           = "${var.acl}"
  force_destroy = "${var.force_destroy}"

  lifecycle_rule {
    enabled = "${var.lifecycle_rule_is_enabled}"
    prefix  = "${var.prefix}"

    noncurrent_version_expiration {
      days = "${var.noncurrent_version_expiration_days}"
    }

    noncurrent_version_transition {
      days          = "${var.noncurrent_version_transition_days}"
      storage_class = "GLACIER"
    }

    transition {
      days          = "${var.standard_transition_days}"
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = "${var.expiration_days}"
    }
  }

  versioning {
    enabled = "${var.versioning_is_enabled}"
  }

  tags = "${merge(local.common_tags, var.tags, map("Name", local.bucket_compose_name))}"
}

resource "aws_s3_bucket" "bucket_encrypt" {
  count = "${var.is_encrypted ? 1 : 0}"

  bucket        = "${local.bucket_compose_name}"
  region        = "${var.bucket_region}"
  acl           = "${var.acl}"
  force_destroy = "${var.force_destroy}"

  lifecycle_rule {
    enabled = "${var.lifecycle_rule_is_enabled}"
    prefix  = "${var.prefix}"

    noncurrent_version_expiration {
      days = "${var.noncurrent_version_expiration_days}"
    }

    noncurrent_version_transition {
      days          = "${var.noncurrent_version_transition_days}"
      storage_class = "GLACIER"
    }

    transition {
      days          = "${var.standard_transition_days}"
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = "${var.expiration_days}"
    }
  }

  versioning {
    enabled = "${var.versioning_is_enabled}"
  }

  server_side_encryption_configuration {
    "rule" {
      "apply_server_side_encryption_by_default" {
        sse_algorithm     = "${var.sse_algorithm}"
        kms_master_key_id = "${var.kms_master_key_id}"
      }
    }
  }

  tags = "${merge(local.common_tags, var.tags, map("Name", local.bucket_compose_name))}"
}
