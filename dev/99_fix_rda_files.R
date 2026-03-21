# ============================================================
# FIX ALL .rda FILES IN THE PACKAGE DATA FOLDER
# Ensures each .rda file contains exactly ONE object
# ============================================================

data_files <- list.files("data", pattern = "\\.rda$", full.names = TRUE)

for (file in data_files) {

  message("\nProcessing: ", file)

  # Load file into isolated environment
  env <- new.env()
  load(file, envir = env)

  # List objects inside the file
  objs <- ls(env)
  message("Objects found: ", paste(objs, collapse = ", "))

  # Determine the correct object name based on filename
  correct_name <- tools::file_path_sans_ext(basename(file))

  if (!(correct_name %in% objs)) {
    stop("ERROR: Expected object '", correct_name, "' not found in ", file)
  }

  # Extract the correct object
  obj <- env[[correct_name]]

  # Overwrite the file with ONLY the correct object
  save(list = correct_name, file = file, envir = env)

  message("✔ Saved ONLY object '", correct_name, "' into ", file)
}

message("\nALL DATASETS FIXED SUCCESSFULLY.")
