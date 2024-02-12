use rustc_hash::FxHasher;
use std::hash::{Hash, Hasher};

use rand::Rng;

#[derive(Debug)]
pub struct HammingHasher {
    indexes: Vec<usize>,
}

impl HammingHasher {
    pub fn new<R:Rng>(max_input_len: usize, band_width: usize, rng: &mut R) -> Self {

        let indexes: Vec<usize> = (0..band_width)
            .map(|_| rng.gen_range(0..max_input_len))
            .collect();

        Self { indexes }
    }

    pub fn hash(&self, x: &str) -> u64 {
        let mut hasher = FxHasher::default();

        let input_len = x.as_bytes().len();

        input_len.hash(&mut hasher);

        self.indexes.iter().filter(|&&x|  x < input_len).for_each(|idx| x.as_bytes()[*idx].hash(&mut hasher));

        hasher.finish()
    }
}
