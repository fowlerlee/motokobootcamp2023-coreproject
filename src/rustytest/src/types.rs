#[allow(unused_variables, unused_imports, dead_code)]
use candid::*;
use ic_cdk::*;
use std::cell::RefCell;
use std::collections::{BTreeMap, BTreeSet};
use std::rc::Rc;
use serde::*;

pub type Link = Option<Rc<RefCell<Node>>>;

struct Node {
    left: Link,
    right: Link,
}

#[non_exhaustive]
#[derive(CandidType, Clone, Deserialize, Eq, Hash, PartialEq, Serialize, Copy, Debug)]
pub enum Errors {
    Failed,
    Pass,
    Pending,
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
