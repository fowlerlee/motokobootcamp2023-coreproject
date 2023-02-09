
use std::collections::{BTreeMap, BTreeSet};
use candid::Principal;
use crate::STORE;
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

impl Store {

    fn transfer(to: Principal, from: Principal) -> Result<(),()> {
        let to_account = STORE.with(|s|{s.borrow().wallets.get(&to)});
        let from_account = STORE.with(|s| {s.borrow().wallets.get(&from)});
        Ok(())

    }
}