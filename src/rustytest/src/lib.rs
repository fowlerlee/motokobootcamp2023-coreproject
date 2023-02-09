use ic_cdk_macros::*;

#[query]
#[ic_cdk::export::candid::candid_method(query)]
fn main() -> u64 {
    1u64
}
