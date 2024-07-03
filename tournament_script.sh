#!/bin/bash

# Set the canister name for local network
CANISTER_NAME="tournament_backend"

# Define admin identity
ADMIN_IDENTITY="bizkit"

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

# Join tournament with different identities
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
  echo "Fetching tournament bracket..."
  TOURNAMENT_BRACKET=$(dfx canister call $CANISTER_NAME getTournamentBracket "($TOURNAMENT_ID)")
  echo "Fetched tournament bracket: $TOURNAMENT_BRACKET"

  # Extract match IDs using a more robust regex
  MATCH_IDS=($(echo "$TOURNAMENT_BRACKET" | grep -oP 'id = \K\d+'))
  echo "Match IDs: ${MATCH_IDS[@]}"
}

# Fetch the initial bracket
fetch_and_parse_bracket

# Generate hardcoded scores and determine the winner
generate_score_and_winner() {
  if (( RANDOM % 2 )); then
    echo "3-1 0"
  else
    echo "1-3 1"
  fi
}

# Switch to admin identity to verify and update matches
echo "Verifying and updating matches as admin..."
dfx identity use $ADMIN_IDENTITY
for match_id in "${MATCH_IDS[@]}"; do
  RESULT=$(generate_score_and_winner)
  SCORE=$(echo $RESULT | cut -d' ' -f1)
  WINNER_INDEX=$(echo $RESULT | cut -d' ' -f2)
  echo "Updating match ID: $match_id with score: $SCORE and winner index: $WINNER_INDEX"
  ADMIN_UPDATE_RESULT=$(dfx canister call $CANISTER_NAME adminUpdateMatch "($TOURNAMENT_ID, $match_id, $WINNER_INDEX, \"$SCORE\")")
  echo "Admin update result for match $match_id: $ADMIN_UPDATE_RESULT"
  
  if [[ "$ADMIN_UPDATE_RESULT" == *"error"* ]]; then
    echo "Failed to update match $match_id."
    continue
  fi
done

# Fetch and display the tournament bracket after the first round
echo "Fetching the tournament bracket after the first round..."
fetch_and_parse_bracket

# Finalize the tournament if necessary
if [ ${#MATCH_IDS[@]} -eq 1 ]; then
  echo "Finalizing the tournament..."
  FINAL_RESULT=$(generate_score_and_winner)
  FINAL_SCORE=$(echo $FINAL_RESULT | cut -d' ' -f1)
  FINAL_WINNER_INDEX=$(echo $FINAL_RESULT | cut -d' ' -f2)
  FINALIZE_RESULT=$(dfx canister call $CANISTER_NAME adminUpdateMatch "($TOURNAMENT_ID, 0, $FINAL_WINNER_INDEX, \"$FINAL_SCORE\")")
  echo "Finalization result: $FINALIZE_RESULT"
  FINAL_BRACKET=$(dfx canister call $CANISTER_NAME getTournamentBracket "($TOURNAMENT_ID)")
  echo "Final tournament bracket: $FINAL_BRACKET"
fi

echo "Tournament process complete."
