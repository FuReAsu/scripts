#Python script to add config and keyring files to config-json.json file automatically without manually escaping json

import json

# Read the contents of mgr.conf
with open("mgr.conf", "r") as conf_file:
    conf_content = conf_file.read()

# Read the contents of mgr.auth
with open("mgr.auth", "r") as auth_file:
    auth_content = auth_file.read()

# Create the JSON structure
data = {
    "config": conf_content,
    "keyring": auth_content
}

# Save to config-json.json
with open("config-json.json", "w") as json_file:
    json.dump(data, json_file, indent=4)

print("Configuration saved to config-json.json")
