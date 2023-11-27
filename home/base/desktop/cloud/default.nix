{
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    # general tools
    pulumi
    pulumictl
    # istioctl

    # aws
    awscli2
    aws-iam-authenticator
    eksctl

    # aliyun
    aliyun-cli
   ];

  programs = {
  };
}
