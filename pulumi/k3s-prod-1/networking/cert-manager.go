package networking

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/helm/v3"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func NewMonitoring(ctx *pulumi.Context, env string) error {
	_, err := helm.NewChart(ctx, "cert-manager", helm.ChartArgs{
		Chart:     pulumi.String("cert-manager"),
		Version:   pulumi.String("v1.14.2 "),
		Namespace: pulumi.String("cert-manager"),
		FetchArgs: helm.FetchArgs{
			Repo: pulumi.String("https://charts.jetstack.io"),
		},
		// https://cert-manager.io/docs/installation/helm/
		Values: pulumi.Map{},
	})

	return err
}
