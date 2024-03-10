# Disko Config

Generate LUKS keyfile to encrypt the root partition, it's used by disko.

```bash
# partition the usb stick
parted /dev/sdb -- mklabel gpt
parted /dev/sdb -- mkpart primary 2M 512MB
parted /dev/sdb -- mkpart primary 512MB 1024MB
mkfs.fat -F 32 -n NIXOS_DSC /dev/sdb1
mkfs.fat -F 32 -n NIXOS_K3S /dev/sdb2

# Generate a keyfile from the true random number generator
KEYFILE=./kubevirt-luks-keyfile
dd bs=8192 count=4 iflag=fullblock if=/dev/random of=$KEYFILE

# generate token for k3s
K3S_TOKEN_FILE=./kubevirt-k3s-token
K3S_TOKEN=$(grep -ao '[A-Za-z0-9]' < /dev/random | head -64 | tr -d '\n' ; echo "")
echo $K3S_TOKEN > $K3S_TOKEN_FILE

# copy the keyfile and token to the usb stick

KEYFILE=./kubevirt-luks-keyfile
DEVICE=/dev/disk/by-label/NIXOS_DSC
dd bs=8192 count=4 iflag=fullblock if=$KEYFILE of=$DEVICE

K3S_TOKEN_FILE=./kubevirt-k3s-token
USB_PATH=/run/media/ryan/NIXOS_K3S
cp $K3S_TOKEN_FILE $USB_PATH
```


