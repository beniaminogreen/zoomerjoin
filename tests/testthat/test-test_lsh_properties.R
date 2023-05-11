test_that("jaccard_probabilitiy gives right results", {
    expect_equal(jaccard_probability(.1,1,1),.1)
    expect_equal(jaccard_probability(.2,1,1),.2)
    expect_equal(jaccard_probability(.8,1,1),.8)

    expect_equal(jaccard_probability(.8,5,8),.6, tolerance =.01)
    expect_equal(jaccard_probability(.8,5,5),.86, tolerance =.01)
})

test_that("jaccard_hyper_grid_search gives right results", {
    expect_equal(
                 jaccard_hyper_grid_search(.1,.9,.1,.9),
                 c(band_width = 2,n_bands = 2)
                 )

    jaccard_hyper_grid_search(.1,.9,.1,.999)

    expect_equal(
                 jaccard_hyper_grid_search(.1,.9,.1,.999),
                 c(band_width = 2,n_bands = 5)
                 )
})
test_that("jaccard_hyper_grid_search validates inputs are length 1", {
     expect_error(jaccard_hyper_grid_search(c(.1,1),.9,.1,.9))
     expect_error(jaccard_hyper_grid_search(1,c(1,.9),.1,.9))
     expect_error(jaccard_hyper_grid_search(1,.9,c(.1,1),.9))
     expect_error(jaccard_hyper_grid_search(1,.9,.1,c(.9,1)))

     expect_error(jaccard_hyper_grid_search(.9,.1,.1,.999))
     expect_error(jaccard_hyper_grid_search(.1,.9,.9,.1))
})

