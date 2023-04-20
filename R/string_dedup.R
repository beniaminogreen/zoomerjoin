#' @export
lsh_string_group <- function(string, n_gram_width = 2, n_bands = 45, band_width = 8, threshold = .7) {

    if (!"igraph" %in% rownames(installed.packages())) {
            stop("library 'igraph' must be installed to run this package")
    }

    string <- c("beniamino", "jack", "benjamin", "beniamin", "jacky")
    n_gram_width =2
    n_bands = 40
    band_width = 5
    threshold = .7

    pairs <- rust_lsh_join(string,
                           string,
                           ngram_width = n_gram_width,
                           n_bands,
                           band_size = band_width,
                           threshold)

    graph <- igraph::graph_from_edgelist(pairs)
    fc <- igraph::fastgreedy.community(igraph::as.undirected(graph))

    groups <- igraph::groups(fc)
    lookup_table <- sapply(groups, function(x){x[[1]]})

    membership <- igraph::membership(fc)

    return(string[lookup_table[membership]])
}
