use nohash_hasher::IntSet;
use std::hash::{Hash, Hasher};

use rustc_hash::FxHasher;

#[derive(Debug, Clone)]
pub struct ShingleSet {
    pub shingles: IntSet<u32>,
    pub shingle_len : usize,
    pub index : usize,
}

impl ShingleSet {
    pub fn new(string: &str, shingle_len: usize, index: usize, salt : Option<&str>) -> Self {
        let mut out_set: IntSet<u32> = IntSet::default();

        let char_vec: Vec<char> = string.chars().collect();

        for window in char_vec.windows(shingle_len) {
            let mut hasher = FxHasher::default();

            if let Some(salt_str) = salt {
                salt_str.hash(&mut hasher);
            };

            window.hash(&mut hasher);

            let result: u32 = hasher.finish() as u32;

            out_set.insert(result);
        }

        Self{
            shingles: out_set,
            shingle_len,
            index
        }

    }

    #[inline]
    pub fn jaccard_similarity(&self, b: &Self) -> f64 {
        if self.shingles.is_empty() | b.shingles.is_empty(){
            0.0
        } else {
            self.shingles.intersection(&b.shingles).count() as f64
                / self.shingles.union(&b.shingles).count() as f64
        }
    }
}
