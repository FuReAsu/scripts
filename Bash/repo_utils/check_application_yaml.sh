#!/bin/bash

file=$(find . | grep -E "main\/resources\/application.(yml|yaml)" || true)

if ! [ -f "$file" ]; then
  echo "No application.yml found. Skipping..."
  exit 0
fi

echo "project root: $(pwd)
application.yml file: $file"

declare pass=true

print_findings () {
    local -n findings=$1        
    local finding_type="$2"
    
    if [ "${#findings[@]}" -eq 0 ]; then
      echo "No $finding_type detected"
      echo "============================="
      echo ""
    else
      pass=false
      echo "Detected $finding_type"
      echo "============================="

      for finding in "${findings[@]}"; do
          
          line=$(grep -nF "$finding" "$file" | awk -F ':' '{print $1}')
          echo "line $line -> $finding"
          echo ""
      done
    fi
}

mapfile -t secrets < <(grep -iE "(password|secret|pass)\s*[:=]\s*[^\s]+" "$file")
print_findings secrets Secrets

mapfile -t apiKeys < <(grep -iE "(api[_-]key|key)[:=]\s[a-zA-Z0-9=_-]{16,}" "$file")
print_findings apiKeys API-Keys

mapfile -t tokens < <(grep -iE "(token)[:=]\s[a-zA-Z0-9=_-]{16,}" "$file")
print_findings tokens Tokens 

mapfile -t dburis < <(grep -iE "(mysql|postgresql|mongodb|redis|jdbc)://[^:]+:[^@]+@" "$file")
print_findings dburis DB-URIs

if ! $pass; then
  exit 1
else
  exit 0
fi
