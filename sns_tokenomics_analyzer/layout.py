#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 20 11:39:10 2023

@author: bjoernassmann
"""

from dash import html, dcc


def create_layout( scenarios ):
    
    direct_participation_scenarios_icp = scenarios['direct_participation_scenarios_icp']
    nf_total_maturity_values = scenarios['nf_total_maturity_values']
    no_participation_scenarios = len(direct_participation_scenarios_icp )
    no_total_maturity_scenarios = len( nf_total_maturity_values)
    
    return html.Div([
        # Title 
        html.Div('SNS Tokenomics Analyzer', style={
            'textAlign': 'center',
            'color': '#333',
            'fontSize': 28,
            'fontWeight': '600',
            'padding': '25px',
            'font-family': 'Helvetica, Arial, sans-serif',
            'backgroundColor': '#f2f2f2',  
            'borderBottom': '1px solid #ddd', 
            'boxShadow': '0 2px 4px rgba(0,0,0,0.1)'
        }),

        # Controls Container
        html.Div([
            html.Div([
                html.Label('Select Commitment by Direct Participants', style={
                    'color': '#333', 
                    'font-family': 'Helvetica', 
                    'display': 'block', 
                    'textAlign': 'center'
                }),
                dcc.Slider(
                    id='slider-scenario-participation',
                    min=0, max=no_participation_scenarios-1, value=0,
                    marks={i: f"{round(direct_participation_scenarios_icp[i]/1000)}K" for i in range(no_participation_scenarios)},
                    step=1,
                    className='custom-slider'
                )
            ], style={'margin': 'auto', 'width': '50%', 'padding': '10px'}),

            html.Div([
                html.Label('Select Neurons\' Fund Total Maturity', style={
                    'color': '#333', 
                    'font-family': 'Helvetica', 
                    'display': 'block', 
                    'textAlign': 'center'
                }),
                dcc.Slider(
                    id='slider-scenario-maturity',
                    min=0, max=no_total_maturity_scenarios-1, value=0,
                    marks={i: f"{round(nf_total_maturity_values[i]/10**6,1)}M" for i in range(no_total_maturity_scenarios)},
                    step=1,
                    className='custom-slider'
                )
            ], style={'margin': 'auto', 'width': '50%', 'padding': '10px'}),        
        ], style={'display': 'flex', 'justifyContent': 'space-around', 'backgroundColor': '#f5f5f5', 'padding': '20px'}),

        # Graphs Container
        html.Div([
            html.Div(dcc.Graph(id='matching-function-graph'), style={'flex': '1', 'margin': '10px', 'padding': '10px', 'background': '#f8f9fa', 'border-radius': '8px', 'box-shadow': '0 4px 8px 0 rgba(0,0,0,0.2)'}),
            html.Div(dcc.Graph(id='linear-function-graph'), style={'flex': '1', 'margin': '10px', 'padding': '10px', 'background': '#f8f9fa', 'border-radius': '8px', 'box-shadow': '0 4px 8px 0 rgba(0,0,0,0.2)'})
        ], style={'display': 'flex', 'justifyContent': 'space-around', 'padding': '10px'}),
        
        # Pie charts Container
        html.Div([
            html.Div(dcc.Graph(id='pie-icp-participation'), style={'flex': '1', 'margin': '10px', 'padding': '10px', 'background': '#f8f9fa', 'border-radius': '8px', 'box-shadow': '0 4px 8px 0 rgba(0,0,0,0.2)'}),
            html.Div(dcc.Graph(id='pie-tokens'), style={'flex': '1', 'margin': '10px', 'padding': '10px', 'background': '#f8f9fa', 'border-radius': '8px', 'box-shadow': '0 4px 8px 0 rgba(0,0,0,0.2)'}),
            html.Div(dcc.Graph(id='pie-voting-power'), style={'flex': '1', 'margin': '10px', 'padding': '10px', 'background': '#f8f9fa', 'border-radius': '8px', 'box-shadow': '0 4px 8px 0 rgba(0,0,0,0.2)'})
        ], style={'display': 'flex', 'justifyContent': 'space-around', 'padding': '10px'})
        
        
        ], style={'backgroundColor': '#f5f5f5', 'color': '#333', 'font-family': 'Helvetica'})

