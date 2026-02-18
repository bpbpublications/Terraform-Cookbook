#cloud-config
package_update: true
packages:
  - curl
  - jq

write_files:
  - path: /opt/kv/fetch_secret.sh
    permissions: '0755'
    content: |
      #!/usr/bin/env bash
      set -euo pipefail

      SECRET_URI="${secret_uri}"
      KV_NAME="${key_vault_name}"

      # Get an access token for Key Vault using the VM's managed identity
      TOKEN=$(curl -s \
        -H "Metadata: true" \
        "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net" \
        | jq -r '.access_token')

      # Read the secret value at deploy time directly from Key Vault
      SECRET_VALUE=$(curl -s -H "Authorization: Bearer $${TOKEN}" "$${SECRET_URI}?api-version=7.5" | jq -r '.value')

      # Store secret securely on VM. Adjust permissions for your app.
      install -d -m 0700 /opt/kv
      umask 077
      echo -n "$${SECRET_VALUE}" > /opt/kv/db-password
      chmod 0600 /opt/kv/db-password

      # Optional: scrub variables from shell history and memory
      unset SECRET_VALUE TOKEN

runcmd:
  - [ bash, -c, "/opt/kv/fetch_secret.sh" ]
