def main [config_file: path, yq: path] {
  mkdir ($config_file | path dirname)

  if not ($config_file | path exists) {
    touch $config_file
  }

  ^$yq eval --inplace --input-format toml --output-format toml (
    '.analytics.enabled = false | ' +
    '.feedback.enabled = false | ' +
    '.check_for_update_on_startup = false'
  ) $config_file
}
