# Plot S-Curve for a LSH with given hyperparameters

Plot S-Curve for a LSH with given hyperparameters

## Usage

``` r
jaccard_curve(n_bands, band_width)
```

## Arguments

- n_bands:

  The number of LSH bands calculated

- band_width:

  The number of hashes in each band

## Value

A plot showing the probability a pair is proposed as a match, given the
Jaccard similarity of the two items.

## Examples

``` r
# Plot the probability two pairs will be matched as a function of their
# jaccard similarity, given the hyperparameters n_bands and band_width.
jaccard_curve(40, 6)

```
