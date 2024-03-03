from pulumi import ResourceOptions
from pulumi_kubernetes.yaml import ConfigGroup

from pathlib import Path


class NewKubeVirt:
    CURRENT_DIR = Path(__file__).parent
    CURRENT_DIR_STR = CURRENT_DIR.as_posix()

    def __init__(self, provider):
        self.provider = provider

        self.kubevirt = ConfigGroup(
            "kubevirt",
            files=[
                self.CURRENT_DIR_STR + "/yaml/kubevirt-operator.yaml",
            ],
            opts=ResourceOptions(provider=self.provider),
        )

        self.kubevirt_cr = ConfigGroup(
            "kubevirt-cr",
            files=[
                self.CURRENT_DIR_STR + "/yaml/custom-kubevirt-*.yaml",
            ],
            opts=ResourceOptions(
                provider=self.provider,
                depends_on=[self.kubevirt],
            ),
        )

        self.containerDataImporter = ConfigGroup(
            "container-data-importer",
            files=[self.CURRENT_DIR_STR + "/yaml/cdi-*.yaml"],
            opts=ResourceOptions(
                provider=self.provider,
                depends_on=[self.kubevirt, self.kubevirt_cr],
            ),
        )

        self.clusterNetworkAddonsOperator = ConfigGroup(
            "cluster-network-addons-operator",
            files=[
                self.CURRENT_DIR_STR + "/yaml/cluster-network-addons-*.yaml",
            ],
            opts=ResourceOptions(
                provider=self.provider,
                depends_on=[self.kubevirt, self.kubevirt_cr],
            ),
        )

        self.clusterNetworkAddons = ConfigGroup(
            "cluster-network-addons",
            files=[
                self.CURRENT_DIR_STR + "/yaml/custom-networkaddons-*.yaml",
            ],
            opts=ResourceOptions(
                provider=self.provider,
                depends_on=[
                    self.kubevirt,
                    self.kubevirt_cr,
                    self.clusterNetworkAddonsOperator,
                ],
            ),
        )

    def resouces(self):
        return [
            self.kubevirt,
            self.kubevirt_cr,
            self.containerDataImporter,
            self.clusterNetworkAddonsOperator,
            self.clusterNetworkAddons,
        ]
