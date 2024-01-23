use extendr_api::prelude::parallel::prelude::ParallelIterator;
use extendr_api::prelude::*;

use dashmap::{DashMap, DashSet};

use rayon::prelude::*;

pub mod shingleset;
use crate::shingleset::ShingleSet;

pub mod em_link;
use crate::em_link::EMLinker;

pub mod minihasher;
pub mod euclidianhasher;
use crate::euclidianhasher::EuclidianHasher;
pub mod minhashjoiner;
use crate::minhashjoiner::MinHashJoiner;

use rand::rngs::StdRng;
use rand::SeedableRng;

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
    let right_string_vec = right_string_r.as_str_vector().unwrap();
    let left_string_vec = left_string_r.as_str_vector().unwrap();

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
    progress : bool,
    seed: u64
) -> Robj {


    let right_string_vec = right_string_r.as_str_vector().unwrap();
    let left_string_vec = left_string_r.as_str_vector().unwrap();

    if progress {
        println!("Starting to generate shingles");
    }

    let joiner = MinHashJoiner::new(left_string_vec, right_string_vec, ngram_width as usize);

    if progress {
        println!("Done generating shingles");
    }

    let chosen_indexes = joiner.join(n_bands as usize, band_size as usize, threshold, progress, seed);

    let mut out_arr: Array2<u64> = Array2::zeros((chosen_indexes.len(), 2));
    for (i, pair) in chosen_indexes.iter().enumerate() {
        out_arr[[i, 0]] = pair.1 as u64 + 1;
        out_arr[[i, 1]] = pair.0 as u64 + 1;
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
    progress : bool,
    seed : u64,
) -> Robj {
    let left_string_vec = left_string_r.as_str_vector().unwrap();
    let right_string_vec = right_string_r.as_str_vector().unwrap();

    let right_salt_vec = right_salt_r.as_str_vector().unwrap();
    let left_salt_vec = left_salt_r.as_str_vector().unwrap();

    if progress {
        println!("Starting to generate shingles");
    }

    let joiner = MinHashJoiner::new_with_salt(
        left_string_vec,
        right_string_vec,
        left_salt_vec,
        right_salt_vec,
        ngram_width as usize,
    );

    if progress {
        println!("Done generating shingles");
    }

    let chosen_indexes = joiner.join(n_bands as usize, band_size as usize, threshold,progress, seed);

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
    progress : bool,
    seed: u64,
) -> Robj {
    let a_mat = <ArrayView2<f64>>::from_robj(&a_mat).unwrap().to_owned();
    let b_mat = <ArrayView2<f64>>::from_robj(&b_mat).unwrap().to_owned();

    let pairs: DashSet<(usize, usize)> = DashSet::new();
    let store: DashMap<u64, Vec<usize>> = DashMap::new();

    let mut rng = StdRng::seed_from_u64(seed);
    for i in 0..n_bands {
        let hasher = EuclidianHasher::new(r, band_width as usize, b_mat.ncols(), &mut rng);

        if progress {
            println!("starting band {i} out of {n_bands}");
        }

        a_mat
            .axis_iter(Axis(0))
            .into_par_iter()
            .enumerate()
            .for_each(|(i, x)| {
                let hash = hasher.hash(x);

                store
                    .entry(hash)
                    .and_modify(|x| x.push(i))
                    .or_insert(vec![i]);

            });

        b_mat
            .axis_iter(Axis(0))
            .into_par_iter()
            .enumerate()
            .for_each(|(j, x)| {
                let hash = hasher.hash(x);
                if store.contains_key(&hash) {
                    let potential_matches = store.get(&hash).unwrap();

                    for i in potential_matches.iter() {
                        let dist: f64 = b_mat
                            .row(j)
                            .iter()
                            .zip(a_mat.row(*i).iter())
                            .map(|(a, b)| (a - b).powi(2))
                            .sum::<f64>()
                            .sqrt();

                        if dist < radius {
                            pairs.insert((*i, j));
                        }
                    }
                } });
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
}
