<template>
  <section>
    <h2>{{ tournament.name }}</h2>
    <p>Start Date: {{ formatDate(tournament.startDate) }}</p>
    <p>Expiration Date: {{ formatDate(tournament.expirationDate) }}</p>
    <p>Prize Pool: {{ tournament.prizePool }}</p>
    <p>Status: {{ tournament.isActive ? 'Active' : 'Inactive' }}</p>
    <h3>Participants ({{ participantCount }})</h3>
    <ul>
      <li v-for="participant in participants" :key="participant.toText()">
        {{ formatPrincipal(participant.toText()) }}
      </li>
    </ul>
    <button @click="joinTournament">Join Tournament</button>
    <button @click="updateBracket">Update Bracket</button>
    <h3>Matches</h3>
    <div class="bracket">
      <div
        class="round"
        v-for="(roundMatches, roundIndex) in organizedMatches"
        :key="roundIndex"
        :class="'round-' + roundIndex"
        :style="{'--matches-per-round': roundMatches.length}"
      >
        <div v-for="match in roundMatches" :key="match.id" class="match-wrapper">
          <Match :match="match" />
        </div>
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

// Function to organize matches into rounds
const organizeMatchesIntoRounds = (matches) => {
  const rounds = [];
  let totalMatches = matches.length;
  let currentRoundMatches = Math.ceil(totalMatches / 2);

  // Initialize rounds with empty arrays
  while (totalMatches > 0) {
    rounds.push([]);
    totalMatches = Math.floor(totalMatches / 2);
  }

  let roundIndex = 0;
  let matchCounter = 0;
  currentRoundMatches = Math.ceil(matches.length / 2);

  // Organize matches into rounds
  while (matchCounter < matches.length) {
    for (let i = 0; i < currentRoundMatches && matchCounter < matches.length; i++) {
      rounds[roundIndex].push(matches[matchCounter]);
      matchCounter++;
    }
    roundIndex++;
    currentRoundMatches = Math.ceil(currentRoundMatches / 2);
  }

  return rounds;
};

const organizedMatches = computed(() => {
  return organizeMatchesIntoRounds(matches.value);
});

const participantCount = computed(() => {
  return participants.value.length;
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

const formatPrincipal = (principal) => {
  return `${principal.slice(0, 5)}..${principal.slice(-3)}`;
};

onMounted(fetchTournamentDetails);
</script>

<style scoped>
.bracket {
  display: grid;
  grid-auto-flow: column; /* Flow grid items by column */
  grid-auto-columns: min-content; /* Ensure columns only take as much width as needed */
  gap: 10px; /* Adjust the space between columns */
  margin-top: 20px;
  padding: 20px 0;
  justify-content: start; /* Align columns to the start */
  overflow-x: auto; /* Enable horizontal scrolling if necessary */
}

.round {
  display: flex;
  flex-direction: column;
  justify-content: space-around;
  position: relative;
  height: 100%;
}

.match-wrapper {
  display: flex;
  justify-content: center;
  align-items: center;
  height: calc(100% / var(--matches-per-round));
}

.match {
  position: relative;
  border: 1px solid #ccc;
  padding: 15px;
  background: #fff;
  border-radius: 5px;
  transition: transform 0.2s, box-shadow 0.2s;
  width: 180px;
  display: flex;
  flex-direction: column;
  align-items: center;
}

.match:hover {
  transform: translateY(-5px);
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
}

.match-id {
  font-weight: bold;
  margin-bottom: 10px;
}

.match-details {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 100%;
}

.participant {
  display: flex;
  justify-content: space-between;
  width: 100%;
  margin: 5px 0;
}

.participant-id {
  cursor: pointer;
  color: #007bff;
  margin-right: 10px;
}

.participant-id:hover {
  text-decoration: underline;
}

@media (max-width: 768px) {
  .bracket {
    grid-auto-flow: row;
    grid-auto-rows: min-content;
  }

  .round {
    flex-direction: row;
    justify-content: center;
    align-items: flex-start;
  }
}
</style>
