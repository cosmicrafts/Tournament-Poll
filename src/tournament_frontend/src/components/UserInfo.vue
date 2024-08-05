<template>
      <div class="user-info">
        <h2>Welcome to your dashboard</h2>
        <div>
          <strong>Principal ID:</strong>
          <p>{{ principalId }}</p>
        </div>
      </div>
    </template>
    
    <script setup>
    import { computed } from 'vue';
    import { useAuthStore } from '@/store/auth';
    
    const authStore = useAuthStore();
    
    const principalId = computed(() => authStore.principalId);
    </script>
    
    <style scoped>
    .user-info {
      margin: 20px;
      padding: 20px;
      border: 1px solid #ddd;
      border-radius: 5px;
      background-color: #f9f9f9;
    }
    
    strong {
      display: block;
      margin-bottom: 5px;
    }
    </style>
    