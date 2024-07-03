# `tournament`

Welcome to your new `tournament` project and to the Internet Computer development community. By default, creating a new project adds this README and some template files to your project directory. You can edit these template files to customize your project and to include your own code to speed up the development cycle.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Motoko Backend](#motoko-backend)
  - [Imports](#imports)
  - [Main Actor](#main-actor)
- [Running the Project Locally](#running-the-project-locally)
- [Scripts](#scripts)
  - [Script 1 - Register Identities (`register_identities.sh`)](#script-1---register-identities-register_identi)
  - [Script 2 - Create Tournament and Manage Matches (`tournament_script.sh`)](#script-2---create-tournament-and-manage-matches-tournament_scriptsh)
  - [Script 3 - Create Tournament Bracket (`create_tournament.sh`)](#script-3---create-tournament-bracket-create_tournamentsh)
- [Useful Resources](#useful-resources)

## Overview

This project implements a tournament backend on the Internet Computer using Motoko. The backend supports creating tournaments, joining tournaments, submitting match results, and updating brackets. Additionally, admin functionalities allow for verifying and updating match results.

## Prerequisites

- DFINITY SDK installed
- Bash shell
- Perl (for parsing output)

## Project Structure

- `main.mo`: The Motoko backend code for managing tournaments and matches.
- `scripts/`: Contains Bash scripts for setting up identities, creating tournaments, and managing matches.

## Motoko Backend

### Imports

Reference to necessary imports for the Motoko backend.

### Main Actor

Explanation of the main actor and its functions:
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

## Scripts

### Script 1 - Register Identities (`register_identities.sh`)

This script registers multiple identities for testing purposes. 

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

This script creates a tournament bracket with participants and fetches the initial bracket.

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
