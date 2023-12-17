{pkgs, ...}: {
  home.packages = with pkgs;
    [
      # general tools
      pulumi
      pulumictl
      # istioctl

      # aws
      awscli2
      ssm-session-manager-plugin # Amazon SSM Session Manager Plugin
      aws-iam-authenticator
      eksctl
      istioctl

      # aliyun
      aliyun-cli
    ]
    ++ (
      if pkgs.stdenv.isLinux
      then [
        # cloud tools that nix do not have cache for.
        terraform
        terraformer # generate terraform configs from existing cloud resources
      ]
      else []
    );
}
