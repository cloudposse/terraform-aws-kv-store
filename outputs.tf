// We are using coalesce here to return the first non-null backend output. In the future we plan to add support for
// other backends such as s3, dynamodb, etc. and only one of them will be enabled at a time.
output "values" {
  value = module.this.enabled ? coalesce(local.ssm_output_value) : {}
}
