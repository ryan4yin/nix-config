# How to Learn Nix & Flake?

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
- [github](https://github.com/divnix/digga): a powerful nix flake template to hold multiple host's configurations in a single flake.


[digga]: https://github.com/divnix/digga
[sway-nvidia]: https://github.com/crispyricepc/sway-nvidia
[New Nix Commands]: https://nixos.org/manual/nix/stable/command-ref/new-cli/nix.html
[Zero to Nix - Determinate Systems]: https://github.com/DeterminateSystems/zero-to-nix
