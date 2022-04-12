#!/bin/bash
cd /app
flask db migrate
flask db upgrade
flask run -h 0.0.0.0
