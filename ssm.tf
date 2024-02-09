locals {
  ssm_get_output         = { for key, value in local.vals_to_read : key => nonsensitive(data.aws_ssm_parameter.read_kv_pair[key].value) }
  ssm_get_by_path_output = { for key, value in local.vals_to_read_by_path : key => nonsensitive(zipmap(data.aws_ssm_parameters_by_path.read_kv_paths[key].names, data.aws_ssm_parameters_by_path.read_kv_paths[key].values)) }
  ssm_output             = merge(local.ssm_get_output, local.ssm_get_by_path_output)

}

resource "aws_ssm_parameter" "write_kv_pair" {
  for_each = local.ssm_enabled ? local.vals_to_write : {}

  name  = each.key
  type  = each.value.sensitive ? "SecureString" : "String"
  value = each.value.value
}

data "aws_ssm_parameter" "read_kv_pair" {
  for_each = local.ssm_enabled ? local.vals_to_read : {}

  name = each.value
}

data "aws_ssm_parameters_by_path" "read_kv_paths" {
  for_each = local.ssm_enabled ? local.vals_to_read_by_path : {}

  path      = each.value
  recursive = true
}
