In the future, the contents of the "SNS lifecycle" section in ./README.md would
be replaced with the content in this file (minus this preface, ofc).

**TODO**: Once README is migrated to 1-proposal, we'll also need to update the
Apple silicon section to mention that yq is needed.

_This section assumes that you have successfully completed the instructions in
the [Bootstrapping a testing environment via Docker] section above._

This section explains how to perform SNS decentralization in the aforementioned
testing environment (i.e. Docker container running a local canister execution
environment where an NNS has been deployed).

The commands mentioned here are to be run from within the Docker container.

'run_basic_scenario.sh` also performs these steps. Therefore, reading that
script may help you understand the steps described in this section. Similarly,
reading the scripts mentioned here will help you understand the procedure in
greater detail.

0. Restore files to a clean state like so:

   ```bash
   ./cleanup.sh
   ```

1. Deploy your dapp to the testing environment the way you would normally deploy
   to a local canister execution environment. Note that the local canister
   execution environment is using port 8080.

   You can find your dapp repo under the path `/dapp` in the Docker
   container.

   Alternatively, you can deploy the [example dapp] like so:

   ```bash
   ./deploy_test_canister.sh
   ```

   [example dapp]: /#test-canister

2. Craft your own SNS configuration file. We recommend that you use
   [example_sns_init.yaml] as a guide.

   [example_sns_init.yaml]: /example_sns_init.yaml

   If you are using the example dapp, this will be done automatically by the
   next step.

3. Give control of your dapp canisters to NNS:

   ```bash
   ./let_nns_control_dapp.sh
   ```

4. Create an NNS proposal to create an SNS that will control your dapp
   canister(s):

   ```bash
   ./propose_sns.sh
   ````

   The proposal will pass right away, because it is made by a neuron that has an
   overwhelming amount of voting power (this is part of the testing environment).

   After a few minutes, you should see a new SNS instance in the [Launchpad]
   section of the NNS dapp.

   [Launchpad]: http://qsgjb-riaaa-aaaaa-aaaga-cai.localhost:8080/launchpad

5. Optional: Upgrade your dapp via SNS proposal.

   If you are going through these instructions using the example dapp rather
   than your own dapp, this step can be done as follows:

   ```bash
   ./upgrade_test_canister.sh "Swap is taking place."
   ```

6. **[TODO(NNS1-2392)][NNS1-2392]**: There is a 24-48 hour delay between
   proposal execution and the start of the token swap. Whereas, for testing, we
   want the swap to start right away.

   [NNS1-2392]: https://go/jira/NNS1-2392

   Once the swap starts, you can have many principals participate like so:

   ```bash
   ./participate_sns_swap.sh <num-participants> <icp-per-participant>
   ```

   You can run `./participate_sns_swap.sh` multiple times (with different
   arguments).

   You can also participate in the swap using the [NNS Dapp][nns-dapp]
   (another feature of the test environment). There, you can conjoure some ICP
   for yourself using the "Get ICP" button (another feature of the test
   environment), and use the ICP to participate in the ongoing swap.

   [nns-dapp]: http://qsgjb-riaaa-aaaaa-aaaga-cai.localhost:8080

   You can make the swap complete immediately by making the total participation
   amount equal to the target ICP amount.

7. Optional: Submit (another) proposal to upgrade one of your dapp
   canisters. Unlike before, the proposal will probably not pass right away,
   because now, the voting power is spread among many neurons.

   This step requires your dapp repo to have an upgrade procedure that interacts
   with the local canister execution environment via the 8080 port.

   If using the example dapp, this step can be performed like so:

   ```bash
   ./upgrade_test_canister.sh "First upgrade after the initial token swap."
   ```

   This is similar to step 5, but we use a different message argument so that
   there will be a visible change to the dapp.

8. To make the upgrade proposal pass, tell the participants used by
   `participate_sns_swap.sh` to vote on the proposal, like so:

   ```bash
   ./vote_on_sns_proposal.sh <num-participants> <proposal-id> y
   ```

   If you would rather have the proposal rejected, you can replace `y` in the
   above command with `n`.

   The script will probably emit some messages that might seem worrying; however
   following are most likely benign:

   1. ```
      Neuron not eligible to vote on proposal.
      ```

      Most likely, this is happening because some of the neurons that the swap
      generates have dissolve delays that are too small for them to vote.
      Whereas, the script tries to vote with all neurons, and does not consider
      whether a neuron would be able to vote.

   2. ```
      Neuron already voted on proposal.
      ```

      Most likely, this happens because some neurons already voted automatically
      via following. Whereas, this script is not aware of this.
