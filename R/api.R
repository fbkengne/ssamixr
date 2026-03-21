# ============================================================
# User-facing API for ssamixr
# ============================================================

#' List all available SSA social contact matrices
#'
#' Returns a tibble containing metadata for all matrices included
#' in the ssamixr package.
#'
#' @return A tibble with one row per matrix and metadata columns.
#' @export
list_matrices <- function() {
  ssa_matrices_meta
}

#' Filter matrices by metadata fields
#'
#' Allows users to filter the available social contact matrices
#' by country, study ID, author-year, or location type.
#'
#' @param country Optional character vector of country names.
#' @param study_id Optional character vector of study IDs.
#' @param author_year Optional character vector of author-year labels.
#' @param location_type Optional character vector such as
#'   "All", "HH", "School", "Work", "Other".
#'
#' @return A tibble containing only matrices that match the filters.
#' @export
filter_matrices <- function(country = NULL,
                            study_id = NULL,
                            author_year = NULL,
                            location_type = NULL) {

  df <- ssa_matrices_meta

  if (!is.null(country)) {
    df <- dplyr::filter(df, country %in% !!country)
  }
  if (!is.null(study_id)) {
    df <- dplyr::filter(df, study_id %in% !!study_id)
  }
  if (!is.null(author_year)) {
    df <- dplyr::filter(df, author_year %in% !!author_year)
  }
  if (!is.null(location_type)) {
    df <- dplyr::filter(df, location_type %in% !!location_type)
  }

  df
}

#' Retrieve a specific social contact matrix by ID
#'
#' Returns the numeric matrix, row/column labels, and metadata
#' for a given matrix ID.
#'
#' @param matrix_id Character or numeric ID of the matrix.
#'
#' @return A list containing:
#'   \describe{
#'     \item{matrix}{Numeric matrix of contact rates}
#'     \item{row_labels}{Character vector of participant age groups}
#'     \item{col_labels}{Character vector of contact age groups}
#'     \item{study_id}{Study identifier}
#'     \item{author_year}{Author-year label}
#'     \item{country}{Country name}
#'     \item{location_type}{Location type (All, HH, School, etc.)}
#'   }
#'
#' @export
get_matrix <- function(matrix_id) {
  matrix_id <- as.character(matrix_id)

  if (!matrix_id %in% names(ssa_matrices_list)) {
    stop("Matrix ID not found. Use list_matrices() to see available IDs.")
  }

  ssa_matrices_list[[matrix_id]]
}
