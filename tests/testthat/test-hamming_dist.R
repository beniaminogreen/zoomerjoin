test_that("hamming distance works", {
  require(babynames)
  require(stringdist)

  for (i in 1:20) {
    nameys <- tolower(unique(babynames$name))
    shuff_nameys <- sample(nameys, length(nameys))


    a <- hamming_distance(nameys, shuff_nameys)
    b <- stringdist(nameys, shuff_nameys, method = "hamming")

    expect_true(all((a == Inf) %in% (b == Inf)))
    expect_true(all((b == Inf) %in% (a == Inf)))

    expect_true(all(abs(a[a != Inf] - b[b != Inf]) < .01))
  }
})
