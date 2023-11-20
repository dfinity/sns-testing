#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 20 11:38:18 2023

@author: bjoernassmann
"""

from dash import Dash
import callbacks
import layout
from scenario_computation import get_scenarios

app = Dash(__name__)
scenarios = get_scenarios()
app.layout = layout.create_layout(scenarios)
callbacks.register_callbacks(app, scenarios)

if __name__ == '__main__':
    app.run_server(debug=True, port=8051)
