# ===============================
# 1. Parsing utilities
# ===============================

parse_age_groups <- function(s) {
  if (is.na(s) || s == "") character(0) else strsplit(s, ";", fixed = TRUE)[[1]]
}

parse_matrix_elt <- function(matrix_str) {
  if (is.na(matrix_str) || matrix_str == "") return(matrix(NA_real_, 0, 0))

  rows <- strsplit(matrix_str, "\\|")[[1]]
  parsed_rows <- lapply(rows, function(r) {
    vals <- strsplit(r, ";")[[1]]
    suppressWarnings(as.numeric(ifelse(vals %in% c("NA", ""), NA, vals)))
  })

  max_len <- max(sapply(parsed_rows, length))
  padded_rows <- lapply(parsed_rows, function(row) {
    length(row) <- max_len
    row
  })

  do.call(rbind, padded_rows)
}

orient_matrix <- function(mat, row_participant_assignment) {
  if (isTRUE(row_participant_assignment)) mat else t(mat)
}

orient_labels <- function(row_labels, col_labels, row_participant_assignment) {
  if (isTRUE(row_participant_assignment)) {
    list(rows = row_labels, cols = col_labels)
  } else {
    list(rows = col_labels, cols = row_labels)
  }
}

# ===============================
# 2. Matrix validation
# ===============================

check_matrix_elt <- function(df) {
  problems <- list()

  for (i in seq_len(nrow(df))) {
    mat_id <- df$Matrix[i]
    elt <- df$MatrixElt[i]

    if (is.na(elt) || elt == "") {
      problems[[length(problems) + 1]] <- data.frame(
        Matrix = mat_id,
        Issue = "Empty or NA MatrixElt",
        stringsAsFactors = FALSE
      )
      next
    }

    rows <- strsplit(elt, "\\|")[[1]]
    row_lengths <- integer(length(rows))

    for (j in seq_along(rows)) {
      vals <- strsplit(rows[j], ";")[[1]]
      row_lengths[j] <- length(vals)

      bad_vals <- vals[!(vals %in% c("NA", "") | !is.na(suppressWarnings(as.numeric(vals))))]
      if (length(bad_vals) > 0) {
        problems[[length(problems) + 1]] <- data.frame(
          Matrix = mat_id,
          Issue = paste("Non-numeric values found:", paste(bad_vals, collapse = ",")),
          stringsAsFactors = FALSE
        )
      }
    }

    if (length(unique(row_lengths)) > 1) {
      problems[[length(problems) + 1]] <- data.frame(
        Matrix = mat_id,
        Issue = paste("Inconsistent row lengths:", paste(row_lengths, collapse = ",")),
        stringsAsFactors = FALSE
      )
    }
  }

  if (length(problems) == 0) {
    message("All MatrixElt entries passed the safety check.")
    return(NULL)
  } else {
    return(do.call(rbind, problems))
  }
}

# ===============================
# 3. Per-matrix object builder
# ===============================

`%||%` <- function(x, y) if (is.null(x) || length(x) == 0 || is.na(x)) y else x

derive_location_text <- function(row) {
  labs <- c(
    if (isTRUE(row$AllLocationMatrix)) "All",
    if (isTRUE(row$HHMatrix)) "HH",
    if (isTRUE(row$NonHHMatrix)) "NonHH",
    if (isTRUE(row$SchoolMatrix)) "School",
    if (isTRUE(row$WorkMatrix)) "Work",
    if (isTRUE(row$OtherLocationMatrix)) "Other"
  )
  labs <- labs[!is.na(labs)]
  if (length(labs) == 0) "—" else paste(labs, collapse = ";")
}

build_per_matrix <- function(row, meta_df) {
  mat_raw <- parse_matrix_elt(row$MatrixElt)
  mat <- orient_matrix(mat_raw, row$RowParticipantAssignment)

  r_labels_raw <- parse_age_groups(row$RowAgeGroup)
  c_labels_raw <- parse_age_groups(row$ColumnAgeGroup)
  labs <- orient_labels(r_labels_raw, c_labels_raw, row$RowParticipantAssignment)

  meta <- dplyr::filter(meta_df, Study == row$Study) |> dplyr::slice(1)

  list(
    Study = row$Study,
    Country = row$Country,
    MatrixId = row$Matrix,
    Matrix = mat,
    RowLabels = labs$rows,
    ColLabels = labs$cols,
    OriginalRowLabels = labs$rows,
    OriginalColLabels = labs$cols,
    OriginalRowLength = length(labs$rows),
    OriginalColLength = length(labs$cols),
    LocationText = derive_location_text(row),
    FacetAuthorYear = meta$Author..Year %||% "",
    FacetCollectionDate = meta$Data.collection.date %||% "",
    FacetReducedDef = meta$Reduced.contact.definition %||% "",
    FacetInformed = meta$Informed.Trained.in.advance. %||% "",
    FacetRefPeriod = meta$Reference.period.Method %||% "",
    FacetReducedMethod = meta$Reduced.Data.Collection.Method %||% "",
    FacetSetting = row$Setting %||% "",
    FacetContactDay = row$ContactDay %||% ""
  )
}

# ===============================
# 4. Padding helpers
# ===============================

pad_matrix <- function(mat, target_rows, target_cols) {
  if (length(mat) == 0) return(matrix(NA_real_, target_rows, target_cols))

  nr <- nrow(mat)
  nc <- ncol(mat)

  out <- matrix(NA_real_, nrow = target_rows, ncol = target_cols)
  out[seq_len(nr), seq_len(nc)] <- mat
  out
}

pad_labels <- function(rows, cols, target_rows, target_cols) {
  list(
    original_rows = rows,
    original_cols = cols,
    padded_rows = c(rows, rep("", max(0, target_rows - length(rows)))),
    padded_cols = c(cols, rep("", max(0, target_cols - length(cols))))
  )
}

# ===============================
# 5. Convert padded matrix to long format
# ===============================

matrix_to_long <- function(mo_padded) {
  df <- reshape2::melt(mo_padded$Matrix, varnames = c("RowIdx", "ColIdx"), value.name = "Value")

  df$RowLabel <- mo_padded$RowLabels[df$RowIdx]
  df$ColLabel <- mo_padded$ColLabels[df$ColIdx]
  df$Study <- mo_padded$Study
  df$MatrixId <- mo_padded$MatrixId

  df$OriginalRowLength <- mo_padded$OriginalRowLength
  df$OriginalColLength <- mo_padded$OriginalColLength

  df$FacetLabel <- mo_padded$FacetLabel
  df$FacetLabelFull <- paste0(mo_padded$FacetLabel, " ", mo_padded$FacetAuthorYear)

  df
}

# ===============================
# 6. Build long-format data for a country
# ===============================

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

# ===============================
# 7. Plotting functions
# ===============================

#' Plot heatmaps for all matrices in a country
#'
#' @param df_long Long-format data from build_country_long().
#' @param country_name Country name for the title.
#' @param ncol Number of columns in the facet layout.
#' @param blank_color Color for missing cells.
#' @param value_text Whether to print numeric values in cells.
#' @param show_original_guides Whether to show dashed lines for original matrix size.
#' @param main_title_size Font size for the main title.
#' @param title_size Font size for facet titles.
#' @param axis_text_size Font size for axis labels.
#' @param axis_title_size Font size for axis titles.
#' @param legend_text_size Font size for legend text.
#' @param legend_title_size Font size for legend title.
#' @param partition Whether this plot is part of a multi-panel figure.
#' @param size Text size for cell values.
#' @param col_label_orientation "normal" or "vertical".
#'
#' @return A ggplot object.
#' @export
plot_country_heatmaps <- function(df_long,
                                  country_name,
                                  ncol = 2,
                                  blank_color = "grey90",
                                  low_color = "white",
                                  high_color = "red",
                                  value_text = TRUE,
                                  show_original_guides = TRUE,
                                  main_title_size = 14,
                                  title_size = 10,
                                  axis_text_size = 10,
                                  axis_title_size = 10,
                                  legend_text_size = 8,
                                  legend_title_size = 12,
                                  partition = FALSE,
                                  size = 4,
                                  col_label_orientation = "normal") {

  guide_df <- NULL
  if (isTRUE(show_original_guides)) {
    guide_df <- df_long |>
      dplyr::group_by(MatrixId) |>
      dplyr::summarise(
        y_guide = dplyr::first(OriginalRowLength),
        x_guide = dplyr::first(OriginalColLength),
        .groups = "drop"
      )
  }

  p <- ggplot2::ggplot(df_long, ggplot2::aes(x = ColLabel, y = RowLabel)) +
    ggplot2::geom_tile(ggplot2::aes(fill = Value), color = "white", linewidth = 0.2) +
    { if (isTRUE(value_text)) ggplot2::geom_text(ggplot2::aes(label = ifelse(is.na(Value), "", round(Value, 2))), size = size, fontface = "bold") } +
    ggplot2::scale_fill_gradient(low = low_color, high = high_color, na.value = blank_color) +
    ggplot2::scale_y_discrete() +
    ggplot2::scale_x_discrete() +
    ggplot2::facet_wrap(ggplot2::vars(FacetLabelFull), ncol = ncol, scales = "free") +
    ggplot2::labs(
      title = ifelse(partition, "", paste0("Social contact matrices — ", country_name)),
      y = "Participants age groups (years)",
      x = "Contacts age groups (years)"
    ) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = main_title_size, face = "bold", hjust = 0.5),
      axis.text.x = if (col_label_orientation == "vertical") {
        ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1, size = axis_text_size)
      } else {
        ggplot2::element_text(size = axis_text_size)
      },
      axis.text.y = ggplot2::element_text(size = axis_text_size),
      axis.title.x = ggplot2::element_text(size = axis_title_size),
      axis.title.y = ggplot2::element_text(size = axis_title_size),
      legend.position = "right",
      legend.title = ggplot2::element_text(size = legend_title_size),
      legend.text = ggplot2::element_text(size = legend_text_size),
      strip.text = ggplot2::element_text(size = title_size, face = "bold", hjust = 0)
    )

  if (!is.null(guide_df)) {
    p <- p +
      ggplot2::geom_hline(
        data = guide_df,
        ggplot2::aes(yintercept = y_guide + 0.5),
        linetype = "dashed",
        color = "grey50"
      ) +
      ggplot2::geom_vline(
        data = guide_df,
        ggplot2::aes(xintercept = x_guide + 0.5),
        linetype = "dashed",
        color = "grey50"
      )
  }

  p
}

#' Plot heatmaps for all matrices in a country (gradientn palette)
#'
#' @param df_long Long-format data from build_country_long().
#' @param country_name Country name for the title.
#' @param ncol Number of columns in the facet layout.
#' @param blank_color Color for missing cells.
#' @param value_text Whether to print numeric values in cells.
#' @param show_original_guides Whether to show dashed lines for original matrix size.
#' @param main_title_size Font size for the main title.
#' @param title_size Font size for facet titles.
#' @param axis_text_size Font size for axis labels.
#' @param axis_title_size Font size for axis titles.
#' @param legend_text_size Font size for legend text.
#' @param legend_title_size Font size for legend title.
#' @param partition Whether this plot is part of a multi-panel figure.
#' @param size Text size for cell values.
#' @param col_label_orientation "normal" or "vertical".
#'
#' @return A ggplot object.
#' @export
plot_country_heatmaps_gradientn <- function(df_long,
                                            country_name,
                                            ncol = 2,
                                            blank_color = "grey90",
                                            value_text = TRUE,
                                            show_original_guides = TRUE,
                                            main_title_size = 14,
                                            title_size = 10,
                                            axis_text_size = 10,
                                            axis_title_size = 10,
                                            legend_text_size = 8,
                                            legend_title_size = 12,
                                            partition = FALSE,
                                            size = 4,
                                            col_label_orientation = "normal") {

  guide_df <- NULL
  if (isTRUE(show_original_guides)) {
    guide_df <- df_long |>
      dplyr::group_by(MatrixId) |>
      dplyr::summarise(
        y_guide = dplyr::first(OriginalRowLength),
        x_guide = dplyr::first(OriginalColLength),
        .groups = "drop"
      )
  }

  p <- ggplot2::ggplot(df_long, ggplot2::aes(x = ColLabel, y = RowLabel)) +
    ggplot2::geom_tile(ggplot2::aes(fill = Value), color = "white", linewidth = 0.2) +
    { if (isTRUE(value_text)) ggplot2::geom_text(ggplot2::aes(label = ifelse(is.na(Value), "", round(Value, 2))), size = size, fontface = "bold") } +
    ggplot2::scale_fill_gradientn(
      colours = c("#FFFFCC", "#9E9AC8", "#6A51A3", "#3F007D"),
      na.value = blank_color
    ) +
    ggplot2::scale_y_discrete() +
    ggplot2::scale_x_discrete() +
    ggplot2::facet_wrap(ggplot2::vars(FacetLabelFull), ncol = ncol, scales = "free") +
    ggplot2::labs(
      title = ifelse(partition, "", paste0("Social contact matrices — ", country_name)),
      y = "Participants age groups (years)",
      x = "Contacts age groups (years)"
    ) +
    ggplot2::theme_minimal(base_size = 14) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(size = main_title_size, face = "bold", hjust = 0.5),
      axis.text.x = if (col_label_orientation == "vertical") {
        ggplot2::element_text(angle = 90, vjust = 0.5, hjust = 1, size = axis_text_size)
      } else {
        ggplot2::element_text(size = axis_text_size)
      },
      axis.text.y = ggplot2::element_text(size = axis_text_size),
      axis.title.x = ggplot2::element_text(size = axis_title_size),
      axis.title.y = ggplot2::element_text(size = axis_title_size),
      legend.position = "right",
      legend.title = ggplot2::element_text(size = legend_title_size),
      legend.text = ggplot2::element_text(size = legend_text_size),
      strip.text = ggplot2::element_text(size = title_size, face = "bold", hjust = 0)
    )

  if (!is.null(guide_df)) {
    p <- p +
      ggplot2::geom_hline(
        data = guide_df,
        ggplot2::aes(yintercept = y_guide + 0.5),
        linetype = "dashed",
        color = "grey50"
      ) +
      ggplot2::geom_vline(
        data = guide_df,
        ggplot2::aes(xintercept = x_guide + 0.5),
        linetype = "dashed",
        color = "grey50"
      )
  }

  p
}
