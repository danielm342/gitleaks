#!/usr/bin/env python3

import subprocess
import sys
import os

GITLEAKS_URL = "https://github.com/zricethezav/gitleaks/releases/latest/download/gitleaks-{platform}-{arch}"
arch = "amd64"

def install_gitleaks():
    # Define the platform
    platform = sys.platform
    if platform.startswith("linux"):
        platform = "linux"
    elif platform.startswith("darwin"):
        platform = "darwin"
    elif platform.startswith("win"):
        platform = "windows"
    else:
        print("Unsupported platform")
        sys.exit(1)

    # Download the URL for the current platform and architecture
    download_url = GITLEAKS_URL.format(platform=platform, arch=arch)

    # Download gitleaks
    process = subprocess.Popen(["curl", "-L", download_url], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, error = process.communicate()

    # Save gitleaks to the current directory
    with open("gitleaks", "wb") as f:
        f.write(output)

    os.chmod("gitleaks", 0o755)

def run_gitleaks():
    # Run gitleaks to check for secrets
    process = subprocess.Popen(["./gitleaks", "--path", "."], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, error = process.communicate()

    return output.decode("utf-8"), error.decode("utf-8"), process.returncode

def main():
    # Get the enable value from git config
    enable = subprocess.check_output(["git", "config", "hooks.gitleaks.enable"]).decode("utf-8").strip()

    if enable.lower() != "true":
        # If enable is not set to "true", skip the check
        sys.exit(0)

    # Check if gitleaks is installed
    try:
        subprocess.check_output(["./gitleaks", "--version"])
    except FileNotFoundError:
        install_gitleaks()

    # Launching gitleaks
    output, error, returncode = run_gitleaks()

    if returncode != 0:
        # If the returned code is not 0, reject the commit
        print("Gitleaks discovered the presence of secrets in the code:")
        print(output)
        sys.exit(1)

if __name__ == "__main__":
    main()
