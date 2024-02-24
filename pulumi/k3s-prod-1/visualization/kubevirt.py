from pulumi_kubernetes.yaml import ConfigGroup

from pathlib import Path

currentDir = Path(__file__).parent


def virtHandlerNodePlacement(obj, opts):
    if obj["kind"] == "KubeVirt":
        obj["spec"]["workloads"] = {
            "nodePlacement": {
                "nodeSelector": {"node-type": "worker"}
            }
        }


kubevirt = ConfigGroup(
    "kubevirt",
    files=[currentDir.as_posix() + "/yaml/*.yaml"],
    # A set of transformations to apply to Kubernetes resource definitions before registering with engine.
    transformations=[virtHandlerNodePlacement],
)
