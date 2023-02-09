
use std::collections::{BTreeMap, BTreeSet};
use crate::types::Store;

impl Default for Store {
    fn default() -> Self {
        Store {
            store: BTreeSet::new(),
            users: BTreeSet::new(),
            wallets: BTreeMap::new(),
        }
    }
}