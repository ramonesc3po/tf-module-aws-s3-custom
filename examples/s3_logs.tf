data "aws_iam_policy_document" "bucket_logs" {
  "statement" {
    principals {
      identifiers = ["*"]
      type = "*"
    }

    actions = [
      "s3:Get*"
    ]

    resources = [
      "*"
    ]
  }
}

module "bucket_logs" {
  source = "../"
  bucket_name         = "artifacts"
  bucket_region       = "us-east-1"
  bucket_tier         = "production"
  bucket_organization = "zigzaga"

  policy_json = "${data.aws_iam_policy_document.bucket_logs.json}"

  versioning_is_enabled = "true"

  lifecycle_rule_is_enabled = "true"
}

output "name_bucket_artifacts" {
  value = "${module.bucket_logs.name_bucket}"
}

output "domain_name_bucket_artifacts" {
  value = "${module.bucket_logs.domain_name_bucket}"
}

output "arn_bucket_artifacts" {
  value = "${module.bucket_logs.arn_bucket}"
}

output "id_bucket_artifacts" {
  value = "${module.bucket_logs.id_bucket}"
}
