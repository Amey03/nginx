#!/bin/bash

# Start Nginx in the foreground
exec $(which nginx) -g 'daemon off;'