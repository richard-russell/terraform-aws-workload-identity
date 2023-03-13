## REQUIRED VARIABLES

variable "organization_name" {
  type = string
  description = "Organization name you want to build this within."
}

variable "workspace_name" {
  type = string
  description = "Name you would like to give the workspace"
}

variable "project_id" {
  type = string
  description = "If wanting to build within a specific project, please add the project_id here and then fill in the project_name variable accordingly"
}

## OPTIONAL VARIABLES

variable "host_name" {
  type = string
  description = "Host name of the TFE/TFC instance, defaults to the TFCB hostname of app.terraform.io"
  default = "app.terraform.io"
}

variable "project_name" {
  type = string
  description = "Project you want to build the workspace within, defaults to the Default Project within any Organization"
  default = "Default Project"
}