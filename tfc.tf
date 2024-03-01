data "tfe_organization" "organization" {
  name = var.organization_name
}

data "tfe_workspace_ids" "dynamic_cred_ws" {
  tag_names    = ["aws_dyn_creds"]
  organization = data.tfe_organization.organization.name
}

resource "tfe_workspace_variable_set" "share_dc_vars" {
  for_each = data.tfe_workspace_ids.dynamic_cred_ws.ids
  variable_set_id = tfe_variable_set.dynamic_creds.id
  workspace_id    = each.value
}

resource "tfe_variable_set" "dynamic_creds" {
  name         = "aws_dynamic_cred_settings"
  description  = "Workspace vars needed for dynamic credentials"
  organization = data.tfe_organization.organization.name
}

resource "tfe_variable" "tfc_aws_provider_auth" {
  key      = "TFC_AWS_PROVIDER_AUTH"
  value    = "true"
  category = "env"
  # workspace_id = tfe_workspace.workspace.id
  variable_set_id = tfe_variable_set.dynamic_creds.id
  sensitive       = false
}

resource "tfe_variable" "tfc_aws_workload_identity_audience" {
  key      = "TFC_AWS_WORKLOAD_IDENTITY_AUDIENCE"
  value    = local.workload_identity_audience
  category = "env"
  # workspace_id = tfe_workspace.workspace.id
  variable_set_id = tfe_variable_set.dynamic_creds.id
  sensitive       = false
}

resource "tfe_variable" "tfc_aws_run_role_arn" {
  key      = "TFC_AWS_RUN_ROLE_ARN"
  value    = aws_iam_role.tfc_role.arn
  category = "env"
  # workspace_id = tfe_workspace.workspace.id
  variable_set_id = tfe_variable_set.dynamic_creds.id
  sensitive       = false
}

