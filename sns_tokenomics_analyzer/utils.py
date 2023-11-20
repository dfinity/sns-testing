#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 20 11:41:20 2023

@author: bjoernassmann
"""


import pandas as pd

# Function to convert time span to years
def convert_to_years(time_str):
    value, unit = time_str.split(" ")
    value = float(value)
    unit = unit.lower().rstrip('s')  # Remove trailing 's' and convert to lowercase
    conversion_factors = {
        'second': 1/(365.25 * 24 * 3600),
        'minute': 1/(365.25 * 24 * 60),
        'hour': 1/(365.25 * 24),
        'day': 1/365.25,
        'month': 1/12,
        'year': 1
    }
    return value * conversion_factors.get(unit, 0)

# Function to convert percentage to absolute value
def convert_to_absolute(value_str):
    value = float(value_str.strip('%'))
    return value / 100

# Function to convert token number from string to numeric value
def convert_tokens(stake_str):
    return int(stake_str.replace('_', '').split(' ')[0])

def voting_power(dissolve_delay, stake, gov_params):    
    if dissolve_delay < gov_params['min_dissolve_delay']:
        return 0
    
    # Calculate the dissolve delay bonus
    max_delay = gov_params['max_dissolve_delay']
    max_bonus = gov_params['dissolve_delay_bonus']
    dissolve_delay_capped = min( max_delay,dissolve_delay )
    
    dissolve_delay_bonus = 1 + (max_bonus * dissolve_delay_capped/max_delay)
    
    # Voting power is stake multiplied by the dissolve delay bonus
    return stake * dissolve_delay_bonus

def calculate_relative_swap_voting_power(neuron_basket_count, neuron_basket_interval, gov_params):
    vp = 0
    stake = 1/neuron_basket_count    
    for i in range(neuron_basket_count):
        dissolve_delay = i * neuron_basket_interval
        vp += voting_power(dissolve_delay, stake, gov_params)  
    return vp

def calculate_swap_average_dissolve_delay(neuron_basket_count, neuron_basket_interval):
    dd = []
    for i in range(neuron_basket_count):
        dd.append(i * neuron_basket_interval)
    average_dissolve_delay = sum(dd) / len(dd) if dd else 0  
    return average_dissolve_delay

def parse_gov_params(sns_init_data):
    gov_params = {}

    # Convert time-related fields to years
    gov_params['min_dissolve_delay'] = convert_to_years(sns_init_data['Voting']['minimum_dissolve_delay'])
    gov_params['max_dissolve_delay'] = convert_to_years(sns_init_data['Voting']['MaximumVotingPowerBonuses']['DissolveDelay']['duration'])
    gov_params['max_age'] = convert_to_years(sns_init_data['Voting']['MaximumVotingPowerBonuses']['Age']['duration'])
    gov_params['reward_rate_transition_duration'] = convert_to_years(sns_init_data['Voting']['RewardRate']['transition_duration'])

    # Convert percentage values to absolute values
    gov_params['dissolve_delay_bonus'] = convert_to_absolute(sns_init_data['Voting']['MaximumVotingPowerBonuses']['DissolveDelay']['bonus'])
    gov_params['age_bonus'] = convert_to_absolute(sns_init_data['Voting']['MaximumVotingPowerBonuses']['Age']['bonus'])
    gov_params['reward_rate_initial'] = convert_to_absolute(sns_init_data['Voting']['RewardRate']['initial'])
    gov_params['reward_rate_final'] = convert_to_absolute(sns_init_data['Voting']['RewardRate']['final'])

    return gov_params


def parse_dev_neurons(sns_init_data, gov_params):

    dev_neurons_list = []

    # Iterate over each neuron in the YAML data
    for neuron in sns_init_data['Distribution']['Neurons']:
        neuron_dict = {
            'controller': neuron['principal'],
            'stake': convert_tokens(neuron['stake']),
            'dissolve_delay': convert_to_years(neuron['dissolve_delay']),
            'vesting_period': convert_to_years(neuron['vesting_period']),
            'memo': neuron['memo'],
        }
        neuron_dict['voting_power'] = voting_power(neuron_dict['dissolve_delay'], neuron_dict['stake'], gov_params)
        dev_neurons_list.append(neuron_dict)

    return pd.DataFrame(dev_neurons_list)


def create_token_distribution_df(sns_init_data, 
                                 dev_neurons_df,
                                 scenarios,
                                 particpation_scenario_index,
                                 maturity_scenario_index):
    
    
    # Calculate the sum of the stakes and the stake-weighted average dissolve delay
    total_dev_neurons_stake = dev_neurons_df['stake'].sum()
    avg_dissolve_delay_dev_neurons = (dev_neurons_df['stake'] * dev_neurons_df['dissolve_delay']).sum() / total_dev_neurons_stake
    return pd.DataFrame([
        {
            'type': 'Treasury',
            'tokens': convert_tokens(sns_init_data['Distribution']['InitialBalances']['governance']),
            'average_dissolve_delay': 0,
            'voting_power': 0
        },
        {
            'type': 'Developer Neurons',
            'tokens': total_dev_neurons_stake,
            'average_dissolve_delay': avg_dissolve_delay_dev_neurons,
            'voting_power': dev_neurons_df['voting_power'].sum()
        },
        {
            'type': 'Swap: Direct',
            'tokens': scenarios['direct_participation_scenarios_matrix'][maturity_scenario_index][particpation_scenario_index],
            'average_dissolve_delay': scenarios['swap_avg_dissolve_delay'],
            'voting_power': scenarios['vp_direct_scenarios_matrix'][maturity_scenario_index][particpation_scenario_index]
        },
        {
            'type': 'Swap: Fund',
            'tokens': scenarios['fund_participation_scenarios_matrix'][maturity_scenario_index][particpation_scenario_index],
            'average_dissolve_delay': scenarios['swap_avg_dissolve_delay'],
            'voting_power': scenarios['vp_fund_scenarios_matrix'][maturity_scenario_index][particpation_scenario_index]
        }
    ])

def create_icp_participation_df(scenarios,
                                scenario_index, 
                                maturity_scenario_index):
    return pd.DataFrame({
        'Category': ['Swap: Fund', 'Swap: Direct', 'Swap: Remaining Capacity'],
        'Value': [
            scenarios['fund_participation_scenarios_icp_matrix'][maturity_scenario_index][scenario_index],
            scenarios['direct_participation_scenarios_icp'][scenario_index],
            scenarios['overall_participation_icp_max'][maturity_scenario_index] - scenarios['overall_participation_scenarios_icp_matrix'][maturity_scenario_index][scenario_index]
        ]})