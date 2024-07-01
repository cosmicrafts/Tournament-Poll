#!/bin/bash

# Loop to create 64 player identities
for i in {1..64}; do
  dfx identity new player$i
done

echo "Created 64 player identities."
