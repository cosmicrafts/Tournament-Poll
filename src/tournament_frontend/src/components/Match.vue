<template>
  <div class="match">
    <div class="match-id">Match ID: {{ match.id }}</div>
    <div class="match-details">
      <div class="participant">
        <span class="participant-id" @click="copyToClipboard(match.participants[0].toText())">{{ formatPrincipal(match.participants[0].toText()) }}</span>
        <span class="participant-score">{{ match.result && match.result.length > 0 ? match.result[0].score.split('-')[0] : '-' }}</span>
      </div>
      <div class="participant">
        <span class="participant-id" @click="copyToClipboard(match.participants[1].toText())">{{ formatPrincipal(match.participants[1].toText()) }}</span>
        <span class="participant-score">{{ match.result && match.result.length > 0 ? match.result[0].score.split('-')[1] : '-' }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { defineProps } from 'vue';

const props = defineProps({
  match: Object
});

const formatPrincipal = (principal) => {
  return `${principal.slice(0, 5)}..${principal.slice(-3)}`;
};

const copyToClipboard = (text) => {
  navigator.clipboard.writeText(text).then(() => {
    alert('Copied to clipboard');
  });
};
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
  position: relative;
  transition: transform 0.2s, box-shadow 0.2s;
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
}

@media (max-width: 768px) {
  .match-details {
    flex-direction: row;
  }

}
</style>
