use dashmap::{DashMap, DashSet};

use extendr_api::prelude::parallel::prelude::ParallelIterator;
use extendr_api::prelude::*;

use std::sync::Arc;

use rayon::prelude::*;

pub mod shingleset;
use crate::shingleset::ShingleSet;

pub mod minihasher;
use crate::minihasher::LSHHasher;


#[extendr]
fn rust_lsh_join(
    left_string_r: Robj,
    right_string_r: Robj,
    ngram_width: i64,
    n_bands: i64,
    band_size: i64,
    threshold: f64,
) -> Robj {
    let left_string_vec = <Vec<String>>::from_robj(&left_string_r).unwrap();
    let right_string_vec = <Vec<String>>::from_robj(&right_string_r).unwrap();

    // vector to hold sets of n_gram strings in each document
    let left_set_vec: Vec<ShingleSet> = left_string_vec
        .par_iter()
        .enumerate()
        .map(|(i, x)| ShingleSet::new(x, ngram_width as usize, i))
        .collect();
    let right_set_vec: Vec<ShingleSet> = right_string_vec
        .par_iter()
        .enumerate()
        .map(|(i, x)| ShingleSet::new(x, ngram_width as usize, i))
        .collect();

    let smaller_set;
    let larger_set;

    // if left_set_vec.len() < right_set_vec.len() {

    smaller_set = left_set_vec;
    larger_set = right_set_vec;
    // } else {
    // smaller_set = right_set_vec;
    // larger_set = left_set_vec;
    // }

    let small_set_map: Arc<DashMap<u64, Vec<usize>>> = Arc::new(DashMap::default());

    let processors = num_cpus::get();
    let chunk_len = ((smaller_set.len() / processors) + 1) as usize;

    //let mut matched_pairs: HashSet<(usize, usize)> = HashSet::new();
    let matched_pairs: Arc<DashSet<(usize, usize)>> = Arc::new(DashSet::new());

    for i in 0..n_bands {
        println!("Starting band {}", i);

        let hasher = Arc::new(LSHHasher::new(band_size as usize));
        let chunks = smaller_set.chunks(chunk_len);

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



        let chunk_len = ((smaller_set.len() / processors) + 1) as usize;
        let chunks = larger_set.chunks(chunk_len);

        let smaller_set = Arc::new(&smaller_set);


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
                                    if shingleset.jaccard_similarity(&smaller_set[*matched]) >= threshold {
                                        matched_pairs.insert((shingleset.index, *matched));
                                    }
                                }
                            }
                        }
                    }
                });
            }
        });

        small_set_map.clear();
    }

    let chosen_indexes = matched_pairs;

    let mut out_arr: Array2<u64> = Array2::zeros((chosen_indexes.len(), 2));
    for (i, pair) in chosen_indexes.iter().enumerate() {
        out_arr[[i, 0]] = pair.1 as u64 + 1;
        out_arr[[i, 1]] = pair.0 as u64 + 1;
    }

    Robj::try_from(&out_arr).into()
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod zoomerjoin;
    fn rust_lsh_join;
}
