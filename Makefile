#
#  NOTE: Makefile's target name should not be the same as one of the file or directory in the current directory, 
#    otherwise the target will not be executed!
#


############################################################################
#
#  Nix commands related to the local machine
#
############################################################################

i3: 
	nixos-rebuild switch --flake .#ai_i3 --use-remote-sudo

hyprland:
	nixos-rebuild switch --flake .#ai_hyprland --use-remote-sudo

debug_i3:
	nixos-rebuild switch --flake .#ai_i3 --use-remote-sudo --show-trace --verbose

debug_hyprland:
	nixos-rebuild switch --flake .#ai_hyprland --use-remote-sudo --show-trace --verbose

update:
	nix flake update

history:
	nix profile history --profile /nix/var/nix/profiles/system

gc:
	# remove all generations older than 7 days
	sudo nix profile wipe-history --profile /nix/var/nix/profiles/system  --older-than 7d

	# garbage collect all unused nix store entries
	sudo nix store gc --debug

# adjust brightness(x11)
# usage: make bright b=0.9
bright:
	xrandr --output DP-2 --brightness $(b)

############################################################################
#
#  Darwin related commands, harmonica is my macbook pro's hostname
#
############################################################################

darwin-set-proxy:
	sudo python3 scripts/darwin_set_proxy.py

darwin: darwin-set-proxy
	nix build .#darwinConfigurations.harmonica.system
	./result/sw/bin/darwin-rebuild switch --flake .

darwin-debug: darwin-set-proxy
	nix build .#darwinConfigurations.harmonica.system --show-trace --verbose
	./result/sw/bin/darwin-rebuild switch --flake .#harmonica --show-trace --verbose


############################################################################
#
#  Idols, Commands related to my remote distributed building cluster
#
############################################################################


add-idols-ssh-key:
	ssh-add ~/.ssh/ai-idols

aqua: add-idols-ssh-key
	nixos-rebuild --flake .#aquamarine --target-host aquamarine --build-host aquamarine switch --use-remote-sudo

aqua-debug: add-idols-ssh-key
	nixos-rebuild --flake .#aquamarine --target-host aquamarine --build-host aquamarine switch --use-remote-sudo --show-trace --verbose

ruby: add-idols-ssh-key
	nixos-rebuild --flake .#ruby --target-host ruby --build-host ruby switch --use-remote-sudo

ruby-debug: add-idols-ssh-key
	nixos-rebuild --flake .#ruby --target-host ruby --build-host ruby switch --use-remote-sudo --show-trace --verbose

kana: add-idols-ssh-key
	nixos-rebuild --flake .#kana --target-host kana --build-host kana switch --use-remote-sudo

kana-debug: add-idols-ssh-key
	nixos-rebuild --flake .#kana --target-host kana --build-host kana switch --use-remote-sudo --show-trace --verbose

idols: aqua ruby kana

idols-debug: aqua-debug ruby-debug kana-debug

# only used once to setup the virtual machines
idols-image:
	# take image for idols, and upload the image to proxmox nodes.
	nom build .#aquamarine
	scp result/vzdump-qemu-*.vma.zst root@gtr5:/var/lib/vz/dump

	nom build .#ruby
	scp result/vzdump-qemu-*.vma.zst root@s500plus:/var/lib/vz/dump

	nom build .#kana
	scp result/vzdump-qemu-*.vma.zst root@um560:/var/lib/vz/dump


############################################################################
#
#  Misc, other useful commands
#
############################################################################

fmt:
	# format the nix files in this repo
	nix fmt

.PHONY: clean  
clean:  
	rm -rf result
