# ./overlays/default.nix (更优化的版本)
#
# 这个文件接收一个参数 `packages`，这个参数将由 flake.nix 传入。
# `packages` 是一个包含了所有自定义包的属性集。
final: prev: {
  # 将 `packages` 里的所有属性（即我们的所有自定义包）
  # 都添加到最终的包集中。
  inherit (final.callPackage ../pkgs { }) sing-box;
}
