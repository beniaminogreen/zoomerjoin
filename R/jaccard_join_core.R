
#' @importFrom dplyr pull %>%
jaccard_join  <- function(a, b, by_a, by_b, block_by_a, block_by_b, n_gram_width, n_bands,
                          band_width, threshold, progress = FALSE, a_salt = NULL, b_salt = NULL,
                         clean = FALSE, nthread = NULL) {

  stopifnot("'threshold' must be of length 1" = length(threshold) == 1)
  stopifnot("'threshold' must be between 0 and 1" = threshold <= 1 & threshold >= 0)

  stopifnot("'by_a' must be of length 1" = length(by_a) == 1)
  stopifnot("'by_b' must be of length 1" = length(by_b) == 1)

  stopifnot("'n_bands' must be greater than 0" = n_bands > 0)
  stopifnot("'n_bands' must be length than 1" = length(n_bands) == 1)

  stopifnot("'band_width' must be greater than 0" = band_width > 0)
  stopifnot("'band_width' must be length than 1" = length(band_width) == 1)

  stopifnot("'n_gram_width' must be greater than 0" = n_gram_width > 0)
  stopifnot("'n_gram_width' must be length than 1" = length(n_gram_width) == 1)

  thresh_prob <- jaccard_probability(threshold, n_bands, band_width)

  if (thresh_prob < .95) {
    str <- paste0(
      "A pair of records at the threshold (", threshold,
      ") have only a ", round(thresh_prob * 100), "% chance of being compared.\n",
      "Please consider changing `n_bands` and `band_width`."
    )
    warning(str)
  }

  stopifnot("'by' vectors must have length 1" = length(by_a) == 1)
  stopifnot("'by' vectors must have length 1" = length(by_b) == 1)

  stopifnot("There should be no NA's in by_a" = !anyNA(a[[by_a]]))
  stopifnot("There should be no NA's in by_b" = !anyNA(b[[by_b]]))

  # Clean strings that are matched on
  if (clean) {
    a_col <- tolower(gsub("[[:punct:] ]", "", dplyr::pull(a, by_a)))
    b_col <- tolower(gsub("[[:punct:] ]", "", dplyr::pull(b, by_b)))

    if (!is.null(block_by_a) && !is.null(block_by_b)) {
      a_salt_col <- tidyr::unite(a, "block_by_a", dplyr::all_of(block_by_a)) %>%
        dplyr::pull("block_by_a")
      b_salt_col <- tidyr::unite(b, "block_by_b", dplyr::all_of(block_by_b)) %>%
        dplyr::pull("block_by_b")

      a_salt_col <- tolower(gsub("[[:punct:] ]", "", a_salt_col))
      b_salt_col <- tolower(gsub("[[:punct:] ]", "", b_salt_col))
    }
  } else {
    a_col <- dplyr::pull(a, by_a)
    b_col <- dplyr::pull(b, by_b)

    if (!is.null(block_by_a) && !is.null(block_by_b)) {
      a_salt_col <- tidyr::unite(a, "block_by_a", dplyr::all_of(block_by_a)) %>%
        dplyr::pull("block_by_a")

      b_salt_col <- tidyr::unite(b, "block_by_b", dplyr::all_of(block_by_b)) %>%
        dplyr::pull("block_by_b")
    }
  }

  if (is.null(block_by_a) || is.null(block_by_b)) {
    match_table <- rust_jaccard_join(
      a_col, b_col,
      n_gram_width, n_bands, band_width, threshold,
      progress,
      seed = 1,
      nthread = nthread
    )
  } else {
    match_table <- rust_salted_jaccard_join(
      a_col, b_col,
      a_salt_col, b_salt_col,
      n_gram_width, n_bands, band_width, threshold,
      progress,
      seed = round(runif(1, 0, 2^64)),
      nthread = nthread
    )
  }

  similarities <- jaccard_similarity(
      pull(a[match_table[, 1], ], by_a),
      pull(b[match_table[, 2], ], by_b),
       n_gram_width,
      nthread = nthread
     )

  return(list(
              match_table = match_table,
              similarities = similarities
    ))
}



