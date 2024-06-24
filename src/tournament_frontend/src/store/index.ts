import { defineStore } from 'pinia';
import { tournament_backend } from '../../../declarations/tournament_backend';
import type { Principal } from '@dfinity/principal';

interface Match {
  id: bigint;
  participants: Principal[];
  result: { winner: Principal; score: string }[] | null;
  status: string;
  tournamentId: bigint;
}


interface Tournament {
  id: bigint;
  participants: Principal[];
  name: string;
  isActive: boolean;
  expirationDate: bigint;
  prizePool: string;
  startDate: bigint;
  bracketCreated: boolean;
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
      const tournaments = await tournament_backend.getAllTournaments();
      console.log('Fetched Tournaments:', tournaments); // Log the fetched tournaments
      this.tournaments = tournaments ? [...tournaments] : [];
    },
    async fetchActiveTournaments() {
      const activeTournaments = await tournament_backend.getActiveTournaments();
      this.activeTournaments = activeTournaments ? [...activeTournaments] : [];
    },
    async fetchInactiveTournaments() {
      const inactiveTournaments = await tournament_backend.getInactiveTournaments();
      this.inactiveTournaments = inactiveTournaments ? [...inactiveTournaments] : [];
    },
    async fetchTournamentBracket(tournamentId: bigint) {
      const bracket = await tournament_backend.getTournamentBracket(tournamentId);
      this.tournamentBracket = bracket ? { matches: [...bracket.matches] } : { matches: [] };
    },
    async fetchRegisteredUsers(tournamentId: bigint) {
      const users = await tournament_backend.getRegisteredUsers(tournamentId);
      this.users = users ? [...users] : [];
    },
    async joinTournament(tournamentId: bigint) {
      return await tournament_backend.joinTournament(tournamentId);
    },
    async createTournament(name: string, startDate: bigint, prizePool: string, expirationDate: bigint) {
      return await tournament_backend.createTournament(name, startDate, prizePool, expirationDate);
    },
    async updateBracket(tournamentId: bigint) {
      return await tournament_backend.updateBracket(tournamentId);
    },
    async adminUpdateMatch(matchId: bigint, score: string) {
      return await tournament_backend.adminUpdateMatch(matchId, score);
    },
    async submitFeedback(tournamentId: bigint, feedback: string) {
      return await tournament_backend.submitFeedback(tournamentId, feedback);
    },
    async submitMatchResult(matchId: bigint, score: string) {
      return await tournament_backend.submitMatchResult(matchId, score);
    },
    async disputeMatch(matchId: bigint, reason: string) {
      return await tournament_backend.disputeMatch(matchId, reason);
    },
    async deleteAllTournaments() {
      return await tournament_backend.deleteAllTournaments();
    },
  },
});
