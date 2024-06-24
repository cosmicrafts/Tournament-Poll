<template>
      <div class="match">
        <div class="match-id">Match ID: {{ match.id }}</div>
        <div class="participant">
          {{ match.participants[0].toText() }}: {{ match.result && match.result.length > 0 ? match.result[0].score : '-' }}
        </div>
        <div class="participant">
          {{ match.participants[1].toText() }}: {{ match.result && match.result.length > 1 ? match.result[1].score : '-' }}
        </div>
      </div>
    </template>
    
    <script setup>
    import { defineProps } from 'vue';
    
    const props = defineProps({
      match: Object
    });
    </script>
    
    <style scoped>
    .match {
      border: 1px solid #ccc;
      padding: 15px;
      margin: 10px 0;
      display: flex;
      flex-direction: column;
      align-items: flex-start;
      background: #fff;
      border-radius: 5px;
    }
    
    .match-id {
      font-weight: bold;
      margin-bottom: 10px;
    }
    
    .participant {
      margin-bottom: 5px;
    }
    </style>
    