#' Plot S-Curve for a LSH with given hyperparameters
#'
#' @param n_bands The number of LSH bands calculated
#'
#' @param band_width The number of hashes in each band
#'
#' @return A plot showing the probability a pair is proposed as a match, given
#' the Jaccard similarity of the two items.
#'
#' @examples
#' # Plot the probability two pairs will be matched as a function of their
#' # jaccard similarity, given the hyperparameters n_bands and band_width.
#' jaccard_curve(40,6)
#'
#' @export
jaccard_curve <- function(n_bands, band_width) {

    stopifnot("number of bands must be a single integer" = length(n_bands)==1)
    stopifnot("band width must be a single integer" = length(band_width)==1)

    stopifnot(n_bands > 0)
    stopifnot(band_width > 0)

    similarity <- seq(0,1,.005)

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
#' This is a port of the
#' [lsh_probability](https://docs.ropensci.org/textreuse/reference/lsh_probability.html)
#' function from the
#' [textreuse](https://cran.r-project.org/package=textreuse)
#' package, with arguments changed to reflect the hyperparameters in this
#' package. It gives the probability that two strings of jaccard similarity
#' `similarity` will be matched, given the chosen bandwidth and number of
#' bands.
#'
#' @param similarity the similarity of the two strings you want to compare
#'
#' @param n_bands The number of LSH bands used in hashing.
#'
#' @param band_width The number of hashes in each band.
#'
#' @return a decimal number giving the probability that the two items will be
#' returned as a candidate pair from the minhash algorithm.
#'
#' @examples
#' # Find the probability two pairs will be matched given they have a
#' # jaccard_similarity of .8,
#' # band width of 5, and 50 bands:
#' jaccard_probability(.8,5,50)
#' @export
jaccard_probability <- function(similarity, n_bands, band_width){
    1-(1-similarity^band_width)^n_bands
}

#' Plot S-Curve for a LSH with given hyperparameters
#'
#' @param n_bands The number of LSH bands calculated
#'
#' @param band_width The number of hashes in each band
#'
#' @param r the "r" hyperparameter used to govern the sensitivity of the hash.
#'
#' @param up_to the right extent of the x axis.
#'
#' @return A plot showing the probability a pair is proposed as a match, given
#' the Jaccard similarity of the two items.
#'
euclidean_curve <- function(n_bands, band_width, r, up_to = 100) {
    x <- seq(0, up_to, length.out=1500)
    y <- euclidean_probability(x, n_bands, band_width,r)


    plot(x, y,
         xlab = "Euclidian Distance Between Two Vectors",
         ylab = "Probability that Vectors are Proposed as a Match",
         type="l",
         col = "blue"
    )
}

#' Find Probability of Match Based on Similarity
#'
#' @param distance the euclidian distance between the two vectors you want to
#' compare.
#'
#' @param n_bands The number of LSH bands used in hashing.
#'
#' @param band_width The number of hashes in each band.
#'
#' @param r the "r" hyperparameter used to govern the sensitivity of the hash.
#'
#' @return a decimal number giving the proability that the two items will be
#' returned as a candidate pair from the minihash algorithm.
#'
#' @importFrom stats pnorm
#' @export
euclidean_probability <- function(distance, n_bands, band_width, r) {
    p <- 1 - 2*pnorm(-r/distance) - 2/(sqrt(2*pi)*r/distance)*(1-exp(-(r^2/(2*distance^2))))

    1 - (1-p^band_width)^n_bands
}


#' Help Choose the Appropriate LSH Hyperparameters
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
#' @param s1  the s1 parameter (the first similaity).
#' @param s2  the s2 parameter (the second similarity, must be greater than s1).
#' @param p1  the p1 parameter (the first probability).
#' @param p2  the p2 parameter (the second probability, must be greater than p1).
#'
#' @return a named vector with the hyperparameters that will meet the LSH
#' criteria, while reducing runitme.
#'
#' @examples
#' # Help me find the parameters that will minimize runtime while ensuring that
#' # two strings with similarity .1 will be compared less than .1% of the time,
#' # strings with .8 similaity will have a 99.95% chance of being compared:
#' jaccard_hyper_grid_search(.1,.9,.001,.995)
#'
#' @export
jaccard_hyper_grid_search <- function(s1=.1,s2=.7,p1=.001,p2=.999) {

    stopifnot("s1 must be a single number"=length(s1)==1)
    stopifnot("s2 must be a single number"=length(s2)==1)
    stopifnot("p1 must be a single number"=length(p1)==1)
    stopifnot("p2 must be a single number"=length(p2)==1)

    stopifnot("similarity 1 must be less than similarity 2" = s1 < s2)
    stopifnot("proability 1 must be less than similarity 2" = p1 < p2)

    df <- expand.grid(
                band_width = seq(1,75,1),
                n_bands = seq(1,50000,1)
            )

    df$p1 <-jaccard_probability(s1, n_bands = df$n_bands,  band_width = df$band_width)
    df$p2 <-jaccard_probability(s2, n_bands = df$n_bands,  band_width = df$band_width)

    df$feasible <- (df$p1 < p1) & (df$p2 > p2)

    df$prod <- df$band_width * df$n_bands

    df <- df[df$feasible,]

    selected <- which.min(df$prod)

    return(c(
        "band_width" = df$band_width[selected] ,
        "n_bands" = df$n_bands[selected]
      ))

}



