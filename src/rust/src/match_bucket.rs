use std::{collections::HashSet};
use smallvec::{SmallVec};

pub struct MatchBucket {
    pub a : SmallVec<[usize;3]>,
    pub b : SmallVec<[usize;3]>
}

impl MatchBucket {
    pub fn new() -> Self {
        MatchBucket{
            a : SmallVec::<[usize; 3]>::new(),
            b : SmallVec::<[usize; 3]>::new()
        }
    }

    pub fn get_pairs(&self) -> HashSet<(usize, usize)> {
        let mut out_set : HashSet<(usize, usize)> = HashSet::new();
        for i in self.a.iter() {
            for j in self.b.iter() {
                out_set.insert((*i,*j));
            }
        }
        out_set
    }

    pub fn contains_match(&self) -> bool {
        (self.a.len() >= 1) & (self.b.len() >= 1)
    }
}
