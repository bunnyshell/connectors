# About Xata

[Xata](https://xata.io/) is a serverless data platform which offers autoscaling, branching, and bottomless storage.

Xata's [branching feature](https://xata.io/docs/getting-started/workflow#branching-your-database) is particularly well-suited for development and ephemeral environments, as you can now instantly have an isolated database (or more) for your environment.

# Bunnyshell <> Xata connector

Bunnyshell can leverage Xata to create database branches when an Environment is deployed, and have them destroyed when an Environment is deleted from Bunnyshell.

**Effectively, this means being able to create ephemeral data storage services (aka databases) for ephemeral environments.**

Xata can be connected to Bunnyshell by adding a `GenericComponent` within the Environment.

## Pre-requisites

You will need to supply **from Xata**:
- the [API token](https://app.xata.io/settings); read more in [Xata's documentation](https://xata.io/docs/getting-started/installation#managing-api-keys)
- the Workspace slug, visible in the URL address bar on the dashboard, right after logging in: `https://app.xata.io/workspaces/{workspace}` (it consists of a slug part and ends in an 6-char alphanumeric ID)
- the database name and region, visible on the database card in the dashboard, in the database selector or in the URL address bar upon entering the database screen

## How to add the Connector

You can add the code either from the UI, from the **Add Component** button, or manually.

After adding the code to the Configuration editor, make sure to replace the placeholders:
- `[[XATA_API_TOKEN]]` (see Pre-requisites)
- `[[XATA_WORKSPACE]]` (see Pre-requisites)
- `[[XATA_REGION]]` (see Pre-requisites)
- `[[XATA_DATABASE_NAME]]` (see Pre-requisites)

## How to use the Connector

In the backend Component(s) which use the database, you will need to set the host exported from the Xata Component as an environment variable.

```
components:
    - 
        name: backend
        kind: Application
        ...
        dockerCompose:
            environment:
                XATA_API_KEY: '{{ components.xata-database.exported.API_TOKEN }}'
                XATA_DATABASE_URL: '{{ components.xata-database.exported.DB_HOST }}'
                XATA_BRANCH: '{{ components.xata-database.exported.TARGET_BRANCH }}'
                ...
```

### Xata branch name

You can name your Xata branches as you like, as long as they're unique. The name can be passed to the Xata Component as an environment variable called `TARGET_BRANCH`.

For example, you could use `TARGET_BRANCH` as `bns-{{ env.unique}}`.  
`{{ env.unique}}` is an unique identifier for an Environment in Bunnyshell and will be interpolated in the actual value of the Environment variable, resulting in something similar to `bns-4wgffz`.

### Multiple Xata instances in an Environment

You can use as many Xata databases as you need in a single Environment.  
Just make sure the component names and the `TARGET_BRANCH` have distict values.


&nbsp;

📖 Find out more about the [Xata Connector](https://documentation.bunnyshell.com/docs/connectors-xata-dataplatform) from the documentation.