from pulumi_kubernetes.yaml import ConfigGroup

from pathlib import Path

currentDir = Path(__file__).parent

kubevirt = ConfigGroup(
    "virtual-machines",
    files=[currentDir.as_posix() + "/yaml/*.yaml"],
)
