mod service;
mod types;

// use ic_cdk::{
//     api::call::ManualReply, export::Principal, init, post_upgrade, pre_upgrade, query, storage,
//     update,
// };
use ic_cdk::caller;
use crate::service::*;
use crate::types::*;
use ic_cdk_macros::*;
use ic_cdk::export::Principal;

use std::cell::RefCell;
use std::collections::{BTreeMap, BTreeSet};

thread_local! {
    pub static STORE: RefCell<Store> = RefCell::new(Store::default());
}

#[query]
#[ic_cdk::export::candid::candid_method(query)]
pub fn whoami() -> Principal{
    caller()
}

#[query]
#[ic_cdk::export::candid::candid_method(query)]
pub fn get_users() -> Vec<Principal>{
    STORE.with(|s| {
        s.borrow().clone().users
    })
}

#[query]
#[ic_cdk::export::candid::candid_method(query)]
pub fn get_orders() -> Vec<Order>{
    STORE.with(|s| {
        s.borrow().clone().store
    })
}

#[update]
#[ic_cdk::export::candid::candid_method]
pub fn add_user(principal : Principal) {
    STORE.with(|s| {
        s.borrow_mut()
        .users
        .push(principal)
        });
}

#[update]
#[ic_cdk::export::candid::candid_method]
pub fn add_order(order : Order) {
    STORE.with(|s| {
        s.borrow_mut()
        .store
        .push(order)
        });
}

