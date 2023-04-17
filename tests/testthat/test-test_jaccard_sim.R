test_that("jaccard sim works", {
    require(babynames)
    require(stringdist)

    for (i in 1:20) {
        nameys <- tolower(unique(babynames$name))
        shuff_nameys <- sample(nameys, length(nameys))


        a <- 1-stringdist(nameys, shuff_nameys, q=1, method="jaccard")
        b <- jaccard_similarity(nameys, shuff_nameys, ngram_width = 1)
        expect_true(all(abs(a-b) < .01))

        a <- 1-stringdist(nameys, shuff_nameys, q=2, method="jaccard")
        b <- jaccard_similarity(nameys, shuff_nameys, ngram_width = 2)
        expect_true(all(abs(a-b) < .01))
    }
})
