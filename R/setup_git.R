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
pacman::p_load(
  usethis, gitcreds, usethis
)

# ------------------------------------------------------------
# 1. Set Git identity (run once per machine)
# ------------------------------------------------------------
use_git_config(
  user.name  = "Francis Barnabe Kengne",
  user.email = "fbkengne@gmail.com"
)

# ------------------------------------------------------------
# 2. Initialize Git in the project
#    (creates .git folder, stages files, first commit)
# ------------------------------------------------------------
use_git()

# ------------------------------------------------------------
# 3. Connect the local project to GitHub
#    (pushes all files to the GitHub repo you created)
# ------------------------------------------------------------
use_github()

# ------------------------------------------------------------
# After running this script:
# - Your package will be fully version-controlled
# - Your GitHub repo will contain all package files
# - Other researchers can install via:
#       devtools::install_github("fbkengne/ssamixr")
# ------------------------------------------------------------

# Create your GitHub token
usethis::create_github_token()

# This will:

# Open GitHub in your browser

# Take you directly to the “Generate new token (classic)” page

# On that page:

#  ✔ Token name
# R package development

# ✔ Expiration
# Choose 90 days or No expiration

# ✔ Scopes (VERY IMPORTANT)
# Check:

#  repo

# workflow (optional but recommended)

# Scroll down → click Generate token.

# 90 days token for the project
# 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

#Install github and verify the version
system("git --version")

# Store the token in R
gitcreds::gitcreds_set()


# Use github
usethis::use_github()







