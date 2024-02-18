package main

import (
	"k3s-prod-1/monitoring"
	"k3s-prod-1/networking"

	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func main() {
	pulumi.Run(func(ctx *pulumi.Context) error {
		if err := monitoring.NewMonitoring(ctx, "prod"); err != nil {
			return err
		}
		if err := networking.NewNetworking(ctx, "prod"); err != nil {
			return err
		}

		return nil
	})
}
