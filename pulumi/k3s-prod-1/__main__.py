import pulumi
import pulumi_kubernetes as kubernetes


from monitoring import *
from networking import *
from visualization import *


provider = kubernetes.Provider(
    "k3s-prod-1",
    # The name of the kubeconfig context to use
    context="default",
    # Disable server-side apply to make the cluster more reproducible.
    # It will(TODO: not sure) discard any server-side changes to resources when set to false.
    enable_server_side_apply=False,
)

# networking
new_cert_manager = NewCertManager(provider)

# monitoring
new_victoria_metrics = NewVictoriaMetrics(provider)

# visualization
new_kubevirt = NewKubeVirt(provider)
new_virtual_machines = NewVirtualMachines(provider, new_kubevirt)


