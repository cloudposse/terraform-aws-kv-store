locals {
  // Build a map of key-value pairs to write to the key/value store with a shape of:
  // key = { sensitive = bool, value = string }
  //
  // where the key is the specified key_path or, if not specified, a constructed key path from the context, which also
  // allows namespace, tenant, stage, environment, name and attributes to be overridden and joins the
  vals_to_write = module.this.enabled ? ({ for key, value in var.set :
    coalesce(
      var.set[key]["key_path"],
    join("/", concat([var.key_prefix], compact(flatten([for label in var.key_label_order : [try(coalesce(var.set[key][label], module.this[label]), "")]]))), [key])) => { sensitive = value.sensitive, value = value.value }
  }) : {}

  // Build a map of keys to read from the key/value store and the key they should be output to, with a shape of: { output_key_name = key_path_to_read_from }
  vals_to_read = module.this.enabled ? ({
    for key, value in var.get :
  key => coalesce(var.get[key]["key_path"], join("/", concat([var.key_prefix], compact(flatten([for label in var.key_label_order : [try(coalesce(var.get[key][label], module.this[label]), "")]])), [key]))) }) : {}

  vals_to_read_by_path = module.this.enabled ? ({
    for key, value in var.get_by_path :
  key => coalesce(var.get_by_path[key]["key_path"], join("/", concat([var.key_prefix], compact(flatten([for label in var.key_label_order : [try(coalesce(var.get[key][label], module.this[label]), "")]])), [key]))) }) : {}

  ssm_enabled = module.this.enabled && var.ssm_enabled
}




