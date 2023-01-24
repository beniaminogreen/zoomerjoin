use extendr_api::prelude::parallel::prelude::IntoParallelIterator;
use extendr_api::prelude::parallel::prelude::ParallelIterator;
use extendr_api::prelude::*;

use fxhash::FxHasher;

use ndarray_rand::rand_distr::Uniform;
use ndarray_rand::RandomExt;

use std::collections::{HashMap, HashSet};
use std::hash::{Hash, Hasher};

pub mod shingleset;
use crate::shingleset::ShingleSet;

pub mod match_bucket;
use crate::match_bucket::MatchBucket;

use rayon::prelude::*;

fn calculate_minihash_array(set_vec: &Vec<ShingleSet>, seed_array: ArrayView1<u64>) -> Array2<u64> {
    // Array to store the first ngram in each set for each different ordering

    let mut dense_array: Array2<u64> = Array2::zeros((seed_array.len(), set_vec.len()));

    dense_array
        .axis_iter_mut(Axis(0))
        .enumerate()
        .for_each(|(seed_idx, mut row)| {
            for (y, shingleset) in set_vec.iter().enumerate() {
                let mut min_hash_seen = u64::MAX;
                for item in &shingleset.shingles {
                    let mut hasher = FxHasher::default();

                    seed_array[seed_idx].hash(&mut hasher);
                    item.hash(&mut hasher);

                    let result: u64 = hasher.finish();

                    if result < min_hash_seen {
                        min_hash_seen = result;
                    }
                }
                row[y] = min_hash_seen;
            }
        });

    dense_array
}

fn calculate_matches(
    left_array: ArrayView2<u64>,
    right_array: ArrayView2<u64>,
) -> HashSet<(usize, usize)> {
    let mut matches: HashSet<(usize, usize)> = HashSet::new();

    let mut match_set: HashMap<u64, MatchBucket> = HashMap::new();

    for (index, col) in left_array.axis_iter(Axis(1)).enumerate() {
        let mut hasher = FxHasher::default();

        for signature in col.iter() {
            signature.hash(&mut hasher)
        }

        let key = hasher.finish();

        if match_set.contains_key(&key) {
            match_set.get_mut(&key).map(|val| val.a.push(index));
        } else {
            let mut bucket = MatchBucket::new();
            bucket.a.push(index);
            match_set.insert(key, bucket);
        }
    }

    for (index, col) in right_array.axis_iter(Axis(1)).enumerate() {
        let mut hasher = FxHasher::default();

        for signature in col.iter() {
            signature.hash(&mut hasher)
        }

        let key = hasher.finish();

        if match_set.contains_key(&key) {
            match_set.get_mut(&key).map(|val| val.b.push(index));
        } else {
            let mut bucket = MatchBucket::new();
            bucket.b.push(index);
            match_set.insert(key, bucket);
        }
    }

    for (_, bucket) in match_set.drain() {
        if bucket.contains_match() {
            for matchy in bucket.get_pairs() {
                matches.insert(matchy);
            }
        }
    }

    matches
}

/// Return string `"Hello world!"` to R.
/// @export
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
        .map(|x| ShingleSet::new(x, ngram_width as usize))
        .collect();
    let right_set_vec: Vec<ShingleSet> = right_string_vec
        .par_iter()
        .map(|x| ShingleSet::new(x, ngram_width as usize))
        .collect();

    let seed_array: Array1<u64> = Array1::random(
        n_bands as usize * band_size as usize,
        Uniform::new(0, u64::MAX),
    );

    let matched_pairs = seed_array
        .axis_chunks_iter(Axis(0), band_size as usize)
        .into_par_iter()
        .map(|x| {
            let left_minihash_array = calculate_minihash_array(&left_set_vec, x.view());
            let right_minihash_array = calculate_minihash_array(&right_set_vec, x.view());
            calculate_matches(left_minihash_array.view(), right_minihash_array.view())
        });

    let flattened_pairs : HashSet<(usize,usize)> = matched_pairs.flatten().collect();

    let chosen_indexes: Vec<(usize, usize)> = flattened_pairs
        .into_par_iter()
        .filter(|x| left_set_vec[x.0].jaccard_similarity(&right_set_vec[x.1]) > threshold)
        .collect();

    let mut out_arr: Array2<u64> = Array2::zeros((chosen_indexes.len(), 2));
    for (i, (left_index, right_index)) in chosen_indexes.into_iter().enumerate() {
        out_arr[[i, 0]] = left_index as u64 + 1;
        out_arr[[i, 1]] = right_index as u64 + 1;
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
