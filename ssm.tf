locals {
  ssm_output_value = { for key, value in local.vals_to_write : key => data.aws_ssm_parameter.read_kv_pair[key].value }
}

resource "aws_ssm_parameter" "write_kv_pair" {
  for_each = local.ssm_enabled ? local.vals_to_write : {}

  name  = each.key
  type  = each.value.sensitive ? "SecureString" : "String"
  value = each.value.value
}

data "aws_ssm_parameter" "read_kv_pair" {
  for_each = local.ssm_enabled ? local.vals_to_write : {}

  name = each.key
}
