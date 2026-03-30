# Sample Application with Go and Gin

This sample is running on: https://go-gin.is-easy-on-scalingo.com/

## Deploy via Git

Create an application on https://scalingo.com, then:

```shell
scalingo --app my-app git-setup
git push scalingo master
```

And that's it!

## Deploy via One-Click

[![Deploy to Scalingo](https://cdn.scalingo.com/deploy/button.svg)](https://my.scalingo.com/deploy)

## Running Locally

```shell
docker-compose up
```

The app listens by default on the port 3000 or the one defined in the `PORT`
environment variable.

## DNS Debug Cron

This project now uses the official Scalingo Scheduler with a `cron.json` file
at the repository root:

```json
{
  "jobs": [
    {
      "command": "*/10 * * * * /bin/bash ./scripts/debug_dns_allowlist.sh"
    }
  ]
}
```

The schedule respects the Scalingo Scheduler limitation documented by Scalingo:
the minimum interval is 10 minutes, and schedules are evaluated in UTC.

The job executed by the scheduler only probes domains you explicitly provide.
It logs:

- `/etc/resolv.conf`
- Scalingo runtime context such as `APP`, `CONTAINER`, `HOSTNAME`,
  `SCALINGO_PRIVATE_HOSTNAME`, `SCALINGO_PRIVATE_NETWORK_ID`, and `REGION_NAME`
- `dig` output when available
- `getent ahosts` output when available
- `nslookup` output when available

Available environment variables:

```shell
SCALINGO_APP=test-secnum
DNS_DEBUG_ALLOWLIST_FILE=./dns-allowlist.txt
DNS_DEBUG_CLI_TABLE_FILE=./private-networks-domain-names.txt
DNS_DEBUG_DOMAINS=db.internal.example,redis.internal.example
```

Local test:

```shell
cp dns-allowlist.txt.example dns-allowlist.txt
./scripts/debug_dns_allowlist.sh
```

You can also inject the domains directly through an environment variable:

```shell
DNS_DEBUG_DOMAINS="db.internal.example redis.internal.example" ./scripts/debug_dns_allowlist.sh
```

Or paste the output of `scalingo -a test-secnum private-networks-domain-names`
into `private-networks-domain-names.txt`; the script extracts the `DOMAIN NAME`
column automatically:

```shell
cp private-networks-domain-names.txt.example private-networks-domain-names.txt
./scripts/debug_dns_allowlist.sh
```

## Trigger Scalingo Deployments In A Loop

The repository also includes a helper script that waits a random amount of
time, then triggers a real manual deployment through the Scalingo CLI:

```shell
chmod +x scripts/simulate_scalingo_deployments.sh
DEPLOY_BRANCH=main MIN_WAIT_SECONDS=30 MAX_WAIT_SECONDS=180 ./scripts/simulate_scalingo_deployments.sh test-secnum
```

By default the loop runs forever. Set `DEPLOY_COUNT` if you want a fixed number
of deployments:

```shell
DEPLOY_BRANCH=main DEPLOY_COUNT=5 MIN_WAIT_SECONDS=10 MAX_WAIT_SECONDS=30 ./scripts/simulate_scalingo_deployments.sh test-secnum
```

If you want the CLI to follow deployment logs, enable `FOLLOW_DEPLOY=true`:

```shell
DEPLOY_BRANCH=main FOLLOW_DEPLOY=true ./scripts/simulate_scalingo_deployments.sh test-secnum
```
