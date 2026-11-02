# IPython

[`default.nix`](./default.nix) manages `~/.ipython/profile_default` with two pieces:

- `ipython_config.py` disables SQLite history because interactive sessions may contain secrets.
- `startup/10-data-helpers.py` loads JSON, YAML, TOML, and CSV helpers at every IPython start. It
  also pre-imports a small set of common standard-library names such as `Path`, `Counter`, and
  `datetime`.

[`data-helpers.py`](./data-helpers.py) deliberately keeps heavier libraries such as NumPy and pandas
out of startup; import them explicitly when needed. The `~/.ipython` profile is not persisted by
`hosts/idols-ai/preservation.nix`, so Home Manager recreates the config and helpers from the Nix
store on every activation.
