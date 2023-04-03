#' Plot S-Curve for a given LSH function
#'
#' @param n_bands: The number of LSH bands calculated
#'
#' @param band_width: The number of hashes in each band
#'
#' @return A plot showing the probability a pair is proposed as a match, given
#' the Jaccard similarity of the two items.
#'
#' @export
lsh_curve <- function(n_bands, band_width) {
    similarity <- seq(0,1,.005)

    stopifnot(n_bands > 0)
    stopifnot(band_width > 0)

    probs <- 1-(1-similarity^band_width)^n_bands

    plot(similarity, probs,
         xlab = "Jaccard Similarity of Two Strings",
         ylab = "Probability that Strings are Proposed as a Match",
         type="l",
         col = "blue"
    )
}

#' Find Probability of Match Based on Similarity
#'
#' @param n_bands: The number of LSH bands used in hashing
#'
#' @param band_width: The number of hashes in each band
#'
#' @return a decimal number giving the proability that the two items will be
#' returned as a candidate pair from the minihash algotithm.
#'
#' @export
lsh_probability <- function(similarity, n_bands, band_width){
    1-(1-similarity^band_width)^n_bands
}


#' Choose the Appropriate LSH hyperparamaters
#'
#' Runs a grid search to find the hyperparameters that will achieve an
#' (s1,s2,p1,p2)-sensitive locality sensitive hash. A locality sensitive hash
#' can be called (s1,s2,p1,p2)-sensitive if to strings with a similarity less
#' than s1 have a less than p1 chance of being compared, while two strings with
#' similarity s2 have a greater than p2 chance of being compared. As an
#' example, a (.1,.7,.001,.999)-sensitive LSH means that strings with
#' similarity less than .1 will have a .1% chance of being compared, while
#' strings with .7 similarity have a 99.9% chance of being compared.
#'
#' @param s1: the s1 paramater (the first similaity).
#' @param s2: the s2 parameter (the second similarity, must be greater than s1).
#' @param p1: the p1 paramater (the first probability).
#' @param p2: the p2 parameter (the second probability, must be greater than p1).
#'
#' @export
lsh_hyperparameters <- function(s1=.1,s2=.7,p1=.001,p2=.999) {

    stopifnot("similarity 1 must be less than similarity 2" = s1 < s2)
    stopifnot("proability 1 must be less than similarity 2" = p1 < p2)

    df <- expand.grid(
                band_width = seq(1,20,1),
                n_bands = seq(1,10000,1)
            )

    df$p1 <-lsh_probability(s1, n_bands = df$n_bands,  band_width = df$band_width)
    df$p2 <-lsh_probability(s2, n_bands = df$n_bands,  band_width = df$band_width)

    df$feasible <- (df$p1 < p1) & (df$p2 > p2)

    df$prod <- df$band_width * df$n_bands

    df <- df[df$feasible,]

    selected <- which.min(df$prod)

    return(c(
        "band_width" = df$band_width[selected] ,
        "n_bands" = df$n_bands[selected]
      ))

}



