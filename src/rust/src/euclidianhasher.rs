use ndarray::prelude::*;
use ndarray_rand::rand_distr::{Normal, Uniform};
use ndarray_rand::RandomExt;

use rustc_hash::FxHasher;
use std::hash::{Hash, Hasher};

#[derive(Debug)]
pub struct EuclidianHasher {
    a_vectors: Array2<f64>,
    b_vectors: Array1<f64>,
    r: f64,
}

impl EuclidianHasher {
    pub fn new(r: f64, band_width: usize, d: usize) -> Self {
        Self {
            a_vectors: Array2::random(
                (d, band_width),
                Normal::new(0.0, 1.0).expect("could not intialize normal!"),
            ),
            b_vectors: Array1::random(band_width, Uniform::new(0.0, r)),
            r,
        }
    }

    pub fn hash(&self, x: ArrayView1<f64>) -> u64 {
        let numerator = x.dot(&self.a_vectors) + &self.b_vectors;

        let rounded = (numerator / self.r)
            .map(|x| x.round() as u64);

        let mut hasher = FxHasher::default();

        rounded.hash(&mut hasher);

        hasher.finish()
    }
}
