# Neon

[Neon](https://neon.tech/) is a serverless Postgres database which offers autoscaling, branching, and bottomless storage.

Neon's [branching feature](https://neon.tech/branching) is particularly well-suited for development and ephemeral environments, as you can now instantly have an isolated database (or more) for your environment.

# Bunnyshell connector

Bunnyshell can leverage Neon databases by adding a `GenericComponent` within the Environment.

## Pre-requisites

You will need to supply from Neon:
- the [API token](https://console.neon.tech/app/settings/api-keys); read more in [Neon's documentation](https://neon.tech/docs/manage/api-keys)
- the Project ID; go to Home > {{ YOUR_PROJECT }} > Settings and get the `Project ID`
- the source Branch ID; go to Home > {{ YOUR_PROJECT }} > Branches > {{ YOUR_SOURCE_BRANCH }} and get the `ID` (it starts with `br-`)

## How to add the Connector

You can add the code either from the UI, from the **Add Component** button, or manually.

After adding the code to the Configuration editor, make sure to replace the placeholders:
- `[[BNS_COMPONENT_NAME]]` with your chosen name for the component, eg. `neon-database`
- `[[NEON_API_TOKEN]]` (see Pre-requisites)
- `[[NEON_PROJECT_ID]]` (see Pre-requisites)
- `[[NEON_SOURCE_BRANCH_ID]]` (see Pre-requisites)

## How to use the Connector

In the backend Component(s) which use the database, you will need to set the host exported from the Neon Component as an environment variable.

```
components:
    - 
        name: backend
        kind: Application
        ...
        dockerCompose:
            environment:
                POSTGRES_HOST: '{{ components.<<BNS_COMPONENT_NAME>>.exported.DB_HOST }}'
                ...
```

Example for a component named `neon-database`:
```
POSTGRES_HOST: '{{ components.neon-database.exported.DB_HOST }}'
```

### Neon branch name

You can name your Neon branches as you like, as long as they're unique. The name can be passed to the Neon Component as an environment variable called `TARGET_BRANCH_NAME`.

For example, you could use `TARGET_BRANCH_NAME` as `bns-{{ env.unique}}`.  
`{{ env.unique}}` is an unique identifier for an Environment in Bunnyshell and will be interpolated in the actual value of the Environment variable, resulting in something similar to `bns-4wgffz`.

### Multiple Neon databases in an Environment

You can use as many Neon databases as you need in a single Environment.  
Just make sure the component names and the `TARGET_BRANCH_NAME` have distict values.


&nbsp;

📖 Find out more about the [Neon Connector](https://documentation.bunnyshell.com/docs/connectors-neon-database) from the documentation.