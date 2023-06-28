# About PlanetScale

[PlanetScale](https://planetscale.com/) is a serverless MySQL database which offers autoscaling, branching, and bottomless storage.

PlanetScale's [branching feature](https://planetscale.com/docs/concepts/branching) is particularly well-suited for development and ephemeral environments, as you can now instantly have an isolated database (or more) for your environment.

# Bunnyshell <> PlanetScale connector

Bunnyshell can leverage PlanetScale to create database branches when an Environment is deployed, and have them destroyed when an Environment is deleted from Bunnyshell.

**Effectively, this means being able to create ephemeral MySQL databases for ephemeral environments.**

PlanetScale can be connected to Bunnyshell by adding a `GenericComponent` within the Environment.

## Pre-requisites

You need to create a Service token **in PlanetScale**, from _Settings_ -> _Service tokens_; read more in [PlanetScale's documentation](https://planetscale.com/docs/concepts/service-tokens). From the _Database access_ section, you need to add:
  - read_database
  - create_branch
  - read_branch
  - delete_branch
  - connect_branch
  - 
Please keep both the `ID` and the `Token` at hand, as you will need them in Bunnyshell.

You also need to know the Organization name and Database name.

## How to add the Connector

You can add the code either from the UI, from the **Add Component** button, or manually.

After adding the code to the Configuration editor, make sure to replace the placeholders:
- `[[PLANETSCALE_ORGANIZATION]]` (see Pre-requisites)
- `[[PLANETSCALE_DB]]` (see Pre-requisites)
- `[[PLANETSCALE_SERVICE_TOKEN_ID]]` (see Pre-requisites) 
- `[[PLANETSCALE_SERVICE_TOKEN]]` (see Pre-requisites)

## How to use the Connector

In the backend Component(s) which use the database, you will need to set the host exported from the PlanetScale Component as an environment variable.

```
components:
    - 
        name: backend
        kind: Application
        ...
        dockerCompose:
            environment:
                POSTGRES_HOST: '{{ components.planetscale-database.exported.DB_HOST }}'
                ...
```

### PlanetScale branch name

You can name your PlanetScale branches as you like, as long as they're unique. The name can be passed to the PlanetScale Component as an environment variable called `TARGET_BRANCH_NAME`.

For example, you could use `TARGET_BRANCH_NAME` as `bns-{{ env.unique}}`.  
`{{ env.unique}}` is an unique identifier for an Environment in Bunnyshell and will be interpolated in the actual value of the Environment variable, resulting in something similar to `bns-4wgffz`.

### Multiple PlanetScale databases in an Environment

You can use as many PlanetScale databases as you need in a single Environment.  
Just make sure the component names and the `TARGET_BRANCH_NAME` have distict values.


&nbsp;

📖 Find out more about the [PlanetScale Connector](https://documentation.bunnyshell.com/docs/connectors-planetscale-database) from the documentation.
