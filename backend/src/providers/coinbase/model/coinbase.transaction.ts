/** Represents a transaction as returned by the Coinbase V2 API. */
export interface CoinbaseTransaction {
  id: string;
  type?: string;
  status?: string;
  amount?: {
    amount: string;
    currency: string;
  };
  native_amount?: {
    amount: string;
    currency: string;
  };
  created_at?: string;
}
