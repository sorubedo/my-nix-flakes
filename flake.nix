# ./flake.nix
{
  description = "My collection of Nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # 获取当前系统的 nixpkgs 实例
        pkgs = import nixpkgs { inherit system; };
        lib = pkgs.lib;
        # --- 自动发现包的逻辑 (保持不变, 但更清晰) ---
        # 扫描 ./pkgs 目录下的所有子目录（每个子目录代表一个包）
        packagesPath = ./pkgs;
        packageNames = builtins.attrNames (
          lib.filterAttrs (name: type: type == "directory") (builtins.readDir packagesPath)
        );

        # 为每个发现的包名调用 callPackage
        buildPackage = name: pkgs.callPackage "${packagesPath}/${name}/package.nix" {};

        # 生成所有包的属性集, 例如 { sing-box = <derivation>; ... }
        allPackages = lib.genAttrs packageNames buildPackage;

      in
      {
        # --- 输出 1: Packages ---
        # 将为当前系统构建的所有包暴露在 packages 下
        # 结果: self.packages.x86_64-linux.sing-box
        packages = allPackages;

        # --- 输出 2: Overlays ---
        # 提供一个默认的 overlay，它会把我们所有的包添加到一个命名空间下
        # 这是最重要和最健壮的实现方式
        overlays.default = final: prev: {
          # 我们创建一个名为 `myFlakes` 的属性集来存放所有的包
          # 这样做可以避免与 nixpkgs 中的官方包名冲突，是最佳实践
          myFlakes = self.packages.${prev.system};
        };
      }
    );
}
