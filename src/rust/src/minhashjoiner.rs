use crate::shingleset::ShingleSet;

use std::sync::Arc;

use rayon::prelude::*;

use dashmap::{DashMap, DashSet};

use crate::minihasher::MinHasher;

use rand::rngs::StdRng;
use rand::SeedableRng;

pub struct MinHashJoiner {
    smaller_set: Vec<ShingleSet>,
    larger_set: Vec<ShingleSet>,
}

impl MinHashJoiner {
    pub fn new(
        left_string_vec: Vec<&str>,
        right_string_vec: Vec<&str>,
        ngram_width: usize,
    ) -> Self {
        let left_set_vec: Vec<ShingleSet> = left_string_vec
            .par_iter()
            .enumerate()
            .map(|(i, x)| ShingleSet::new(x, ngram_width as usize, i, None))
            .collect();
        let right_set_vec: Vec<ShingleSet> = right_string_vec
            .par_iter()
            .enumerate()
            .map(|(i, x)| ShingleSet::new(x, ngram_width as usize, i, None))
            .collect();

        Self {
            smaller_set: left_set_vec,
            larger_set: right_set_vec,
        }
    }

    pub fn new_with_salt(
        left_string_vec: Vec<&str>,
        right_string_vec: Vec<&str>,
        left_salt_vec: Vec<&str>,
        right_salt_vec: Vec<&str>,
        ngram_width: usize,
    ) -> Self {
        let left_set_vec: Vec<ShingleSet> = left_string_vec
            .par_iter()
            .zip(left_salt_vec)
            .enumerate()
            .map(|(i, (string, salt))| {
                ShingleSet::new(string, ngram_width as usize, i, Some(&salt))
            })
            .collect();
        let right_set_vec: Vec<ShingleSet> = right_string_vec
            .par_iter()
            .zip(right_salt_vec)
            .enumerate()
            .map(|(i, (string, salt))| {
                ShingleSet::new(string, ngram_width as usize, i, Some(&salt))
            })
            .collect();

        Self {
            smaller_set: left_set_vec,
            larger_set: right_set_vec,
        }
    }

    pub fn join(
        &self,
        n_bands: usize,
        band_size: usize,
        threshold: f64,
        progress: bool,
        seed: u64,
    ) -> DashSet<(usize, usize)> {
        //let mut matched_pairs: HashSet<(usize, usize)> = HashSet::new();
        let matched_pairs: DashSet<(usize, usize)> = DashSet::new();

        let mut rng = StdRng::seed_from_u64(seed);
        let small_set_map: Arc<DashMap<u64, Vec<usize>>> =
            Arc::new(DashMap::with_capacity(self.smaller_set.len()));
        for i in 0..n_bands {
            if progress {
                println!("starting band {i} out of {n_bands}");
            }

            let hasher = MinHasher::new(band_size as usize, &mut rng);

            self.smaller_set.par_iter().for_each(|shingleset| {
                let key = hasher.hash(&shingleset);

                small_set_map
                    .entry(key)
                    .and_modify(|x| x.push(shingleset.index))
                    .or_insert(vec![shingleset.index]);
            });

            self.larger_set.par_iter().for_each(|shingleset| {
                let key = hasher.hash(&shingleset);
                if small_set_map.contains_key(&key) {
                    for matched in small_set_map.get(&key).unwrap().iter() {
                        if !matched_pairs.contains(&(shingleset.index, *matched)) {
                            if shingleset.jaccard_similarity(&self.smaller_set[*matched])
                                >= threshold
                            {
                                matched_pairs.insert((shingleset.index, *matched));
                            }
                        }
                    }
                }
            });

            small_set_map.clear()
        }

        matched_pairs
    }
}
