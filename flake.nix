{
  description = "awchat — Android development environment (Nix + direnv)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Best declarative Android SDK solution in the Nix ecosystem
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      android-nixpkgs,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Android SDK composition for this project
      # Targeting Android 17 QPR Beta 3 (API 37) + AGP 8.9.2
      mkAndroidSdk =
        system:
        android-nixpkgs.sdk.${system} (
          sdkPkgs: with sdkPkgs; [
            # Using stable API 36 for reliable builds.
            # Android 17 (API 37) platform packages are not yet available in the public SDK repository.
            # Your physical device can still be Android 17 — the app will run fine.
            cmdline-tools-latest
            platforms-android-36
            build-tools-36-0-0
            platform-tools

            # If you have the Android 17 beta SDK installed locally via Android Studio,
            # you can temporarily switch the lines above to:
            # platforms-android-37
            # build-tools-37-0-0

            # Highly recommended for development
            # emulator
            # sources-android-36
          ]
        );
    in
    {
      # `nix develop` / direnv entry point
      devShells = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true; # Android SDK license acceptance
          };

          android-sdk = mkAndroidSdk system;

          # Use the same JDK family as the project (Temurin 21)
          jdk = pkgs.temurin-bin-21;
        in
        {
          default = pkgs.mkShell {
            name = "awchat-dev";

            packages = with pkgs; [
              jdk
              android-sdk
              gradle
              just # Excellent for project-specific tasks (see Justfile)
            ];

            # Environment variables expected by Gradle / Android tooling
            ANDROID_HOME = "${android-sdk}/share/android-sdk";
            ANDROID_SDK_ROOT = "${android-sdk}/share/android-sdk";
            JAVA_HOME = jdk;

            # Make adb, emulator, etc. available in PATH
            # Strongly put JAVA_HOME first so ./gradlew works even if no system Java is installed
            shellHook = ''
              export PATH="$JAVA_HOME/bin:$PATH"
              export PATH="$ANDROID_HOME/platform-tools:$PATH"
              export PATH="$ANDROID_HOME/emulator:$PATH"

              echo ""
              echo "🚀 AWChat development environment ready (API 36)"
              echo "   • Java:   $(java -version 2>&1 | head -1)"
              echo "   • ANDROID_HOME: $ANDROID_HOME"
              echo ""
              echo "Common commands (Justfile recommended):"
              echo "  just build            # Gradle build"
              echo "  just test             # Unit tests"
              echo ""
              echo "  adb devices"
              echo "  adb logcat -s AWChat:*"
              echo ""
            '';
          };
        }
      );

      # Convenience: `nix run .` opens a shell (same as nix develop)
      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.devShells.${system}.default}/bin/bash";
        };
      });
    };
}
