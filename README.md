# Testing SNS in local testing environment

> This repository currently does not accept external contributions in the form of pull requests. Please submit your suggestions and bug reports by [opening a ticket](https://github.com/dfinity/sns-testing/issues).


## Purpose

The main purpose of `sns-testing` is to enable developers of Internet Computer (IC) dapps to test Service Nervous System (SNS) decentralization. However, this solution may also be applicable in other scenarios, e.g.:

* Testing tools such as `dfx`, `sns-quill`.
* Testing UX-related aspects before releasing the [NNS frontend dapp](https://nns.ic0.app/).

## How to use these instructions

Assuming you are a developer who wants to test SNS-decentralization of their dapp, you need to establish your own dapp's deployment process before using this solution. Usually, a testing deployment is done in a shell script that interacts with a local replica via [DFX](https://internetcomputer.org/docs/current/references/cli-reference/dfx-parent).

You might need to slightly adjust your deployment script to work with sns-testing. In particular, please avoid running `dfx start` or `dfx replica` inside your deployment script (`sns-testing` will take care of starting a replica instance for you).

If you do not yet have a dapp that is ready for decentralization, you may still run `sns-testing` with the built-in example dapp.

## Special instructions for Apple silicon users

<a name="apple-silicon"></a>

_[Skip to the next section](#docker) if you are using an x86-compatible system, e.g., Linux, Windows, or Intel-based Mac._

The `sns-testing` solution is based on Docker; however, there are subtle issues while running Docker on new [Apple silicon](https://support.apple.com/en-us/HT211814) systems (e.g., Apple M1, Apple M2). Therefore, Apple silicon users are advised to run the commands provided by this repository _directly_. This requires additional preparation:

0. Make sure you have Homebrew installed.
   * Instructions: https://brew.sh/
   * Use Homebrew to install `coreutils` (needed for tools e.g., `sha256sum`) and `jq`:
     ```bash
     brew install coreutils jq
     ```
   Also make sure you have Rust installed including the `wasm32-unknown-unknown` target
   that you can add into your active toolchain by running:

   ```bash
   rustup target add wasm32-unknown-unknown
   ```

1. Ensure the newly installed tools are added to your `PATH`:
   ```bash
   echo 'export PATH="$PATH:/opt/homebrew/bin/:/usr/local/opt/coreutils/libexec/gnubin"' >> "${HOME}/.bashrc"
   ```
   Above, we rely on `.bashrc`, as the main commands from this repository are to be executed via Bash.
2. Clone this repository: 
   ```
   git clone git@github.com:dfinity/sns-testing.git
   cd sns-testing
   ```
3. Clone the dependency repositories and run the installation script:
   ```bash
   git clone https://github.com/dfinity/internet-identity.git
   git clone https://github.com/dfinity/nns-dapp.git
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
            "subnet_type": "system"
         }
      }
   }' > "${DX_NET_JSON}"
   ./bin/dfx start --clean; \
   mv "${DX_NET_JSON}.tmp" "$DX_NET_JSON" 2>/dev/null  # restore original config if it was present
   ```

   While running these instructions for the first time, you may need to hit the ``Allow'' button to authorize the system to execute the binaries shipped with sns-testing, e.g., `./bin/dfx`.

   This should print the dashboard URL, e.g.:

    ```
    Awaiting local replica ...
    Dashboard: http://localhost:35727/_/dashboard
    ```

5. Open another Bash console:
   ```bash
   bash
   ```
   and run the setup script:
   ```bash
   bash-3.2$ ./setup_locally.sh
   ```
   After this step, you can also access the [NNS frontend dapp](http://qsgjb-riaaa-aaaaa-aaaga-cai.localhost:8080/) from the browser.


6. To validate the testing environment, run the example dapp shipped with this repository through the entire SNS lifecycle:
   ```bash
   bash-3.2$ ./run_basic_scenario.sh
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
    bash-3.2$ ./cleanup.sh
    ```

    It should now be possible to repeat the scenario starting from step 1.

## Bootstrapping a testing environment via Docker

<a name="docker"></a>

_This section explains the simplest way to set up a local environment for testing SNS decentralization. However, this solution is based on Docker and is currently [not supported on Apple silicon systems](#apple-silicon). Please proceed if you are using Linux, Windows, or Intel-based Mac._

After getting familiar with the basic scenario, you may replace the test canister with your own one, and use this repo as a skeleton for creating a custom testing environment.

1. If your dapp is ready for testing, clone it into the current directory and cd into it.

2. Start a local replica instance:
    ```bash
   SNS_TESTING_INSTANCE=$(
       docker run -p 8080:8080 -v "`pwd`":/dapp -d martin2718/sns-testing:latest dfx start --clean
   )
   while ! docker logs $SNS_TESTING_INSTANCE 2>&1 | grep -m 1 'Dashboard:'
   do
       echo "Awaiting local replica ..."
       sleep 3
   done
    ```
    This should print the dashboard URL, e.g.:

    ```
    Awaiting local replica ...
    Dashboard: http://localhost:35727/_/dashboard
    ```

    Note that the dashboard is currently not accessible from the browser on your host system.

3. Run setup:
    ```bash
    docker exec -it $SNS_TESTING_INSTANCE bash setup_locally.sh
    ```
    After this step, you can also access the [NNS frontend dapp](http://qsgjb-riaaa-aaaaa-aaaga-cai.localhost:8080/)
    from the browser on your host machine.

4. Run the basic scenario:
    ```bash
    docker exec $SNS_TESTING_INSTANCE bash run_basic_scenario.sh
    ```
    If the basic scenario finished successfully, you should see the message
    `Basic scenario has successfully finished.` on the last line of the output.

    Observe the newly created SNS instance via the [NNS frontend dapp](http://qsgjb-riaaa-aaaaa-aaaga-cai.localhost:8080/). When you try to login for the first time, you will need to register a new Internet Identity for testing.

5. If you have successfully executed the above commands, enter a Bash shell inside your `sns-testing` Docker instance by running
   ```bash
   docker exec -it $SNS_TESTING_INSTANCE bash
   ```
   Note: The instruction for testing your own dapp's SNS decentralization assume that all commands are executed from _this_ bash session (inside Docker). You should still have access to your dapp's files, as the repo was mounted at `/dapp` inside the container.

   

   > You are now ready to [test your own dapp's SNS decentralization](#lifecycle).

6. Clean-up (after you are done testing):
    ```bash
    docker kill $SNS_TESTING_INSTANCE
    ```
    It should now be possible to repeat the scenario starting from step 1.

The above run-book could be easily automated and integrated into your CI/CD pipeline.

## SNS lifecycle

<a name="lifecycle"></a>

_This section assumes that you have successfully deployed a local environment for testing SNS decentralization and validated your setup by creating an SNS instance for the example dapp (shipped with `sns-testing`)._

We now explain how to test your own dapp's SNS decentralization.

Your SNS configuration file should only specify a single initial SNS developer neuron
controlled by your DFX principal for the following instructions to work without
any additional steps required (otherwise, you'd need to _manually vote_ on SNS proposals
created during these steps with your initial SNS developer neurons).

0. Deploy your dapp onto the local replica instance as per usual. You can find your dapp repo under the path `/dapp` in the Docker container. This step requires your dapp repo to have a deployment script that interacts with the replica via the 8080 port.

   If you don't yet have a solution to deploy your custom dapp, you can still proceed with these instructions by deploying the example dapp provided with this repo:

   ```bash
   ./deploy_test_canister.sh
   ```

   This will deploy a test canister (see Section
   [Test canister](https://github.com/dfinity/sns-testing#test-canister)
   for further details) which can be thought of as a placeholder
   for your dapp.
1. Run the script `deploy_sns.sh <config-path>` to deploy an SNS passing
   the path to the SNS configuration file as an argument.
   A sample configuration is available in the file `sns-test.yml`.
2. Run the script `register_dapp.sh <canister-id>` to register canister
   with a provided canister ID with the SNS deployed in the previous step.
   After this step, the SNS is able to manage the canister.

3. Upgrade your dapp by submitting an SNS proposal that can be voted on using the SNS developer neuron.

   This step requires your dapp repo to have an upgrade script that interacts with the replica via the 8080 port.

   If you don't yet have a solution to upgrade your custom dapp, you can still proceed with these instructions by upgrading the example dapp using the scripts provided with this repo:

   ```bash
   ./upgrade_test_canister.sh
   ```

   This will upgrade the test canister (see Section
   [Test canister](https://github.com/dfinity/sns-testing#test-canister)
   for further details) which can be thought of as a placeholder
   for your dapp.

4. Run the script `open_sns_swap.sh` to open the initial decentralization swap.
   You can adjust the swap parameters directly in the script.
5. Run the script `participate_sns_swap.sh <num-participants>
   <icp-per-participant>` to participate in the swap providing the number of
   participants and the number of ICP that each participant contributes as arguments.
   You can also participate in the swap using the [NNS frontend dapp](http://qsgjb-riaaa-aaaaa-aaaga-cai.localhost:8080/).
   You can use the "Get ICP" button in the [NNS frontend dapp](http://qsgjb-riaaa-aaaaa-aaaga-cai.localhost:8080/)
   or run the script `send_icp.sh <icp> <account>` to send
   a certain amount of ICP to your ledger account so you are able
   to participate in the swap. Make sure that the participation satisfies all the constraints
   imposed by the swap parameters from the previous step (e.g., the minimum number
   of swap participants and the total amount of ICP raised).
6. Once the swap is completed, run the script `finalize_sns_swap.sh` to
   distribute the SNS neurons to the swap participants.

7. Upgrade your dapp again by submitting an SNS proposal that can be voted on using the SNS developer neuron. This however might not be enough to execute the upgrade, so you also need to vote on this proposal using your participants' neurons (this will be covered in the next step).

    This step requires your dapp repo to have an upgrade script that interacts with the replica via the 8080 port.

    If you don't yet have a solution to upgrade your custom dapp, you can still proceed with these instructions by upgrading the example dapp using the scripts provided with this repo:

    ```bash
    ./upgrade_test_canister.sh
    ```

   This will upgrade the test canister (see Section
   [Test canister](https://github.com/dfinity/sns-testing#test-canister)
   for further details) which can be thought of as a placeholder
   for your dapp.

8. After the decentralization swap, your developer neuron might not have
   a majority of the voting power and thus the SNS proposal to upgrade your dapp canister must be voted
   on. To this end, open the [NNS frontend dapp](http://qsgjb-riaaa-aaaaa-aaaga-cai.localhost:8080/) and vote with the individual neurons or run the script:

   ```bash
   ./vote_on_sns_proposal.sh <num-participants> <id> <vote>
   ```

   to vote on
   SNS proposal with ID `<id>` with the SNS neurons of *all* the participants
   created by the script `participate_sns_swap.sh` above.
   Make sure to pass the same number of participants `<num-participants>` as in
   `participate_sns_swap.sh <num-participants> <icp-per-participant>` above,
   the proposal ID, and the vote (`y` for yes and `n` for no). It is expected to get the error
   "Neuron not eligible to vote on proposal." for some neurons because
   each participant gets a basket of neurons with various dissolve delays
   and only neurons with dissolve delay at least
   `neuron_minimum_dissolve_delay_to_vote_seconds` (according to the SNS configuration
   file from step 1.) are eligible to vote. It is also expected to get the error
   "Neuron already voted on proposal." for some neurons because
   they are followers of other neurons and our simple voting script
   does not take this into account.

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

## Asset canister

This section is relevant if your project contains an asset canister
and describes how you can test handing over control of an asset canister
to an SNS.

Note that you can interleave the steps for the asset canister from this section
and the steps for the test canister (and also your own canister)
from the previous section within the
[SNS lifecycle](https://github.com/dfinity/sns-testing#sns-lifecycle).
We list additional constraints in between the steps below.

1. You can deploy an asset canister by running the script `./deploy_assets.sh`.

You should run the following steps after `deploy_sns.sh <config-path>`
and before `open_sns_swap.sh` according to
the [SNS lifecycle](https://github.com/dfinity/sns-testing#sns-lifecycle) section.

2. To prepare the asset canister for handing it over to the SNS, run the script
   `./prepare_assets.sh`. This grants the SNS governance canister the permission
   to manage access to the asset canister.
3. You can then register the asset canister with the SNS by running the script
   `./register_dapp.sh <canister-id>`, where `<canister-id>` is the canister ID
   of the asset canister.
4. To test managing permissions in the asset canister via SNS proposals, you need to register
   the asset canister's functions to manage permissions with the SNS as generic functions. This is
   accomplished by running the script `./register_permission_assets.sh`.
5. Now you can add or revoke a permission to the asset canister via
   SNS proposals. To this end, run the script
   `./add_permission_assets.sh <dfx-identity> <permission>` or
   `./revoke_permission_assets.sh <dfx-identity> <permission>`, respectively,
   where `<dfx-identity>` is the name of an identity to manage permissions for
   and `<permission>` is one of `Commit`, `Prepare`, and `ManagePermissions`.
   You can check the actual permissions by running

```bash
dfx canister --network ${NETWORK} call assets list_permitted '(record {permission = variant {<permission>}})'
```

  or by running the script `./get_permission_assets.sh`.

6. Make sure that you can still commit assets by running the script
   `./commit_assets.sh <path> <content>`, where `<path>` is the HTTP path
   of the asset, e.g., `/myasset.txt` and `<content>` is the ASCII-encoded
   content of the asset.

Testing all possible SNS launch scenarios includes testing a failed swap (e.g., if not enough funds have been raised)
where the control of the asset canister is given back to your principal.

You should run the following step after `finalize_sns_swap.sh` for an unsuccessful swap.

7. After a failed swap, you can run the script `take_ownership_assets.sh`
   to reset the permissions of the asset canister back to only your principal
   having the `Commit` permission (in particular, with the SNS governance
   having no permission anymore).

## Check out canister status

You can inspect the status of a canister `<name>` (with a corresponding entry
in the `dfx.json` file) by running the script `./get_canister_status.sh <name>`.
Note that your DFX identity must be a controller of the canister `<name>`
for that script to succeed. In particular, you can also invoke the script
to check if your DFX identity is a controller of the canister `<name>`.

## Hacking

You can find further instructions for expert users in the file
[HACKING.md](https://github.com/dfinity/sns-testing/blob/main/HACKING.md).
