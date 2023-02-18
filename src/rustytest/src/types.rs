#[allow(unused_variables, unused_imports, dead_code)]
use candid::*;
use ic_cdk::*;
use std::cell::RefCell;
use std::collections::{BTreeMap, BTreeSet};
use std::rc::Rc;

pub type Link = Option<Rc<RefCell<Node>>>;

struct Node {
    left: Link,
    right: Link,
}

struct NFT {
    id: u64,
    creator: Principal,
    owner: Principal,
    date: f64,
}

struct User {
    devices: BTreeSet<Devices>,
    nfts: BTreeSet<NFT>,
}

struct Devices {
    devices: BTreeMap<Principal, Devices>,
}

#[derive(Default)]
pub struct Shop {
    users: BTreeSet<User>,
}
