mod service;
mod types;

use crate::service::*;
use crate::types::*;
use ic_cdk::export::Principal;
use ic_cdk::{caller, storage};
use ic_cdk_macros::*;
use ic_cdk_macros::import;

use std::cell::RefCell;
use std::collections::{BTreeMap, BTreeSet};

#[import(canister = "rustytest")]
struct TestCanister;

thread_local! {
    pub static STORE: RefCell<Store> = RefCell::new(Store::default());
}

#[query]
#[ic_cdk::export::candid::candid_method(query)]
pub fn whoami() -> Principal {
    caller()
}

#[query]
#[ic_cdk::export::candid::candid_method(query)]
pub fn get_users() -> BTreeSet<Principal> {
    STORE.with(|s| s.borrow().clone().users)
}

#[query]
#[ic_cdk::export::candid::candid_method(query)]
pub fn get_orders() -> BTreeSet<Order> {
    STORE.with(|s| s.borrow().clone().store)
}

#[update]
#[ic_cdk::export::candid::candid_method]
pub fn add_user(principal: Principal) {
    STORE.with(|s| s.borrow_mut().users.insert(principal));
}

#[update]
#[ic_cdk::export::candid::candid_method]
pub fn add_wallet(pr: Principal, subacc : Option<SubAccount>) {
    STORE.with(|s| s.borrow_mut().wallets.insert(pr, Account { principal: (pr), subaccount: (subacc) }));
}

#[update]
#[ic_cdk::export::candid::candid_method]
pub fn add_order(order: Order) {
    STORE.with(|s| s.borrow_mut().store.insert(order));
}


// #[update(name = "main")]
// async fn main() -> u64 {
//     TestCanister::main().await.0
// }

#[pre_upgrade]
fn pre_upgrade() {
    STORE.with(|store| storage::stable_save((store,)).unwrap());
}

#[post_upgrade]
fn post_upgrade() {
    let (old_store,): (Store,) = storage::stable_restore().unwrap();
    STORE.with(|store| *store.borrow_mut() = old_store);
}
