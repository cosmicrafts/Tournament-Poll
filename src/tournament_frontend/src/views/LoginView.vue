<template>
  <div class="main-div">
    <img src="@/assets/Cosmicrafts_Logo.svg" class="cosmic-logo-img" alt="Cosmicrafts Logo" />
    <label class="cosmic-label-connect">Connect with:</label>
    <div id="buttonDiv"></div>
    <div class="inner-div">
      <div class="btn-div" v-for="method in authMethods" :key="method.text" @click="method.onClick">
        <label class="btn-label">
          <img :src="method.logo" class="button-account-icon" :alt="method.text" />
          Login with {{ method.text }}
        </label>
      </div>
    </div>
    <div class="bottom-div">
      <img src="@/assets/wou_logo.svg" alt="wou-icon" class="bottom-wou-icon" />
      <label class="bottom-label">
        &copy;&nbsp;2023 World of Unreal<br />
        All trademarks referenced herein are the properties of their respective owners.
      </label>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/store/auth';
import MetaMaskService from '@/services/MetaMaskService';
import PhantomService from '@/services/PhantomService';
import { Ed25519KeyIdentity } from '@dfinity/identity';
import nacl from 'tweetnacl';
import { encode as base64Encode, decode as base64Decode } from 'base64-arraybuffer';

// Convert Base64 to Uint8Array
function base64ToUint8Array(base64) {
  const binaryString = atob(base64);
  const len = binaryString.length;
  const bytes = new Uint8Array(len);
  for (let i = 0; i < len; i++) {
    bytes[i] = binaryString.charCodeAt(i);
  }
  return bytes;
}

// Convert Uint8Array to Base64
function uint8ArrayToBase64(uint8Array) {
  const binaryString = uint8Array.reduce((data, byte) => data + String.fromCharCode(byte), '');
  return btoa(binaryString);
}

// Auth Store Actions
const authStore = useAuthStore();
const router = useRouter();

const handleAfterLogin = () => {
  router.push({ name: 'Dashboard' });
};

const loadGoogleIdentityServices = () => {
  const script = document.createElement('script');
  script.src = 'https://accounts.google.com/gsi/client';
  script.onload = initializeGoogleSignIn;
  script.onerror = () => {
    setTimeout(loadGoogleIdentityServices, 1000);
  };
  document.body.appendChild(script);
};

const initializeGoogleSignIn = () => {
  window.google.accounts.id.initialize({
    client_id: import.meta.env.VITE_GOOGLE_CLIENT_ID,
    callback: handleCredentialResponse,
  });
  window.google.accounts.id.renderButton(
    document.getElementById('buttonDiv'),
    { theme: 'filled_black', size: 'large' }
  );
  window.google.accounts.id.prompt();
};

const handleCredentialResponse = (response) => {
  authStore.loginWithGoogle(response).then(handleAfterLogin);
};

onMounted(() => {
  loadGoogleIdentityServices();
});

const generateKeysFromSignature = async (signature) => {
  const encoder = new TextEncoder();
  const encodedSignature = encoder.encode(signature);
  const hashBuffer = await window.crypto.subtle.digest('SHA-256', encodedSignature);
  const seed = new Uint8Array(hashBuffer.slice(0, 32));
  const keyPair = nacl.sign.keyPair.fromSeed(seed);

  const publicKeyBase64 = uint8ArrayToBase64(keyPair.publicKey);
  const privateKeyBase64 = uint8ArrayToBase64(keyPair.secretKey);

  const publicKeyArray = base64ToUint8Array(publicKeyBase64);
  const privateKeyArray = base64ToUint8Array(privateKeyBase64);

  const identity = Ed25519KeyIdentity.fromKeyPair(publicKeyArray, privateKeyArray);
  authStore.createIdentity(publicKeyBase64, privateKeyBase64);
  authStore.isAuthenticated = true;
  return identity;
};

const loginWithMetaMask = async () => {
  const uniqueMessage = 'Sign this message to log in with your Ethereum wallet';
  const signature = await MetaMaskService.signMessage(uniqueMessage);
  await generateKeysFromSignature(signature).then(handleAfterLogin);
};

const loginWithPhantom = async () => {
  const message = 'Sign this message to log in with your Phantom Wallet';
  const signature = await PhantomService.signAndSend(message);
  await generateKeysFromSignature(signature).then(handleAfterLogin);
};

const authMethods = [
  {
    logo: '@/assets/NFID_logo.svg',
    text: 'NFID',
    onClick: () => authStore.loginWithIdentityProvider('NFID').then(handleAfterLogin),
  },
  {
    logo: '@/assets/icp_logo.svg',
    text: 'Internet Identity',
    onClick: () => authStore.loginWithIdentityProvider('InternetIdentity').then(handleAfterLogin),
  },
  {
    logo: '@/assets/metaMask_icon.svg',
    text: 'MetaMask',
    onClick: loginWithMetaMask,
  },
  {
    logo: '@/assets/Phantom_icon.svg',
    text: 'Phantom',
    onClick: loginWithPhantom,
  },
  {
    logo: '@/assets/wouid_icon.svg',
    text: 'Other Options',
    onClick: () => window.location.href = import.meta.env.VITE_AUTH0_REDIRECT_URI,
  },
];
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Ubuntu&display=swap');

body, .cosmic-label-connect, .btn-label, .bottom-label {
  font-family: 'Ubuntu', sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
}

.main-div {
  width: 100vw;
  height: 100vh;
  text-align: center;
  overflow: hidden;
  background-image: url('@/assets/fondo.jpg');
  background-repeat: no-repeat;
  background-size: cover;
  background-position: center;
}

.cosmic-logo-img {
  --h: 275px;
  --wr: calc(var(--h) / 383px);
  width: calc(var(--h) * var(--wr));
  height: var(--h);
  margin-top: 4vh;
}

.cosmic-label-connect {
  color: #FFFFFF;
  font-weight: 600;
  display: block;
  margin: 16px 0px;
}

.inner-div {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
}

.btn-div {
  width: 280px;
  height: 48px;
  position: relative;
  background-image: url('@/assets/Boton_Inactivo.svg');
  cursor: pointer;
  display: grid;
  grid-template-columns: 20% 80%;
  border-radius: 8px;
}

.btn-div:hover {
  background-image: url('@/assets/activebtn.svg');
  transition: background-image 0.1s ease;
}

.button-account-icon {
  width: 1.5rem;
  vertical-align: middle;
  margin-right: 12px;
}

.btn-label {
  color: #FFFFFF;
  font-weight: 500;
  font-size: 16px;
  position: absolute;
  width: 100%;
  height: 50%;
  left: 50%;
  top: 50%;
  transform: translate(-50%, -50%);
  cursor: pointer;
  margin-top: 1px;
  vertical-align: bottom;
}

.bottom-div {
  position: absolute;
  width: 100%;
  bottom: 20px;
  text-align: center;
}

.bottom-wou-icon {
  width: 50px;
}

.bottom-label {
  color: #aaaaaa;
  display: block;
  font-size: 10px;
  margin-top: 2px;
}

@media (max-width: 480px) {
  .btn-div {
    margin: 2px auto;
  }
}
</style>
