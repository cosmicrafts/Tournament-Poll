<script setup>
import { ref, onMounted } from 'vue';
import { tournament_poll_backend } from 'declarations/tournament_poll_backend/index';

let greeting = ref('');
let tournaments = ref([]);
let name = ref('');

async function handleSubmit(e) {
  e.preventDefault();
  await tournament_poll_backend.registerUser().then((response) => {
    greeting.value = response ? 'User registered!' : 'User already registered.';
  });
}

async function createTournament() {
  await tournament_poll_backend.createTournament(name.value).then((id) => {
    alert(`Tournament created with ID: ${id}`);
    loadTournaments();
  });
}

async function loadTournaments() {
  await tournament_poll_backend.getTournaments().then((response) => {
    tournaments.value = response;
  });
}

onMounted(loadTournaments);
</script>

<template>
  <main>
    <img src="/logo2.svg" alt="DFINITY logo" />
    <br />
    <br />
    <form @submit="handleSubmit">
      <label for="name">Enter your name: &nbsp;</label>
      <input v-model="name" id="name" type="text" />
      <button type="submit">Click Me!</button>
    </form>
    <section id="greeting">{{ greeting }}</section>
    <br />
    <input v-model="name" placeholder="Tournament Name" />
    <button @click="createTournament">Create Tournament</button>
    <h2>Tournaments</h2>
    <ul>
      <li v-for="tournament in tournaments" :key="tournament.id">
        {{ tournament.id }}: {{ tournament.name }}
      </li>
    </ul>
  </main>
</template>
