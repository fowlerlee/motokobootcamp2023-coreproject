use std::async_iter;

// mod rustycan;
use candid::*;

use ic_cdk::*;
use ic_cdk::{api::management_canister::main::*, export::Principal};
use ic_cdk_macros::*;
use std::collections::{BTreeSet};

// #[import(canister = "rustycan")]
// struct RustyCan;

#[derive(Debug, PartialEq, CandidType, Deserialize)]
struct Called {
    topic: String,
} 

#[update]
async fn get_orders() -> u64 {
    let called = Called{topic: "lee".to_string()};
    // async fn test(number: i32) -> Result<i32, sudograph::async_graphql::Error> {
    let call_result: Result<u64, _> = ic_cdk::api::call::call(ic_cdk::export::Principal::from_text("qoctq-giaaa-aaaaa-aaaea-cai").unwrap(), "main", (called,)).await;
    return call_result.unwrap().0;
    // }
    //     let (canister,) : (candid::Principal,) = ic_cdk::api::call(candid::Principal::management_canister(), "create_canister", ()).await?;
    // let (canister,) : (BTreeSet<Order>,) = ic_cdk::api::call(, "create_canister", ()).await?;
    // return RustyCan::get_orders().await.0;
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
