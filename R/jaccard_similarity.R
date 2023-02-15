#' Calculate jaccard_similarity of two character vectors
#'
#' @param a the first character vector
#' @param b the first character vector
#'
#' @param ngram_width the length of the shingles / ngrams used in the
#' similarity calculation
#'
#'
#' @export
jaccard_similarity <- function(a, b, ngram_width=2) {
    stopifnot(length(a) == length(b))
    rust_jaccard_similarity(a, b, ngram_width)
}
