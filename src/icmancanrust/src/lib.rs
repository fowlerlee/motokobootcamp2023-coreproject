use candid::*;
use ic_cdk::caller;
use ic_cdk::*;
use ic_cdk::{api::management_canister::main::*, export::Principal};
use ic_cdk::{api::management_canister::bitcoin::GetBalanceRequest, api::management_canister::*};
use ic_cdk_macros::*;
use std::collections::BTreeSet;
use std::collections::HashMap;
use std::cell::RefCell;

use ic_ledger_types::{
    AccountIdentifier, Memo, Tokens, DEFAULT_SUBACCOUNT, MAINNET_LEDGER_CANISTER_ID,
};



#[derive(Debug, PartialEq, CandidType, Deserialize)]
struct Called {
    topic: String,
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
    #[test]
    fn it_works() {
        let result = 2 + 2;
        assert_eq!(result, 4);
    }
}
