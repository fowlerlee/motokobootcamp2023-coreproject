
use std::collections::{BTreeMap, BTreeSet};
use candid::Principal;
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

    pub fn new() -> Self {
        Store{
            store: Default::default(),
            users: Default::default(),
            wallets: Default::default()
        }
    }

    pub async fn transfer (&self, to: Principal, from: Principal, amount: usize) ->  {

    }

    // fn transfer(to: Principal, from: Principal) -> Result<(),()> {
    //     let to_account = STORE.with(|s|{s.borrow().wallets.get(&to)});
    //     let from_account = STORE.with(|s| {s.borrow().wallets.get(&from)});
    //     Ok(())

    // }

}