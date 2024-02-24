export RELEASE=$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
echo "The latest kubevirt's version is $RELEASE"

curl -Lo kubevirt-operator-${RELEASE}.yaml https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-operator.yaml
curl -Lo kubevirt-cr-${RELEASE}.yaml https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-cr.yaml
