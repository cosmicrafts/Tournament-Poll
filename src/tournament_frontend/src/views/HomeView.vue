<template>
  <section>
    <h2>Welcome to Tournament System</h2>
    <router-link to="/dashboard">
      <button>Go to Dashboard</button>
    </router-link>
  </section>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useTournamentStore } from '@/store';

const tournamentStore = useTournamentStore();

const fetchAllTournaments = async () => {
  await tournamentStore.fetchAllTournaments();
};

onMounted(() => {
  fetchAllTournaments();
});
</script>

<style scoped>
ul {
  padding: 0;
  list-style: none;
}

li {
  padding: 10px;
  border-bottom: 1px solid #ddd;
}

li:last-child {
  border-bottom: none;
}
</style>
