{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "sing-box";
  version = "1.12.0-rc.2";

  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    rev = "v${finalAttrs.version}";

    hash = "sha256-VftcUOXQRkeaMJ3Bz4xO+aSzSoXb2Rh9dVNfrqAr8JQ=";
  };
  vendorHash = "sha256-tyGCkVWfCp7F6NDw/AlJTglzNC/jTMgrL8q9Au6Jqec=";

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
  '';

  meta = {
    homepage = "https://sing-box.sagernet.org";
    description = "The universal proxy platform";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ sorubedo ];
    mainProgram = "sing-box";
  };
})
