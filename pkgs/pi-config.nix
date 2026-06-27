{ lib
, stdenvNoCC
, buildNpmPackage
, fetchFromGitHub
}:

let
  sandbox = buildNpmPackage rec {
    pname = "pi-sandbox";
    version = "1.1.1";

    src = fetchFromGitHub {
      owner = "sysid";
      repo = "pi-extensions";
      rev = "sandbox-v${version}";
      hash = "sha256-kSxaXlNksQDUY95j+vVws/MAeDbRofjx4A1re6usuds=";
    };

    # npm workspace root
    npmRoot = ".";
    npmDepsHash = "sha256-8s9lL2+SPFDePWFfs/RVAWV7OG2MtpUpPzL+ZIjU6kc=";

    # No build step needed for this extension
    dontNpmBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out"

      # The extension root pi will load
      cp -r packages/sandbox/* "$out/"

      # Keep workspace symlink targets valid
      mkdir -p "$out/packages"
      cp -r packages/sandbox "$out/packages/"
      if [ -d packages/access-guard ]; then
        cp -r packages/access-guard "$out/packages/"
      fi
      if [ -d packages/vim-editor ]; then
        cp -r packages/vim-editor "$out/packages/"
      fi

      # Copy the full installed dependency tree, not just one package
      cp -r node_modules "$out/"

      runHook postInstall
    '';

    meta = with lib; {
      description = "Sandbox extension for pi";
      homepage = "https://github.com/sysid/pi-extensions";
      license = licenses.mit;
      platforms = platforms.unix;
    };
  };

  # pi-questions: structured ask_questions tool extension
  pi-questions = stdenvNoCC.mkDerivation rec {
    pname = "pi-questions";
    version = "0.3.4";

    src = fetchFromGitHub {
      owner = "drsh4dow";
      repo = "pi-questions";
      rev = "main";
      hash = "sha256-9IlYbtMxU3QJtFh6pAqQrE+fk74WIp9ItycJkJ18aQo=";
    };

    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r "$src/extensions/ask-questions.ts" "$out/"
      runHook postInstall
    '';

    meta = with lib; {
      description = "Structured ask_questions tool for Pi planning and clarification flows";
      homepage = "https://github.com/drsh4dow/pi-questions";
      license = licenses.unlicense;
      platforms = platforms.unix;
    };
  };
in

stdenvNoCC.mkDerivation {
  pname = "pi-config";
  version = "0.1.0";
  src = ../.;

  nativeBuildInputs = [ ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"

    # Copy sandbox extension
    mkdir -p "$out/extensions"
    cp -r ${sandbox} "$out/extensions/sandbox"

    # Copy extensions from repo root (e.g. sandbox.json config)
    if [ -d extensions ]; then
      cp -r extensions/* "$out/extensions/" 2>/dev/null || true
    fi

    # Copy pi-questions extension
    mkdir -p "$out/extensions"
    cp -r ${pi-questions}/* "$out/extensions/"

    # Copy skills
    if [ -d skills ]; then
      cp -r skills "$out/"
    fi

    # Copy prompts
    if [ -d prompts ]; then
      cp -r prompts "$out/"
    fi

    # Copy themes
    if [ -d themes ]; then
      cp -r themes "$out/"
    fi

    runHook postInstall
  '';

  meta = with lib; {
    description = "Pi agent configuration — extensions, skills, prompts, and themes";
    homepage = "https://github.com/sysid/pi-tools";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
