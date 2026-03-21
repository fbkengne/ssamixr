#' Metadata for all SSA social contact matrices
#'
#' A tibble containing metadata for all matrices included in the package.
#'
#' @format A tibble with columns:
#' \describe{
#'   \item{matrix_id}{Matrix identifier}
#'   \item{study_id}{Study identifier}
#'   \item{author_year}{Author-year label}
#'   \item{country}{Country name}
#'   \item{location_type}{Location type}
#'   \item{row_age_groups}{Row age groups}
#'   \item{col_age_groups}{Column age groups}
#' }
#'
#' @usage data(ssa_matrices_meta)
#' @docType data
#' @keywords datasets
"ssa_matrices_meta"

#' List of matrices grouped by country
#'
#' A named list where each element corresponds to a country and contains
#' all matrices for that country.
#'
#' @usage data(country_list)
#' @docType data
#' @keywords datasets
"country_list"
