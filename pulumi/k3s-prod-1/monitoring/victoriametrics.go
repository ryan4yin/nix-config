package monitoring

import (
	"github.com/pulumi/pulumi-kubernetes/sdk/v4/go/kubernetes/helm/v3"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

func NewMonitoring(ctx *pulumi.Context, env string) error {
	// https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-k8s-stack
	_, err := helm.NewChart(ctx, "victoria-metrics-k8s-stack", helm.ChartArgs{
		Chart:     pulumi.String("victoria-metrics-k8s-stack"),
		Version:   pulumi.String("0.19.0"),
		Namespace: pulumi.String("monitoring"),
		FetchArgs: helm.FetchArgs{
			Repo: pulumi.String("https://victoriametrics.github.io/helm-charts/"),
		},
		// https://github.com/VictoriaMetrics/helm-charts/blob/master/charts/victoria-metrics-k8s-stack/README.md
		Values: pulumi.Map{
			// grafana.ingress.enabled: true
			"ingress": pulumi.Map{
				"enabled": pulumi.Bool(true),
			},
			// grafana.defaultDashboardsTimezone: utc+8
			// grafana.ingress.hosts[0].host: grafana.example.com
			"grafana": pulumi.Map{
				"defaultDashboardsTimezone": pulumi.String("utc+8"),
				"ingress": pulumi.Map{
					"hosts": pulumi.Array{
						pulumi.Map{
							"host": pulumi.String("k8s-grafana.writefor.fun"),
						},
					},
				},
			},
			// prometheus-node-exporter.enabled: false
			"nodeExporter": pulumi.Map{
				"enabled": pulumi.Bool(false),
			},
			"vmsingle": pulumi.Map{
				"enabled": pulumi.Bool(true),
				"ingress": pulumi.Map{
					"hosts": pulumi.Array{
						pulumi.Map{
							"host": pulumi.String("vm.writefor.fun"),
						},
					},
				},
				// https://docs.victoriametrics.com/operator/api/#vmsinglespec
				"spec": pulumi.Map{
					"affinity": pulumi.Map{
						"nodeAffinity": pulumi.Map{
							"requiredDuringSchedulingIgnoredDuringExecution": pulumi.Map{
								"nodeSelectorTerms": pulumi.Array{
									pulumi.Map{
										"matchExpressions": pulumi.Array{
											pulumi.Map{
												"key":      pulumi.String("kubernetes.io/arch"),
												"operator": pulumi.String("In"),
												"values": pulumi.Array{
													pulumi.String("amd64"),
												},
											},
										},
									},
								},
							},
						},
					},
					"storage": pulumi.Map{
						"resources": pulumi.Map{
							"requests": pulumi.Map{
								"storage": pulumi.String("50Gi"),
							},
						},
					},
				},
			},
		},
	})
	return err
}
