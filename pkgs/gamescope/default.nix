{ gamescope'
, fetchpatch
, fetchFromGitHub
}:

# NOTE: vendoring gamescope for the time being since we want to match the
#       version shipped by the vendor, ensuring feature level is equivalent.
#       We're also patching-in features.

gamescope'.overrideAttrs(old: rec {
  version = "3.15.14";

  src = fetchFromGitHub {
    owner = "ValveSoftware";
    repo = "gamescope";
    rev = version;
    fetchSubmodules = true;
    hash = "sha256-LVwwkISokjSXEYd/SFRtCDDY6P2sr6pQp8Xb8BsrXAw=";
  };

  patches = old.patches ++ [
    # wlserver: Sythesize QAM combo on F22
    (fetchpatch {
      url = "https://github.com/ValveSoftware/gamescope/commit/3df5a1bc977d36b68e15371b25dadc0380ffc9e0.patch";
      hash = "sha256-BbwAxJYPulOVB7m17R9yskwOePprSwoqKJ1V7dEASJI=";
    })
  ];
})
