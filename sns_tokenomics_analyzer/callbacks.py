#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 20 12:06:21 2023

@author: bjoernassmann
"""

from dash.dependencies import Input, Output
import plotly.graph_objs as go
import numpy as np
from NF_matching_function import matching_function


# Color mapping
color_map = {
   'Treasury': '#5DADE2',  # Light Blue
   'Developer Neurons': '#AF7AC5',  # Light Purple
   'Swap: Fund': '#2ECC71',  # Soft Green
   'Swap: Direct': '#ABEBC6',  # Pale Green
   'Swap: Remaining Capacity': '#BDC3C7'  # Light Grey
}

def register_callbacks(app, scenarios):
    token_distribution_scenarios = scenarios['token_distribution_scenarios']
    icp_participation_scenarios = scenarios['icp_participation_scenarios']
    overall_participation_scenarios_icp_matrix = scenarios['overall_participation_scenarios_icp_matrix']
    token_price_scenarios_matrix = scenarios['token_price_scenarios_matrix']
    direct_participation_scenarios_icp = scenarios['direct_participation_scenarios_icp']
    nf_total_maturity_values = scenarios['nf_total_maturity_values']
    
    # Update charts based on slider selection
    @app.callback(
        [Output('pie-tokens', 'figure'),
         Output('pie-voting-power', 'figure'),
         Output('pie-icp-participation', 'figure'),
         Output('linear-function-graph', 'figure'),
         Output('matching-function-graph', 'figure') 
         ],  
        [
          Input('slider-scenario-participation', 'value'),
          Input('slider-scenario-maturity', 'value')  
      ]
    )

    
    def update_charts(selected_participation_scenario, selected_maturity_scenario):

        
        df = token_distribution_scenarios[selected_maturity_scenario][selected_participation_scenario]
        df_icp = icp_participation_scenarios[selected_maturity_scenario][selected_participation_scenario]
        df = df.sort_values('type')
    
        # Pie chart for token distribution
        fig_tokens = go.Figure(data=[go.Pie(
            labels=df['type'],
            values=df['tokens'],
            hole=0.4,
            marker=dict(colors=[color_map[t] for t in df['type']]),
            sort=False
        )])
        fig_tokens.update_layout(
            title=dict(text='SNS Token Distribution', font=dict(size=16)),
            paper_bgcolor='#f8f9fa',
            font=dict(color='#333', family='Helvetica', size=12),
            #legend=dict(bgcolor='#f8f9fa', bordercolor='#333', borderwidth=1)
        )
    
        # Pie chart for voting power
        fig_voting_power = go.Figure(data=[go.Pie(
            labels=df['type'],
            values=df['voting_power'],
            hole=0.4,
            marker=dict(colors=[color_map[t] for t in df['type']]),
            sort=False
        )])
        fig_voting_power.update_layout(
            title=dict(text='SNS Voting Power Distribution', font=dict(size=16)),
            paper_bgcolor='#f8f9fa',
            font=dict(color='#333', family='Helvetica', size=12),
            #legend=dict(bgcolor='#f8f9fa', bordercolor='#333', borderwidth=1)
        )
    
        # Pie chart for ICP Participation
        fig_icp = go.Figure(data=[go.Pie(
            labels=df_icp['Category'],
            values=df_icp['Value'],
            hole=0.4,
            textinfo='value',
            marker=dict(colors=[color_map[t] for t in df_icp['Category']]),
            sort=False
        )])
        fig_icp.update_layout(
            title=dict(text='ICP Swap Commitment', font=dict(size=16)),
            paper_bgcolor='#f8f9fa',
            font=dict(color='#333', family='Helvetica', size=12),
            #legend=dict(bgcolor='#f8f9fa', bordercolor='#333', borderwidth=1)
        )
        
        # Create the Linear Function Graph for the token price
        linear_function_fig = go.Figure(data=[
            go.Scatter(
                x=[0] + overall_participation_scenarios_icp_matrix[selected_maturity_scenario],
                y=[0] + token_price_scenarios_matrix[selected_maturity_scenario],
                mode='lines',  
                line=dict(color='#3498DB'),  
                name='Token Price Curve'
            ),
            go.Scatter(
                x=[overall_participation_scenarios_icp_matrix[selected_maturity_scenario][selected_participation_scenario]],
                y=[token_price_scenarios_matrix[selected_maturity_scenario][selected_participation_scenario]],
                mode='markers',
                marker=dict(color='#F39C12', size=10),
                name='Selected Scenario'
            )
        ])
        
        x_min_linear = -min(overall_participation_scenarios_icp_matrix[selected_maturity_scenario])
        y_min_linear = -min(token_price_scenarios_matrix[selected_maturity_scenario]) 
        x_max_linear = max(overall_participation_scenarios_icp_matrix[selected_maturity_scenario]) * 1.05
        y_max_linear = max(token_price_scenarios_matrix[selected_maturity_scenario]) * 1.05
        
        linear_function_fig.update_layout(
            plot_bgcolor='#f8f9fa',  
            paper_bgcolor='#f8f9fa',  
            font=dict(color='#333', family='Helvetica', size=12),
            title=dict(text='SNS Token Price', font=dict(size=16)),
            showlegend=True,
            #legend=dict(bgcolor='#f8f9fa', bordercolor='#333', borderwidth=1),
            xaxis=dict(
                title=dict(text='ICP Swap Commitment (Direct & Fund)', font=dict(size=14)),
                gridcolor='#ddd',  # Light grid color
                gridwidth=1,
                zerolinecolor='#ccc',  
                range=[x_min_linear, x_max_linear]
            ),
            yaxis=dict(
                title=dict(text='Token Price in ICP', font=dict(size=14)),
                gridcolor='#ddd',
                gridwidth=1,
                zerolinecolor='#ccc',
                range=[y_min_linear, y_max_linear]
            )
        )
        
    
    
        # Create a more granular range for direct participation
        #min_direct_icp = min(direct_participation_scenarios_icp)
        min_direct_icp = 0
        max_direct_icp = max(direct_participation_scenarios_icp)
        granular_direct_participation = np.linspace(min_direct_icp, max_direct_icp, len(direct_participation_scenarios_icp) * 200)
        
        # Evaluate the matching function at each point in the granular range
        nf_total_maturity = nf_total_maturity_values[selected_maturity_scenario]
        granular_matching_function_data = [ matching_function(x, nf_total_maturity) for x in granular_direct_participation]
        
        # Create the Matching Function Graph with the granular data
        matching_function_fig = go.Figure(data=[
            go.Scatter(
                x=granular_direct_participation,
                y=granular_matching_function_data,
                mode='lines',
                line=dict(color='#2ECC71'),
                name='Matching Function'
            ),
            go.Scatter(
                x=[direct_participation_scenarios_icp[selected_participation_scenario]],
                y=[matching_function(direct_participation_scenarios_icp[selected_participation_scenario], nf_total_maturity)],
                mode='markers',
                marker=dict(color='#F39C12', size=10),
                name='Selected Scenario'
            )
        ])
        
        # Update layout for matching_function_fig
        x_max_matching = max_direct_icp * 1.05
        y_max_matching = max(granular_matching_function_data) * 1.05
        matching_function_fig.update_layout(
            plot_bgcolor='#f8f9fa',
            paper_bgcolor='#f8f9fa',
            font=dict(color='#333', family='Helvetica', size=12),
            title=dict(text='Matched Funding', font=dict(size=16)),
            showlegend=True,
            #legend=dict(bgcolor='#f8f9fa', bordercolor='#333', borderwidth=1),
            xaxis=dict(
                title=dict(text='Direct Participation in ICP', font=dict(size=14)),
                gridcolor='#ddd',
                gridwidth=1,
                zerolinecolor='#ccc',
                range=[-10**4, x_max_matching]
            ),
            yaxis=dict(
                title=dict(text='Fund Participation in ICP', font=dict(size=14)),
                gridcolor='#ddd',
                gridwidth=1,
                zerolinecolor='#ccc',
                range=[-10**4, y_max_matching]
            )
        )
    
        return fig_tokens, fig_voting_power, fig_icp, linear_function_fig, matching_function_fig