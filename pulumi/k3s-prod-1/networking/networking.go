package networking

import (
	corev1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/core/v1"
	metav1 "github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/meta/v1"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func NewNetworking(ctx *pulumi.Context, env string) error {
	// Create a Kubernetes Namespace
	namespaceName := "networking"
	namespace, err := corev1.NewNamespace(ctx, namespaceName, &corev1.NamespaceArgs{
		Metadata: &metav1.ObjectMetaArgs{
			Name: pulumi.String(namespaceName),
		},
	})
	if err != nil {
		return err
	}

	// Export the name of the namespace
	ctx.Export("networkingNamespaceName", namespace.Metadata.Name())

	if err := NewCertManager(ctx, env, namespace); err != nil {
		return err
	}
	return nil
}
