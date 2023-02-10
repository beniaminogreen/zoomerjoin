#' Calculate jaccard_similarity of two character vectors
#`
#' @export
jaccard_similarity <- function(a, b, ngram_width=2) {
    stopifnot(length(a) == length(b))
    rust_jaccard_similarity(a, b, ngram_width)
}
