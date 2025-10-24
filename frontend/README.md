<p align="center">
  <img width="75%" src="https://media.githubusercontent.com/media/cameronroudebush/sprout/master/frontend/assets/logo/color-transparent.png">
  <br></br>
  <h1>Frontend</h1>
</p>

# API Client Generation

Since the backend is nice enough to provide an [`openapi-spec.json`](../backend/README.md#open-api-spec), we can use the following command to just generate the clients as needed by our frontend:

```sh
npm run api:generate:dart
```

This will then place the clients appropriately in the frontend.

**Note:** This must be executed in the root directory of the workspace.
