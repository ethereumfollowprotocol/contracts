declare module NodeJS {
  interface ProcessEnv {
    readonly NODE_ENV: 'development' | 'production' | 'test'
    readonly ANVIL_ACCOUNT_PRIVATE_KEY: string;
    readonly PRIVATE_KEY: string;
    readonly ETHERSCAN_API_KEY: string
    readonly SEPOLIA_ADDRESS: string
    readonly SEPOLIA_ACCOUNT_PRIVATE_KEY: string
  }
}
