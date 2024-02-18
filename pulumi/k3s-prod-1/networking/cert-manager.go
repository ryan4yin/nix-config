package networking

import (
	corev1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/core/v1"
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/helm/v3"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func NewCertManager(ctx *pulumi.Context, env string, namespace corev1.Namespace) error {
	var opts []pulumi.ResourceOption
	opts = append(opts, pulumi.DependsOn([]pulumi.Resource{namespace}))

	_, err := helm.NewChart(ctx, "cert-manager", helm.ChartArgs{
		Chart:     pulumi.String("cert-manager"),
		Version:   pulumi.String("corev1.14.2 "),
		Namespace: pulumi.String(namespace.Metadata.Name()),
		FetchArgs: helm.FetchArgs{
			Repo: pulumi.String("https://charts.jetstack.io"),
		},
		// https://cert-manager.io/docs/installation/helm/
		Values: pulumi.Map{},
	}, opts...)

	return err
}
