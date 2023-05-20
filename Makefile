deploy: 
	sudo nixos-rebuild switch --flake .

debug:
	sudo nixos-rebuild switch --flake . --show-trace --verbose

update:
	nix flake update

history:
	sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

gc:
	sudo nix-collect-garbage --delete-older-than 14d

