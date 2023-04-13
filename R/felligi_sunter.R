felligi_sunter <- function(X) {
    n <- nrow(X)
    agreement_levels <- apply(X,2, function(x){sort(unique(x))}, simplify = "list")

    log_match_probs <- list()
    log_not_match_probs <- list()

    for (i in seq_along(agreement_levels)) {
        agreements <- agreement_levels[[i]]

        log_match_probs[[i]] <- log((agreements+1)/(3*max(agreements)+1))
        log_not_match_probs[[i]] <- log(1-(agreements+1)/(3*max(agreements)+1))
    }


    log_match_like = numeric(n)
    log_not_match_like = numeric(n)
    for (i in seq(n)) {

    }




}


n <- 100
p <- 3
X <- cbind(matrix(sample(1:4, n*p, replace=T), nrow = n), sample(c(0,1), n, replace=T))

felligi_sunter(X)


