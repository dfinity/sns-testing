# Testing SNS in local testing environment

> This repository currently does not accept external contributions in the form of pull requests. Please submit your suggestions and bug reports by [opening a ticket](https://github.com/dfinity/sns-testing/issues).


## Purpose

The main purpose of `sns-testing` is to enable developers of Internet Computer (IC) dapps to test Service Nervous System (SNS) decentralization. However, this solution may also be applicable in other scenarios, e.g.:

* Testing tools such as `dfx`, `quill`, `sns`.
* Testing UX-related aspects before releasing the [NNS frontend dapp](https://nns.ic0.app/).

## How to use these instructions

Assuming you are a developer who wants to test SNS-decentralization of their dapp, you need to establish your own dapp's deployment process before using this solution. Usually, a testing deployment is done in a shell script that interacts with a local replica via [DFX](https://internetcomputer.org/docs/current/references/cli-reference/dfx-parent).

You might need to slightly adjust your deployment script to work with sns-testing. In particular, please avoid running `dfx start` or `dfx replica` inside your deployment script (`sns-testing` will take care of starting a replica instance for you).

If you do not yet have a dapp that is ready for decentralization, you may still run `sns-testing` with the built-in test dapp.

## Special instructions for Apple silicon users

<a name="apple-silicon"></a>

_[Skip to the next section](#docker) if you are using an x86-compatible system, e.g., Linux, Windows, or Intel-based Mac._

The `sns-testing` solution is based on Docker; however, there are subtle issues while running Docker on new [Apple silicon](https://support.apple.com/en-us/HT211814) systems (e.g., Apple M1, Apple M2). Therefore, Apple silicon users are advised to run the commands provided by this repository _directly_. This requires additional preparation:

0. Make sure you have Homebrew installed.
   * Instructions: https://brew.sh/
   * Use Homebrew to install (or upgrade to the latest available versions) `bash`, `coreutils` (needed for tools e.g., `sha256sum`), `jq`, and `yq`:
     ```bash
     brew install bash coreutils jq yq
     ```

   You also need rosetta that you can install by running:
   ```bash
   softwareupdate --install-rosetta
   ```

   Also make sure you have Rust installed including the `wasm32-unknown-unknown` target.
   * Instructions: https://www.rust-lang.org/tools/install
   * Add `wasm32-unknown-unknown` into your active toolchain by running:
   ```bash
   rustup target add wasm32-unknown-unknown
   ```

1. Ensure the newly installed tools are added to your `PATH`:
   ```bash
   echo 'export PATH="$PATH:/opt/homebrew/bin/:/usr/local/opt/coreutils/libexec/gnubin"' >> "${HOME}/.bashrc"
   ```
   Above, we rely on `.bashrc`, as the main commands from this repository are to be executed via Bash.
2. Clone this repository: 
   ```bash
   git clone git@github.com:dfinity/sns-testing.git
   cd sns-testing
   ```
3. Run the installation script:
   ```bash
   bash install.sh
   ```
4. Start a local replica (this will keep running in the current console; press ⌘+C to stop):
   ```bash
   DX_NET_JSON="${HOME}/.config/dfx/networks.json"
   mkdir -p "$(dirname "${DX_NET_JSON}")"
   cp "$DX_NET_JSON" "${DX_NET_JSON}.tmp" 2>/dev/null  # save original config if present
   echo '{
      "local": {
         "bind": "0.0.0.0:8080",
         "type": "ephemeral",
         "replica": {
            "subnet_type": "system",
            "port": 8000
         }
      }
   }' > "${DX_NET_JSON}"
   ./bin/dfx start --clean; \
   mv "${DX_NET_JSON}.tmp" "$DX_NET_JSON" 2>/dev/null  # restore original config if it was present
   ```

   While running these instructions for the first time, you may need to hit the "Allow" button to authorize the system to execute the binaries shipped with sns-testing, e.g., `./bin/dfx`.

   This should print the dashboard URL:

    ```
    Replica API running on 0.0.0.0:8000
    ```

5. Open another Bash console:
   ```bash
   bash
   ```
   and run the setup script:
   ```bash
   ./setup_locally.sh  # from Bash
   ```
   After this step, you can also access the [NNS frontend dapp](http://qsgjb-riaaa-aaaaa-aaaga-cai.localhost:8080/) from the browser.


6. To validate the testing environment, run the test dapp shipped with this repository through the entire SNS lifecycle:
   ```bash
   ./run_basic_scenario.sh  # from Bash
   ```
   If the basic scenario finished successfully, you should see the message
    `Basic scenario has successfully finished.` on the last line of the output.

   Observe the newly created SNS instance via the [NNS frontend dapp](http://qsgjb-riaaa-aaaaa-aaaga-cai.localhost:8080/). When you try to login for the first time, you will need to register a new Internet Identity for testing.

   > If you have successfully executed the above commands, you are now ready to [test your own dapp's SNS decentralization](#lifecycle).

7. Clean-up (after you are done testing):

    > Note that performing the clean-up will delete some files in the sns-testing repository and your DFX wallets
    > for the local network (not affecting mainnet).
    > Make sure to back up all files you move into the sns-testing repository.

    ```bash
    ./cleanup.sh  # from Bash
    ```

    It should now be possible to repeat the scenario starting from step 4.

## Bootstrapping a testing environment via Docker

<a name="docker"></a>

_This section explains the simplest way to set up a local environment for testing SNS decentralization. However, this solution is based on Docker and is currently [not supported on Apple silicon systems](#apple-silicon). Please proceed if you are using Linux, Windows, or Intel-based Mac._

After getting familiar with the basic scenario, you may replace the test canister with your own one, and use this repo as a skeleton for creating a custom testing environment.


1. If your dapp is ready for testing, clone it into the current directory and cd into it.

2. Make sure you have the latest verion of the sns-testing Docker container by running the command:
   ```bash
   docker pull ghcr.io/dfinity/sns-testing:main
   ```

3. Start a local replica instance inside a Docker container:
    ```bash
   SNS_TESTING_INSTANCE=$(
       docker run -p 8000:8000 -p 8080:8080 -v "`pwd`":/dapp -d ghcr.io/dfinity/sns-testing:main dfx start --clean
   )
   while ! docker logs $SNS_TESTING_INSTANCE 2>&1 | grep -m 1 'Replica API running'
   do
       echo "Awaiting local replica ..."
       sleep 3
   done
    ```
    This should print the dashboard URL:

    ```
    Awaiting local replica ...
    Replica API running on 0.0.0.0:8080
    ```

4. Run setup:
    ```bash
    docker exec -it $SNS_TESTING_INSTANCE bash setup_locally.sh
    ```
    After this step, you can also access the [NNS frontend dapp](http://qsgjb-riaaa-aaaaa-aaaga-cai.localhost:8080/)
    from the browser on your host machine.

5. Run the basic scenario:
    ```bash
    docker exec $SNS_TESTING_INSTANCE bash run_basic_scenario.sh
    ```
    If the basic scenario finished successfully, you should see the message
    `Basic scenario has successfully finished.` on the last line of the output.

    Observe the newly created SNS instance via the [NNS frontend dapp](http://qsgjb-riaaa-aaaaa-aaaga-cai.localhost:8080/). When you try to login for the first time, you will need to register a new Internet Identity for testing.

6. If you have successfully executed the above commands, enter a Bash shell inside your `sns-testing` Docker instance by running
   ```bash
   docker exec -it $SNS_TESTING_INSTANCE bash
   ```
   Note: The instruction for testing your own dapp's SNS decentralization assume that all commands are executed from _this_ bash session (inside Docker). You should still have access to your dapp's files, as the repo was mounted at `/dapp` inside the container.

   > You are now ready to [test your own dapp's SNS decentralization](#lifecycle).

7. Clean-up (after you are done testing):
    ```bash
    docker kill $SNS_TESTING_INSTANCE
    ```
    It should now be possible to repeat the scenario starting from step 1.

The above run-book could be easily automated and integrated into your CI/CD pipeline.

## Troubleshooting

-  If either of the ports 8000 or 8080 are occupied, then `docker run -p 8000:8000 -p 8080:8080 ...` and `./bin/dfx start --clean` are expected to fail.
   In that case, you should run `docker ps` (if you have Docker installed on your system) and `lsof -i :8000` or `lsof -i :8080`
   to determine the service listening on the port 8000 or 8080, correspondingly, and then close the service.

## SNS lifecycle

<a name="lifecycle"></a>

_This section assumes that you have successfully deployed a local environment for testing SNS decentralization and validated your setup by creating an SNS instance for the test dapp (shipped with `sns-testing`)._

We now explain how to test your own dapp's SNS decentralization.

Your SNS configuration file should only specify a single initial SNS developer neuron
controlled by your DFX principal for the following instructions to work without
any additional steps required (otherwise, you'd need to _manually vote_ on SNS proposals
created during these steps with your initial SNS developer neurons).

0. Run the following script to ensure the local file system is in the right state:

   ```bash
   ./cleanup.sh  # from Bash
   ```

1. Deploy your dapp onto the local replica instance as per usual. You can find
   your dapp repo under the path `/dapp` in the Docker container. This step
   requires your dapp repo to have a deployment script that interacts with the
   replica via the 8080 port.

   If you don't yet have a solution to deploy your custom dapp, you can still
   proceed with these instructions by deploying the test dapp provided with this
   repo:

   ```bash
   ./deploy_test_canister.sh  # from Bash
   ```

   This will deploy a test canister (see Section
   [Test canister](https://github.com/dfinity/sns-testing#test-canister)
   for further details) which can be thought of as a placeholder
   for your dapp.

2. Give control of your dapp canisters to NNS:
   ```bash
   ./let_nns_control_dapp.sh  # from Bash
   ```` 
   This automatically creates an SNS
   configuration file named `sns_init.yaml`, unless such a file already exists
   (e.g. you hand-crafted one yourself). The auto-generated file assumes that
   you are using the test dapp.

3. Submit an NNS proposal to create an SNS that will control your dapp canister(s):
   ```bash
   ./propose_sns.sh  # from Bash
   ``` 
   The proposal will pass right away, because it is made by a neuron that has an
   overwhelming amount of voting power (this is part of the testing environment).

   After a few minutes, you should see a new SNS instance in the [Launchpad]
   section of the NNS dapp.

   [Launchpad]: http://qsgjb-riaaa-aaaaa-aaaga-cai.localhost:8080/launchpad

4. Optional: Upgrade your dapp canister(s) via SNS proposal.

   If you are going through these instructions using the test dapp, this step 
   can be done as follows:

   ```bash
   ./upgrade_test_canister.sh "Swap is taking place."  # from Bash
   ```

   This submits an SNS proposal to upgrade the test dapp. If you are using the
   auto-generated `sns_init.yaml` file, the proposing neuron will have all of
   the voting power in the SNS. Thus, the proposal will be adopted and executed
   right away. Otherwise, you you might to vote with additional initial neurons
   to pass the upgrade proposal.

   If you are using your own dapp rather than the test dapp, look at how
   `upgrade_test_canister.sh` works. In short, it ends up calling `quill sns
   make-upgrade-canister-proposal`. That command takes a fair number of
   arguments. Therefore, it is helpful to look at how the script(s) here invoke
   that command as a guide to how you can invoke the command to propose an
   upgrade to your own dapp.
   
5. Once the swap starts, you can simulate multiple users' participation:

   ```bash
   ./participate_sns_swap.sh <num-participants> <icp-per-participant>  # from Bash
   ``` 
   
   You can run `./participate_sns_swap.sh` multiple times (with different
   arguments). For example, if you run 
   ```
   ./participate_sns_swap.sh 2 7
   ./participate_sns_swap.sh 4 3
   ```

   The first above command creates two user identities (called
   `participant-000` and `participant-001`), each contributing 7 ICPs to the
   swap. The second command then _reuses_ the first two participants, each
   of which now contributes 3 _more_ ICPs; it then creates two _new_
   participants, each contributing 3 ICPs as well. So, the overall contributions
   will be:

   Identity Name   | Swap Contribution, ICP
   --------------- | ----------------------
   participant-000 | 10
   participant-001 | 10
   participant-002 | 3
   participant-003 | 3

   You can also participate in the swap using the [NNS Dapp][nns-dapp]
   (another feature of the test environment). There, you can conjure some ICP
   for yourself using the "Get ICP" button (another feature of the test
   environment), and use the ICP to participate in the ongoing swap.

   [nns-dapp]: http://qsgjb-riaaa-aaaaa-aaaga-cai.localhost:8080

   You can make the swap complete immediately by making the total participation
   amount equal to the target ICP amount.

6. Optional: Submit (another) proposal to upgrade one of your dapp canisters.
   Unlike before, the proposal will probably not pass right away, because now,
   the voting power is spread among multiple neurons.

   If using the test dapp, this step can be performed like so:

   ```bash
   ./upgrade_test_canister.sh "First upgrade after the initial token swap."  # from Bash
   ```

   This is similar to step 4, but we use a different message argument so that
   there will be a visible change to the dapp.

   * To make the upgrade proposal pass, tell the participants created by 
      `participate_sns_swap.sh` to vote on the proposal, like so:

      ```bash
      ./vote_on_sns_proposal.sh <num-participants> <proposal-id> y  # from Bash
      ```

   * If you would rather test the proposal rejection scenario, simply replace
      `y` in the above command with `n`.

   **Casting sufficient votes.** In either of the above cases, make sure that `<num-participants>` is sufficient
   for the proposal to be decided by majority; i.e., we need _strictly more_ than
   50%.
   
   For example, if you called `./participate_sns_swap.sh 100 <icp-per-participant>`, then
   `./vote_on_sns_proposal.sh 51 <proposal-id> y` will cast enough yes-votes for
   the proposal to be adopted, and `./vote_on_sns_proposal.sh 51 <proposal-id> n`
   will cast enough no-votes for the proposal to be rejected, whereas, e.g.,
   `./vote_on_sns_proposal.sh 50 <proposal-id> n` will still keep the proposal
   open.

   **Observing voting errors.** It is expected to get the error
   "Neuron not eligible to vote on proposal." for some neurons because
   each participant gets a basket of neurons with various dissolve delays
   and only neurons with dissolve delay at least
   `neuron_minimum_dissolve_delay_to_vote_seconds` (according to the SNS configuration
   file from step 1.) are eligible to vote. It is also expected to get the error
   "Neuron already voted on proposal." for some neurons because
   they are followers of other neurons and our simple voting script
   does not take this into account.
  
Congratulations! You have now seen SNS in action in a test environment. We
recommend that you experiment with different configurations until you find one
that works best for your project.

## Check out SNS state

You can inspect the SNS state by running the following scripts:

- `get_last_sns_proposal.sh`: displays the SNS proposal that was added most recently;
- `get_sns_proposal.sh <proposal-id>`: displays the SNS proposal with given `<proposal-id>`;
- `get_sns_canisters.sh`: shows the canister IDs of the SNS canisters and the registered dapp canisters;
- `get_sns_neurons.sh`: displays all SNS neurons of your DFX identity;
- `get_all_sns_neurons.sh`: displays all SNS neurons in the SNS governance canister;
- `get_sns_swap_state.sh`: displays the SNS swap's state.

## Test canister

The test canister is available in the directory `test`. Its purpose is
* to provide a simple dapp that can be deployed
  and handed over control of to an SNS in the basic scenario and
* to show how generic SNS functions can be implemented and secured to be
  only called by the SNS governance canister.

Internally, the test canister keeps an integer counter and a greeting message.
Furthermore, the test canister exposes public methods to get the value of the counter,
a greeting text starting with the greeting message, and a pair of functions (called
`validate` and `execute` that can be used as generic SNS functions, which means that these methods can be called as a result of an SNS proposal ---
see Section 7 of this
[tutorial](https://internetcomputer.org/docs/current/developer-docs/integrations/sns/get-sns/testflight)
for further details). 
Callers to the `execute` function are restricted to a canister ID that can be set
in the initial arguments when deploying or upgrading the test canister.
By specifying the SNS governance canister ID as the allowed canister ID to call the `execute`
function you make sure that this method can _only_ be invoked as a result of an adopted SNS proposal.
Note that the `validate` function must be safe to call with any arguments because
every submitted SNS proposal for executing generic SNS functions triggers
the execution of the `validate` function (also if the SNS proposal is eventually rejected)
and every SNS neuron can make such an SNS proposal.
Hence, callers of the `validate` function are not restricted in the test canister
(you might still want to restrict callers of the `validate` function in your own canister, e.g.,
to prevent users from using up your canister's cycles by calling the `validate` function)
and the `validate` function is implemented to be safe to call by anyone with any arguments.

You should specify the SNS governance canister ID as the allowed canister ID
to call the `execute` function.

1. You can deploy the test canister from this repository by running the script
   `./deploy_test_canister.sh`.

You should run the following steps after `deploy_sns.sh <config-path>`
and before `open_sns_swap.sh` according to
the [SNS lifecycle](https://github.com/dfinity/sns-testing#sns-lifecycle) section.

2. You can then register the test canister with the SNS by running the script
   `./register_dapp.sh <canister-id>`.
   
   Here, `<canister-id>` is the principal of the canister that you want to decentralize.

3. Upgrade the test canister by running the script `upgrade_test_canister.sh`.
   The upgrade also stores the SNS governance canister ID in the canister's
   memory to implement access control restrictions
   to the `execute` method of the test canister
   (only the SNS governance canister is allowed to call this method).
4. To test generic functions of the test canister, you need to register them
   first. An example SNS proposal to register generic functions (the functions
   `validate` and `execute` of the test canister)
   is submitted by running the script `./register_generic_functions_test.sh`.
5. Now you can submit SNS proposals to execute the generic functions by running
   `./execute_generic_functions_test.sh <greeting>` where `<greeting>`
   is the new greeting message to be set in the test canister. Note that
   `<greeting>` must be non-empty (otherwise the proposal validation
   should fail).
6. Once the SNS proposal is executed, you should see the new greeting
   message when invoking `dfx canister call test greet "Martin"`.
   You should also see that the counter obtained via
   `dfx canister call test get` got incremented after executing
   the SNS proposal (the counter gets incremented upon every call to
   the `execute` function).

## Check out canister status

You can inspect the status of a canister `<name>` (with a corresponding entry
in the `dfx.json` file) by running the script `./get_canister_status.sh <name>`.
Note that your DFX identity must be a controller of the canister `<name>`
for that script to succeed. In particular, you can also invoke the script
to check if your DFX identity is a controller of the canister `<name>`.

## Hacking

You can find further instructions for expert users in the file
[HACKING.md](https://github.com/dfinity/sns-testing/blob/main/HACKING.md).
