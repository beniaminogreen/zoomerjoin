use extendr_api::prelude::parallel::prelude::ParallelIterator;
use extendr_api::prelude::*;

use itertools::Itertools;
use std::collections::hash_map::DefaultHasher;
use std::collections::HashMap;
use std::hash::{Hash, Hasher};

use rayon::prelude::*;

use kdtree::distance::squared_euclidean;
use kdtree::KdTree;

pub mod shingleset;
use crate::shingleset::ShingleSet;

pub mod minihasher;

pub mod lshjoiner;
use crate::lshjoiner::LSHjoiner;

#[derive(Debug)]
struct AgreeBundle {
    pattern: Array1<usize>,
    ids: Vec<usize>,
    n: f64,
    prob_match: f64,
}

impl AgreeBundle {
    fn new(pattern: ArrayView1<usize>, id: usize) -> Self {
        Self {
            pattern: pattern.to_owned(),
            ids: vec![id],
            n: 1.0,
            prob_match: 0.5,
        }
    }

    fn add(&mut self, id: usize) {
        self.ids.push(id);
        self.n += 1.0
    }
}

#[derive(Debug)]
struct EMLinker {
    bundles: Vec<AgreeBundle>,
    n: f64,
    match_params: Vec<Vec<f64>>,
    not_match_params: Vec<Vec<f64>>,
    lambda: f64,
}

impl EMLinker {
    fn new(x_mat: ArrayView2<usize>) -> Self {
        let mut agree_collection: HashMap<u64, AgreeBundle> = HashMap::new();
        let mut match_params = Vec::new();
        let mut not_match_params = Vec::new();

        for col in x_mat.axis_iter(Axis(1)) {
            let unique = col.iter().unique().collect::<Vec<&usize>>().len();

            match_params.push(vec![0.0; unique]);
            not_match_params.push(vec![0.0; unique]);
        }

        for (i, row) in x_mat.axis_iter(Axis(0)).enumerate() {
            let mut hasher = DefaultHasher::new();
            row.hash(&mut hasher);
            let key = hasher.finish();

            match agree_collection.get_mut(&key) {
                Some(bundle) => bundle.add(i),
                None => {
                    agree_collection.insert(key, AgreeBundle::new(row, i));
                }
            }
        }

        Self {
            bundles: agree_collection.into_values().collect(),
            n: x_mat.nrows() as f64,
            match_params,
            not_match_params,
            lambda: 0.0,
        }
    }

    fn m_step(&mut self) {

        // update lambda
        self.lambda = self
            .bundles
            .iter()
            .map(|bundle| bundle.prob_match * bundle.n)
            .sum::<f64>()
            / self.n;

        // set paramaters to zero
        for variable in &mut self.match_params {
            for paramater in variable.iter_mut(){
                *paramater = 0.0;
            }
        }

        for variable in self.not_match_params.iter_mut() {
            for paramater in variable.iter_mut(){
                *paramater = 0.0;
            }
        }

        // update match and not_match params
        for bundle in &self.bundles {
            for (i, agree_level) in bundle.pattern.iter().enumerate() {
                self.match_params[i][*agree_level] += bundle.n*bundle.prob_match;
                self.not_match_params[i][*agree_level] += bundle.n*(1.0 - bundle.prob_match);
            }
        }

    }

    fn e_step(&mut self) {
        // classify each unit
        for bundle in &mut self.bundles {
            let mut match_likelihood = 1.0;
            let mut not_match_likelihood = 1.0;

            for (i, agree_level) in bundle.pattern.iter().enumerate() {
                match_likelihood *= self.match_params[i][*agree_level];
                not_match_likelihood *= self.not_match_params[i][*agree_level];
            }

            bundle.prob_match = self.lambda * match_likelihood / (match_likelihood + not_match_likelihood);
        }

    }

    fn link(&mut self) {
        for i in 0..1000 {
            println!("{i}");
            self.e_step();
            self.m_step();
        }

    }
}

#[extendr]
fn agreement_linker(x_robj: Robj) {
    let x_mat = <ArrayView2<i32>>::from_robj(&x_robj)
        .unwrap()
        .to_owned()
        .map(|x| *x as usize);

    let mut linker = EMLinker::new(x_mat.view());
    linker.link();
    println!("constructed!");
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
fn rust_lsh_join(
    left_string_r: Robj,
    right_string_r: Robj,
    ngram_width: i64,
    n_bands: i64,
    band_size: i64,
    threshold: f64,
) -> Robj {
    let left_string_vec = left_string_r.as_str_vector().unwrap();
    let right_string_vec = right_string_r.as_str_vector().unwrap();

    let joiner = LSHjoiner::new(left_string_vec, right_string_vec, ngram_width as usize);

    let chosen_indexes = joiner.join(n_bands as usize, band_size as usize, threshold);

    let mut out_arr: Array2<u64> = Array2::zeros((chosen_indexes.len(), 2));
    for (i, pair) in chosen_indexes.iter().enumerate() {
        out_arr[[i, 0]] = pair.1 as u64 + 1;
        out_arr[[i, 1]] = pair.0 as u64 + 1;
    }

    Robj::try_from(&out_arr).into()
}

#[extendr]
fn rust_salted_lsh_join(
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

    let joiner = LSHjoiner::new_with_salt(
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
fn rust_kd_join(a_mat: Robj, b_mat: Robj, radius: f64) -> Robj {
    let a_mat = <ArrayView2<f64>>::from_robj(&a_mat).unwrap().to_owned();

    let b_mat = <ArrayView2<f64>>::from_robj(&b_mat).unwrap().to_owned();

    let mut kdtree = KdTree::with_capacity(2, a_mat.nrows());
    for (i, row) in a_mat.axis_iter(Axis(0)).enumerate() {
        kdtree
            .add([row[0], row[1]], i + 1)
            .expect("error loading tree");
    }

    let mut matches: Vec<[u64; 2]> = Vec::new();

    for (j, row) in b_mat.axis_iter(Axis(0)).enumerate() {
        let closest = kdtree
            .within(&[row[0], row[1]], radius, &squared_euclidean)
            .unwrap();
        for (_, i) in closest {
            matches.push([*i as u64, (j + 1) as u64]);
        }
    }

    let out_arr: Array2<u64> = matches.into();

    Robj::try_from(&out_arr).into()
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod zoomerjoin;
    fn rust_lsh_join;
    fn rust_salted_lsh_join;
    fn rust_kd_join;
    fn rust_jaccard_similarity;
    fn agreement_linker;
}
