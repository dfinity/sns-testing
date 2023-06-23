# Testing SNS in local test environment (for expert users)

## Customizing test environment parameters

You can customize some parameters of the test environment in the file `settings.sh`.
Its default contents are:

```bash
#!/usr/bin/env bash

# put your dfx identity here
export DX_IDENT="default"

# if you don't export CANISTER_TEST or set its value to "_test",
# then the test flag is set for NNS and SNS governance canisters;
# if you export CANISTER_TEST to be the empty string "",
# then the test flag is not set.
# export CANISTER_TEST=""

# you can find available II releases here:
# https://github.com/dfinity/internet-identity/tags
export II_RELEASE="release-2023-04-28"

# you can find NNS proposals upgrading system canisters here:
# https://dashboard.internetcomputer.org/governance?topic=TOPIC_NETWORK_CANISTER_MANAGEMENT
# NNS proposals to upgrade NNS frontend dapp are called "Upgrade Nns Canister: qoctq-giaaa-aaaaa-aaaea-cai"
export NNS_DAPP_RELEASE="proposal-120468"

# only edit IC_COMMIT to a commit to master with disk image obtained via:
# $ ./gitlab-ci/src/artifacts/newest_sha_with_disk_image.sh origin/master
# from the IC monorepo: https://github.com/dfinity/ic
# if you change IC_COMMIT, then you need to rerun `source install.sh`
export IC_COMMIT="cac353c15ad1e8713607ebc3c56f9e2afd94650a"

export TESTNET="local"
```

To build II from sources, run `git clone https://github.com/dfinity/internet-identity.git`,
change the working directory to `internet-identity`, and run

```bash
II_FETCH_ROOT_KEY=1 II_DUMMY_CAPTCHA=1 II_DUMMY_AUTH=1 ./scripts/docker-build
```

If you built II from sources, comment the line starting with
`export II_RELEASE` in the file `settings.sh`.

To build the NNS frontend dapp and SNS aggregator canister from sources, run `git clone https://github.com/dfinity/nns-dapp.git`,
change the working directory to `nns-dapp`, and run

```bash
docker build --target scratch -t "nns-dapp" -o "out" .
```

If you built the NNS frontend dapp and SNS aggregator canister from sources, comment the line starting with
`export NNS_DAPP_RELEASE` in the file `settings.sh`.

## Setting up developer's wallet

Run the script `source setup_wallet.sh`. This will set up a developer wallet
and export its canister ID in the environment variable `WALLET`.

## Initial NNS neurons

You can specify initial NNS neurons in the file `initial_neurons.csv`.
Make sure that the last neuron with ID 449479075714955186
and owner `b2ucp-4x6ou-zvxwi-niymn-pvllt-rdxqr-wi4zj-jat5l-ijt2s-vv4f5-4ae`
is present and has a majority for the scripts to work.

If you want to include initial NNS neurons controlled by II principals
(so that they can be browsed in the nns-dapp), then you can specify
these NNS neurons as controlled by your DFX identity and follow the section
[Changing parameters of existing NNS neurons](https://github.com/dfinity/sns-testing/blob/main/HACKING.md#changing-parameters-of-existing-nns-neurons)
to update the controllers of these NNS neurons to your II principals
(you can find them in the "My Canisters" tab of nns-dapp).

You can check the initial NNS neurons by running the script
`get_initial_nns_neurons.sh` that fetches information about
all initial NNS neurons provided in `initial_neurons.csv`
from the NNS governance canister.

## Changing parameters of existing NNS neurons

Note. This section only applies if you use NNS governance with the test flag
set, i.e., if you don't export `${CANISTER_TEST}` or set its value to `_test`.

To change some parameters of an existing NNS neuron:

1. If your DFX principal is not a controller of the NNS neuron,
   add your DFX principal as the neuron's hot key.

2. Run the script `./get_nns_neuron.sh` passing the neuron ID (formatted
   as a natural number):

```console
$ ./get_nns_neuron.sh 14411968203686748321
Using identity: "spm".
(
  variant {
    Ok = record {
      id = opt record { id = 14_411_968_203_686_748_321 : nat64 };
      staked_maturity_e8s_equivalent = null;
      controller = opt principal "2ipgy-voyab-bvl7y-dk2pw-f6wje-cgllj-2uxlv-qki3u-tk6sp-gbtnj-qae";
      recent_ballots = vec {};
      kyc_verified = true;
      not_for_profit = false;
      maturity_e8s_equivalent = 0 : nat64;
      cached_neuron_stake_e8s = 100_000_000_000 : nat64;
      created_timestamp_seconds = 1_680_290_895 : nat64;
      auto_stake_maturity = null;
      aging_since_timestamp_seconds = 1_680_290_907 : nat64;
      hot_keys = vec {
        principal "or7qj-w2f5d-iuyzb-aobay-qcymq-n7s4i-4vd72-2krii-k72c4-czdjp-uae";
      };
      account = blob "3\8fZ\9fn\af]\a9\17\be\ea\14yA\f3\b3\00\16\af[\ae\1cq\c0\a0\dd\1d?\d8\e7\a96";
      joined_community_fund_timestamp_seconds = null;
      dissolve_state = opt variant {
        DissolveDelaySeconds = 252_460_800 : nat64
      };
      followees = vec {};
      neuron_fees_e8s = 0 : nat64;
      transfer = null;
      known_neuron_data = null;
      spawn_at_timestamp_seconds = null;
    }
  },
)
```

3. Run the script `./update_nns_neuron.sh` to override some parameters
   of the NNS neuron. Provide the content of the `Ok` field
   from the response to `./get_nns_neuron.sh` with the desired
   modifications.

   For instance, to increase `maturity_e8s_equivalent`, run:

```console
$ ./update_nns_neuron.sh 'record {
      id = opt record { id = 14_411_968_203_686_748_321 : nat64 };
      staked_maturity_e8s_equivalent = null;
      controller = opt principal "2ipgy-voyab-bvl7y-dk2pw-f6wje-cgllj-2uxlv-qki3u-tk6sp-gbtnj-qae";
      recent_ballots = vec {};
      kyc_verified = true;
      not_for_profit = false;
      maturity_e8s_equivalent = 1_000_000_000 : nat64;
      cached_neuron_stake_e8s = 100_000_000_000 : nat64;
      created_timestamp_seconds = 1_680_290_895 : nat64;
      auto_stake_maturity = null;
      aging_since_timestamp_seconds = 1_680_290_907 : nat64;
      hot_keys = vec {
        principal "or7qj-w2f5d-iuyzb-aobay-qcymq-n7s4i-4vd72-2krii-k72c4-czdjp-uae";
      };
      account = blob "3\8fZ\9fn\af]\a9\17\be\ea\14yA\f3\b3\00\16\af[\ae\1cq\c0\a0\dd\1d?\d8\e7\a96";
      joined_community_fund_timestamp_seconds = null;
      dissolve_state = opt variant {
        DissolveDelaySeconds = 252_460_800 : nat64
      };
      followees = vec {};
      neuron_fees_e8s = 0 : nat64;
      transfer = null;
      known_neuron_data = null;
      spawn_at_timestamp_seconds = null;
    }'
Using identity: "spm".
(null)
```

   The response `(null)` means that the update was successful. Otherwise, the response
   contains a description of the error.

   Note that the controller must be a self-authenticating principal and
   hot keys and followees must not be changed via `update_neuron`!

## Changing parameters of existing SNS neurons

Note. This section only applies if you use SNS governance with the test flag
set, i.e., if you don't export `${CANISTER_TEST}` or set its value to `_test`.
To change some parameters of an existing SNS neuron:

1. Run the script `./get_sns_neuron.sh` passing the neuron ID (formatted
   as Candid blob):

```console
$ ./get_sns_neuron.sh 'YO\d5\d8\dc\e3\e7\93\c3\e4!\e1\b8}U$v\27\f8\a64s\04vq\f7\f5\cc\c4\8e\dac'
Using identity: "spm".
(
  record {
    result = opt variant {
      Neuron = record {
        id = opt record {
          id = blob "YO\d5\d8\dc\e3\e7\93\c3\e4!\e1\b8}U$v\27\f8\a64s\04vq\f7\f5\cc\c4\8e\dac";
        };
        staked_maturity_e8s_equivalent = null;
        permissions = vec {
          record {
            "principal" = opt principal "or7qj-w2f5d-iuyzb-aobay-qcymq-n7s4i-4vd72-2krii-k72c4-czdjp-uae";
            permission_type = vec { 0 : int32; 1 : int32; 2 : int32; 3 : int32; 4 : int32; 5 : int32; 6 : int32; 7 : int32; 8 : int32; 9 : int32; 10 : int32;};
          };
        };
        maturity_e8s_equivalent = 0 : nat64;
        cached_neuron_stake_e8s = 5_000_000_000 : nat64;
        created_timestamp_seconds = 1_677_872_158 : nat64;
        source_nns_neuron_id = null;
        auto_stake_maturity = null;
        aging_since_timestamp_seconds = 1_677_872_158 : nat64;
        dissolve_state = opt variant {
          DissolveDelaySeconds = 15_780_000 : nat64
        };
        voting_power_percentage_multiplier = 100 : nat64;
        vesting_period_seconds = null;
        disburse_maturity_in_progress = vec {};
        followees = vec {};
        neuron_fees_e8s = 0 : nat64;
      }
    };
  },
)
```

   Make sure to use single quotes around the Candid blob to prevent bash
   from interpreting the escaped characters.

2. Run the script `./update_sns_neuron.sh` to override some parameters
   of the SNS neuron. Provide the content of the `Neuron` field
   from the response to `./get_sns_neuron.sh` with the desired
   modifications.

   For instance, to increase `staked_maturity_e8s_equivalent`, run:

```console
$ ./update_sns_neuron.sh 'record {
        id = opt record {
          id = blob "YO\d5\d8\dc\e3\e7\93\c3\e4!\e1\b8}U$v\27\f8\a64s\04vq\f7\f5\cc\c4\8e\dac";
        };
        staked_maturity_e8s_equivalent = opt (1_000_000_000 : nat64);
        permissions = vec {
          record {
            "principal" = opt principal "or7qj-w2f5d-iuyzb-aobay-qcymq-n7s4i-4vd72-2krii-k72c4-czdjp-uae";
            permission_type = vec { 0 : int32; 1 : int32; 2 : int32; 3 : int32; 4 : int32; 5 : int32; 6 : int32; 7 : int32; 8 : int32; 9 : int32; 10 : int32;};
          };
        };
        maturity_e8s_equivalent = 0 : nat64;
        cached_neuron_stake_e8s = 5_000_000_000 : nat64;
        created_timestamp_seconds = 1_677_872_158 : nat64;
        source_nns_neuron_id = null;
        auto_stake_maturity = null;
        aging_since_timestamp_seconds = 1_677_872_158 : nat64;
        dissolve_state = opt variant {
          DissolveDelaySeconds = 15_780_000 : nat64
        };
        voting_power_percentage_multiplier = 100 : nat64;
        vesting_period_seconds = null;
        disburse_maturity_in_progress = vec {};
        followees = vec {};
        neuron_fees_e8s = 0 : nat64;
      }'
Using identity: "spm".
(null)
```

   The response `(null)` means that the update was successful. Otherwise, the response
   contains a description of the error.

   Note that permissions and followees must not be changed via `update_neuron`!

## Inspecting SNS aggregator state

You can inspect the SNS aggregator canister's state by running the following script:

- `query_sns_aggregator.sh`: queries the SNS aggregator canister and
  displays the HTTP status code and whether the SNS governance canister ID
  is contained in the SNS aggregator canister's response (a signal whether
  the SNS aggregator canister has successfully recognized the SNS).
