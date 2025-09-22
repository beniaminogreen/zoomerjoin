hamming_join <- function(a, b, by_a, by_b, block_by_a, block_by_b, n_bands, band_width,
                         threshold, progress = FALSE,
                         similarity_column = NULL,
                         clean = FALSE,
                         nthread = NULL) {
  a <- tibble::as_tibble(a)
  b <- tibble::as_tibble(b)

  stopifnot("'threshold' must be of length 1" = length(threshold) == 1)
  stopifnot("'threshold' must be greater than 0" = threshold > 0)

  stopifnot("'n_bands' must be greater than 0" = n_bands > 0)
  stopifnot("'n_bands' must be length than 1" = length(n_bands) == 1)

  stopifnot("'band_width' must be greater than 0" = band_width > 0)
  stopifnot("'band_width' must be length than 1" = length(band_width) == 1)

  stopifnot("'by' vectors must have length 1" = length(by_a) == 1)
  stopifnot("'by' vectors must have length 1" = length(by_b) == 1)

  stopifnot("There should be no NA's in by_a" = !anyNA(a[[by_a]]))
  stopifnot("There should be no NA's in by_b" = !anyNA(b[[by_b]]))

  # Clean strings that are matched on
  if (clean) {
    a_col <- tolower(gsub("[[:punct:] ]", "", dplyr::pull(a, by_a)))
    b_col <- tolower(gsub("[[:punct:] ]", "", dplyr::pull(b, by_b)))
  } else {
    a_col <- dplyr::pull(a, by_a)
    b_col <- dplyr::pull(b, by_b)
  }

  max_chars <- max(c(nchar(a_col), nchar(b_col)))
  thresh_prob <- hamming_probability(threshold, max_chars, n_bands, band_width)

  if (thresh_prob < .95) {
    str <- paste0(
      "A pair of records at the threshold (", threshold,
      ") have only a ", round(thresh_prob * 100), "% chance of being compared.\n",
      "Please consider changing `n_bands` and `band_width`."
    )

    warning(str)
  }

  match_table <- rust_hamming_join(
    a_col, b_col,
    band_width, n_bands, threshold,
    progress,
    seed = 1,
    nthread = nthread
  )

  sims <- hamming_distance(
      pull(a[match_table[, 1], ], by_a),
      pull(b[match_table[, 2], ], by_b),
      nthread = nthread
  )

  return(
         list(
              match_table = match_table,
              similarities = sims
         )
  )
}
