use ic_cdk_macros::*;
use candid::*;
use serde::Deserialize;


#[derive(Debug, PartialEq, CandidType, Deserialize)]
struct Called {
    topic: String,
} 


#[query]
#[ic_cdk::export::candid::candid_method(query)]
fn main(_called : Called) -> u64 {
    10u64
}
