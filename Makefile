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

darwin-set-proxy:
	sudo python3 scripts/darwin_set_proxy.py

darwin: darwin-set-proxy
	nix build .#darwinConfigurations.harmonica.system \
	  --extra-experimental-features 'nix-command flakes'
	./result/sw/bin/darwin-rebuild switch --flake .

darwin-debug: darwin-set-proxy
	nix build .#darwinConfigurations.harmonica.system \
	  --show-trace --verbose \
	  --extra-experimental-features 'nix-command flakes'
	./result/sw/bin/darwin-rebuild switch --flake . --show-trace --verbose


.PHONY: clean  
clean:  
	-rm -rf result
