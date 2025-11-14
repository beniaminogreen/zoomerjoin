# Plot S-Curve for a LSH with given hyperparameters

Plot S-Curve for a LSH with given hyperparameters

## Usage

``` r
euclidean_curve(n_bands, band_width, r, up_to = 100)
```

## Arguments

- n_bands:

  The number of LSH bands calculated

- band_width:

  The number of hashes in each band

- r:

  the "r" hyperparameter used to govern the sensitivity of the hash.

- up_to:

  the right extent of the x axis.

## Value

A plot showing the probability a pair is proposed as a match, given the
Jaccard similarity of the two items.
