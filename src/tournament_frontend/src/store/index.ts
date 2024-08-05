import { defineStore } from 'pinia';
import type { Principal } from '@dfinity/principal';
import { useAuthStore } from './auth';
import type { Tournament as BackendTournament, Match as BackendMatch, _SERVICE as TournamentBackendService } from '../../../declarations/tournament_backend/tournament_backend.did';

interface Match extends BackendMatch {
  participants: Principal[];
}

interface Tournament extends BackendTournament {
  participants: Principal[];
  registeredParticipants: Principal[];
}

interface TournamentBracket {
  matches: Match[];
}

export const useTournamentStore = defineStore('tournament', {
  state: () => ({
    tournaments: [] as Tournament[],
    activeTournaments: [] as Tournament[],
    inactiveTournaments: [] as Tournament[],
    tournamentBracket: { matches: [] } as TournamentBracket,
    users: [] as Principal[],
    matches: [] as Match[],
  }),
  actions: {
    async fetchAllTournaments() {
      const authStore = useAuthStore();
      const tournament_backend = authStore.tournament_backend;
      if (!tournament_backend) {
        throw new Error("Tournament backend is not initialized");
      }
      const tournaments = await tournament_backend.getAllTournaments();
      console.log('Fetched Tournaments:', tournaments); // Log the fetched tournaments
      this.tournaments = tournaments ? [...tournaments] : [];
    },
    async fetchActiveTournaments() {
      const authStore = useAuthStore();
      const tournament_backend = authStore.tournament_backend;
      if (!tournament_backend) {
        throw new Error("Tournament backend is not initialized");
      }
      const activeTournaments = await tournament_backend.getActiveTournaments();
      this.activeTournaments = activeTournaments ? [...activeTournaments] : [];
    },
    async fetchInactiveTournaments() {
      const authStore = useAuthStore();
      const tournament_backend = authStore.tournament_backend;
      if (!tournament_backend) {
        throw new Error("Tournament backend is not initialized");
      }
      const inactiveTournaments = await tournament_backend.getInactiveTournaments();
      this.inactiveTournaments = inactiveTournaments ? [...inactiveTournaments] : [];
    },
    async fetchTournamentBracket(tournamentId: bigint) {
      const authStore = useAuthStore();
      const tournament_backend = authStore.tournament_backend;
      if (!tournament_backend) {
        throw new Error("Tournament backend is not initialized");
      }
      const bracket = await tournament_backend.getTournamentBracket(tournamentId);
      this.tournamentBracket = bracket ? { matches: [...bracket.matches] } : { matches: [] };
    },
    async fetchRegisteredUsers(tournamentId: bigint) {
      const authStore = useAuthStore();
      const tournament_backend = authStore.tournament_backend;
      if (!tournament_backend) {
        throw new Error("Tournament backend is not initialized");
      }
      const users = await tournament_backend.getRegisteredUsers(tournamentId);
      this.users = users ? [...users] : [];
    },
    async joinTournament(tournamentId: bigint) {
      const authStore = useAuthStore();
      const tournament_backend = authStore.tournament_backend;
      if (!tournament_backend) {
        throw new Error("Tournament backend is not initialized");
      }
      return await tournament_backend.joinTournament(tournamentId);
    },
    async createTournament(name: string, startDate: bigint, prizePool: string, expirationDate: bigint) {
      const authStore = useAuthStore();
      const tournament_backend = authStore.tournament_backend;
      if (!tournament_backend) {
        throw new Error("Tournament backend is not initialized");
      }
      return await tournament_backend.createTournament(name, startDate, prizePool, expirationDate);
    },
    async updateBracket(tournamentId: bigint) {
      const authStore = useAuthStore();
      const tournament_backend = authStore.tournament_backend;
      if (!tournament_backend) {
        throw new Error("Tournament backend is not initialized");
      }
      return await tournament_backend.updateBracket(tournamentId);
    },
    async adminUpdateMatch(tournamentId: bigint, matchId: bigint, winner: bigint, score: string) {
      const authStore = useAuthStore();
      const tournament_backend = authStore.tournament_backend;
      if (!tournament_backend) {
        throw new Error("Tournament backend is not initialized");
      }
      return await tournament_backend.adminUpdateMatch(tournamentId, matchId, winner, score);
    },
    async submitFeedback(tournamentId: bigint, feedback: string) {
      const authStore = useAuthStore();
      const tournament_backend = authStore.tournament_backend;
      if (!tournament_backend) {
        throw new Error("Tournament backend is not initialized");
      }
      return await tournament_backend.submitFeedback(tournamentId, feedback);
    },
    async submitMatchResult(tournamentId: bigint, matchId: bigint, score: string) {
      const authStore = useAuthStore();
      const tournament_backend = authStore.tournament_backend;
      if (!tournament_backend) {
        throw new Error("Tournament backend is not initialized");
      }
      return await tournament_backend.submitMatchResult(tournamentId, matchId, score);
    },
    async disputeMatch(tournamentId: bigint, matchId: bigint, reason: string) {
      const authStore = useAuthStore();
      const tournament_backend = authStore.tournament_backend;
      if (!tournament_backend) {
        throw new Error("Tournament backend is not initialized");
      }
      return await tournament_backend.disputeMatch(tournamentId, matchId, reason);
    },
    async deleteAllTournaments() {
      const authStore = useAuthStore();
      const tournament_backend = authStore.tournament_backend;
      if (!tournament_backend) {
        throw new Error("Tournament backend is not initialized");
      }
      return await tournament_backend.deleteAllTournaments();
    },
  },
});
