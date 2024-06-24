<template>
  <section>
    <h2>{{ tournament.name }}</h2>
    <p>Start Date: {{ formatDate(tournament.startDate) }}</p>
    <p>Expiration Date: {{ formatDate(tournament.expirationDate) }}</p>
    <p>Prize Pool: {{ tournament.prizePool }}</p>
    <p>Status: {{ tournament.isActive ? 'Active' : 'Inactive' }}</p>
    <h3>Participants</h3>
    <ul>
      <li v-for="participant in participants" :key="participant">
        {{ participant }}
      </li>
    </ul>
    <button @click="joinTournament">Join Tournament</button>
    <button @click="updateBracket">Update Bracket</button>
    <h3>Matches</h3>
    <ul>
      <li v-for="match in matches" :key="match.id">
        Match {{ match.id }}: {{ match.participants[0] }} vs {{ match.participants[1] }}
        <span v-if="match.result">
          - Winner: {{ match.result.winner }}, Score: {{ match.result.score }}
        </span>
      </li>
    </ul>
  </section>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useTournamentStore } from '@/store';
import { useRoute } from 'vue-router';

const tournamentStore = useTournamentStore();
const route = useRoute();
const tournamentId = ref(BigInt(route.params.id));

const tournament = ref({});
const participants = ref([]);
const matches = ref([]);

const fetchTournamentDetails = async () => {
  await tournamentStore.fetchTournamentBracket(tournamentId.value);
  console.log('Fetched Bracket:', tournamentStore.tournamentBracket.matches);
  matches.value = tournamentStore.tournamentBracket.matches;

  await tournamentStore.fetchRegisteredUsers(tournamentId.value);
  console.log('Fetched Users:', tournamentStore.users);
  participants.value = tournamentStore.users;

  await tournamentStore.fetchAllTournaments();
  console.log('Fetched Tournaments:', tournamentStore.tournaments);
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
/* Add your scoped styles here */
</style>
