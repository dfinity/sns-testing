use candid::{CandidType, Principal};
use ic_cdk::{caller, trap};
use serde::Deserialize;
use std::cell::RefCell;

thread_local! {
    static CTR: RefCell<u64> = RefCell::new(0);
    static STR: RefCell<String> = RefCell::new("Hoi".to_string());
    static GOVERNANCE: RefCell<Option<Principal>> = RefCell::new(None);
}

#[derive(CandidType, Deserialize)]
struct InitArgs {
    sns_governance: Option<Principal>,
    greeting: Option<String>,
}

fn init_impl(x: Option<InitArgs>) {
    match x {
        None => (),
        Some(x) => {
            GOVERNANCE.with(|g| *g.borrow_mut() = x.sns_governance);
            match x.greeting {
                None => (),
                Some(g) => {
                    STR.with(|s| *s.borrow_mut() = g);
                }
            };
        }
    }
}

#[ic_cdk::init]
fn init(x: Option<InitArgs>) {
    init_impl(x);
}

#[ic_cdk::post_upgrade]
fn post_upgrade(x: Option<InitArgs>) {
    init_impl(x);
}

#[ic_cdk::update]
fn validate(x: String) -> Result<String, String> {
    if x.is_empty() {
        Err("empty".to_string())
    } else {
        Ok(format!("the new greeting message is: {}", x))
    }
}

#[ic_cdk::update]
fn execute(x: String) {
    let gov = GOVERNANCE.with(|g| *g.borrow());
    match gov {
        None => trap("SNS Governance canister ID is not set"),
        Some(sns_governance) => {
            if caller() == sns_governance {
                STR.with(|s| *s.borrow_mut() = x);
                CTR.with(|c| (*c.borrow_mut()) += 1);
            } else {
                trap("execute can only be called by SNS Governance");
            }
        }
    }
}

#[ic_cdk::update]
fn get() -> u64 {
    CTR.with(|c| *c.borrow_mut())
}

#[ic_cdk::update]
fn greet(name: String) -> String {
    format!("{}, {}!", STR.with(|s| (*s.borrow_mut()).clone()), name)
}

ic_cdk::export_candid!();
