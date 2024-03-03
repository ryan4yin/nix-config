# ========================================
# Install KubeVirt
# https://github.com/kubevirt/kubevirt/tree/main
# ========================================

export RELEASE=$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
echo "The latest kubevirt's version is $RELEASE"

curl -Lo kubevirt-operator-${RELEASE}.yaml https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-operator.yaml
curl -Lo kubevirt-cr-${RELEASE}.yaml https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-cr.yaml

# ========================================
# Install CDI(Containerized Data Importer)
# https://github.com/kubevirt/containerized-data-importer
# ========================================

export CDI_VERSION=$(curl -s https://api.github.com/repos/kubevirt/containerized-data-importer/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
echo "The latest CDI(Containerized Data Importer)'s version is $CDI_VERSION"

curl -Lo cdi-operator-${CDI_VERSION}.yaml https://github.com/kubevirt/containerized-data-importer/releases/download/$CDI_VERSION/cdi-operator.yaml
curl -Lo cdi-cr-${CDI_VERSION}.yaml https://github.com/kubevirt/containerized-data-importer/releases/download/$CDI_VERSION/cdi-cr.yaml

# ========================================
# Install Cluster Network Addons Operator
# https://github.com/kubevirt/cluster-network-addons-operator/tree/main?tab=readme-ov-file#deployment
# ========================================

export CNAO_VERSION=$(curl -s https://api.github.com/repos/kubevirt/cluster-network-addons-operator/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
echo "The latest Cluster Network Addons Operator's version is $CNAO_VERSION"

curl -Lo cluster-network-addons-namespace-${CNAO_VERSION}.yaml https://github.com/kubevirt/cluster-network-addons-operator/releases/download/${CNAO_VERSION}/namespace.yaml
curl -Lo cluster-network-addons-config.crd-${CNAO_VERSION}.yaml https://github.com/kubevirt/cluster-network-addons-operator/releases/download/${CNAO_VERSION}/network-addons-config.crd.yaml
curl -Lo cluster-network-addons-operator-${CNAO_VERSION}.yaml https://github.com/kubevirt/cluster-network-addons-operator/releases/download/${CNAO_VERSION}/operator.yaml
