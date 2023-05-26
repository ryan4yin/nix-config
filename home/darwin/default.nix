{pkgs, ...}: 
{
  home.packages = with pkgs; [
    docker-compose
    kubectl
    kubernetes-helm
    terraform
    pulumi
  ];
}