use candid::Principal;
use ic_agent::Agent;
use std::env;

#[tokio::main]
async fn main() {
    let args: Vec<String> = env::args().collect();
    let url = &args[1];

    let agent = Agent::builder().with_url(url).build().unwrap();

    let root_key = agent
        .status()
        .await
        .expect("Could not get agent status")
        .root_key
        .expect("Agent should have fetched the root key.");

    println!("{}", Principal::self_authenticating(root_key).to_string());
}
