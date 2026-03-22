# ============================================================
# Git + GitHub Setup Script for ssamixr
# Author: Francis Barnabe Kengne
# Purpose: Initialize Git, configure identity, and connect
#          the local R package to GitHub.
# ============================================================

# Load required package
if (!requireNamespace("pacman", quietly = TRUE)) {
  install.packages("pacman")
}
pacman::p_load(usethis, gitcreds)

# ------------------------------------------------------------
# 1. Set Git identity (run once per machine)
# ------------------------------------------------------------
use_git_config(
  user.name  = "Francis Barnabe Kengne",
  user.email = "fbkengne@gmail.com"
)

# ------------------------------------------------------------
# 2. Initialize Git in the project
# ------------------------------------------------------------
use_git()

# Verify Git installation
system("git --version")

# ------------------------------------------------------------
# 3. Create and store GitHub token (manual step)
# ------------------------------------------------------------
# Run this to open GitHub in your browser:
# usethis::create_github_token()
#
# Then store the token securely:
# gitcreds::gitcreds_set()
#
# IMPORTANT:
# Never paste your token inside this script.

# ------------------------------------------------------------
# 4. Add GitHub remote manually
# ------------------------------------------------------------
usethis::use_git_remote(
  name = "origin",
  url = "https://github.com/fbkengne/ssamixr.git"
)

# ------------------------------------------------------------
# 5. Mark this directory as safe for Git
# ------------------------------------------------------------
system('git config --global --add safe.directory D:/ssamixr')

# ------------------------------------------------------------
# 6. Verify remote
# ------------------------------------------------------------
system("git remote -v")

# ------------------------------------------------------------
# 7. Push manually using RStudio Git pane or:
# ------------------------------------------------------------
 system("git push -u origin master")

# 3 commit failed due to security violation, so we reset 3 times
system("git reset --soft HEAD~3")

#Force-push the cleaned history
system("git push -u origin master --force-with-lease")

#Check the remote branch names
system("git ls-remote --heads origin")

#If the remote branch is main
system("git push origin --delete main")

#Then push your clean branch:
#Rename your local branch to main
system("git branch -M main")

#Fetch the latest remote branch
system("git fetch origin")

#Set your local branch to track the remote
system("git branch -u origin/main")

#Try the force‑push again
system("git push -u origin main --force")

#Confirm the sensitive commit is gone from your history
system("git log --oneline")

#Hard reset to the clean commit
system("git reset --hard 14bc8f4")

#Rewrite history to remove earlier commits
system("git push origin main --force")

#Bump the version in DESCRIPTION
usethis::use_version("minor")
