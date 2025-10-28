<p align="center">
  <img width="75%" src="https://media.githubusercontent.com/media/cameronroudebush/sprout/master/frontend/assets/logo/color-transparent.png">
  <br></br>
  <h1>Backend</h1>
</p>

# Database Migrations

To generate a database migration, use the following command:

```sh
npm run migrate --name=MY_NAME_HERE
```

**Note**: For PR's, you may only have one migration and it must be named relevantly.
**Note**: Due to webpacks compilation, you'll need to restart the backend after running the migration command so it knows the file exists.

# Open API Spec

To generate an `openapi-spec.json`, use the following command:

```sh
npm run export:api:spec
```

**Note**: You'll want to run this whenever you make changes to the backend client. This will allow us to update the dart client and any documentation required.
