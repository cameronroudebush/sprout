/** Represents an address going into zillow to lookup it's ID */
interface ZillowAddress {
  street: string;
  city: string;
  state: string;
  zipcode: string;
  latitude?: number;
  longitude?: number;
}
