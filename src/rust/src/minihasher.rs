use rustc_hash::FxHasher;
use std::hash::{Hash, Hasher};

use ndarray_rand::rand_distr::Uniform;

use rand::Rng;

use crate::shingleset::ShingleSet;

#[derive(Debug)]
pub struct MinHasher {
    seeds: Vec<u64>,
}

impl MinHasher {
    pub fn new<R: Rng>(band_width: usize, rand_state : &mut R) -> Self {
        let dist = Uniform::new(0, 20000000);
        let seeds: Vec<u64> = (0..band_width).map(|_| rand_state.sample(&dist)).collect();
        Self { seeds }
    }

    pub fn hash(&self, shingle_set: &ShingleSet) -> u64 {
        let mini_hashes = self.seeds.iter().map(|seed| {
            let mut min_hash_seen = u64::MAX;
            for item in &shingle_set.shingles {
                let mut hasher = FxHasher::default();

                seed.hash(&mut hasher);
                item.hash(&mut hasher);

                let result: u64 = hasher.finish();

                if result < min_hash_seen {
                    min_hash_seen = result;
                }
            }
            min_hash_seen
        });

        let mut hasher = FxHasher::default();
        for mini_hash in mini_hashes {
            mini_hash.hash(&mut hasher);
        }
        hasher.finish()
    }
}
