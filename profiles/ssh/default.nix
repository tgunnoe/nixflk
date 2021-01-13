{ ... }: {
  services.openssh = {
    enable = true;
    challengeResponseAuthentication = false;
    passwordAuthentication = true;
    forwardX11 = true;
  };
}
