# Find Probability of Match Based on Similarity

Find Probability of Match Based on Similarity

## Usage

``` r
hamming_probability(distance, input_length, n_bands, band_width)
```

## Arguments

- distance:

  The hamming distance of the two strings you want to compare

- input_length:

  the length (number of characters) of the input strings you want to
  calculate.

- n_bands:

  The number of LSH bands used in hashing.

- band_width:

  The number of hashes in each band.

## Value

A decimal number giving the probability that the two items will be
returned as a candidate pair from the lsh algotithm.
