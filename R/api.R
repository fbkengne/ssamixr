# ============================================================
# User-facing API for ssamixr
# ============================================================

#' @import dplyr
#' @import tidyr
#' @import reshape2
#' @import ggplot2
NULL

#' List all available SSA social contact matrices
#'
#' @description
#' Returns a tibble with metadata for all matrices included in the ssamixr package.
#'
#' @details
#' For a complete catalogue of all 171 matrices across 18 Sub-Saharan African countries,
#' see the appendix included in the package:
#' \code{system.file("extdata", "social_contact_appendix.pdf", package = "ssamixr")}.
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
#'   "All", "HH", "NonHH", "School", "Work", "Other".
#'
#' @details
#' For a complete catalogue of all 171 matrices across 18 Sub-Saharan African countries,
#' see the appendix included in the package:
#' \code{system.file("extdata", "social_contact_appendix.pdf", package = "ssamixr")}.
#'
#' @return A tibble containing only matrices that match the filters.
#' @export
filter_matrices <- function(country = NULL,
                            study_id = NULL,
                            author_year = NULL,
                            location_type = NULL) {

  df <- ssa_matrices_meta

  # Step 1: Expand location_type internally
  df_expanded <- df %>%
    dplyr::mutate(row_id = dplyr::row_number()) %>%   # track original rows
    tidyr::separate_rows(location_type, sep = ";")

  # Step 2: Apply filters on expanded data
  if (!is.null(country)) {
    df_expanded <- dplyr::filter(df_expanded, country %in% !!country)
  }
  if (!is.null(study_id)) {
    df_expanded <- dplyr::filter(df_expanded, study_id %in% !!study_id)
  }
  if (!is.null(author_year)) {
    df_expanded <- dplyr::filter(df_expanded, author_year %in% !!author_year)
  }
  if (!is.null(location_type)) {
    df_expanded <- dplyr::filter(df_expanded, location_type %in% !!location_type)
  }

  # Step 3: Return original rows (preserve combined location_type)
  df %>%
    dplyr::slice(unique(df_expanded$row_id))
}

#' Retrieve a specific social contact matrix by ID
#'
#' Returns the numeric matrix, row/column labels, and metadata
#' for a given matrix ID.
#'
#' @param matrix_id Character or numeric ID of the matrix.
#'
#' @details
#' For a complete catalogue of all 171 matrices across 18 Sub-Saharan African countries,
#' see the appendix included in the package:
#' \code{system.file("extdata", "social_contact_appendix.pdf", package = "ssamixr")}.
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

#' Plot a single social contact matrix
#'
#' @param m A list returned by get_matrix().
#' @param blank_color Color for missing cells.
#' @param low_color Low end of the fill gradient.
#' @param high_color High end of the fill gradient.
#' @param value_text Whether to print numeric values in cells.
#' @param size Text size for cell values.
#' @param col_label_orientation "normal", "vertical", or "auto".
#' @param base_size Base font size for the plot.
#'
#' @return A ggplot object.
#' @export
plot_matrix <- function(m,
                        blank_color = "grey90",
                        low_color = "white",
                        high_color = "red",
                        value_text = TRUE,
                        size = 4.5,
                        col_label_orientation = "auto",
                        base_size = 16) {

  stopifnot(is.list(m), !is.null(m$matrix))

  # Auto-rotate if many age groups
  if (col_label_orientation == "auto") {
    col_label_orientation <- if (length(m$col_labels) > 10) "vertical" else "normal"
  }

  df <- reshape2::melt(m$matrix, varnames = c("RowIdx", "ColIdx"), value.name = "Value")
  df$RowLabel <- m$row_labels[df$RowIdx]
  df$ColLabel <- m$col_labels[df$ColIdx]

  ggplot2::ggplot(df, ggplot2::aes(x = ColLabel, y = RowLabel)) +
    ggplot2::geom_tile(ggplot2::aes(fill = Value), color = "white", linewidth = 0.2) +
    { if (isTRUE(value_text)) ggplot2::geom_text(
      ggplot2::aes(label = ifelse(is.na(Value), "", round(Value, 2))),
      size = size, fontface = "bold"
    ) } +
    ggplot2::scale_fill_gradient(low = low_color, high = high_color, na.value = blank_color) +
    ggplot2::labs(
      title = paste0("Matrix — ", m$country, " (", m$location_type, ")"),
      subtitle = m$author_year,
      x = "Contacts age groups (years)",
      y = "Participants age groups (years)"
    ) +
    ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      axis.text.x = if (col_label_orientation == "vertical") {
        ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1)
      } else {
        ggplot2::element_text()
      },
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
      plot.subtitle = ggplot2::element_text(hjust = 0.5)   # CENTERED SUBTITLE
    )
}

#' Plot a single social contact matrix (gradientn palette)
#'
#' @param m A list returned by get_matrix().
#' @param blank_color Color for missing cells.
#' @param value_text Whether to print numeric values in cells.
#' @param size Text size for cell values.
#' @param col_label_orientation "normal", "vertical", or "auto".
#' @param base_size Base font size for the plot.
#'
#' @return A ggplot object.
#' @export
plot_matrix_gradient <- function(m,
                                 blank_color = "grey90",
                                 value_text = TRUE,
                                 size = 4.5,
                                 col_label_orientation = "auto",
                                 base_size = 16) {

  stopifnot(is.list(m), !is.null(m$matrix))

  # Auto-rotate if many age groups
  if (col_label_orientation == "auto") {
    col_label_orientation <- if (length(m$col_labels) > 10) "vertical" else "normal"
  }

  df <- reshape2::melt(m$matrix, varnames = c("RowIdx", "ColIdx"), value.name = "Value")
  df$RowLabel <- m$row_labels[df$RowIdx]
  df$ColLabel <- m$col_labels[df$ColIdx]

  ggplot2::ggplot(df, ggplot2::aes(x = ColLabel, y = RowLabel)) +
    ggplot2::geom_tile(ggplot2::aes(fill = Value), color = "white", linewidth = 0.2) +
    { if (isTRUE(value_text)) ggplot2::geom_text(
      ggplot2::aes(label = ifelse(is.na(Value), "", round(Value, 2))),
      size = size, fontface = "bold"
    ) } +
    ggplot2::scale_fill_gradientn(
      colours = c("#FFFFCC", "#9E9AC8", "#6A51A3", "#3F007D"),
      na.value = blank_color
    ) +
    ggplot2::labs(
      title = paste0("Matrix — ", m$country, " (", m$location_type, ")"),
      subtitle = m$author_year,
      x = "Contacts age groups (years)",
      y = "Participants age groups (years)"
    ) +
    ggplot2::theme_minimal(base_size = base_size) +
    ggplot2::theme(
      axis.text.x = if (col_label_orientation == "vertical") {
        ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1)
      } else {
        ggplot2::element_text()
      },
      plot.title = ggplot2::element_text(face = "bold", hjust = 0.5),
      plot.subtitle = ggplot2::element_text(hjust = 0.5)   # CENTERED SUBTITLE
    )
}
