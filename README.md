## Usage instructions

 1. Add the pre-commit-hook.sh file to your project directory

 2. To use the script, create a `pre-commit` file in the `.git/hooks/` folder of your repository with the following contents:
```
 #!/bin/sh
 python3 /full_path/pre-commit-hook.sh
```
 3. Run the following commands to enable the hook and set the enable value in git config:
```
 git config hooks.gitleaks.enable true
 chmod +x /full_path/pre-commit
```
With each commit, git will automatically execute a script, install gitleaks (if not installed), and check for secrets using gitleaks. If secrets are found or the option is disabled, the commit will be rejected.
