# ~/my-sing-box/package.nix
{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  coreutils,
  # 我们不再需要 nix-update-script 和 nixosTests，因为这是我们自己的包
}:

buildGoModule (finalAttrs: {
  pname = "sing-box";
  # -------------------  第一处修改  -------------------
  # 将版本号更新为你在 GitHub 上找到的最新版本
  version = "1.12.0-rc.2";

  # -------------------  第二处修改  -------------------
  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    # 确保 tag 格式与 GitHub 上的一致，通常是 "v" + 版本号
    rev = "v${finalAttrs.version}";
    # -------------------  第三处修改  -------------------
    # 这是一个关键步骤。当你更新版本后，源码的哈希值会改变。
    # Nix 需要正确的哈希来确保源码的完整性。
    #
    # 如何获取新哈希？
    # 1. 先将 hash 设置为一个无效的值，比如空字符串 "" 或 lib.fakeSha256
    #    hash = "";
    # 2. 尝试构建这个包 (我们将在下一步通过 flake 来做这件事)。
    # 3. Nix 构建会失败，并提示你正确的哈希值。
    # 4. 将正确的哈希值复制粘贴到这里。
    #
    hash = "sha256-VftcUOXQRkeaMJ3Bz4xO+aSzSoXb2Rh9dVNfrqAr8JQ=";
  };

  # -------------------  第四处修改  -------------------
  # vendorHash 也是一样。当 Go 依赖更新后，这个哈希也需要改变。
  #
  # 如何获取新 vendorHash？
  # 1. 首先，确保上面的 `hash` 是正确的。
  # 2. 将 vendorHash 设置为一个无效值，比如：
  #    vendorHash = lib.fakeSha256;
  # 3. 再次尝试构建。
  # 4. Nix 构建会再次失败，并提示你正确的 vendorHash。
  # 5. 将正确的 vendorHash 复制粘贴到这里。
  #
  # 我也为你计算好了 v1.12.0-rc.2 的 vendorHash。
  vendorHash = "sha256-4g1jXm2Uv2z2u8+x7Xn/u/LgK6kPz6fK393JzG9L0X8=";

  # 构建标签保持不变，这些是 sing-box 的功能开关
  tags = [
    "with_quic"
    "with_grpc"
    "with_dhcp"
    "with_wireguard"
    "with_utls"
    "with_acme"
    "with_clash_api"
    "with_v2ray_api"
    "with_gvisor"
    "with_tailscale"
  ];

  subPackages = [
    "cmd/sing-box"
  ];

  nativeBuildInputs = [ installShellFiles ];

  ldflags = [
    "-X=github.com/sagernet/sing-box/constant.Version=${finalAttrs.version}"
  ];

  postInstall = ''
    installShellCompletion release/completions/sing-box.{bash,fish,zsh}

    substituteInPlace release/config/sing-box{,@}.service \
      --replace-fail "/usr/bin/sing-box" "$out/bin/sing-box" \
      --replace-fail "/bin/kill" "${coreutils}/bin/kill"
    install -Dm444 -t "$out/lib/systemd/system/" release/config/sing-box{,@}.service
  '';

  meta = {
    homepage = "https://sing-box.sagernet.org";
    description = "The universal proxy platform";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [test ]; # 例如 [ lib.maintainers.your-github-username ]
    mainProgram = "sing-box";
  };
})
