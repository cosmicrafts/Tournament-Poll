# `Tournament System`

## 🚀 Embarking on a Decentralized Adventure

At Cosmicrafts, we believe in the power of decentralization to revolutionize internet services. That's why we've been hard at work crafting a transparent and immutable tournament system that empowers players and fosters fair competition.

## 🔍 Open Source for a Decentralized Gaming Future

We also believe in the power of community and open innovation. That's why we're making the Motoko code and frontend for our tournament system open source. This means developers around the world can build upon our work, creating their own decentralized tournaments, contests, and even hackathons!

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Motoko Backend](#motoko-backend)
  - [Imports](#imports)
  - [Main Actor](#main-actor)
- [Running the Project Locally](#running-the-project-locally)
- [Scripts](#scripts)
  - [Script 1 - Register Identities (`register_identities.sh`)](#script-1---register-identities-register_identities.sh)
  - [Script 2 - Create Tournament and Manage Matches (`tournament_script.sh`)](#script-2---create-tournament-and-manage-matches-tournament_script.sh)
  - [Script 3 - Create Tournament Bracket (`create_tournament.sh`)](#script-3---create-tournament-bracket-create_tournament.sh)
- [Useful Resources](#useful-resources)

## Overview

This project implements a tournament backend on the Internet Computer using Motoko. The backend supports creating tournaments, joining tournaments, submitting match results, and updating brackets. Additionally, admin functionalities allow for verifying and updating match results. It also implements a basic frontend to visualize the tournaments, using Vue and Pinia as the default DFX frontend framework.

## Prerequisites

- DFINITY SDK installed
- Bash shell
- Perl (for parsing output)
- Node.js > 16

## Project Structure

- `src/`: Contains all source code.
  - `declarations/`: Auto-generated files for canisters.
  - `tournament_backend/`: The backend canister.
    - `main.mo`: The Motoko backend code for managing tournaments and matches.
  - `tournament_frontend/`: The frontend code.
    - `src/`: Source files for the frontend.
      - `components/`: Vue components.
      - `store/`: Pinia store setup.
      - `views/`: Vue views.
- `scripts/`: Contains Bash scripts for setting up identities, creating tournaments, and managing matches.
  - `register_identities.sh`
  - `tournament_script.sh`
  - `create_tournament.sh`
  
## Motoko Backend

### Main Actor

Here are some of the main functions:
- Creating tournaments
- Joining tournaments
- Submitting feedback
- Submitting and verifying match results
- Updating the tournament bracket

## Running the Project Locally

If you want to test your project locally, you can use the following commands:

```bash
# Starts the replica, running in the background
dfx start --background

# Deploys your canisters to the replica and generates your candid interface
dfx deploy
```

Once the job completes, your application will be available at `http://localhost:4943?canisterId={asset_canister_id}`.

## Scripts

### Script 1 - Register Identities (`register_identities.sh`)

This script registers multiple identities for testing purposes with the name of player#.
It will prompt how many identities you want to create to automate the script tournament automated creation process

To run the script:
```bash
./register_identities.sh
```

### Script 2 - Create Tournament and Manage Matches (`tournament_script.sh`)

This script creates a tournament with a given number of participants, creates the bracket, and verifies matches.

To run the script:
```bash
./tournament_script.sh
```

### Script 3 - Create Tournament Bracket (`create_tournament.sh`)

This script only registers players and creates a tournament bracket with participants and fetches the initial bracket.
For a more complete tournament management use script 2.

To run the script:
```bash
./create_tournament.sh
```

## Useful Resources

To learn more before you start working with `tournament`, see the following documentation available online:

- [Quick Start](https://internetcomputer.org/docs/current/developer-docs/setup/deploy-locally)
- [SDK Developer Tools](https://internetcomputer.org/docs/current/developer-docs/setup/install)
- [Motoko Programming Language Guide](https://internetcomputer.org/docs/current/motoko/main/motoko)
- [Motoko Language Quick Reference](https://internetcomputer.org/docs/current/motoko/main/language-manual)
