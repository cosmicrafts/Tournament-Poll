<template>
  <div class="match">
    <div class="match-id">Match ID: {{ match.id }}</div>
    <div class="match-details">
      <div class="participant">
        <span>{{ match.participants[0].toText() }}</span>
        <span>{{ match.result && match.result.length > 0 ? match.result[0].score.split('-')[0] : '-' }}</span>
      </div>
      <div class="participant">
        <span>{{ match.participants[1].toText() }}</span>
        <span>{{ match.result && match.result.length > 0 ? match.result[0].score.split('-')[1] : '-' }}</span>
      </div>
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
  background: #fff;
  border-radius: 5px;
}

.match-id {
  font-weight: bold;
  margin-bottom: 10px;
}

.match-details {
  display: flex;
  justify-content: space-between;
  width: 100%;
}

.participant {
  display: flex;
  justify-content: space-between;
  width: 45%;
}
</style>
