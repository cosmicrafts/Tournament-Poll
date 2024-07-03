#!/bin/bash

# Prompt user for number of player identities
echo -n "Enter the number of player identities to create: "
read num_players

# Loop to create player identities
for ((i=1; i<=$num_players; i++)); do
  dfx identity new player$i
done

echo "Created $num_players player identities."
