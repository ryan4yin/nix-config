import pulumi
from pulumi_kubernetes.core.v1 import Namespace
from pulumi_kubernetes_cert_manager import CertManager, ReleaseArgs

ns_name = "cert-manager"
ns = Namespace("cert-manager", metadata={"name": ns_name})

# Install cert-manager into our cluster.
manager = CertManager(
    "cert-manager",
    install_crds=True,
    helm_options=ReleaseArgs(
        namespace=ns_name,
    ),
)
