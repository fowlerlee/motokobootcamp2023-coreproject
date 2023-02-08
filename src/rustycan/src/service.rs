
use std::collections::{BTreeMap, BTreeSet};
use ic_cdk::export::Principal;
use crate::types::Store;

impl Default for Store {
    fn default() -> Self {
        Store {
            store: BTreeSet::new(),
            users: BTreeSet::new(),
        }
    }
}