#!/bin/bash

# Set the canister name for local network
CANISTER_NAME="tournament_backend"

# Define admin identity
ADMIN_IDENTITY="bizkit"
declare -a PRINCIPALS_KEYS
declare -a PRINCIPALS_VALUES

# Prompt for the number of identities
read -p "Enter the number of identities to use (e.g., 8, 16, etc): " NUM_IDENTITIES

# Validate input
if ! [[ "$NUM_IDENTITIES" =~ ^[0-9]+$ ]] || [ "$NUM_IDENTITIES" -le 0 ]; then
  echo "Invalid number of identities. Please enter a positive integer."
  exit 1
fi

# Generate the IDENTITIES array based on the input
IDENTITIES=()
for ((i=1; i<=NUM_IDENTITIES; i++)); do
  IDENTITIES+=("player$i")
done

# Display the selected identities
echo "Using the following identities: ${IDENTITIES[@]}"

# Create a tournament and capture the tournament ID
echo "Creating a tournament..."
TOURNAMENT_ID=$(dfx canister call $CANISTER_NAME createTournament '("Test Tournament", 1625151600000, "100 ICP", 1627730000000)' | perl -nle 'print $1 if /\((\d+) : nat\)/')

# Check if the tournament was created successfully
if [ -z "$TOURNAMENT_ID" ]; then
  echo "Failed to create tournament."
  exit 1
fi

echo "Created tournament with ID: $TOURNAMENT_ID"

# Join tournament with different identities and fetch their principals
echo "Joining tournament with different identities..."
for identity in "${IDENTITIES[@]}"; do
  dfx identity use $identity
  echo "Using identity: \"$identity\" to join tournament."
  JOIN_RESULT=$(dfx canister call $CANISTER_NAME joinTournament "($TOURNAMENT_ID)")
  
  # Check for join success
  if [[ "$JOIN_RESULT" == *"error"* ]]; then
    echo "Failed to join tournament with identity: $identity"
    continue
  fi

  echo "Join result for $identity: $JOIN_RESULT"
  PRINCIPAL=$(dfx identity get-principal | awk -F'"' '/Principal/ {print $2}')
  PRINCIPALS_KEYS+=("$identity")
  PRINCIPALS_VALUES+=("$PRINCIPAL")
  echo "Principal for $identity: $PRINCIPAL"
done

# Switch to admin identity and update the bracket
echo "Updating bracket as admin..."
dfx identity use $ADMIN_IDENTITY
BRACKET_UPDATE_RESULT=$(dfx canister call $CANISTER_NAME updateBracket "($TOURNAMENT_ID)")

if [[ "$BRACKET_UPDATE_RESULT" == *"error"* ]]; then
  echo "Failed to update bracket."
  exit 1
fi

echo "Bracket update result: $BRACKET_UPDATE_RESULT"

# Function to fetch and parse the tournament bracket
fetch_and_parse_bracket() {
  TOURNAMENT_BRACKET=$(dfx canister call $CANISTER_NAME getTournamentBracket "($TOURNAMENT_ID)")
  echo "Updated tournament bracket: $TOURNAMENT_BRACKET"

  MATCH_PARTICIPANTS=()
  MATCH_IDS=($(echo "$TOURNAMENT_BRACKET" | perl -nle 'print $1 if /id = (\d+)/'))
  MATCH_PARTICIPANT_BLOCKS=($(echo "$TOURNAMENT_BRACKET" | perl -nle 'print $1 if /participants = vec \{([^}]+)\}/'))
  for (( i=0; i<${#MATCH_IDS[@]}; i++ )); do
    PARTICIPANTS=$(echo "${MATCH_PARTICIPANT_BLOCKS[$i]}" | sed 's/, / /g')
    MATCH_PARTICIPANTS[$i]=$PARTICIPANTS
    echo "Match ${MATCH_IDS[$i]} participants: $PARTICIPANTS"
  done
}

# Fetch the initial bracket
fetch_and_parse_bracket

# Switch to admin identity to verify and update matches
echo "Verifying and updating matches as admin..."
dfx identity use $ADMIN_IDENTITY
for match_id in "${MATCH_IDS[@]}"; do
  ADMIN_UPDATE_RESULT=$(dfx canister call $CANISTER_NAME adminUpdateMatch "($match_id, \"3-2\")")
  echo "Admin update result for match $match_id: $ADMIN_UPDATE_RESULT"
done

# Fetch and display the tournament bracket after the first round
echo "Fetching the tournament bracket after the first round..."
fetch_and_parse_bracket

# Finalize the tournament if necessary
if [ ${#MATCH_IDS[@]} -eq 1 ]; then
  echo "Finalizing the tournament..."
  FINALIZE_RESULT=$(dfx canister call $CANISTER_NAME adminUpdateMatch "(0, \"3-2\")")
  echo "Finalization result: $FINALIZE_RESULT"
  FINAL_BRACKET=$(dfx canister call $CANISTER_NAME getTournamentBracket "($TOURNAMENT_ID)")
  echo "Final tournament bracket: $FINAL_BRACKET"
fi

echo "Tournament process complete."
