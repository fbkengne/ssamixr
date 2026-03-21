# ============================================================
# Build per-matrix list and country-level structures
# ============================================================

#' Build per-matrix objects from aggregated data
#'
#' Converts the raw MatrixData_aggregated data frame into a list
#' of structured per-matrix objects used internally by ssamixr.
#'
#' @param matrix_df A data frame containing matrix elements,
#'   age groups, and study metadata.
#'
#' @return A list of per-matrix objects.
#' @export
build_per_matrix_list <- function(matrix_df) {
  rows_list <- split(matrix_df, seq_len(nrow(matrix_df)))
  purrr::map(rows_list, ~ build_per_matrix(.x, matrix_df))
}

#' Build country-level list of matrices
#'
#' Groups per-matrix objects by country and assigns facet labels
#' used for plotting.
#'
#' @param per_matrix_list A list returned by build_per_matrix_list().
#'
#' @return A named list:
#'  country -> list of per-matrix objects with FacetLabel added.
#'
#' @export
build_country_list <- function(per_matrix_list) {

  # Split by country
  country_list <- split(per_matrix_list, sapply(per_matrix_list, `[[`, "Country"))

  # Add facet labels
  purrr::imap(country_list, function(mats, country) {

    # Kenya and South Africa use numeric labels
    if (country %in% c("Kenya", "South Africa")) {
      panel_ids <- paste0(seq_along(mats), ")")
    } else {
      # Other countries use letters
      panel_ids <- paste0(make.unique(LETTERS, sep = ""), ")")[seq_along(mats)]
    }

    purrr::map2(mats, panel_ids, function(mo, pid) {
      mo$FacetLabel <- pid
      mo
    })
  })
}

#' Build long-format data for a given country
#'
#' Converts all matrices for a country into a long-format tibble
#' suitable for heatmap plotting.
#'
#' @param country_name Name of the country.
#'
#' @return A tibble in long format.
#' @export
build_country_long <- function(country_name) {

  # Use lazy-loaded internal object
  mats <- country_list[[country_name]]
  stopifnot(!is.null(mats))

  long_list <- purrr::map(mats, matrix_to_long)
  df_long <- dplyr::bind_rows(long_list)

  df_long |>
    dplyr::group_by(MatrixId) |>
    dplyr::mutate(
      RowLabel = factor(RowLabel, levels = unique(RowLabel)),
      ColLabel = factor(ColLabel, levels = unique(ColLabel))
    ) |>
    dplyr::ungroup()
}
