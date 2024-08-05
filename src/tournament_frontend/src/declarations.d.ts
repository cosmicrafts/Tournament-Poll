// src/declarations.d.ts
declare module '@/services/MetaMaskService' {
  const MetaMaskService: {
    isMetaMaskInstalled(): Promise<boolean>;
    getEthereumAddress(): Promise<string>;
    signMessage(message: string): Promise<string>;
  };
  export default MetaMaskService;
}

declare module '@/services/PhantomService' {
  const PhantomService: {
    connectWallet(): Promise<string | null>;
    signAndSend(message: string): Promise<string | void>;
  };
  export default PhantomService;
}
