use std::{collections::HashMap, ops::Deref};

// Import necessary modules
// use ic_cdk::export::candid::{Deserialize};

use candid::{CandidType, Decode, Encode, Deserialize};
#[allow(unused_imports)]
use ic_cdk::storage;
use ic_cdk_macros::*;
use ic_stable_structures::memory_manager::{MemoryId, MemoryManager, VirtualMemory};
use ic_stable_structures::{BoundedStorable, DefaultMemoryImpl, StableBTreeMap, Storable};
use std::{borrow::Cow, cell::RefCell};


const MAX_VALUE_SIZE: u32 = 100;

// Define the data structure for a file
#[derive(Clone, Debug, Deserialize, Default, CandidType)]
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

impl Storable for File {
    fn to_bytes(&self) -> std::borrow::Cow<[u8]> {
        Cow::Owned(Encode!(self).unwrap())
    }

    fn from_bytes(bytes: std::borrow::Cow<[u8]>) -> Self {
        Decode!(bytes.as_ref(), Self).unwrap()
    }
}

impl BoundedStorable for File {
    const MAX_SIZE: u32 = MAX_VALUE_SIZE;
    const IS_FIXED_SIZE: bool = false;
}

// Define the interface for the canister
#[derive(CandidType, Deserialize)]
pub struct FileStorageCanister {
    files: HashMap<String, File>,
}

impl Storable for FileStorageCanister {
    fn to_bytes(&self) -> std::borrow::Cow<[u8]> {
        Cow::Owned(Encode!(self).unwrap())
    }

    fn from_bytes(bytes: std::borrow::Cow<[u8]>) -> Self {
        Decode!(bytes.as_ref(), Self).unwrap()
    }
}

impl BoundedStorable for FileStorageCanister {
    const MAX_SIZE: u32 = MAX_VALUE_SIZE;
    const IS_FIXED_SIZE: bool = false;
}

impl FileStorageCanister {
    // Implement the methods for the canister
    // #[ic_cdk_macros::update]
    #[allow(dead_code)]
    fn add_file(&mut self, name: String, content: Vec<u8>, metadata: String) {
        let file = File {
            name: name.clone(),
            content: content,
            metadata: metadata,
        };
        self.files.insert(name, file);
    }

    // #[ic_cdk_macros::update]
    #[allow(dead_code)]
    fn create_file(&mut self, name: String, content: Vec<u8>, metadata: String) {
        let file = File {
            name: name.clone(),
            content: content,
            metadata: metadata,
        };
        self.files.insert(name, file);
    }

    // #[ic_cdk_macros::update]
    #[allow(dead_code)]
    fn update_file(&mut self, name: String, content: Vec<u8>, metadata: String) {
        if let Some(mut file) = self.files.get_mut(&name) {
            file.content = content;
            file.metadata = metadata;
            // self.files.insert(name, *mut file);
        }
    }

    // #[ic_cdk_macros::update]
    #[allow(dead_code)]
    fn delete_file(&mut self, name: String) {
        self.files.remove(&name);
    }

    // #[ic_cdk_macros::query]
    #[allow(dead_code)]
    fn get_file(&self, name: String) -> Option<File> {
        self.files.get(&name).cloned()
    }
}
