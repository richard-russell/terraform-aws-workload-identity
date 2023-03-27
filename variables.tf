## REQUIRED VARIABLES
variable "aws_region" {
  type = string
}

variable "aws_default_tags" {
}

variable "organization_name" {
  type = string
  description = "Organization name you want to build this within."
}

## OPTIONAL VARIABLES

variable "host_name" {
  type = string
  description = "Host name of the TFE/TFC instance, defaults to the TFCB hostname of app.terraform.io"
  default = "app.terraform.io"
}
