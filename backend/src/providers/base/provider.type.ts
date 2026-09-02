/** List of available provider types */
export enum ProviderType {
  simpleFin = "simple-fin",
  zillow = "zillow",
  plaid = "plaid",
  snapTrade = "snapTrade",
  coinbase = "coinbase",
}

/** List of sub types that a provider would belong to */
export enum ProviderSubType {
  bankingInvestments = "Bank Investments",
  realEstate = "Real Estate",
  crypto = "Crypto",
}
