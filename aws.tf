locals {
  workload_identity_audience = "aws.workload.identity"
}

data "aws_caller_identity" "current" {}

data "tls_certificate" "tfc_certificate" {
  url = "https://${var.host_name}"
}

resource "aws_iam_openid_connect_provider" "tfc_provider" {
  url             = "https://${var.host_name}"
  client_id_list  = [local.workload_identity_audience]
  thumbprint_list = ["${data.tls_certificate.tfc_certificate.certificates.0.sha1_fingerprint}"]
}

data "aws_iam_policy_document" "tfc_role_trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.tfc_provider.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.host_name}:aud"
      values   = [local.workload_identity_audience]
    }

    condition {
      test     = "StringLike"
      variable = "${var.host_name}:sub"
      values = [
        "organization:${data.tfe_organization.organization.name}:project:*:workspace:*:run_phase:*",
        "organization:${data.tfe_organization.organization.id}:project:*:stack:*:deployment:*:operation:*",
      ]
    }
  }
}

resource "aws_iam_role" "tfc_role" {
  name               = "tfc-workload-identity-${var.organization_name}"
  assume_role_policy = data.aws_iam_policy_document.tfc_role_trust_policy.json
}

output "audience" {
  value = local.workload_identity_audience
}

output "role_arn" {
  value = aws_iam_role.tfc_role.arn
}
