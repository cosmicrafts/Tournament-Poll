import { createRouter, createWebHistory } from 'vue-router';
import HomeView from '../views/HomeView.vue';
import TournamentView from '../views/TournamentView.vue';

const routes = [
  {
    path: '/',
    name: 'Home',
    component: HomeView,
  },
  {
    path: '/tournament/:id',
    name: 'Tournament',
    component: TournamentView,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

export default router;
