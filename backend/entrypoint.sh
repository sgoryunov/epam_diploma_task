#!/bin/bash
cd /app
flask db init
flask db migrate
flask db upgrade
flask run 
