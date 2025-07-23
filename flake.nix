# ./flake.nix
{
  description = "My collection of Nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # 支持的系统架构
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # 一个为每个系统生成属性的辅助函数
      forAllSystems = function: nixpkgs.lib.genAttrs supportedSystems (system: function system);

      # --- 自动发现包的魔法 ---
      # 导入 pkgs 目录，并为每个系统构建其中的所有包
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
      pkgs = forAllSystems (system:
        let
          # 过滤出 pkgs 目录下的所有文件夹
          pkg-names = builtins.attrNames (
            nixpkgs.lib.filterAttrs (name: type: type == "directory") (builtins.readDir ./pkgs)
          );
          # 为每个文件夹（包）调用 callPackage
          callPackageFor = pkg-name: nixpkgsFor.${system}.callPackage (./pkgs + "/${pkg-name}/package.nix") {};
        in
        # 生成 { sing-box = <derivation>; another-package = <derivation>; ... }
        nixpkgs.lib.genAttrs pkg-names callPackageFor
      );

    in
    {
      # --- 输出 1: Packages ---
      # 将所有发现的包暴露在 packages.<system> 下
      # 其他 flake 可以通过 my-flakes.packages.x86_64-linux.sing-box 来引用
      packages = pkgs;

      # --- 输出 2: Overlays ---
      # 提供一个方便的 overlay，可以一次性添加所有包
      overlays.default = final: prev: {
        # 将我们构建的所有包都添加到 overlay 中
        # 例如，pkgs.x86_64-linux 包含了为该系统构建的所有包
        inherit (pkgs.${prev.system}) sing-box; # 你可以手动指定，或者直接用 pkgs.${prev.system}
      };

      # --- (可选) 输出 3: NixOS 模块 ---
      # 如果你的某些包有对应的 NixOS 服务模块，可以在这里提供
#       nixosModules.default = { ... }: {
#         # 例如，为你的 overlay 创建一个选项
#         options.my-flakes.enable = lib.mkEnableOption "Enable overlay for my custom packages";
#         config = lib.mkIf config.my-flakes.enable {
#           nixpkgs.overlays = [ self.overlays.default ];
#         };
#       };
    };
}
