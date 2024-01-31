#' Fuzzy String Grouping Using Minhashing
#'
#' Performs fuzzy string grouping in which similar strings are assigned to the
#' same group. Uses the `fastgreedy.community` community detection algorithm
#' from the `igraph` package to create the groups. Must have igraph installed
#' in order to use this function.
#'
#'
#' @param string a character you wish to perform entity resolution on.
#'
#' @param n_gram_width the length of the n_grams used in calculating the
#' jaccard similarity. For best performance, I set this large enough that the
#' chance any string has a specific n_gram is low (i.e. \code{n_gram_width} = 2
#' or 3 when matching on first names, 5 or 6 when matching on entire
#' sentences).
#'
#' @param n_bands the number of bands used in the minihash algorithm (default
#' is 40). Use this in conjunction with the \code{band_width} to determine the
#' performance of the hashing. The default settings are for a
#' (.2,.8,.001,.999)-sensitive hash i.e. that pairs with a similarity of less
#' than .2 have a >.1% chance of being compared, while pairs with a similarity
#' of greater than .8 have a >99.9% chance of being compared.
#'
#' @param band_width the length of each band used in the minihashing algorithm
#' (default is 8) Use this in conjunction with the \code{n_bands} to determine
#' the performance of the hashing. The default settings are for a
#' (.2,.8,.001,.999)-sensitive hash i.e. that pairs with a similarity of less
#' than .2 have a >.1% chance of being compared, while pairs with a similarity
#' of greater than .8 have a >99.9% chance of being compared.
#'
#' @param threshold the jaccard similarity threshold above which two strings
#' should be considered a match (default is .95). The similarity is euqal to 1
#' - the jaccard distance between the two strings, so 1 implies the strings are
#' identical, while a similarity of zero implies the strings are completely
#' dissimilar.
#'
#' @param progress set to true to report progress of the algorithm
#'
#' @return a string vector storing the group of each element in the original
#' input strings. The input vector is grouped so that similar strings belong to
#' the same group, which is given a standardized name.
#'
#' @examples
#'
#' string <- c("beniamino", "jack", "benjamin", "beniamin",
#'     "jacky", "giacomo", "gaicomo")
#' jaccard_string_group(string, threshold = .2, n_bands=90, n_gram_width=1)
#'
#' @export
#' @importFrom stats runif
#' @importFrom utils installed.packages
jaccard_string_group <- function(string, n_gram_width = 2, n_bands = 45, band_width = 8, threshold = .7, progress = FALSE) {

    if (system.file(package = "igraph")=="") {
            stop("library 'igraph' must be installed to run this function")
    }

    pairs <- rust_jaccard_join(string,
                           string,
                           ngram_width = n_gram_width,
                           n_bands,
                           band_size = band_width,
                           threshold = threshold,
                           progress = progress,
                           seed = round(stats::runif(1,0,2^64))
    )


    graph <- igraph::graph_from_edgelist(pairs)
    fc <- igraph::fastgreedy.community(igraph::as.undirected(graph))

    groups <- igraph::groups(fc)
    lookup_table <- vapply(groups, "[[", integer(1), 1)

    membership <- igraph::membership(fc)

    return(string[lookup_table[membership]])
}
