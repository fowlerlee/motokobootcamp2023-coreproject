#[allow(unused_imports)]
use ic_cdk::{api::management_canister::bitcoin::GetBalanceRequest, api::management_canister::*};
use ic_cdk_macros::*;
#[allow(unused_imports)]
use ic_ledger_types::{
    AccountIdentifier, Memo, Tokens, DEFAULT_SUBACCOUNT, MAINNET_LEDGER_CANISTER_ID,
};
use std::collections::BTreeSet;

use candid::*;
use ic_cdk::caller;

use ic_cdk::{api::management_canister::main::*, export::Principal};

use ic_stable_structures::memory_manager::{MemoryId, MemoryManager, VirtualMemory};
use ic_stable_structures::{DefaultMemoryImpl, StableBTreeMap};
use std::cell::RefCell;
use std::collections::HashMap;

mod types;
use types::Memory;

mod filestore;
#[allow(unused_imports)]
use filestore::*;

#[derive(Debug, PartialEq, CandidType, Deserialize)]
struct Called {
    topic: String,
}

pub fn find_first(p: Principal) {
    STATE.with(|s| if let Some(x) = s.borrow_mut().owner.take() {})
}

// pub async fn get_balance(network: Network, address: String) -> u64 {
//     let balance_res: Result<(Satoshi,), _> = call_with_payment(
//         Principal::management_canister(),
//         "bitcoin_get_balance",
//         (GetBalanceRequest {
//             address,
//             network,
//             min_confirmations: None,
//         },),
//         GET_BALANCE_COST_CYCLES,
//     )
//     .await;

//     balance_res.unwrap().0
// }

// pub async fn bitcoin_get_balance(arg: GetBalanceRequest) -> CallResult<(Satoshi,)> {
//     call_with_payment128(
//         Principal::management_canister(),
//         "bitcoin_get_balance",
//         (arg,),
//         GET_BALANCE_CYCLES,
//     )
//     .await
// }

// #[update]
// async fn get_orders() -> u64 {
//     let called = Called{topic: "lee".to_string()};
//     // async fn test(number: i32) -> Result<i32, sudograph::async_graphql::Error> {
//     let call_result: Result<u64, _> = ic_cdk::api::call::call(ic_cdk::export::Principal::from_text("qoctq-giaaa-aaaaa-aaaea-cai").unwrap(), "main", (called,)).await;
//     return call_result.unwrap().0;
//     // }
//     //     let (canister,) : (candid::Principal,) = ic_cdk::api::call(candid::Principal::management_canister(), "create_canister", ()).await?;
//     // let (canister,) : (BTreeSet<Order>,) = ic_cdk::api::call(, "create_canister", ()).await?;
//     // return RustyCan::get_orders().await.0;
// }

thread_local! {
    static STATE: RefCell<State> = RefCell::new(State::default());

    static MEMORY_MANAGER: RefCell<MemoryManager<DefaultMemoryImpl>> =
    RefCell::new(MemoryManager::init(DefaultMemoryImpl::default()));

    static MAP: RefCell<StableBTreeMap<u64, FileStorageCanister, Memory>> = RefCell::new(
    StableBTreeMap::init(
        MEMORY_MANAGER.with(|m| m.borrow().get(MemoryId::new(0))),
    ));

    static FILES: RefCell<filestore::File> = RefCell::new(filestore::File::default())
}

#[derive(Default)]
pub struct Balances(pub HashMap<Principal, HashMap<Principal, Nat>>);
type Orders = HashMap<OrderId, Order>;


#[derive(Default)]
pub struct State {
    owner: Option<Principal>,
    ledger: Option<Principal>,
    exchange: Exchange,
}

#[derive(Default)]
pub struct Exchange {
    pub next_id: OrderId,
    pub balances: Balances,
    pub orders: Orders,
}

pub type OrderId = u32;

pub struct Order {
    pub id: OrderId,
    pub owner: Principal,
    pub from: Principal,
    pub fromAmount: u8,
    pub to: Principal,
    pub toAmount: u8,
}

// Retrieves the value associated with the given key if it exists.
#[query]
fn get(key: u64) -> Option<FileStorageCanister> {
    MAP.with(|p| p.borrow().get(&key))
}

// Inserts an entry into the map and returns the previous value of the key if it exists.
#[update]
fn insert(key: u64, value: FileStorageCanister) -> Option<FileStorageCanister> {
    MAP.with(|p| p.borrow_mut().insert(key, value))
}


#[update]
async fn execute_main_methods() {
    let arg = CreateCanisterArgument {
        settings: Some(CanisterSettings {
            controllers: Some(vec![ic_cdk::id()]),
            compute_allocation: Some(0.into()),
            memory_allocation: Some(10000.into()),
            freezing_threshold: Some(10000.into()),
        }),
    };
    create_canister(arg).await.unwrap();

    let canister_id =
        create_canister_with_extra_cycles(CreateCanisterArgument::default(), 1_000_000_000_000u128)
            .await
            .unwrap()
            .0
            .canister_id;

    let arg = UpdateSettingsArgument {
        canister_id,
        settings: CanisterSettings::default(),
    };
    update_settings(arg).await.unwrap();
}

#[cfg(test)]
mod tests {
    use super::*;
    #[test]
    fn it_works() {
        let result = 2 + 2;
        assert_eq!(result, 4);
    }
}
