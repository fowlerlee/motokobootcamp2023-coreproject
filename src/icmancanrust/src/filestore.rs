use std::{collections::HashMap, ops::Deref};

// Import necessary modules
use ic_cdk::export::candid::{CandidType, Deserialize};
use ic_cdk::storage;
use ic_cdk_macros::*;
use ic_stable_structures::BoundedStorable;

// Define the data structure for a file
#[derive(Clone, Debug, CandidType, Deserialize, Default)]
pub struct File {
    name: String,
    content: Vec<u8>,
    metadata: String, // Or any other metadata you want to include
}

impl Deref for File {
    type Target = Self;

    fn deref(&self) -> &Self::Target {
        todo!()
    }
}

// Define the interface for the canister
#[derive(CandidType)]
struct FileStorageCanister {
    // #[init]
    files: HashMap<String, File>,
}

impl FileStorageCanister {
    // Implement the methods for the canister
    // #[ic_cdk_macros::update]
    fn add_file(&mut self, name: String, content: Vec<u8>, metadata: String) {
        let file = File {
            name: name.clone(),
            content: content,
            metadata: metadata,
        };
        self.files.insert(name, file);
    }

    // #[ic_cdk_macros::update]
    fn create_file(&mut self, name: String, content: Vec<u8>, metadata: String) {
        let file = File {
            name: name.clone(),
            content: content,
            metadata: metadata,
        };
        self.files.insert(name, file);
    }

    // #[ic_cdk_macros::update]
    fn update_file(&mut self, name: String, content: Vec<u8>, metadata: String) {
        if let Some(mut file) = self.files.get_mut(&name) {
            file.content = content;
            file.metadata = metadata;
            // self.files.insert(name, *mut file);
        }
    }

    // #[ic_cdk_macros::update]
    fn delete_file(&mut self, name: String) {
        self.files.remove(&name);
    }

    // #[ic_cdk_macros::query]
    fn get_file(&self, name: String) -> Option<File> {
        self.files.get(&name).cloned()
    }
}
