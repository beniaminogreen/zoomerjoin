use extendr_api::prelude::*;

fn l2_norm(x: ArrayView1<f64>) -> f64 {
    x.map(|x| x.powi(2)).sum().sqrt()
}

pub struct EMLinker<'a> {
    lambda: f64,
    params_given_match: Array1<f64>,
    params_given_not_match: Array1<f64>,
    pub match_probs: Option<Array1<f64>>,
    comparisons: ArrayView2<'a, bool>,
}

impl<'a> EMLinker<'a> {
    pub fn new(comparisons: ArrayView2<'a, bool>, params_given_match: Array1<f64>, params_given_not_match : Array1<f64>, lambda: f64) -> Self {
        Self {
            comparisons,
            params_given_match,
            params_given_not_match,
            match_probs: None,
            lambda
        }
    }

    fn m_step(&mut self) {
        let n_matches = self
            .match_probs
            .as_ref()
            .expect("Probabilities not Generated Yet")
            .sum();

        self.lambda = n_matches / self.comparisons.nrows() as f64;
        println!("lambda: {}", self.lambda);

        self.params_given_match = self
            .comparisons
            .axis_iter(Axis(1))
            .map(|col| {
                col.iter()
                    .zip(
                        self.match_probs.as_ref().expect("Probabilities Not Generated Yet"))
                    .map(|(x, y)| if *x { *y } else { 0.0 })
                    .sum::<f64>()
                    / n_matches
            })
            .collect();

        self.params_given_not_match = self
            .comparisons
            .axis_iter(Axis(1))
            .map(|col| {
                col.iter()
                    .zip(
                        self.match_probs
                            .as_ref()
                            .expect("Probabilities Not Generated Yet"),
                    )
                    .map(|(x, y)| if *x { 1.0 - *y } else { 0.0 })
                    .sum::<f64>()
                    / (self.comparisons.nrows() as f64 - n_matches)
            })
            .collect();
    }

    fn e_step(&mut self) {
        println!("starting e step");
        dbg!(&self.params_given_match);
        dbg!(&self.params_given_not_match);
        let log_unnormalized_match_probs : Array1<f64> = self.comparisons.axis_iter(Axis(0)).map(|c| {
            c.iter()
                .zip(self.params_given_match.iter())
                .map(|(x, y)| if *x { y.log2() } else { (1.0 - y).log2() })
                .sum::<f64>()
        }).collect::<Array1<f64>>() + self.lambda.log2();

        let log_unnormalized_not_match_probs : Array1<f64> = self.comparisons.axis_iter(Axis(0)).map(|c| {
            c.iter()
                .zip(self.params_given_not_match.iter())
                .map(|(x, y)| if *x { y.log2() } else { (1.0 - *y).log2() })
                .sum::<f64>()
        }).collect::<Array1<f64>>() + (1.0-self.lambda).log2();

        // println!("log_unnormalized_match_probs {:?}", log_unnormalized_match_probs);
        // println!("log_unnormalized_not_match_probs {:?}", log_unnormalized_not_match_probs);

        self.match_probs = Some(
            log_unnormalized_match_probs.into_iter()
                .zip(log_unnormalized_not_match_probs.into_iter())
                .map(|(x, y)| 2.0_f64.powf(x)/(2.0_f64.powf(x) + 2.0_f64.powf(y)))
                .map(|x| if x.is_nan() {0.0} else {x})
                .collect()
        );
        println!("match_probs : {:?}", self.match_probs);
        // println!("lambda : {}", self.lambda);

        // println!("match_probs : {:?}", self.match_probs.as_ref().unwrap().iter().map(|x| *x < 0.0 ).collect::<Vec<bool>>());
    }

    pub fn train(&mut self, tol : f64 ) {
        self.e_step();

        println!("Probs Given Match: {:?}", self.params_given_match);
        println!("Probs Given not Match: {:?}", self.params_given_not_match);

        let mut old_probs = self.match_probs.as_ref().unwrap().clone();

        self.m_step();
        self.e_step();

        let mut new_probs = self.match_probs.as_ref().unwrap().clone();

        let mut i = 0;
        while l2_norm((&old_probs - &new_probs).view()) > tol {
            i += 1;
            println!("iter: {i}");
            println!("Probs Given Match: {:?}", self.params_given_match);
            println!("Probs Given not Match: {:?}", self.params_given_not_match);

            self.m_step();
            self.e_step();
            old_probs = new_probs;
            new_probs = self.match_probs.as_ref().unwrap().clone();
        }

    }
}
