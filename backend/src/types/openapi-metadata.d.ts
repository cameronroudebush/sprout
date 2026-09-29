declare module "@backend/metadata.js" {
  const metadata: () => Promise<Record<string, any>>;
  export default metadata;
}
