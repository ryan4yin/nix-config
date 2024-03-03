from pulumi import ResourceOptions, FileAsset
import pulumi_kubernetes as kubernetes

from pathlib import Path


class NewVictoriaMetrics:
    NAMESPACE = "monitoring"

    def __init__(self, provider):
        self.provider = provider

        app_labels = {
            "app": "monitoring",
        }

        victoriaMetricsvaluesPath = (
            Path(__file__).parent / "victoria_metrics_helm_values.yml"
        )

        # Create a namespace (user supplies the name of the namespace)
        self.ns = kubernetes.core.v1.Namespace(
            "monitoring",
            metadata=kubernetes.meta.v1.ObjectMetaArgs(
                labels=app_labels,
                name=self.NAMESPACE,
            ),
            opts=ResourceOptions(
                provider=self.provider,
            ),
        )

        # https://github.com/VictoriaMetrics/helm-charts/tree/master/charts/victoria-metrics-k8s-stack
        self.victoriaMetrics = kubernetes.helm.v3.Release(
            "victoria-metrics-k8s-stack",
            chart="victoria-metrics-k8s-stack",
            namespace=self.ns.metadata.name,
            repository_opts=kubernetes.helm.v3.RepositoryOptsArgs(
                repo="https://victoriametrics.github.io/helm-charts/",
            ),
            version="0.19.2",
            skip_crds=False,
            atomic=True,  # purges chart on fail
            cleanup_on_fail=True,  # Allow deletion of new resources created in this upgrade when upgrade fails.
            dependency_update=True,  # run helm dependency update before installing the chart
            reset_values=True,  # When upgrading, reset the values to the ones built into the chart
            # verify=True, # verify the package before installing it
            # recreate_pods=True, # performs pods restart for the resource if applicable
            value_yaml_files=[FileAsset(victoriaMetricsvaluesPath)],
            opts=ResourceOptions(
                provider=self.provider,
            ),
        )
