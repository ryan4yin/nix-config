{
  pkgs,
  pkgs-unstable,
  ...
}: {
  home.packages = with pkgs; [
    # general tools
    terraform
    # terraformer # generate terraform configs from existing cloud resources
    pulumi
    pulumictl
    # istioctl

    # aws
    awscli2
    aws-iam-authenticator
    eksctl
   ];

  programs = {
  };
}
