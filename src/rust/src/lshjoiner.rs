use crate::shingleset::ShingleSet;

use rayon::prelude::*;

use dashmap::{DashMap, DashSet};

use std::sync::Arc;

use crate::minihasher::LSHHasher;

pub struct LSHjoiner {
    smaller_set: Vec<ShingleSet>,
    larger_set: Vec<ShingleSet>
}

impl LSHjoiner {
    pub fn new(
        left_string_vec: Vec<String>,
        right_string_vec: Vec<String>,
        ngram_width: usize
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
            larger_set: right_set_vec
        }
    }

    pub fn new_with_salt(
        left_string_vec: Vec<String>,
        right_string_vec: Vec<String>,
        left_salt_vec: Vec<String>,
        right_salt_vec: Vec<String>,
        ngram_width: usize
        ) -> Self {

        let left_set_vec: Vec<ShingleSet> = left_string_vec
            .par_iter()
            .zip(left_salt_vec)
            .enumerate()
            .map(|(i, (string, salt))| ShingleSet::new(string, ngram_width as usize, i, Some(&salt)))
            .collect();
        let right_set_vec: Vec<ShingleSet> = right_string_vec
            .par_iter()
            .zip(right_salt_vec)
            .enumerate()
            .map(|(i, (string, salt))| ShingleSet::new(string, ngram_width as usize, i, Some(&salt)))
            .collect();

        Self {
            smaller_set: left_set_vec,
            larger_set: right_set_vec
        }
    }

    pub fn join(&self, n_bands : usize, band_size : usize, threshold : f64) -> DashSet<(usize, usize)>{

    let processors = num_cpus::get();
    let chunk_len = ((self.smaller_set.len() / processors) + 1) as usize;

    //let mut matched_pairs: HashSet<(usize, usize)> = HashSet::new();
    let matched_pairs: Arc<DashSet<(usize, usize)>> = Arc::new(DashSet::new());

    for i in 0..n_bands {
        println!("starting iteration {}", i);
        let small_set_map: Arc<DashMap<u64, Vec<usize>>> = Arc::new(DashMap::default());

        let hasher = Arc::new(LSHHasher::new(band_size as usize));
        let chunks = self.smaller_set.chunks(chunk_len);

        std::thread::scope(|scope| {
            for chunk in chunks {
                let small_set_map = Arc::clone(&small_set_map);
                let hasher = Arc::clone(&hasher);

                scope.spawn(move || {
                    for shingleset in chunk {
                        let key = hasher.hash(shingleset);
                        if small_set_map.contains_key(&key) {
                            small_set_map.get_mut(&key).unwrap().push(shingleset.index);
                        } else {
                            small_set_map.insert(hasher.hash(shingleset), vec![shingleset.index]);
                        }
                    }
                });
            }
        });

        let chunk_len = ((self.smaller_set.len() / processors) + 1) as usize;
        let chunks = self.larger_set.chunks(chunk_len);

        let smaller_set = Arc::new(&self.smaller_set);

        std::thread::scope(|scope| {
            for chunk in chunks {
                let matched_pairs = Arc::clone(&matched_pairs);
                let small_set_map = Arc::clone(&small_set_map);
                let hasher = Arc::clone(&hasher);
                let smaller_set = Arc::clone(&smaller_set);

                scope.spawn(move || {
                    for shingleset in chunk.iter() {
                        let key = hasher.hash(&shingleset);
                        if small_set_map.contains_key(&key) {
                            for matched in small_set_map.get(&key).unwrap().iter() {
                                if !matched_pairs.contains(&(shingleset.index, *matched)) {
                                    if shingleset.jaccard_similarity(&smaller_set[*matched])
                                        >= threshold
                                    {
                                        matched_pairs.insert((shingleset.index, *matched));
                                    }
                                }
                            }
                        }
                    }
                });
            }
        });
    }

    Arc::try_unwrap(matched_pairs).expect("Still has multiple owners")

    }

}
