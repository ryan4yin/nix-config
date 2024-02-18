package monitoring

import (
	v1 "github.com/pulumi/pulumi-kubernetes/sdk/go/kubernetes/core/v1"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func NewMonitoring(ctx *pulumi.Context, env string) error {
	// Create a Kubernetes Namespace
	namespaceName := "monitoring"
	namespace, err := v1.NewNamespace(ctx, namespaceName, &v1.NamespaceArgs{
		Metadata: &v1.ObjectMetaArgs{
			Name: pulumi.String(namespaceName),
		},
	})
	if err != nil {
		return err
	}

	// Export the name of the namespace
	ctx.Export("monitoringNamespaceName", namespace.Metadata.Name())

	if err := NewVictoriaMetrics(ctx, env); err != nil {
		return err
	}
	return nil
}
