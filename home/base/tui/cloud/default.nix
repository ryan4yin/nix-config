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
    # doctl # digitalocean
    aliyun-cli
    # aws
    awscli2
    # ssm-session-manager-plugin # Amazon SSM Session Manager Plugin
    aws-iam-authenticator
    # eksctl

    # google cloud
    (pkgs-stable.google-cloud-sdk.withExtraComponents (
      with pkgs-stable.google-cloud-sdk.components;
      [
        gke-gcloud-auth-plugin
      ]
    ))
    # google-cloud-sql-proxy
    google-alloydb-auth-proxy

    # cloud tools that nix do not have cache for.
    terraform
    # terraformer # generate terraform configs from existing cloud resources
    # packer # machine image builder
  ];
}
