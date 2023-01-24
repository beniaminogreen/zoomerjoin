use std::collections::HashSet;

pub struct MatchBucket {
    pub a : Vec<usize>,
    pub b : Vec<usize>
}

impl MatchBucket {
    pub fn new() -> Self {
        MatchBucket{
            a : Vec::new(),
            b : Vec::new()
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
