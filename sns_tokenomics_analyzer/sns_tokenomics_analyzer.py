#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: bjoernassmann
"""

import pandas as pd
import yaml
import dash
from dash import dcc
from dash import html
from dash.dependencies import Input, Output
import plotly.graph_objs as go
import numpy as np

###############################################################################
# Define name of input file
input_file  = "sns_init.yaml"


###############################################################################
# Helper functions for parsing and computing stats

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

def parse_gov_params(data):
    gov_params = {}

    # Convert time-related fields to years
    gov_params['min_dissolve_delay'] = convert_to_years(data['Voting']['minimum_dissolve_delay'])
    gov_params['max_dissolve_delay'] = convert_to_years(data['Voting']['MaximumVotingPowerBonuses']['DissolveDelay']['duration'])
    gov_params['max_age'] = convert_to_years(data['Voting']['MaximumVotingPowerBonuses']['Age']['duration'])
    gov_params['reward_rate_transition_duration'] = convert_to_years(data['Voting']['RewardRate']['transition_duration'])

    # Convert percentage values to absolute values
    gov_params['dissolve_delay_bonus'] = convert_to_absolute(data['Voting']['MaximumVotingPowerBonuses']['DissolveDelay']['bonus'])
    gov_params['age_bonus'] = convert_to_absolute(data['Voting']['MaximumVotingPowerBonuses']['Age']['bonus'])
    gov_params['reward_rate_initial'] = convert_to_absolute(data['Voting']['RewardRate']['initial'])
    gov_params['reward_rate_final'] = convert_to_absolute(data['Voting']['RewardRate']['final'])

    return gov_params
 
###############################################################################
# Reading the YAML file and parse goverannce paramters
with open(input_file, "r") as file:
    data = yaml.safe_load(file)

gov_params = parse_gov_params(data)
print("gov_params:", gov_params)


###############################################################################
# Parse swap data and compute swap stats
no_scenarios = 11 
scenario_indices = list(range(no_scenarios))

swap_data = data['Swap']
dist_data = data['Distribution']['InitialBalances']

min_icp, max_icp = map(convert_tokens, [swap_data['minimum_icp'], swap_data['maximum_icp']])
swap_distribution = convert_tokens(dist_data['swap'])

collected_icp_scenarios = np.linspace(min_icp, max_icp, no_scenarios).tolist()

token_price_scenarios = [icp / swap_distribution for icp in collected_icp_scenarios]


fund_participation_icp = convert_tokens(swap_data['neurons_fund_investment_icp'])
direct_participation_icp_scenarios = [collected_icp_scenarios[index] - fund_participation_icp for index in scenario_indices]

fund_participation_scenarios = [fund_participation_icp / price for price in token_price_scenarios]
direct_participation_scenarios = [swap_distribution - fund for fund in fund_participation_scenarios]

vest_data = swap_data['VestingSchedule']
neuron_basket_count = vest_data['events']
neuron_basket_interval = convert_to_years(vest_data['interval'])

rel_vp = calculate_relative_swap_voting_power(neuron_basket_count, neuron_basket_interval, gov_params)

vp_fund_scenarios = [rel_vp * value for value in fund_participation_scenarios]
vp_direct_scenarios = [rel_vp * value for value in direct_participation_scenarios]

swap_avg_dissolve_delay = calculate_swap_average_dissolve_delay(neuron_basket_count, neuron_basket_interval)


###############################################################################
# Parse dev neurons  
dev_neurons_list = []

# Iterate over each neuron in the YAML data
for neuron in data['Distribution']['Neurons']:
    neuron_dict = {}
    neuron_dict['controller'] = neuron['principal']
    neuron_dict['stake'] = convert_tokens(neuron['stake'])
    neuron_dict['dissolve_delay'] = convert_to_years(neuron['dissolve_delay'])
    neuron_dict['vesting_period'] = convert_to_years(neuron['vesting_period'])
    neuron_dict['memo'] = neuron['memo']
    neuron_dict['voting_power'] = voting_power( neuron_dict['dissolve_delay'], neuron_dict['stake'], gov_params)
    dev_neurons_list.append(neuron_dict)

dev_neurons_df = pd.DataFrame(dev_neurons_list)
print(dev_neurons_df)

# Calculate the sum of the stakes and the stake-weighted average dissolve delay
total_dev_neurons_stake = dev_neurons_df['stake'].sum()
avg_dissolve_delay_dev_neurons = (dev_neurons_df['stake'] * dev_neurons_df['dissolve_delay']).sum() / total_dev_neurons_stake


###############################################################################
# Generate data frame for aggreated data

def create_token_distribution_df_new(scenario_index):
    return pd.DataFrame([
        {
            'type': 'Treasury',
            'tokens': convert_tokens(data['Distribution']['InitialBalances']['governance']),
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
            'tokens': direct_participation_scenarios[scenario_index],
            'average_dissolve_delay': swap_avg_dissolve_delay,
            'voting_power': vp_direct_scenarios[scenario_index]
        },
        {
            'type': 'Swap: Fund',
            'tokens': fund_participation_scenarios[scenario_index],
            'average_dissolve_delay': swap_avg_dissolve_delay,
            'voting_power': vp_fund_scenarios[scenario_index]
        }
    ])

token_distribution_scenarios = [create_token_distribution_df_new(index) for index in scenario_indices]

# Data frames for ICP participation 
def create_icp_participaiton_df(scenario_index):
    return pd.DataFrame({
        'Category': ['Swap: Fund', 'Swap: Direct', 'Swap: Remaining Capacity'],
        'Value': [
            fund_participation_icp,
            direct_participation_icp_scenarios[scenario_index],
            max_icp - collected_icp_scenarios[scenario_index]
        ]})

icp_participation_scenarios = [create_icp_participaiton_df(index) for index in scenario_indices]

###############################################################################
# Create a Dash app
app = dash.Dash(__name__)

# Your data preparation code here

# Color mapping
color_map = {
    'Treasury': 'blue',
    'Developer Neurons': 'purple',
    'Swap: Fund': 'green',
    'Swap: Direct': 'lightgreen',
    'Swap: Remaining Capacity': 'grey'
}

# App layout
app = dash.Dash(__name__)

app.layout = html.Div([
    # Title 
    html.Div('SNS Tokenomics Analyzer', style={'textAlign': 'center', 'color': 'white', 'fontSize': 36, 'padding': '20px', 'font-family': 'Arial'}),

    # Slider
    html.Div([
        html.Label('Select commitment by direct participants',
                   style={'color': 'white', 'font-family': 'Arial', 'display': 'block', 'textAlign': 'center'}),
        html.Div([
            dcc.Slider(
                id='slider-scenario',
                min=0,  # Min index
                max=no_scenarios-1,  # Max index
                value=0,  # Default index
                marks={i: f"{round(direct_participation_icp_scenarios[i]/1000)}K" for i in range(no_scenarios)},
                step=1  # Increment by 1
            )
        ], style={'margin': 'auto', 'width': '40%'})  
    ], style={
        'textAlign': 'center',  
        'marginTop': '50px',
        'backgroundColor': 'black'  
    }),
          
    # ICP pie chart and token price chart
    html.Div([
    html.Div([
        dcc.Graph(id='pie-icp-participation'),
    ], style={'flex': '1'}),
    html.Div([
        dcc.Graph(id='linear-function-graph'),
    ], style={'flex': '1' }),
    ], style={'display': 'flex'}),
               
    # SNS token pie charts
    html.Div([
        dcc.Graph(id='pie-tokens', style={'display': 'inline-block'}),
        dcc.Graph(id='pie-voting-power', style={'display': 'inline-block'})
    ], style={ #'marginTop': '350px',
              'width': '1500px',
    })  
], style={'backgroundColor': 'black', 'color': 'white'})

            
# Update charts based on slider selection
@app.callback(
    [Output('pie-tokens', 'figure'),
     Output('pie-voting-power', 'figure'),
     Output('pie-icp-participation', 'figure'),
     Output('linear-function-graph', 'figure'),
     ],  
    [Input('slider-scenario', 'value')]
)
def update_charts(selected_scenario):
    df = token_distribution_scenarios[selected_scenario]  
    df_icp = icp_participation_scenarios[selected_scenario]  
    df = df.sort_values('type')

    # Pie chart for token distribution 
    fig_tokens = go.Figure(data=[go.Pie(
        labels=df['type'],
        values=df['tokens'],
        hole=0.4,
        marker=dict(colors=[color_map[t] for t in df['type']]),
        sort=False
    )])
    fig_tokens.update_layout(title='Token Distribution', paper_bgcolor='black', font=dict(color='white'))

    # Pie chart for voting power
    fig_voting_power = go.Figure(data=[go.Pie(
        labels=df['type'],
        values=df['voting_power'],
        hole=0.4,
        marker=dict(colors=[color_map[t] for t in df['type']]),
        sort=False
    )])
    fig_voting_power.update_layout(title='Voting Power Distribution', paper_bgcolor='black', font=dict(color='white'))

    # Pie chart for ICP Participation
    fig_icp = go.Figure(data=[go.Pie(
        labels=df_icp['Category'], 
        values=df_icp['Value'],   
        hole=0.4,
        textinfo='value', 
        marker=dict(colors=[color_map[t] for t in df_icp['Category']]),
        sort=False
    )])
    fig_icp.update_layout(title='ICP Swap Commitment', paper_bgcolor='black', font=dict(color='white'))
    
    # Create the Linear Function Graph for the token price
    linear_function_fig = go.Figure(data=[
        go.Scatter(
            x=collected_icp_scenarios,
            y=token_price_scenarios,
            mode='lines',  
            line=dict(color='blue'),  
            name='Token Price Curve'
        ),
        go.Scatter(
            x=[collected_icp_scenarios[selected_scenario]],
            y=[token_price_scenarios[selected_scenario]],
            mode='markers',
            marker=dict(color='red', size=10),
            name='Selected Scenario'
        )
    ])
    
    # Update background and font color for linear_function_fig
    y_min = min(token_price_scenarios) * 0.95  
    y_max = max(token_price_scenarios) * 1.05  
    x_min = min(collected_icp_scenarios) * 0.95
    x_max = max(collected_icp_scenarios) * 1.05

    linear_function_fig.update_layout(
        plot_bgcolor='black',
        paper_bgcolor='black',
        font=dict(color='white'),
        title='Token Price vs ICP Swap Commitment',
        showlegend=False,  
        xaxis=dict(
            title='ICP Swap Commitment',
            showgrid=False,  
            zeroline=True,  
            zerolinewidth=2,  
            zerolinecolor='white',  
            tickcolor='white', 
            range=[x_min, x_max]
        ),
        yaxis=dict(
            title='Token Price in ICP',
            showgrid=False, 
            zeroline=True,  
            zerolinewidth=2,  
            zerolinecolor='white',  
            tickcolor='white',  
            range=[y_min, y_max]  
        )
    )
    return fig_tokens, fig_voting_power, fig_icp, linear_function_fig  


# Run the app
if __name__ == '__main__':
    app.run_server(debug=True, port=8051)

