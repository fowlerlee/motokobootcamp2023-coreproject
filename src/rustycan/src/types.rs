use candid::{CandidType, Deserialize};
use ic_cdk::export::Principal;
use serde::Serialize;
use std::collections::{BTreeMap, BTreeSet};

pub type OrderId = u32;

#[allow(non_snake_case)]
#[derive(Clone, Serialize, Debug, CandidType, Deserialize, PartialEq, PartialOrd, Ord, Eq)]
pub struct Order {
    pub id: OrderId,
    pub owner: Principal,
    pub from: Principal,
    pub fromAmount: u8,
    pub to: Principal,
    pub toAmount: u8,
}

// #[derive(Clone, Serialize, CandidType, Deserialize)]
// pub type SubAccount = u8;

// #[derive(Clone, Serialize, CandidType, Deserialize)]
// pub type Account = {
//     pub principal : Principal,
//     pub subaccount : Option<SubAccount>,
// }

#[derive(Clone, Serialize, CandidType, Deserialize)]
pub struct Store {
    pub store: BTreeSet<Order>,
    pub users: BTreeSet<Principal>,
}

// #[derive(CandidType)]
// pub struct Balance {
//     pub owner: Principal,
//     pub token: Principal,
//     pub amount: Nat,
// }

// pub type CancelOrderReceipt = Result<OrderId, CancelOrderErr>;

// #[derive(CandidType)]
// pub enum CancelOrderErr {
//     NotAllowed,
//     NotExistingOrder,
// }

// pub type DepositReceipt = Result<Nat, DepositErr>;

// #[derive(CandidType)]
// pub enum DepositErr {
//     BalanceLow,
//     TransferFailure,
// }

// pub type OrderPlacementReceipt = Result<Option<Order>, OrderPlacementErr>;

// #[derive(CandidType)]
// pub enum OrderPlacementErr {
//     InvalidOrder,
//     OrderBookFull,
// }

// pub type WithdrawReceipt = Result<Nat, WithdrawErr>;

// #[derive(CandidType)]
// pub enum WithdrawErr {
//     BalanceLow,
//     TransferFailure,
// }
