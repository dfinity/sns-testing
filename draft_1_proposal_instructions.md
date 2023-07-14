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

`run_basic_scenario.sh` also performs these steps. Therefore, reading that
script may help you understand the steps described in this section. Similarly,
reading the scripts mentioned here will help you understand the procedure in
greater detail.

0. Restore files to a clean state like so:

   ```bash
   ./cleanup.sh
   ```

1. Deploy a dapp to the testing environment. You can use your own dapp (found in
   `/dapp`), or the [example dapp].

   [example dapp]: /#test-canister

   If this is your first time performing this exercise, it will be easier to use
   the example dapp. Once you have completed this exercise using the example
   dapp, you can try this exercise again using your own dapp.

   The example dapp can be deployed very easily like so:

   ```bash
   ./deploy_test_canister.sh
   ```

   Once you are ready to deploy your own dapp, do so as you normally would to a
   local canister execution environment using port 8080.

2. Craft an SNS configuration file. We recommend that you use
   [example_sns_init.yaml] as a guide.

   [example_sns_init.yaml]: /example_sns_init.yaml

   If you are using the example dapp, this will be done automatically by the
   next step.

3. Give control of your dapp canisters to NNS:

   ```bash
   ./let_nns_control_dapp.sh
   ```

   As mentioned in the previous step, this automatically creates an SNS
   configuration file named `sns_init.yaml`, unless such a file already exists
   (e.g. you hand-crafted one yourself). The auto-generated file assumes that
   you are using the example dapp.

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

5. Optional: Upgrade youf dapp canister(s) via SNS proposal.

   If you are going through these instructions using the example dapp, this step
   can be done as follows:

   ```bash
   ./upgrade_test_canister.sh "Swap is taking place."
   ```

   This submits an SNS proposal to upgrade the test dapp. If you are using the
   auto-generated `sns_init.yaml` file, the proposing neuron will have all of
   the voting power in the SNS. Thus, the proposal will be adopted and executed
   right away. Otherwise, you will have to vote with additional initial neurons
   to pass the upgrade proposal.

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

You have now seen SNS in action in a test environment. We recommend that you
experiment with different configurations until you find one that like.

Once you arrive at a configuration that pleases you, you can use it to [create
an SNS on the Internet Computer][real-sns]. By performing this exercise, you
have armed yourself with the appropriate knowledge and experience to be
successful in your SNS journey.

[real-sns]: https://internetcomputer.org/docs/current/developer-docs/integrations/sns/launching/launch-steps

Therefore, carry forth with confidence, and do great things. We will watch your
career with great interest.

❤️,<br>
All of us here at the DFINITY Foundation