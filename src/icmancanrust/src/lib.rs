use ic_cdk::api::management_canister::main::*;
use ic_cdk_macros::*;

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
