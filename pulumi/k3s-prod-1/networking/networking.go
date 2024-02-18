package networking

import (
	v1 "github.com/pulumi/pulumi-kubernetes/sdk/go/kubernetes/core/v1"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func NewNetworking(ctx *pulumi.Context, env string) error {
	// Create a Kubernetes Namespace
	namespaceName := "networking"
	namespace, err := v1.NewNamespace(ctx, namespaceName, &v1.NamespaceArgs{
		Metadata: &v1.ObjectMetaArgs{
			Name: pulumi.String(namespaceName),
		},
	})
	if err != nil {
		return err
	}

	// Export the name of the namespace
	ctx.Export("networkingNamespaceName", namespace.Metadata.Name())

	if err := NewCertManager(ctx, env); err != nil {
		return err
	}
	return nil
}
