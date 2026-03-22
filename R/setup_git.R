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
# system("git push -u origin master")
