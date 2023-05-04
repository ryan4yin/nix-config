## Nix 简介

Nix 包管理器，跟 DevOps 领域当前流行的 plulumi/terraform 很类似，都是声明式的配置管理工具，用户需要用 DSL 语言声明好期望的系统状态，而 nix 负责达成目标。区别在于 Nix 的管理目标是软件包，而 plulumi/terraform 的管理目标是云上资源。

基于 nix 构建的 Linux 发行版 NixOS，可以简单用 OS as Code 来形容，它通过声明式的 Nix 配置文件来描述整个系统的状态。

NixOS 的配置只负责管理系统状态，用户目录不受它管辖。有另一个重要的社区项目 home-manager 专门用于管理用户目录，将 home-manager 与 NixOS、Git 结合使用，就可以得到一个完全可复现、可回滚的系统环境。

因为 nix 声明式、可复现的特性，nix 不仅可用于管理桌面电脑的环境，也有很多人用它管理开发编译环境、云上虚拟机、容器镜像构建，并且 Nix 官方也推出了基于 Nix 的运维工具 NixOps。

>Home 目录下文件众多，行为也不一，因此不可能对其中的所有文件进行版本控制，代价太高。一般仅使用 home-manager 管理一些重要的配置文件，而其他需要备份的文件可以用 rsync 定期备份到其他地方。或者用 synthing 实时同步到其他主机。

总结下 nix 的优点：

- 声明式配置，environment as code
  - nix flake 通过函数式语言的方式描述了软件包的依赖关系，并通过 flake.lock （借鉴了 cargo/npm）记录了所有依赖项的数据源与 hash 值，这使得 nix 可以在不同机器上生成完全一致的环境。
  - 这与 docker/vargrant 有点类似，不过 docker/vargrant 的目标环境都是隔离的容器或虚拟机，nix 比它们更通用，可以用于管理任何物理机、虚拟机、容器的环境。
- 可回滚：可以随时回滚到任一历史环境，NixOS 甚至默认将所有旧版本都加入到了启动项，确保系统滚挂了也能随时回滚。所以也被认为是最稳定的包管理方式。
- 没有依赖冲突问题：因为 nix 中每个软件包都拥有唯一的 hash，其安装路径中也会包含这个 hash 值，因此可以多版本共存。任何其他依赖了某个特定包的 nix 包，都会在其配置文件中声明依赖的包的 hash，这样它只能看到这个 hash 对应的包，就不存在冲突。

nix 的缺点：

- 学习成本高：如果你希望系统完全可复现，并且避免各种不当使用导致的坑，那就需要学习了解 nix 的整个设计。而其他发行版可以直接 `apt install`，因此想要用好 nix，学习成本还是比较高的。
- 文档混乱：入门文档与进阶使用之间缺乏比较好的填充，学习曲线比较陡峭。另一方面 nix flake 不仅文档比较缺乏，还与旧的 nix-env/nix-channel 相关的文档混在一起，增加了学习与辨别的难度。
- 包数量比较少：官方宣称 nixpkgs 是有 [80000+](https://search.nixos.org/packages) 个软件包，但是实际体验下来跟 arch linux 的差距还比较大，毕竟 AUR 生态是真的丰富。
  - 官方包不一定能满足需求，因此为了使系统可复现，逐渐熟悉 nix 后肯定需要学习如何自己打包。
- 比较吃硬盘空间：为了保证系统可以随时回退，nix 默认总是保留所有历史环境，这非常吃硬盘空间。虽然可以定期使用 `nix-collect-garbage` 来手动清理旧的历史环境，也还是建议配置个更大的硬盘...


## 为什么选择 Nix

以前就听说过 Nix，最近搞系统迁移又遇到两件麻烦事，使我决定尝试下 Nix.

第一件事是在新组装的 PC 主机上安装 EndeavourOS，这是 Arch Linux 的一个衍生发行版。因为旧系统也是 EndeavourOS 系统，安装完为了省事，我就直接把旧电脑的 Home 目录 rsync 同步到了新 PC 上。
这一同步就出了问题，所有功能都工作正常，但是视频播放老是卡住，firefox/chrome/mpv 都会卡住，网上找各种资料都没解决，还是我灵光一闪想到是不是 Home 目录同步的锅，清空了 Home 目录，问题立马就解决了...后面又花好长时间从旧电脑一点点恢复 Home 目录下的东西。

第二件事是，想尝鲜 wayland，从 i3wm 换成 sway 后感觉区别不明显，因为用的 nvidia 显卡改起来也麻烦，就回退到了 i3wm，结果回退后，每次系统刚启动时，有一段时间 firefox/thunar 等 GUI 程序会一直卡着。

发生第二件事时我就懒得折腾了，想到归根结底还是系统没有版本控制跟回滚机制，导致系统出了问题不能还原，装新系统时各种软件包也全靠自己手工从旧机器导出软件包清单，再在新机器安装恢复。就打算干脆换成 NixOS 试试。


## 安装

Nix 有多种安装方式，我选择了直接使用 NixOS 的 ISO 镜像安装 NixOS 系统，从而最大程度上掌控整个系统的环境。

安装很简单，这里不多介绍，参见相关资料：

- 国内镜像源说明：https://mirrors.bfsu.edu.cn/help/nix/
- [NixOS Download](https://nixos.org/download.html): 官方安装文档


## Nix Flake 与旧的 Nix

Nix 长期依赖一直没有标准的包结构定义，直到 2020 年才推出了 `nix-command` & `flake`，它们虽然至今仍然是实验性特性，但是已经得到广泛使用，是强烈推荐使用的功能。

因为 nix-command 与 flake 还未 stable，旧的 Nix 包结构与相关命令行工具仍然是大量 Nix Wiki/教程中的主要内容，从可复现、易于管理维护的角度讲，旧的 Nix 包结构与命令行工具已经不推荐使用了，因此本文档也不会介绍旧的 Nix 包结构与命令行工具的使用方法，也建议新手直接忽略掉这些旧的内容，从 nix flake 学起。

这里列举下在 nix flake 中已经不需要用到的旧的 Nix 命令行工具与相关概念，在查找资料时，如果看到它们直接忽略掉就行：

1. `nix-channel`: nix-channel 与其他包管理工具类似，通过 stable/unstable/test 等 channel 来管理软件包的版本。
   1. nix flake 在 flake.nix 中通过 inputs 声明依赖包的数据源，通过 flake.lock 锁定依赖版本，完全取代掉了 nix-channel 的功能。
2. `nix-env`: 用于管理用户环境的软件包，是传统 Nix 的核心命令行工具。它从 nix-channel 定义的数据源中安装软件包，所以安装的软件包版本受 channel 影响。通过 `nix-env` 安装的包不会被自动记录到 nix 的声明式配置中，是完全脱离掌控的，无法在其他主机上复现，因此不推荐使用。
   1. 在 nix flake 中对应的命令为 `nix profile`
3. `nix-shell`: nix-shell 用于创建一个临时的 shell 环境
   1. 在 nix flake 中它被 `nix develop` 与 `nix shell` 取代了。
4. ...


### 名词解释

在真正开始使用 Nix 前，需要先了解下 Nix 的一些名词（看不懂没关系，先有个大概的概念就行）：

- derivation: 一个构建动作的 nix 语言描述，它描述了如何构建一个软件包，它的执行结果是一个 store object
- store: store object 的存储位置，它是一个只读的文件系统，所有的 store object 都是不可变的。
  - 其位置通常为 `/nix/store`
- sotre object: derivation 的执行结果，它是 store 中的一个文件，它可以是一个普通文件，也可以是一个目录。它可以是一个软件包，也可以是另一个 derivation。
- store path: store object 的路径，它的格式为 `/nix/store/<hash>-<name>`，其中 `<hash>` 是 store object 的 hash，`<name>` 是 store object 的名字。
- substitute: 它是存储在 Nix database 中的一个命令调用，描述了在跳过普通构建过程（如 derivation）的情况下，如何从其他服务器上获取对应的 store object。
  - 这应该就是 nix 的 cache 机制，大部分常用的软件包都可以直接从 cache.nixos.org 上获取，这避免了耗时的本地构建。
- purity: nix 系统假设 derivation 的每次执行总是产生同样的结果，这意味着 derivation 的执行结果只与输入有关，而与执行环境无关。
  - purity 是 nix 系统能通过 substitute 实现缓存、以及它承诺的可复现性的基础。
  - 但是这并不是总能做到，因为 derivation 基本都需要依赖一些外部资源作为输入，如第三方服务器上的资源、时间等，这些东西的变化可能会导致 derivation 的执行结果不同。
- Nix expression： 软件包的一个 nix 语言描述，它被翻译成 derivation 并保存在 store 中。
- user environment: 用户环境，它是一个由 nix 管理的目录，它包含了用户的软件包，以及用户的配置文件。
- Nix Flake: Nix 包管理器的一项重要的新功能，它提供了一种更加简单、可重复、可扩展和灵活的方式来管理软件和系统。
  - 它允许用户将 Nix 包管理器的所有功能打包成一组可重复、可复制和可扩展的“碎片”，称为 Flake。一个 Flake 可以包含 Nix 表达式、NixOS 配置、软件包描述、构建脚本等多个组件，并且通过 flake.lock 文件来锁定其依赖的其他 Flake——以确保 Flake 的可重复性。
  - 目前虽然还是实验性，但是已经实验一年多了（2021-11-11 开始），很多人都在用（感觉就跟 Kubernetes 的 beta API 一样...）。
- Nix Profile: nixos 中的 Profile 类似 Python 的虚拟环境，可以用于创建隔离的软件环境。Profile 存储在 /nix/var/nix/profiles 目录中。默认情况下，系统预定义了一些 Profile，如 system、user 和 nixos-test。
  - 感觉跟 home-manager 的功能有那么点类似，不过 home-manager 是跟用户绑定的，而 profile 跟用户没有关联性。
- Nix Container: 用于创建运行 NixOS 系统的容器，可以说它就是 Docker 的 Nix 版本。
- direnv: direnv 是一个 shell 扩展，它能够根据当前目录的环境变量来修改 shell 的行为，nix 结合 direnv 可很方便地使用各种互相隔离的开发环境。

此外跟 Arch Linux 类似，Nix 也有官方与社区的软件包仓库：

1. [nixpkgs](https://github.com/NixOS/nixpkgs) 是一个包含了所有 nix 包与 nixos 模块/配置的 Git 仓库，其 master 分支包含最新的 nix 包与 nixos 模块/配置。
2. [NUR](https://github.com/nix-community/NUR): 类似 Arch Linux 的 AUR，NUR 是 Nix 的一个第三方的 nix 包仓库，它包含了一些 nix 包，但是它们并不包含在 nixpkgs 仓库中，因此需要单独安装。

### NixOS 的声明式配置

>https://nixos.wiki/wiki/Overview_of_the_NixOS_Linux_distribution

NixOS 的系统配置路径为 `/etc/nixos/configuration.nix`，它包含系统的所有声明式配置，如时区、语言、键盘布局、网络、用户、文件系统、启动项等。

如果想要以可复现的方式修改系统的状态（这也是最推荐的方式），就需要手工修改 `/etc/nixos/configuration.nix` 文件，然后执行 `sudo nixos-rebuild switch` 命令来应用配置，此命令会根据配置文件生成一个新的系统环境，并将新的环境设为默认环境。
同时上一个系统环境会被保留，而且会被加入到 grub 的启动项中，这确保了即使新的环境不能启动，也能随时回退到旧环境。

另一方面，`/etc/nixos/configuration.nix` 是传统的 Nix 配置方式，它依赖 nix-channel 配置的数据源，也没有任何版本锁定机制，实际无法确保系统的可复现性。
更推荐使用的是 Nix Flake，它可以确保系统的可复现性，同时也可以很方便地管理系统的配置。

在使用 Flake 管理系统配置时，系统的核心配置文件为 `/etc/nixos/flake.nix`，`sudo nixos-rebuild switch` 命令会优先读取该文件，如果找不到再尝试使用 `/etc/nixos/configuration.nix`。

## 正式使用

>这里假设你已经了解 Nix 语言的基本语法。

### 1. 启用 openssh 服务

然后添加 openssh 相关配置，参数可以在 <https://search.nixos.org/options> 中查到：

```nix
{ config, pkgs, ... }:

{

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ryan = {
    isNormalUser = true;
    description = "ryan";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
        # replace with your own public key
        "ssh-ed25519 some-public-key ryan@ryan-pc"
    ];
    packages = with pkgs; [
      firefox
    #  thunderbird
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    permitRootLogin = "no";         # disable root login
    passwordAuthentication = false; # disable password login
    openFirewall = true;
    forwardX11 = true;              # enable X11 forwarding
  };
}
```

这里我启用了 openssh 服务，并为 ryan 用户添加了 ssh 公钥，这样我就可以通过 ssh 登录到我的系统了。

然后运行 `nixos-rebuild switch` 后，就能使用我的私钥登录系统了，密码登录会直接报错。

### 2. 启用 nix flake

前面提到了 flake 提供了 flake.lock 确保系统可复现，而我的目标正是打造一个可复现的系统，所以我决定使用 flake 来管理我的系统。

但是目前 flake 作为一个实验性的功能，仍未被默认启用。所以我们需要手动启用它，修改 `/etc/nixos/configuration.nix` 文件，在函数块中启用 flakes 与 nix-command 功能：

```nix
{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

然后运行 `nixos-rebuild switch` 应用修改。


#### 2.1 学习 flake 的编写方式

可以首先使用官方提供的模板来学习 flake 的编写，先查下有哪些模板：

```bash
nix flake show templates
```

其中有个 `templates#full` 模板展示了所有可能的用法，可以看看它的内容：

```bash
nix flake init -t templates#full
cat flake.nix
```

简单浏览后，我们创建文件 `/etc/nixos/flake.nix`，后续系统的所有修改都将全部由 nix flake 接管，参照前面的模板，编写如下内容：

```nix
{
  description = "Ryan's NixOS Flake";

  # 输入配置，即软件源
  inputs = {
    # NixOS 官方软件源
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # home-manager，用于管理用户配置
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # 输出配置，即 NixOS 系统配置
  outputs = { self, nixpkgs, ... }@inputs: {
    # 定义一个名为 nixos 的系统
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # 导入之前我们使用的 configuration.nix，这样旧的配置文件仍然能生效
      modules = [
        ./configuration.nix
      ];
    };
  };
}
```

这里我们定义了一个名为 nixos 的系统，它的配置文件为 `./configuration.nix`，这个文件就是我们之前的配置文件，这样我们仍然可以沿用旧的配置。

现在执行 `nixos-rebuild switch` 应用配置。


### 3 安装 home-manager

根据官方文档 [Home Manager Manual](https://nix-community.github.io/home-manager/index.htm)，安装流程如下：

首先，我希望将 home manager 作为 NixOS 模块安装，首先需要创建 `/etc/nixos/home.nix`，官方给出了样板：

```nix
{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  # 注意修改这里的用户名与用户目录
  home.username = "ryan";
  home.homeDirectory = "/home/ryan";

  # Packages that should be installed to the user profile.
  home.packages = [ 
    # 用户目录下安装的软件包                              
    pkgs.htop
  ];

  # git 相关配置
  programs.git = {
    enable = true;
    userName = "Ryan Yin";
    userEmail = "xiaoyin_c@qq.com";
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  # alacritty 终端配置，貌似还需要配置 X11 环境，否则无法启动
  programs.alacritty = {
    enable = true;
    settings = {
      colors = {
        primary = {
          background = "0x282828";
          foreground = "0xebdbb2";
        };
        normal = {
          black = "0x282828";
          red = "0xcc241d";
          green = "0x98971a";
          yellow = "0xd79921";
          blue = "0x458588";
          magenta = "0xb16286";
          cyan = "0x689d6a";
          white = "0xa89984";
        };
        bright = {
          black = "0x928374";
          red = "0xfb4934";
          green = "0xb8bb26";
          yellow = "0xfabd2f";
          blue = "0x83a598";
          magenta = "0xd3869b";
          cyan = "0x8ec07c";
          white = "0xebdbb2";
        };
      };
      env.TERM = "xterm-256color";
      font = {
        size = 12;
        draw_bold_text_with_bright_colors = true;
      };
      hints = {
        alphabet = "jfkdls;ahgurieowpq";
        enabled = [{
          regex = "(https:|http:|git:|ftp:)[^\\u0000-\\u001F\\u007F-\\u009F<>\"\\\\s{-}\\\\^⟨⟩`]+";
          command = "${pkgs.xdg-utils}/bin/xdg-open";
          post_processing = true;
          mouse = { enabled = true; mods = "Alt"; };
        }];
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
```

然后再使用如下命令在 `/etc/nixos` 中创建 home-manager 的 flake.nix 配置：

```shell
nix flake new /etc/nixos -t github:nix-community/home-manager#nixos
```

通过模板生成好 `/etc/nixos/flake.nix` 配置后不是万事大吉，还得手动改下相关参数：

```nix
{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      # 这里替换成你的主机名称
      <your-hostname> = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # 这里的 ryan 也得替换成你的用户名
            home-manager.users.ryan = import ./home.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };
  };

}
```

然后执行 `nixos-rebuild switch` 应用配置。

### 4. 配置 i3wm 窗口管理器

首先，确保在 `/etc/nixos/configuration.nix` 中添加如下配置：

```nix
{ config, pkgs, ... }:

{
  services.xserver.enable = true;
}
```

然后既然我们已经安装了 home manager，i3wm 可以直接在 `/etc/nixos/home.nix` 中配置，添加如下内容：

```nix
{ config, pkgs, ... }:

{
  # Enable the i3 windows manager
  xsession = {
    enable = true;
    windowManager.i3 = {
      enable = true;
      config = {
        bars = {
          status = {
            position = "bottom";
            statusCommand = "i3status-rust";
          };
        };
      };
    };
  };

}
```

## How to Learn Nix & Flake?

Nix Flake is a new feature in Nix, it's the unit for packaging Nix code in a reproducible and discoverable way. 
They can have dependencies on other flakes, making it possible to have multi-repository Nix projects.

A flake is a filesystem tree (typically fetched from a Git repository or a tarball) that contains a file named flake.nix in the
root directory. flake.nix specifies some metadata about the flake such as dependencies (called inputs), as well as its outputs
(the Nix values such as packages or NixOS modules provided by the flake).

Nix Flake is an experimental feature till now (2023-04-23), but it's already very useful and being used by many people.

>Because `nix-command` & `flake` are still experimental, many document about nix are stll using old commands such as `nix-env`, `nix-channel` & `nix-shell`, but they are not very reproducible compared with `nix-command` & `flake`, So please forget those old commands, and start with the [New Nix Commands][New Nix Commands] for Nix Flake.

## 一、Nix Flake's Command Line

after enabled `nix-command` & `flake`, you can use `nix help` to get all the info of [New Nix Commands][New Nix Commands], the main commands include:

- `nix build` - build a derivation or fetch a store path, generate a result symlink in the current directory
- `nix develop` - run a bash shell that provides the build environment of a derivation
- `nix flake` - provides subcommands for creating, modifying and querying Nix flakes.
  - `nix flake archive` - copy a flake and all its inputs to a store 
  - `nix flake check` - check whether the flake evaluates and run its tests 
  - `nix flake clone` - clone flake repository 
  - `nix flake info` - show flake metadata 
  - `nix flake init` - create a flake in the current directory from a template 
  - `nix flake lock` - create missing lock file entries 
  - `nix flake metadata` - show flake metadata 
  - `nix flake new` - create a flake in the specified directory from a template 
  - `nix flake prefetch` - download the source tree denoted by a flake reference into the Nix store 
  - `nix flake show` - show the outputs provided by a flake 
  - `nix flake update` - update flake lock file 
- `nix profile` - manage Nix profiles. nix profile allows you to create and manage Nix profiles. A Nix profile is a set of packages that can be installed and upgraded independently from each other. Nix profiles are versioned, allowing them to be rolled back easily. its a replacement of `nix-env`.
    - `nix profile diff-closures` - show the closure difference between each version of a profile 
    - `nix profile history` - show all versions of a profile 
    - `nix profile install` - install a package into a profile 
    - `nix profile list` - list installed packages 
    - `nix profile remove` - remove packages from a profile 
    - `nix profile rollback` - roll back to the previous version or a specified version of a profile 
    - `nix profile upgrade` - upgrade packages using their most recent flake 
    - `nix profile wipe-history` - delete non-current versions of a profile 
- `nix repl` - start an interactive environment for evaluating Nix expressions
- `nix run` - run a Nix application. (use `nix run --help` for detail explanation)
- `nix search` - search for packages, maybe your woulde prefer the website <https://search.nixos.org> instead of this command.
- `nix shell` - run a shell in which the specified packages are available

[Zero to Nix - Determinate Systems][Zero to Nix - Determinate Systems] is a brand new guide to get started with Nix & Flake, recommended to read for beginners.

### Flake outpus

Flake outputs are what a flake produces as part of its build. Each flake can have many different outputs simultaneously, including but not limited to:

- Nix packages: named `apps.<system>.<name>`, `packages.<system>.<name>`, or `legacyPackages.<system>.<name>`
- Nix Helper Functions: named `lib`, which means a library for other flakes.
- Nix development environments: named `devShell`
- NixOS configurations: has many different outputs
- Nix templates: named `templates`
  - templates can be used by command `nix flake init --template <reference>`

### Flake Command Examples

examples:

```bash
# `nixpkgs#ponysay` means `ponysay` from `nixpkgs` flake.
# [nixpkgs](https://github.com/NixOS/nixpkgs) contains `flake.nix` file, so it's a flake.
# `nixpkgs` is a falkeregistry id for `github:NixOS/nixpkgs/nixos-unstable`.
# you can find all the falkeregistry ids at <https://github.com/NixOS/flake-registry/blob/master/flake-registry.json>
# so this command means install and run package `ponysay` in `nixpkgs` flake.
echo "Hello Nix" | nix run "nixpkgs#ponysay"

# this command is the same as above, but use a full flake URI instead of falkeregistry id.
echo "Hello Nix" | nix run "github:NixOS/nixpkgs/nixos-unstable#ponysay"

# instead of treat flake package as an application, 
# this command use the example package in zero-to-nix flake to setup the development environment,
# and then open a bash shell in that environment.
nix develop "github:DeterminateSystems/zero-to-nix#example"

# instead of using a remote flake, you can open a bash shell using the flake located in the current directory.
mkdir my-flake && cd my-flake
## init a flake with template
nix flake init --template "github:DeterminateSystems/zero-to-nix#javascript-dev"
# open a bash shell using the flake in current directory
nix develop
# or if your flake has multiple devShell outputs, you can specify which one to use.
nix develop .#example

# build package `bat` from flake `nixpkgs`, and put a symlink `result` in the current directory.
mkdir build-nix-package && cd build-nix-package
nix build "nixpkgs#bat"
# build a local flake is the same as nix develop, skip it
```

### Nix Flakes Repo

除了官方的 Nixpkgs 之外，nix flake 还可以从任何第三方仓库中获取 flake，这个前面已经演示过许多了。

第三方仓库虽然多，不过有几个比较常用的，官方也给它们提供了别名，列表保存在 [NixOS/flake-registry](ttps://github.com/NixOS/flake-registry/blob/master/flake-registry.json)，可供参考。

比较知名的有：

- [NUR](https://github.com/nix-community/NUR): 它类似 Arch Linux 的 AUR，是一个第三方 packages/flakes 的集合
- [home-manager](https://github.com/nix-community/home-manager): home-manager 的 flake 版本

## Basics of Nix Language

>https://nix.dev/tutorials/nix-language

主要包含如下内容：

1. 数据类型
2. 函数的声明与调用语法
3. 内置函数与库函数
4. inputs 的不纯性
5. 用于描述 build task 的 derivation

### 1. 基础数据类型一览

```nix
{
  string = "hello";
  integer = 1;
  float = 3.141;
  bool = true;
  null = null;
  list = [ 1 "two" false ];
  attribute-set = {
    a = "hello";
    b = 2;
    c = 2.718;
    d = false;
  }; # comments are supported
}
```

以及一些基础操作符，普通的算术运算、布尔运算就跳过了：

```nix
# List concatenation
[ 1 2 3 ] ++ [ 4 5 6 ] # [ 1 2 3 4 5 6 ]

# Update attribute set attrset1 with names and values from attrset2.
{ a = 1; b = 2; } // { b = 3; c = 4; } # { a = 1; b = 3; c = 4; }

# 逻辑隐含，等同于 !b1 || b2.
bool -> bool
```

### 2. attribute set 说明

花括号 `{}` 用于创建 attribute set，也就是 key-value 对的集合，类似于 JSON 中的对象。

attribute set 默认不支持递归引用，如下内容会报错：

```nix
{
  a = 1;
  b = a + 1; # error: undefined variable 'a'
}
```

不过 nix 提供了 `rec` 关键字（recursive attribute set），可用于创建递归引用的 attribute set：

```nix
rec {
  a = 1;
  b = a + 1; # ok
}
```

在递归引用的情况下，nix 会按照声明的顺序进行求值，所以如果 `a` 在 `b` 之后声明，那么 `b` 会报错。

可以使用 `.` 操作符来访问 attribute set 的成员：

```nix
let
  a = {
    b = {
      c = 1;
    };
  };
in
a.b.c # result is 1
```

`.` 操作符也可直接用于赋值：

```nix
{ a.b.c = 1; }
```

### 3. let ... in ...

nix 的 `let ... in ...` 语法被称作「let 表达式」或者「let 绑定」，它用于创建临时使用的局部变量：

```nix
let
  a = 1;
in
a + a  # result is 2
```

let 表达式中的变量只能在 `in` 之后的表达式中使用，理解成临时变量就行。

### 4. with 语句


with 语句的语法如下：

```nix
with <attribute-set> ; <expression>
```

`with` 语句会将 `<attribute-set>` 中的所有成员添加到当前作用域中，这样在 `<expression>` 中就可以直接使用 `<attribute-set>` 中的成员了，简化 attribute set 的访问语法，比如：

```nix
let
  a = {
    x = 1;
    y = 2;
    z = 3;
  };
in
with a; [ x y z ]  # result is [ 1 2 3 ], equavlent to [ a.x a.y a.z ]
```

### 5. 继承 inherit ...

`inherit` 语句用于从 attribute set 中继承成员，同样是一个简化代码的语法糖，比如：

```nix
let
  x = 1;
  y = 2;
in
{
  inherit x y;
}  # result is { x = 1; y = 2; }
```

inherit 还能直接从某个 attribute set 中继承成员，语法为 `inherit (<attribute-set>) <member-name>;`，比如：

```nix
let
  a = {
    x = 1;
    y = 2;
    z = 3;
  };
in
{
  inherit (a) x y;
}  # result is { x = 1; y = 2; }
```

### 6. ${ ... } 字符串插值

`${ ... }` 用于字符串插值，懂点编程的应该都很容易理解这个，比如：

```nix
let
  a = 1;
in
"the value of a is ${a}"  # result is "the value of a is 1"
```

### 7. 文件系统路径

Nix 中不带引号的字符串会被解析为文件系统路径，路径的语法与 Unix 系统相同。

### 8. 搜索路径

>请不要使用这个功能，搜索路径不是 pure 的，会导致不可预期的行为。

Nix 会在看到 `<nixpkgs>` 这类三角括号语法时，会在 `NIX_PATH` 环境变量中指定的路径中搜索该路径。

因为环境变量 `NIX_PATH` 是可变更的值，所以这个功能是不纯的，会导致不可预期的行为。

### 9. 多行字符串

多行字符串的语法为 `''`，比如：

```nix
''
  this is a
  multi-line
  string
''
```

### 10. 函数

函数的声明语法为：

```nix
<arg1>:
  <body>;
```

举几个常见的例子：

```nix
# function with one argument
a: a + a

# 嵌套函数
a: b: a + b

# function with two arguments
{ a, b }: a + b

# function with two arguments and default values
{ a ? 1, b ? 2 }: a + b

# 带有命名 attribute set 作为参数的函数，并且使用　... 收集其他可选参数
# 命名　args 与　... 可选参数通常被一起作为函数的参数定义使用
args@{ a, b, ... }: a + b + args.c
# 如下内容等价于上面的内容
{ a, b, ... }@args: a + b + args.c

# 但是要注意命名参数仅绑定了输入的 attribute set，默认参数不在其中，举例
let 
  f = { a ? 1, b ? 2, ... }@args: args  # this will cause an error
in
  f {}  # result is {}

# 函数的调用方式就是把参数放在后面，比如下面的 2 就是前面这个函数的参数
a: a + a 2  # result is 4

# 还可以给函数命名，不过必须使用 let 表达式
let
  f = a: a + a;
in
f 2  # result is 4
```

#### 内置函数

Nix 内置了一些函数，可通过 `builtins.<function-name>` 来调用，比如：

```nix
builtins.add 1 2  # result is 3
```

详细的内置函数列表参见 [Built-in Functions - Nix Reference Mannual](https://nixos.org/manual/nix/stable/language/builtins.html)

#### import 表达式

`import` 表达式以其他 nix 文件的路径作为参数，返回该 nix 文件的执行结果。

`import` 的参数如果为文件夹路径，那么会返回该文件夹下的 `default.nix` 文件的执行结果。

举个例子，首先创建一个 `file.nix` 文件：

```shell
$ echo "x: x + 1" > file.nix
```

然后使用 import 执行它：

```nix
import ./file.nix 1  # result is 2
```

#### pkgs.lib 函数包

除了 builtins 之外，Nix 的 nixpkgs 仓库还提供了一个名为 `lib` 的 attribute set，它包含了一些常用的函数，它通常被以如下的形式被使用：

```nix
let
  pkgs = import <nixpkgs> {};
in
pkgs.lib.strings.toUpper "search paths considered harmful"  # result is "SEARCH PATHS CONSIDERED HARMFUL"
```


可以通过 [Nixpkgs Library Functions - Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/#sec-functions-library) 查看 lib 函数包的详细内容。

### 不纯

Nix 语言本身是纯函数式的，是纯的，也就是说它就跟数学中的函数一样，同样的输入永远得到同样的输出。

**Nix 唯一的不纯之处在这里：从文件系统路径或者其他输入源中读取文件作为构建任务的输入**。

nix 的构建输入只有两种，一种是从文件系统路径等输入源中读取文件，另一种是将其他函数作为输入。

>nix 中的搜索路径与 `builtins.currentSystem` 也是不纯的，但是这两个功能都不建议使用，所以这里略过了。

### Fetchers

构建输入除了直接来自文件系统路径之外，还可以通过 Fetchers 来获取，Fetcher 是一种特殊的函数，它的输入是一个 attribute set，输出是 nix store 中的一个系统路径。

Nix 提供了四个内置的 Fetcher，分别是：

- `builtins.fetchurl`：从 url 中下载文件
- `builtins.fetchTarball`：从 url 中下载 tarball 文件
- `builtins.fetchGit`：从 git 仓库中下载文件
- `builtins.fetchClosure`：从 Nix store 中获取 derivation


举例：

```nix
builtins.fetchurl "https://github.com/NixOS/nix/archive/7c3ab5751568a0bc63430b33a5169c5e4784a0ff.tar.gz"
# result example => "/nix/store/7dhgs330clj36384akg86140fqkgh8zf-7c3ab5751568a0bc63430b33a5169c5e4784a0ff.tar.gz"

builtins.fetchTarball "https://github.com/NixOS/nix/archive/7c3ab5751568a0bc63430b33a5169c5e4784a0ff.tar.gz"
# result example(auto unzip the tarball) => "/nix/store/d59llm96vgis5fy231x6m7nrijs0ww36-source"
```


### Derivations

一个构建动作的 nix 语言描述被称做一个 Derivation，它描述了如何构建一个软件包，它的执行结果是一个 store object

在 Nix 语言的最底层，一个构建任务就是使用 builtins 中的不纯函数 `derivation` 创建的，我们实际使用的 `stdenv.mkDerivation` 就是它的一个 wrapper，屏蔽了底层的细节，简化了用法。

### stdenv.mkDerivation

stdenv，顾名思义即标准构建环境，它是一个 attribute set，提供了构建 Unix 程序所需的标准环境，比如 gcc、glibc、binutils 等等。
它可以完全取代我们在其他操作系统上常用的构建工具链，比如 `./configure`; `make`; `make install` 等等。

即使 stdenv 提供的环境不能满足你的要求，你也可以通过 `stdenv.mkDerivation` 来创建一个自定义的构建环境。

举个例子：

```nix
{ lib, stdenv }:

stdenv.mkDerivation rec {
  pname = "libfoo";
  version = "1.2.3";
  # 源码
  src = fetchurl {
    url = "http://example.org/libfoo-source-${version}.tar.bz2";
    sha256 = "0x2g1jqygyr5wiwg4ma1nd7w4ydpy82z9gkcv8vh2v8dn3y58v5m";
  };

  # 构建依赖
  buildInputs = [libbar perl ncurses];

  # Nix 默认将构建拆分为一系列 phases，这里仅用到其中两个
  # https://nixos.org/manual/nixpkgs/stable/#ssec-controlling-phases
  buildPhase = ''
    gcc foo.c -o foo
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp foo $out/bin
  '';
}
```


## Override 与 Overlays

TODO

## Usfeful Flakes

those flakes are useful for flake development, but require more knowledge about nix modules, profiles, overlays, etc.

- [flake-parts](https://github.com/hercules-ci/flake-parts): Simplify Nix Flakes with the module system, useful to hold multiple system configurations in a single flake.
- [flake-utils-plus](https://github.com/gytis-ivaskevicius/flake-utils-plus): an more powerful utils for flake development.
- [digga](https://github.com/divnix/digga): a powerful nix flake template to hold multiple host's configurations in a single flake.


## 参考

- [NixOS 系列（一）：我为什么心动了](https://lantian.pub/article/modify-website/nixos-why.lantian/): 这是 LanTian 大佬的 NixOS 系列文章，写得非常清晰明了，新手必读。
- [Nix Flakes Series](https://www.tweag.io/blog/2020-05-25-flakes/): 官方的 Nix Flake 系列文章，介绍得比较详细，作为新手入门比较 OK
- [Nix Flakes - Wiki](https://nixos.wiki/wiki/Flakes): Nix Flakes 的官方 Wiki，此文介绍得比较粗略。
- 一些参考 nix 配置
  - [xddxdd/nixos-config](https://github.com/xddxdd/nixos-config)
  - [bobbbay/dotfiles](https://github.com/bobbbay/dotfiles)
  - [gytis-ivaskevicius/nixfiles](https://github.com/gytis-ivaskevicius/nixfiles)
  - [fufexan/dotfiles](https://github.com/fufexan/dotfiles): 好漂亮，教练我想学这个
  - [davidak/nixos-config](https://codeberg.org/davidak/nixos-config)
  - [davidtwco/veritas](https://github.com/davidtwco/veritas)
- [NixOS 手册](https://nixos.org/manual/nixos/stable/index.html): 要想把 NixOS 玩透，这是必读的。前面的文章读来会发现很多陌生的概念，需要靠这个补全。
  - 不过也不是说要把所有内容都补一遍，先看个大概，后面有需要再按图索骥即可。



[digga]: https://github.com/divnix/digga
[New Nix Commands]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix.html
[Zero to Nix - Determinate Systems]: https://github.com/DeterminateSystems/zero-to-nix
