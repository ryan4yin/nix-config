{
  lib,
  pkgs,
  pkgs-stable,
  ...
}:
{
  # https://developer.hashicorp.com/terraform/cli/config/config-file
  home.file.".terraformrc".source = ./terraformrc;

  home.packages = with pkgs; [
    # infrastructure as code
    # pulumi
    # pulumictl
    # tf2pulumi
    # crd2pulumi
    # pulumiPackages.pulumi-random
    # pulumiPackages.pulumi-command
    # pulumiPackages.pulumi-aws-native
    # pulumiPackages.pulumi-language-go
    # pulumiPackages.pulumi-language-python
    # pulumiPackages.pulumi-language-nodejs

    # doctl # digitalocean
    aliyun-cli
    # aws
    awscli2
    aws-iam-authenticator

    # google cloud
    (pkgs-stable.google-cloud-sdk.withExtraComponents (
      with pkgs-stable.google-cloud-sdk.components;
      [
        gke-gcloud-auth-plugin
      ]
    ))
    google-alloydb-auth-proxy

    # cloud tools that nix do not have cache for.
    terraform
  ];
}
