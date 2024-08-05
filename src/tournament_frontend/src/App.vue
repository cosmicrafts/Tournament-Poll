<template>
  <main>
    <header>
      <h1>Tournament System</h1>
      <nav>
        <router-link to="/">Home</router-link>
        <router-link to="/dashboard">Dashboard</router-link>
      </nav>
    </header>
    <router-view></router-view>
  </main>
</template>

<script setup>
import { useAuthStore } from '@/store/auth';

const authStore = useAuthStore();
</script>

<style>
/* Global styles already defined in index.scss */
</style>
