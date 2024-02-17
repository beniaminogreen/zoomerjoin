#' Calculate Jaccard Similarity of two character vectors
#'
#' @param a the first character vector
#' @param b the first character vector
#'
#' @param ngram_width the length of the shingles / ngrams used in the
#' similarity calculation
#'
#' @return a vector of jaccard similarities of the strings
#'
#' @examples
#' jaccard_similarity(
#'   c("the quick brown fox", "jumped over the lazy dog"),
#'   c("the quck bron fx", "jumped over hte lazy dog")
#' )
#'
#' @export
jaccard_similarity <- function(a, b, ngram_width = 2) {
  stopifnot(length(a) == length(b))
  rust_jaccard_similarity(a, b, ngram_width)
}

#' Calculate Hamming distance of two character vectors
#'
#' @param a the first character vector
#' @param b the first character vector
#'
#'
#' @return a vector of hamming similarities of the strings
#'
#' @examples
#' hamming_distance(
#'   c("ACGTCGATGACGTGATGCGTAGCGTA", "ACGTCGATGTGCTCTCGTCGATCTAC"),
#'   c("ACGTCGACGACGTGATGCGCAGCGTA", "ACGTCGATGGGGTCTCGTCGATCTAC")
#' )
#'
#' @export
hamming_distance <- function(a, b) {
  stopifnot(length(a) == length(b))
  rust_hamming_distance(a, b)
}
