/** Represents an account as given by the Coinbase V2 API */
export interface CoinbaseAccount {
  id: string;
  name: string;
  primary: boolean;
  type: string;
  currency: {
    asset_id: string;
    code: string;
    color: string;
    exponent: number;
    name: string;
    slug: string;
    sort_index: number;
    type: string;
  };
  balance: {
    amount: string;
    currency: string;
  };
  created_at: string;
  updated_at: string;
  resource: string;
  resource_path: string;
  ready?: boolean;
}
