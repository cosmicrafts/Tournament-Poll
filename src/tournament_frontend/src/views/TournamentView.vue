<template>
  <section>
    <h2>{{ tournament.name }}</h2>
    <p>Start Date: {{ formatDate(tournament.startDate) }}</p>
    <p>Expiration Date: {{ formatDate(tournament.expirationDate) }}</p>
    <p>Prize Pool: {{ tournament.prizePool }}</p>
    <p>Status: {{ tournament.isActive ? 'Active' : 'Inactive' }}</p>
    <h3>Participants</h3>
    <ul>
      <li v-for="participant in participants" :key="participant.toText()">
        {{ participant.toText() }}
      </li>
    </ul>
    <button @click="joinTournament">Join Tournament</button>
    <button @click="updateBracket">Update Bracket</button>
    <h3>Matches</h3>
    <div class="bracket">
      <div class="round" v-for="(roundMatches, roundIndex) in organizedMatches" :key="roundIndex">
        <Match v-for="match in roundMatches" :key="match.id" :match="match" />
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue';
import { useTournamentStore } from '@/store';
import { useRoute } from 'vue-router';
import Match from '@/components/Match.vue';

const tournamentStore = useTournamentStore();
const route = useRoute();
const tournamentId = ref(BigInt(route.params.id));

const tournament = ref({});
const participants = ref([]);
const matches = ref([]);

// Organize matches into rounds
const organizedMatches = computed(() => {
  const rounds = [];
  let currentRound = [];
  matches.value.forEach((match, index) => {
    currentRound.push(match);
    if (currentRound.length === 2) { // Adjust based on the number of matches per round
      rounds.push(currentRound);
      currentRound = [];
    }
  });
  if (currentRound.length > 0) rounds.push(currentRound);
  return rounds;
});

const fetchTournamentDetails = async () => {
  await tournamentStore.fetchTournamentBracket(tournamentId.value);
  matches.value = tournamentStore.tournamentBracket.matches;

  await tournamentStore.fetchRegisteredUsers(tournamentId.value);
  participants.value = tournamentStore.users;

  await tournamentStore.fetchAllTournaments();
  tournament.value = tournamentStore.tournaments.find(t => t.id === tournamentId.value);
};

const joinTournament = async () => {
  await tournamentStore.joinTournament(tournamentId.value);
  await fetchTournamentDetails();
};

const updateBracket = async () => {
  await tournamentStore.updateBracket(tournamentId.value);
  await fetchTournamentDetails();
};

const formatDate = (bigIntDate) => {
  if (bigIntDate) {
    const date = new Date(Number(bigIntDate));
    return date.toLocaleDateString();
  }
  return 'Invalid Date';
};

onMounted(fetchTournamentDetails);
</script>

<style scoped>
.bracket {
  display: flex;
  flex-wrap: wrap;
  justify-content: space-around;
  margin-top: 20px;
}

.round {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin: 0 10px;
}
</style>
