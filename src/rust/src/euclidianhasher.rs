use ndarray::prelude::*;
use ndarray_rand::rand_distr::{Normal, Uniform};
use ndarray_rand::RandomExt;

use rustc_hash::FxHasher;
use std::hash::{Hash, Hasher};

use rand::Rng;

#[derive(Debug)]
pub struct EuclidianHasher {
    a_vectors: Array2<f64>,
    b_vectors: Array1<f64>,
    r: f64,
}

impl EuclidianHasher {
    pub fn new<R: Rng>(r: f64, band_width: usize, d: usize, rng: &mut R) -> Self {
        Self {
            a_vectors: Array2::random_using(
                (d, band_width),
                Normal::new(0.0, 1.0).expect("could not intialize normal!"),
                rng
            ),
            b_vectors: Array1::random_using(band_width, Uniform::new(0.0, r),rng),
            r,
        }
    }

    pub fn hash(&self, x: ArrayView1<f64>) -> u64 {
        let numerator = x.dot(&self.a_vectors) + &self.b_vectors;

        let rounded = (numerator / self.r)
            .map(|x| x.ceil() as u64);

        let mut hasher = FxHasher::default();

        rounded.hash(&mut hasher);

        hasher.finish()
    }
}
