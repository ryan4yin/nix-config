from pulumi import ResourceOptions
from pulumi_kubernetes.core.v1 import Namespace
from pulumi_kubernetes_cert_manager import CertManager, ReleaseArgs


class NewCertManager:
    NAMESPACE = "cert-manager"

    def __init__(self, provider):
        self.provider = provider

        self.ns = Namespace(
            "cert-manager",
            metadata={"name": self.NAMESPACE},
            opts=ResourceOptions(
                provider=self.provider,
            ),
        )

        # Install cert-manager into our cluster.
        self.manager = CertManager(
            "cert-manager",
            install_crds=True,
            helm_options=ReleaseArgs(
                namespace=self.NAMESPACE,
            ),
            opts=ResourceOptions(
                provider=self.provider,
            ),
        )
