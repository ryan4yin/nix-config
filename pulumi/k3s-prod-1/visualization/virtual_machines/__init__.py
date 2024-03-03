from pulumi import ResourceOptions
from pulumi_kubernetes.yaml import ConfigGroup

from pathlib import Path

from ..kubevirt import NewKubeVirt


class NewVirtualMachines:
    CURRENT_DIR = Path(__file__).parent
    CURRENT_DIR_STR = CURRENT_DIR.as_posix()

    def __init__(self, provider, kubevirt: NewKubeVirt):
        self.provider = provider

        self.kubevirt = ConfigGroup(
            "virtual-machines",
            files=[self.CURRENT_DIR_STR + "/yaml/*.yaml"],
            opts=ResourceOptions(
                provider=self.provider, depends_on=kubevirt.resouces()
            ),
        )
