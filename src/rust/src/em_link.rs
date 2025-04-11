use extendr_api::prelude::*;
use itertools::Itertools;
use ndarray::{Array1, ArrayView1, ArrayView2, Axis};
use std::collections::hash_map::DefaultHasher;
use std::collections::HashMap;
use std::hash::{Hash, Hasher};
struct AgreeBundle {
    pattern: Array1<usize>,
    ids: Vec<usize>,
    n: f64,
    prob_match: f64,
}

impl AgreeBundle {
    fn new(pattern: ArrayView1<usize>, id: usize, prob: f64) -> Self {
        Self {
            pattern: pattern.to_owned(),
            ids: vec![id],
            n: 1.0,
            prob_match: prob,
        }
    }

    fn add(&mut self, id: usize) {
        self.ids.push(id);
        self.n += 1.0
    }
}

pub struct EMLinker {
    bundles: Vec<AgreeBundle>,
    n: f64,
    match_params: Vec<Vec<f64>>,
    not_match_params: Vec<Vec<f64>>,
    lambda: f64,
}

impl EMLinker {
    pub fn new(x_mat: ArrayView2<usize>, guesses: &[f64]) -> Self {
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
                    agree_collection.insert(key, AgreeBundle::new(row, i, guesses[i]));
                }
            }
        }

        Self {
            bundles: agree_collection.into_values().collect(),
            n: x_mat.nrows() as f64,
            match_params,
            not_match_params,
            lambda: 0.5,
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
            for paramater in variable.iter_mut() {
                *paramater = 0.0;
            }
        }

        for variable in self.not_match_params.iter_mut() {
            for paramater in variable.iter_mut() {
                *paramater = 0.0;
            }
        }

        // update match and not_match params
        for bundle in &self.bundles {
            for (i, agree_level) in bundle.pattern.iter().enumerate() {
                self.match_params[i][*agree_level] +=
                    bundle.n * bundle.prob_match / (self.n * self.lambda);
                self.not_match_params[i][*agree_level] +=
                    bundle.n * (1.0 - bundle.prob_match) / (self.n * (1.0 - self.lambda));
            }
        }
    }

    fn e_step(&mut self) {
        for bundle in &mut self.bundles {
            let mut match_likelihood = 1.0;
            let mut not_match_likelihood = 1.0;

            for (i, agree_level) in bundle.pattern.iter().enumerate() {
                match_likelihood *= self.match_params[i][*agree_level];
                not_match_likelihood *= self.not_match_params[i][*agree_level];
            }

            bundle.prob_match = self.lambda * match_likelihood
                / (self.lambda * match_likelihood + (1.0 - self.lambda) * not_match_likelihood);
        }
    }

    fn unlist_parameters(&self) -> Vec<f64> {
        let mut unlisted_parameters = Vec::new();

        for col in self.not_match_params.iter() {
            for param in col {
                unlisted_parameters.push(*param);
            }
        }

        for col in self.match_params.iter() {
            for param in col {
                unlisted_parameters.push(*param);
            }
        }

        unlisted_parameters
    }

    pub fn link(&mut self, tol: f64, max_iter: i32) -> Vec<f64> {
        self.m_step();

        let mut max_diff = 80.0;
        let mut old_parameters = self.unlist_parameters();
        let mut i = 0;

        while max_diff > tol {
            i += 1;

            if i > max_iter {
                panic!("maxium iterations exceeded!");
            }

            self.e_step();
            self.m_step();

            let new_parameters = self.unlist_parameters();

            max_diff = old_parameters
                .iter()
                .zip(new_parameters.iter())
                .map(|(x, y)| x - y)
                .max_by(|a, b| a.total_cmp(b))
                .unwrap();

            old_parameters = new_parameters;
        }

        let mut out_vec = vec![0.0; self.n as usize];

        for bundle in self.bundles.iter() {
            for i in bundle.ids.iter() {
                out_vec[*i] = bundle.prob_match;
            }
        }

        out_vec
    }
}
