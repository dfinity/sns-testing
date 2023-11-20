#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 20 12:25:05 2023

@author: bjoernassmann
"""


import yaml
import numpy as np
from NF_matching_function import matching_function
from config import input_file, no_participation_scenarios, no_total_maturity_scenarios, nf_total_maturity_min, nf_total_maturity_max
from utils import parse_gov_params, parse_dev_neurons, convert_tokens, convert_to_years, calculate_relative_swap_voting_power, calculate_swap_average_dissolve_delay, create_token_distribution_df, create_icp_participation_df


def get_scenarios():
    # Reading the YAML file and parse goverannce paramters
    with open(input_file, "r") as file:
        sns_init_data = yaml.safe_load(file)

    gov_params = parse_gov_params(sns_init_data)
    scenario_indices = list(range(no_participation_scenarios))

    nf_total_maturity_values = np.linspace(nf_total_maturity_min, nf_total_maturity_max, no_total_maturity_scenarios).tolist()

    swap_data = sns_init_data['Swap']
    dist_data = sns_init_data['Distribution']['InitialBalances']

    min_direct_icp, max_direct_icp = map(convert_tokens, [swap_data['minimum_direct_participation_icp'], swap_data['maximum_direct_participation_icp']])
    swap_distribution = convert_tokens(dist_data['swap'])

    direct_participation_scenarios_icp = np.linspace(min_direct_icp, max_direct_icp, no_participation_scenarios).tolist()

    vest_data = swap_data['VestingSchedule']
    neuron_basket_count = vest_data['events']
    neuron_basket_interval = convert_to_years(vest_data['interval'])
    nf_enabled = swap_data['neurons_fund_participation']
    rel_vp = calculate_relative_swap_voting_power(neuron_basket_count, neuron_basket_interval, gov_params)
    swap_avg_dissolve_delay = calculate_swap_average_dissolve_delay(neuron_basket_count, neuron_basket_interval)

    # Generate matrices for different scenarios
    fund_participation_scenarios_icp_matrix = []
    overall_participation_scenarios_icp_matrix = []
    token_price_scenarios_matrix = []
    fund_participation_scenarios_matrix = []
    direct_participation_scenarios_matrix = []
    vp_fund_scenarios_matrix = []
    vp_direct_scenarios_matrix = []

    overall_participation_icp_max = []


    for nf_total_maturity in nf_total_maturity_values:
        if nf_enabled:
            f = lambda x: matching_function(x, nf_total_maturity)
            fund_participation_scenarios = [round(f(x), 0) for x in direct_participation_scenarios_icp]
        else:
            fund_participation_scenarios = [0] * no_participation_scenarios

        overall_participation_scenarios_icp = [d + f for d, f in zip(direct_participation_scenarios_icp, fund_participation_scenarios)]
        token_price_scenarios = [icp / swap_distribution for icp in overall_participation_scenarios_icp]
        
        fund_participation_scenarios_per_price = [participation/price for participation, price in zip(fund_participation_scenarios, token_price_scenarios)]
        direct_participation_scenarios_per_price = [participation/price for participation, price in zip(direct_participation_scenarios_icp, token_price_scenarios)]

        vp_fund_scenarios = [rel_vp * value for value in fund_participation_scenarios_per_price]
        vp_direct_scenarios = [rel_vp * value for value in direct_participation_scenarios_per_price]

        # Append the scenarios to the matrices
        fund_participation_scenarios_icp_matrix.append(fund_participation_scenarios)
        overall_participation_scenarios_icp_matrix.append(overall_participation_scenarios_icp)
        token_price_scenarios_matrix.append(token_price_scenarios)
        fund_participation_scenarios_matrix.append(fund_participation_scenarios_per_price)
        direct_participation_scenarios_matrix.append(direct_participation_scenarios_per_price)
        vp_fund_scenarios_matrix.append(vp_fund_scenarios)
        vp_direct_scenarios_matrix.append(vp_direct_scenarios)
        overall_participation_icp_max.append( max(overall_participation_scenarios_icp))

    
    scenarios  = {
        'fund_participation_scenarios_icp_matrix': fund_participation_scenarios_icp_matrix,
        'overall_participation_scenarios_icp_matrix': overall_participation_scenarios_icp_matrix,
        'token_price_scenarios_matrix': token_price_scenarios_matrix,
        'fund_participation_scenarios_matrix': fund_participation_scenarios_matrix,
        'direct_participation_scenarios_matrix': direct_participation_scenarios_matrix,
        'vp_fund_scenarios_matrix': vp_fund_scenarios_matrix,
        'vp_direct_scenarios_matrix': vp_direct_scenarios_matrix,
        'nf_total_maturity_values':nf_total_maturity_values,
        'direct_participation_scenarios_icp': direct_participation_scenarios_icp,
        'overall_participation_icp_max': overall_participation_icp_max,
        'swap_avg_dissolve_delay': swap_avg_dissolve_delay
        }
    
           
    dev_neurons_df = parse_dev_neurons(sns_init_data, gov_params)                           
    token_distribution_scenarios = [[create_token_distribution_df(sns_init_data, dev_neurons_df, scenarios, scenario_idx, maturity_idx) 
                                     for scenario_idx in scenario_indices] 
                                    for maturity_idx in range(no_total_maturity_scenarios)]
    
    icp_participation_scenarios = [[create_icp_participation_df(scenarios, scenario_idx, maturity_idx) 
                                    for scenario_idx in scenario_indices] 
                                   for maturity_idx in range(no_total_maturity_scenarios)]
    scenarios['token_distribution_scenarios'] = token_distribution_scenarios
    scenarios['icp_participation_scenarios'] = icp_participation_scenarios
        

    return scenarios


    