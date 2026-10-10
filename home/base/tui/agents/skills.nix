{
  config,
  lib,
  mattpocock-skills,
  i-have-adhd,
  humanizer,
  ponytail,
  context7,
  ...
}:
let
  # Skills kept in this repository (agents/skills/<name>) are linked
  # out-of-store, like the rules, so an edit reaches the next agent session
  # without a switch; adding or removing one still needs a switch.
  local = ../../../../agents/skills;
  checkout = "${config.home.homeDirectory}/nix-config/agents/skills";
  localNames = lib.attrNames (
    lib.filterAttrs (name: type: type == "directory") (builtins.readDir local)
  );

  # Skills taken from flake inputs: name -> directory in the input. Dependencies
  # travel together: grill-with-docs and wayfinder call grilling and
  # domain-modeling, wayfinder also calls research and prototype and points at
  # setup-matt-pocock-skills, and retro calls writing-for-agents.
  upstream =
    let
      mp = "${mattpocock-skills}/skills";
    in
    {
      diagnosing-bugs = "${mp}/engineering/diagnosing-bugs";
      domain-modeling = "${mp}/engineering/domain-modeling";
      grill-with-docs = "${mp}/engineering/grill-with-docs";
      grilling = "${mp}/productivity/grilling";
      prototype = "${mp}/engineering/prototype";
      research = "${mp}/engineering/research";
      retro = "${mp}/engineering/retro";
      setup-matt-pocock-skills = "${mp}/engineering/setup-matt-pocock-skills";
      wayfinder = "${mp}/engineering/wayfinder";
      writing-for-agents = "${mp}/productivity/writing-for-agents";

      i-have-adhd = "${i-have-adhd}/skills/i-have-adhd";
      find-docs = "${context7}/skills/find-docs";
      ponytail-review = "${ponytail}/skills/ponytail-review";
    };

  # humanizer's skill is its repository root, which also carries an AGENTS.md
  # meant for its own contributors; link only the files the skill uses.
  humanizerFiles = {
    ".agents/skills/humanizer/SKILL.md".source = "${humanizer}/SKILL.md";
    ".agents/skills/humanizer/agents".source = "${humanizer}/agents";
  };
in
{
  assertions = [
    {
      assertion = lib.all (name: !(upstream ? ${name}) && name != "humanizer") localNames;
      message = "agents/skills and the upstream skill set define the same skill name";
    }
  ];

  # ~/.agents/skills is the cross-tool Agent Skills scope.
  home.file =
    lib.listToAttrs (
      map (
        name:
        lib.nameValuePair ".agents/skills/${name}" {
          source = config.lib.file.mkOutOfStoreSymlink "${checkout}/${name}";
        }
      ) localNames
    )
    // lib.mapAttrs' (
      name: path: lib.nameValuePair ".agents/skills/${name}" { source = path; }
    ) upstream
    // humanizerFiles;
}
