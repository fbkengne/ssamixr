# ============================================================
# Git + GitHub Setup Script for ssamixr
# Author: Francis Barnabe Kengne
# Purpose: Initialize Git, configure identity, and connect
#          the local R package to GitHub.
# ============================================================

# Load required package
if (!requireNamespace("usethis", quietly = TRUE)) {
  install.packages("usethis")
}
library(usethis)

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
