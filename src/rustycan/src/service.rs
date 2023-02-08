

use ic_cdk::export::Principal;
use crate::types::Store;

impl Default for Store {
    fn default() -> Self {
        Store {
            store: Vec::new(),
            users: Vec::new(),
        }
    }
}