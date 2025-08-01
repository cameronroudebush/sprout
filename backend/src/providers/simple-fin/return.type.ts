/** This namespace specifies the SimpleFIN return data formatting */
export namespace SimpleFINReturn {
  export interface Org {
    domain: string;
    name: string;
    "sfin-url": string;
    url: string;
    id: string;
  }

  export interface Holding {
    id: string;
    created: number;
    currency: string;
    cost_basis: string;
    description: string;
    market_value: string;
    purchase_price: string;
    shares: string;
    symbol: string;
  }

  export interface Transaction {
    id: string;
    posted: number;
    amount: string;
    description: string;
    transacted_at?: number;
    pending?: boolean;
    extra?: {
      category?: string;
    };
  }

  export interface Account {
    org: Org;
    id: string;
    name: string;
    currency: string;
    balance: string;
    "available-balance": string;
    "balance-date": number;
    transactions: Transaction[];
    holdings: Holding[];
    extra: any;
  }

  export interface FinancialData {
    errors: string[];
    accounts: Account[];
    "x-api-message"?: string[];
  }
}
