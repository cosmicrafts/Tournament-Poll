import { defineStore } from 'pinia';
import { Actor, HttpAgent, type ActorSubclass } from '@dfinity/agent';
import { Ed25519KeyIdentity } from '@dfinity/identity';
import nacl from 'tweetnacl';
import { encode as base64Encode } from 'base64-arraybuffer';
import MetaMaskService from '@/services/MetaMaskService';
import PhantomService from '@/services/PhantomService';
import { idlFactory, canisterId } from '../../../declarations/tournament_backend';
import type { _SERVICE as TournamentBackendService } from '../../../declarations/tournament_backend/tournament_backend.did';

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as { publicKey: string; privateKey: string } | null,
    isAuthenticated: false,
    googleSub: '' as string,
    principalId: '' as string,
    tournament_backend: null as ActorSubclass<TournamentBackendService> | null,
  }),
  actions: {
    async loginWithGoogle(response: any) {
      const decodedIdToken = response.credential.split('.')[1];
      const payload = JSON.parse(atob(decodedIdToken));
      this.googleSub = payload.sub;
      await this.generateKeysFromSub(this.googleSub);
    },
    async loginWithMetaMask() {
      const uniqueMessage = 'Sign this message to log in with your Ethereum wallet';
      const signature = await MetaMaskService.signMessage(uniqueMessage);
      if (signature) {
        await this.generateKeysFromSignature(signature);
      }
    },
    async loginWithPhantom() {
      const message = 'Sign this message to log in with your Phantom Wallet';
      const signature = await PhantomService.signAndSend(message);
      if (signature) {
        await this.generateKeysFromSignature(signature);
      }
    },
    async generateKeysFromSignature(signature: string) {
      const encoder = new TextEncoder();
      const encodedSignature = encoder.encode(signature);
      const hashBuffer = await crypto.subtle.digest('SHA-256', encodedSignature);
      const seed = new Uint8Array(hashBuffer.slice(0, 32));
      const keyPair = nacl.sign.keyPair.fromSeed(seed);
      const publicKeyBase64 = base64Encode(keyPair.publicKey);
      const privateKeyBase64 = base64Encode(keyPair.secretKey);
      this.createIdentity(publicKeyBase64, privateKeyBase64);
      this.isAuthenticated = true;
    },
    async generateKeysFromSub(sub: string) {
      const encoder = new TextEncoder();
      const encodedSub = encoder.encode(sub);
      const hashBuffer = await crypto.subtle.digest('SHA-256', encodedSub);
      const seed = new Uint8Array(hashBuffer.slice(0, 32));
      const keyPair = nacl.sign.keyPair.fromSeed(seed);
      const publicKeyBase64 = base64Encode(keyPair.publicKey);
      const privateKeyBase64 = base64Encode(keyPair.secretKey);
      this.createIdentity(publicKeyBase64, privateKeyBase64);
      this.isAuthenticated = true;
    },
    createIdentity(publicKey: string, privateKey: string) {
      const identity = Ed25519KeyIdentity.fromKeyPair(
        base64ToUint8Array(publicKey),
        base64ToUint8Array(privateKey)
      );
      const agent = new HttpAgent({ identity });
      if (import.meta.env.VITE_NETWORK !== 'ic') {
        agent.fetchRootKey();
      }
      const actor = Actor.createActor(idlFactory, { agent, canisterId }) as ActorSubclass<TournamentBackendService>;
      this.principalId = identity.getPrincipal().toText();
      this.user = { publicKey, privateKey };
      this.tournament_backend = actor;

      // Debug logs to trace URL and canister ID
      console.log('Environment Variables:', import.meta.env);
      console.log('Canister ID:', canisterId);
    },
  },
});

// Helper function to convert base64 to Uint8Array
function base64ToUint8Array(base64: string) {
  const binaryString = atob(base64);
  const len = binaryString.length;
  const bytes = new Uint8Array(len);
  for (let i = 0; i < len; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes;
}
