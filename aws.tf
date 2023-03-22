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
        "organization:${data.tfe_organization.organization.name}:project:*:workspace:*:run_phase:plan",
        "organization:${data.tfe_organization.organization.name}:project:*:workspace:*:run_phase:apply",
      ]
    }
  }
}

resource "aws_iam_role" "tfc_role" {
  name               = "tfc-workload-identity-${var.organization_name}"
  assume_role_policy = data.aws_iam_policy_document.tfc_role_trust_policy.json
}

resource "aws_iam_policy" "PowerUserAccess" {
  name        = "tfc-PowerUserAccess"
  description = "TFC run policy - PowerUserAccess"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "PowerUserAccess",
            "NotAction": [
                "account:*",
                "iam:*",
                "organizations:*",
                "rolesanywhere:*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tfc_policy_attachment" {
  role       = aws_iam_role.tfc_role.name
  policy_arn = aws_iam_policy.PowerUserAccess.arn
}

resource "aws_iam_policy" "AllowMutateIAM" {
  name        = "tfc-AllowMutateIAM"
  description = "TFC run policy - AllowMutateIAM"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "AllowIAM",
            "Action": [
                "iam:AttachRolePolicy",
                "iam:CreateRole",
                "iam:DeleteRole",
                "iam:DeleteRolePolicy",
                "iam:DetachRolePolicy",
                "iam:PutRolePolicy",
                "iam:UpdateAssumeRolePolicy",
                "iam:UpdateRole",
                "iam:UpdateRoleDescription",
                "iam:PassRole",
                "iam:TagRole",
                "iam:UntagRole",
                "iam:AddRoleToInstanceProfile",
                "iam:CreateInstanceProfile",
                "iam:DeleteInstanceProfile",
                "iam:RemoveRoleFromInstanceProfile",
                "iam:TagInstanceProfile",
                "iam:UntagInstanceProfile",
                "iam:CreateAccessKey",
                "iam:DeleteAccessKey",
                "iam:UpdateAccessKey",
                "iam:CreateVirtualMFADevice",
                "iam:EnableMFADevice",
                "iam:DeactivateMFADevice",
                "iam:DeleteVirtualMFADevice",
                "iam:ResyncMFADevice",
                "iam:DeleteUserPolicy",
                "iam:PutUserPolicy",
                "iam:GenerateOrganizationsAccessReport",
                "iam:CreateServiceLinkedRole",
                "iam:DeleteServiceLinkedRole",
                "iam:UpdateServerCertificate",
                "iam:UploadServerCertificate",
                "iam:DeleteServerCertificate",
                "rolesanywhere:Delete*",
                "rolesanywhere:Disable*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tfc_AllowMutateIAM" {
  role       = aws_iam_role.tfc_role.name
  policy_arn = aws_iam_policy.AllowMutateIAM.arn
}

resource "aws_iam_policy" "AllowMutateIAMPoliciesAndPassword" {
  name        = "tfc-AllowMutateIAMPoliciesAndPassword"
  description = "TFC run policy - AllowMutateIAMPoliciesAndPassword"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "PoliciesAndPassword",
            "Action": [
                "iam:ChangePassword",
                "iam:DeleteLoginProfile",
                "iam:CreatePolicy",
                "iam:CreatePolicyVersion",
                "iam:DeletePolicy",
                "iam:DeletePolicyVersion",
                "iam:TagPolicy",
                "iam:UntagPolicy"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tfc_AllowMutateIAMPoliciesAndPassword" {
  role       = aws_iam_role.tfc_role.name
  policy_arn = aws_iam_policy.AllowMutateIAMPoliciesAndPassword.arn
}

resource "aws_iam_policy" "IAMAndOrgReadOnlyAccess" {
  name        = "tfc-IAMAndOrgReadOnlyAccess"
  description = "TFC run policy - IAMAndOrgReadOnlyAccess"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Resource": "*",
            "Sid": "ReadOnly",
            "Action": [
                "rolesanywhere:Get*",
                "rolesanywhere:List*",
                "organizations:Describe*",
                "organizations:List*",
                "iam:Generate*",
                "iam:Get*",
                "iam:List*",
                "iam:Simulate*",
                "account:ListRegions"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "tfc_IAMAndOrgReadOnlyAccess" {
  role       = aws_iam_role.tfc_role.name
  policy_arn = aws_iam_policy.IAMAndOrgReadOnlyAccess.arn
}

