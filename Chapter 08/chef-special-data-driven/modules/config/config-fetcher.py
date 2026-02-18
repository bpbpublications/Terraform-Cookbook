#!/usr/bin/env python3
import json

config = {
    "region": "uksouth",
    "environments": ["dev", "test", "prod"],
    "allowed_ips": ["10.10.10.10", "10.20.30.40"]
}

# Terraform external only accepts string values, so serialize arrays as JSON text
result = {
    "region": config["region"],
    "environments": json.dumps(config["environments"]),
    "allowed_ips": json.dumps(config["allowed_ips"]),
}

print(json.dumps(result))
