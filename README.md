# Tournament System

<div align="center">

A decentralized, transparent, and immutable tournament management system built on the Internet Computer.

[![Internet Computer](https://img.shields.io/badge/Internet%20Computer-Blockchain-blue)](https://internetcomputer.org/)
[![Motoko](https://img.shields.io/badge/Backend-Motoko-purple)](https://internetcomputer.org/docs/current/motoko/main/motoko)
[![Vue.js](https://img.shields.io/badge/Frontend-Vue.js%203-green)](https://vuejs.org/)
[![TypeScript](https://img.shields.io/badge/Language-TypeScript-blue)](https://www.typescriptlang.org/)

</div>

## 🚀 Overview

At **Cosmicrafts**, we believe in the power of decentralization to revolutionize internet services. This open-source tournament system leverages blockchain technology to create a transparent, fair, and tamper-proof platform for competitive gaming and esports.

### Why Decentralized Tournaments?

- **🔒 Transparency**: All tournament data is stored on-chain, ensuring complete transparency
- **⚡ Immutability**: Match results cannot be altered once verified
- **🎯 Fair Competition**: Automated bracket generation with randomized seeding
- **🌍 Global Access**: Accessible from anywhere with multi-wallet authentication
- **🔐 Secure**: Leverages Internet Computer's blockchain security

## ✨ Features

### 🎮 Tournament Management
- **Create & Join Tournaments**: Easy tournament creation with configurable parameters
- **Automated Bracket Generation**: Single-elimination brackets with proper seeding and bye handling
- **Match Scheduling**: Automatic match organization with next-match tracking
- **Result Submission**: Players can submit match results directly
- **Admin Verification**: Admin controls for verifying and managing match outcomes
- **Dispute System**: Built-in dispute resolution mechanism

### 🔐 Multi-Wallet Authentication
- **Internet Identity**: Native ICP authentication
- **NFID**: Social login for Web3
- **MetaMask**: Ethereum wallet integration
- **Phantom**: Solana wallet support
- **Google OAuth**: Traditional social login
- **Other Options**: Extensible auth system via Auth0

### 📊 Frontend Features
- **Real-time Tournament View**: Live bracket visualization
- **User Dashboard**: Personal tournament history and stats
- **Modern UI/UX**: Beautiful, responsive design
- **Multi-device Support**: Works on desktop, tablet, and mobile

## 📋 Table of Contents

- [Prerequisites](#prerequisites)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
  - [Installation](#installation)
  - [Development Setup](#development-setup)
  - [Running Locally](#running-locally)
- [Backend API](#backend-api)
- [Authentication](#authentication)
- [Automation Scripts](#automation-scripts)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [Resources](#resources)
- [License](#license)

## 🔧 Prerequisites

Before you begin, ensure you have the following installed:

- **DFINITY SDK (dfx)** - Version 0.15.0 or higher
  ```bash
  sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"
  ```
- **Node.js** - Version 16.0.0 or higher
- **npm** - Version 7.0.0 or higher
- **Bash shell** - For running automation scripts
- **Perl** - For script output parsing (usually pre-installed on Unix systems)

### Optional
- **Git** - For version control
- **MetaMask** - Browser extension for Ethereum wallet auth
- **Phantom** - Browser extension for Solana wallet auth

## 🛠 Tech Stack

### Backend
- **Motoko**: Smart contract language for Internet Computer
- **Internet Computer**: Blockchain platform
- **Candid**: Interface description language

### Frontend
- **Vue.js 3**: Progressive JavaScript framework
- **TypeScript**: Type-safe development
- **Pinia**: State management
- **Vue Router**: Client-side routing
- **Vite**: Build tool and dev server
- **SCSS**: Styling

### Authentication & Integration
- **@dfinity/agent**: ICP agent for canister communication
- **@dfinity/auth-client**: Authentication library
- **@dfinity/identity**: Identity management
- **@solana/web3.js**: Solana integration
- **TweetNaCl**: Cryptographic operations

## 📁 Project Structure

```
tournament-poll/
├── src/
│   ├── tournament_backend/          # Motoko backend canister
│   │   └── main.mo                  # Core tournament logic
│   ├── tournament_frontend/         # Vue.js frontend
│   │   ├── src/
│   │   │   ├── components/          # Reusable Vue components
│   │   │   │   ├── Match.vue
│   │   │   │   └── UserInfo.vue
│   │   │   ├── views/               # Page components
│   │   │   │   ├── HomeView.vue
│   │   │   │   ├── LoginView.vue
│   │   │   │   ├── DashboardView.vue
│   │   │   │   └── TournamentView.vue
│   │   │   ├── store/               # Pinia state management
│   │   │   │   ├── auth.ts          # Authentication store
│   │   │   │   └── index.ts
│   │   │   ├── services/            # External services
│   │   │   │   ├── MetaMaskService.ts
│   │   │   │   └── PhantomService.ts
│   │   │   ├── router/              # Vue Router config
│   │   │   │   └── index.ts
│   │   │   ├── assets/              # Images and static files
│   │   │   └── main.js              # App entry point
│   │   ├── public/                  # Public assets
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── vite.config.js
│   └── declarations/                # Auto-generated Candid bindings
├── register_identities.sh           # Identity registration script
├── tournament_script.sh             # Full tournament automation
├── create_tournament.sh             # Bracket creation script
├── dfx.json                         # DFX configuration
├── package.json                     # Root package config
└── README.md
```

## 🚀 Getting Started

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/tournament-poll.git
   cd tournament-poll
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

### Development Setup

1. **Start the Internet Computer local replica**
   ```bash
   dfx start --clean --background
   ```

2. **Deploy the canisters**
   ```bash
   dfx deploy
   ```

3. **Start the frontend development server**
   ```bash
   cd src/tournament_frontend
   npm start
   ```

4. **Access the application**
   - Frontend: `http://localhost:3000`
   - Backend Candid UI: `http://localhost:4943?canisterId={canister_id}`

### Running Locally

For a complete local setup:

```bash
# Start the local replica
dfx start --background

# Deploy all canisters
dfx deploy

# The frontend will be available at the URL shown in the deploy output
```

To get the canister ID for the frontend:
```bash
dfx canister id tournament_frontend
```

## 📡 Backend API

### Core Functions

#### Tournament Management

**`createTournament`**
```motoko
createTournament(name: Text, startDate: Time, prizePool: Text, expirationDate: Time) : async Nat
```
Creates a new tournament. Returns tournament ID. (Admin only)

**`joinTournament`**
```motoko
joinTournament(tournamentId: Nat) : async Bool
```
Join an active tournament. Returns success status.

**`updateBracket`**
```motoko
updateBracket(tournamentId: Nat) : async Bool
```
Generate tournament bracket with randomized seeding and bye handling.

**`getActiveTournaments`**
```motoko
getActiveTournaments() : async [Tournament]
```
Query all active tournaments accepting registrations.

**`getAllTournaments`**
```motoko
getAllTournaments() : async [Tournament]
```
Query all tournaments (active and inactive).

**`getTournamentBracket`**
```motoko
getTournamentBracket(tournamentId: Nat) : async {matches: [Match]}
```
Get the complete bracket for a tournament.

#### Match Management

**`submitMatchResult`**
```motoko
submitMatchResult(tournamentId: Nat, matchId: Nat, score: Text) : async Bool
```
Submit match results (participant only). Sets status to "pending verification".

**`adminUpdateMatch`**
```motoko
adminUpdateMatch(tournamentId: Nat, matchId: Nat, winnerIndex: Nat, score: Text) : async Bool
```
Verify and update match results (admin only). Auto-advances winner in bracket.

**`disputeMatch`**
```motoko
disputeMatch(tournamentId: Nat, matchId: Nat, reason: Text) : async Bool
```
File a dispute for a match result.

#### Feedback

**`submitFeedback`**
```motoko
submitFeedback(tournamentId: Nat, feedbackText: Text) : async Bool
```
Submit feedback for a tournament.

### Data Types

```motoko
type Tournament = {
    id: Nat;
    name: Text;
    startDate: Time.Time;
    prizePool: Text;
    expirationDate: Time.Time;
    participants: [Principal];
    registeredParticipants: [Principal];
    isActive: Bool;
    bracketCreated: Bool;
    matchCounter: Nat;
};

type Match = {
    id: Nat;
    tournamentId: Nat;
    participants: [Principal];
    result: ?{winner: Principal; score: Text};
    status: Text; // "scheduled", "pending verification", "verified"
    nextMatchId: ?Nat;
};
```

## 🔐 Authentication

The system supports multiple authentication methods through a unified authentication store:

### Supported Methods

1. **Internet Identity** - Native ICP authentication
   - Decentralized identity management
   - No password required
   - Privacy-preserving

2. **NFID** - Social login for Web3
   - Email-based Web3 identity
   - User-friendly onboarding

3. **MetaMask** - Ethereum wallet
   - Sign message to generate ICP identity
   - Deterministic key generation from signature

4. **Phantom** - Solana wallet
   - Sign message to generate ICP identity
   - Cross-chain compatibility

5. **Google OAuth** - Traditional social login
   - Familiar login flow
   - Keys generated from Google Sub ID

### How It Works

All authentication methods generate an Ed25519 key pair that's used to create an ICP identity:

1. User authenticates with their chosen method
2. A unique signature/identifier is obtained
3. SHA-256 hash of the signature creates a deterministic seed
4. Ed25519 key pair is generated from the seed
5. ICP identity is created and used for all backend interactions

## 🤖 Automation Scripts

### 1. Register Identities (`register_identities.sh`)

Quickly create multiple test identities for development and testing.

```bash
./register_identities.sh
```

**Prompts:**
- Number of identities to create

**Output:**
- Creates identities named `player1`, `player2`, etc.
- Lists all created principals

### 2. Full Tournament Management (`tournament_script.sh`)

Complete tournament lifecycle automation: create, register players, generate bracket, and simulate matches.

```bash
./tournament_script.sh
```

**Features:**
- Creates a tournament
- Registers players
- Generates bracket
- Simulates match results
- Verifies matches
- Displays final bracket

### 3. Create Tournament Bracket (`create_tournament.sh`)

Creates a tournament and generates the initial bracket only.

```bash
./create_tournament.sh
```

**Use case:** When you want to manually manage match results.

## 🌐 Deployment

### Deploy to IC Mainnet

1. **Set up cycles wallet** (if not already done)
   ```bash
   dfx identity get-wallet
   ```

2. **Deploy to mainnet**
   ```bash
   dfx deploy --network ic
   ```

3. **Get canister IDs**
   ```bash
   dfx canister id tournament_backend --network ic
   dfx canister id tournament_frontend --network ic
   ```

### Environment Variables

Create a `.env` file in `src/tournament_frontend/`:

```env
VITE_NETWORK=ic                    # or "local"
VITE_GOOGLE_CLIENT_ID=your_id_here
VITE_AUTH0_REDIRECT_URI=your_uri_here
```

### Production Build

```bash
npm run build
```

This creates optimized production builds in `src/tournament_frontend/dist/`.

## 🤝 Contributing

We welcome contributions from the community! Here's how you can help:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit your changes**
   ```bash
   git commit -m 'Add amazing feature'
   ```
4. **Push to the branch**
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open a Pull Request**

### Development Guidelines

- Follow existing code style
- Add tests for new features
- Update documentation as needed
- Keep commits atomic and well-described

## 📚 Resources

### Internet Computer
- [Quick Start Guide](https://internetcomputer.org/docs/current/developer-docs/setup/deploy-locally)
- [SDK Developer Tools](https://internetcomputer.org/docs/current/developer-docs/setup/install)
- [IC Developer Portal](https://internetcomputer.org/developers)

### Motoko
- [Motoko Programming Language Guide](https://internetcomputer.org/docs/current/motoko/main/motoko)
- [Motoko Base Library](https://internetcomputer.org/docs/current/motoko/main/base/)
- [Motoko Language Quick Reference](https://internetcomputer.org/docs/current/motoko/main/language-manual)

### Frontend
- [Vue.js Documentation](https://vuejs.org/)
- [Pinia Documentation](https://pinia.vuejs.org/)
- [Vite Documentation](https://vitejs.dev/)

## 📄 License

This project is open source and available for developers worldwide to build upon and create their own decentralized tournaments, contests, and hackathons.

---

<div align="center">

**Built with ❤️ by [Cosmicrafts](https://cosmicrafts.com)**

*Empowering the future of decentralized gaming*

</div>
