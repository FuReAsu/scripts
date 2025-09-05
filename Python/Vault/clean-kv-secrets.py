import os
import requests

VAULT = "http://172.20.204.44:8200"
BASEPATH = input("Enter the base path (no trailing slash): ").strip()

# Read Vault Token
with open(os.path.expanduser("~/.vault-token"), "r") as f:
    token = f.read().strip()

headers = {
    "X-Vault-Token": token
}

def list_keys(path):
    """List KV2 keys at a given path."""
    url = f"{VAULT}/v1/{path}"
    response = requests.request("LIST", url, headers=headers)
    if response.status_code != 200:
        return []
    return response.json().get("data", {}).get("keys", [])

def delete_metadata(path):
    """Delete metadata (deletes all versions of the secret)."""
    url = f"{VAULT}/v1/{path}"
    response = requests.delete(url, headers=headers)
    if response.status_code == 204:
        print(f"Deleted secret: {path}")
    else:
        print(f"Failed to delete {path}: {response.status_code} {response.text}")

def recursive_delete_secrets_only(path):
    """Recursively deletes only real secrets (not folders)."""
    keys = list_keys(path)
    for key in keys:
        full_path = f"{path}/{key}".rstrip('/')
        if key.endswith('/'):
            # Folder, recurse into it
            recursive_delete_secrets_only(full_path)
        else:
            # Actual secret
            delete_metadata(full_path)

def main():
    top_keys = list_keys(BASEPATH)
    if not top_keys:
        print("No keys found under base path.")
        return

    print("\nAvailable keys:")
    for i, key in enumerate(top_keys):
        print(f"{i}: {key}")

    try:
        selected_index = int(input("Choose a key index to clean recursively: "))
        selected_key = top_keys[selected_index].rstrip('/')
        full_path = f"{BASEPATH}/{selected_key}".rstrip('/')
        confirm = input(f"Confirmation -> delete all the secrets under '{full_path}'? (yes/no): ")
        if confirm.lower() == 'yes':
            recursive_delete_secrets_only(full_path)
        else:
            print("Aborted.")
    except (IndexError, ValueError):
        print("Invalid selection.")

if __name__ == "__main__":
    main()
