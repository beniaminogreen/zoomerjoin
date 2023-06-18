use extendr_api::prelude::parallel::prelude::ParallelIterator;
use extendr_api::prelude::*;

use dashmap::{DashMap, DashSet};

use rayon::prelude::*;
use regex::Regex;

use rustc_hash::FxHasher;
use std::collections::HashMap;
use std::hash::{Hash, Hasher};

pub mod shingleset;
use crate::shingleset::ShingleSet;

pub mod em_link;
use crate::em_link::EMLinker;

pub mod minihasher;

pub mod euclidianhasher;
use crate::euclidianhasher::EuclidianHasher;

pub mod minhashjoiner;
use crate::minhashjoiner::MinHashJoiner;

#[extendr]
fn rust_em_link(x_robj: Robj, probs: &[f64], tol: f64, max_iter: i32) -> Vec<f64> {
    let x_mat = <ArrayView2<i32>>::from_robj(&x_robj)
        .unwrap()
        .to_owned()
        .map(|x| *x as usize);

    let mut linker = EMLinker::new(x_mat.view(), probs);
    linker.link(tol, max_iter)
}

#[extendr]
fn rust_jaccard_similarity(left_string_r: Robj, right_string_r: Robj, ngram_width: i64) -> Doubles {
    let left_string_vec = <Vec<String>>::from_robj(&left_string_r).unwrap();
    let right_string_vec = <Vec<String>>::from_robj(&right_string_r).unwrap();

    // vector to hold sets of n_gram strings in each document
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

    let out_vec = left_set_vec
        .into_par_iter()
        .zip(right_set_vec)
        .map(|(a, b)| a.jaccard_similarity(&b))
        .collect::<Vec<f64>>();

    out_vec
        .into_iter()
        .map(|i| Rfloat::from(i))
        .collect::<Doubles>()
}

#[extendr]
fn rust_jaccard_join(
    left_string_r: Robj,
    right_string_r: Robj,
    ngram_width: i64,
    n_bands: i64,
    band_size: i64,
    threshold: f64,
) -> Robj {
    let left_string_vec = left_string_r.as_str_vector().unwrap();
    let right_string_vec = right_string_r.as_str_vector().unwrap();

    let joiner = MinHashJoiner::new(left_string_vec, right_string_vec, ngram_width as usize);

    let chosen_indexes = joiner.join(n_bands as usize, band_size as usize, threshold);

    let mut out_arr: Array2<u64> = Array2::zeros((chosen_indexes.len(), 2));
    for (i, pair) in chosen_indexes.iter().enumerate() {
        out_arr[[i, 0]] = pair.1 as u64 + 1;
        out_arr[[i, 1]] = pair.0 as u64 + 1;
    }

    Robj::try_from(&out_arr).into()
}

#[extendr]
fn rust_regex_join(left_string_r: Robj, _right_string_r: Robj, r_regex: &str) -> Robj {
    let left_string_vec = left_string_r.as_str_vector().unwrap();
    // let right_string_vec = right_string_r.as_str_vector().unwrap();

    let re = Regex::new(r_regex).expect("Can't compile regular expression!");

    let mut small_dict: HashMap<u64, Vec<u64>> = HashMap::new();

    for (i, row) in left_string_vec.iter().enumerate() {
        // let matches = re.find_iter(row).map(|mat| mat.as_str()).collect::<Vec<&str>>();
        let mut hasher = FxHasher::default();

        for re_match in re.find_iter(row).map(|mat| mat.as_str()) {
            re_match.hash(&mut hasher)
        }

        let key = hasher.finish();

        if key != 0 {
            match small_dict.get_mut(&key) {
                Some(matches) => matches.push(i as u64 +1),
                None => {small_dict.insert(key, vec![i as u64 +1]);},
            }
        }
    }

    let mut output_vec: Vec<(u64, u64)> = Vec::new();

    for (j, row) in left_string_vec.iter().enumerate() {
        // let matches = re.find_iter(row).map(|mat| mat.as_str()).collect::<Vec<&str>>();
        let mut hasher = FxHasher::default();

        for re_match in re.find_iter(row).map(|mat| mat.as_str()) {
            re_match.hash(&mut hasher)
        }

        let key = hasher.finish();

        if key != 0 {
            // relies on property of fx hasher (will be zero if nothing has been hashed)
            match small_dict.get(&key) {
                Some(matches) => {
                    for i in matches {
                        output_vec.push((*i, j as u64 + 1))
                    }
                }
                None => {}
            };
        }
    }

    let mut out_arr: Array2<u64> = Array2::zeros((output_vec.len(), 2));
    for (i, pair) in output_vec.iter().enumerate() {
        out_arr[[i, 0]] = pair.1 as u64;
        out_arr[[i, 1]] = pair.0 as u64;
    }

    Robj::try_from(&out_arr).into()
}

#[extendr]
fn rust_salted_jaccard_join(
    left_string_r: Robj,
    right_string_r: Robj,
    left_salt_r: Robj,
    right_salt_r: Robj,
    ngram_width: i64,
    n_bands: i64,
    band_size: i64,
    threshold: f64,
) -> Robj {
    let left_string_vec = left_string_r.as_str_vector().unwrap();
    let right_string_vec = right_string_r.as_str_vector().unwrap();

    let right_salt_vec = right_salt_r.as_str_vector().unwrap();
    let left_salt_vec = left_salt_r.as_str_vector().unwrap();

    let joiner = MinHashJoiner::new_with_salt(
        left_string_vec,
        right_string_vec,
        left_salt_vec,
        right_salt_vec,
        ngram_width as usize,
    );

    let chosen_indexes = joiner.join(n_bands as usize, band_size as usize, threshold);

    let mut out_arr: Array2<u64> = Array2::zeros((chosen_indexes.len(), 2));
    for (i, pair) in chosen_indexes.iter().enumerate() {
        out_arr[[i, 0]] = pair.1 as u64 + 1;
        out_arr[[i, 1]] = pair.0 as u64 + 1;
    }

    Robj::try_from(&out_arr).into()
}

#[extendr]
fn rust_p_norm_join(
    a_mat: Robj,
    b_mat: Robj,
    radius: f64,
    band_width: u64,
    n_bands: u64,
    r: f64,
) -> Robj {
    let a_mat = <ArrayView2<f64>>::from_robj(&a_mat).unwrap().to_owned();
    let b_mat = <ArrayView2<f64>>::from_robj(&b_mat).unwrap().to_owned();

    let pairs: DashSet<(usize, usize)> = DashSet::new();
    let store: DashMap<u64, Vec<usize>> = DashMap::new();

    let hasher = EuclidianHasher::new(r, band_width as usize, b_mat.ncols());

    for _ in 0..n_bands {
        a_mat
            .axis_iter(Axis(0))
            .into_par_iter()
            .enumerate()
            .for_each(|(i, x)| {
                let hash = hasher.hash(x);
                if store.contains_key(&hash) {
                    store.get_mut(&hash).unwrap().push(i);
                } else {
                    store.insert(hash, vec![i]);
                }
            });

        b_mat
            .axis_iter(Axis(0))
            .into_par_iter()
            .enumerate()
            .for_each(|(j, x)| {
                let hash = hasher.hash(x);
                if store.contains_key(&hash) {
                    let potential_matches = store.get(&hash).unwrap().clone();

                    for i in potential_matches {
                        let dist: f64 = b_mat
                            .row(j)
                            .iter()
                            .zip(a_mat.row(i).iter())
                            .map(|(a, b)| (a - b).powi(2))
                            .sum::<f64>()
                            .sqrt();

                        if dist < radius {
                            pairs.insert((i, j));
                        }
                    }
                }
            });

        store.clear()
    }

    let mut out_arr: Array2<u64> = Array2::zeros((pairs.len(), 2));

    for (idx, (i, j)) in pairs.into_iter().enumerate() {
        out_arr[[idx, 0]] = i as u64 + 1;
        out_arr[[idx, 1]] = j as u64 + 1;
    }

    Robj::try_from(&out_arr).into()
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod zoomerjoin;
    fn rust_jaccard_join;
    fn rust_salted_jaccard_join;
    fn rust_jaccard_similarity;
    fn rust_em_link;
    fn rust_p_norm_join;
    fn rust_regex_join;
}
