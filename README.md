# server-report

Hardware health checks for our Hetzner servers. Alerts go to Slack **#notifications** via [healthchecks.io](https://healthchecks.io).

Every hour each server runs `server-report` from cron and sends a report to healthchecks.io:

- no problems → **OK** ping
- any problem → **FAIL** ping, with the details in the body

healthchecks.io posts to Slack when a server changes state (OK → FAIL, and back), and when a server **stops reporting** (server down, network gone, cron broken).

## What it checks

| Check | Alert when |
|---|---|
| Software RAID (`/proc/mdstat`) | an array is missing a disk (`[_U]`) |
| SMART health | `smartctl` reports the disk as failing |
| SSD wear (NVMe `Percentage Used`) | ≥ 90% |
| Media errors (NVMe) | > 0 |
| Filesystems | ≥ 90% full |
| ECC RAM (if the server reports it) | any uncorrectable error, or ≥ 10 corrected errors since boot |

Each report also includes, for every disk, its model, serial, wear, temperature and error count, plus whether ECC is reported. You can see this in the healthchecks.io log of each check.

A disk that has disconnected completely doesn't show up in SMART. The RAID check catches it instead, because the array becomes degraded.

## Install on a server

```bash
curl -fsSL https://raw.githubusercontent.com/cnj-digital/server-report/main/install.sh | sudo bash -s PINGKEY
```

`PINGKEY` is the project ping key from healthchecks.io → Project Settings. The install:

- installs `smartmontools` if missing
- installs the script to `/usr/local/bin/server-report`
- saves the ping key to `/etc/server-report.key`
- adds the cron job `/etc/cron.d/server-report` (every 15 minutes, as root)
- sends a first report

On its first report, a server gets its own check in healthchecks.io, named after its hostname. **After installing, set that check to Period 15 min, Grace 1 h.** Otherwise a dead server may only be reported much later.

## Update

Run the install line again. Cron runs the installed copy and does not download the script on every run. That's deliberate: write access to this repo shouldn't mean root on every server.

## Test / run by hand

```bash
sudo /usr/local/bin/server-report
```

Then check the server's entry in healthchecks.io.

## Uninstall

```bash
sudo rm /usr/local/bin/server-report /etc/server-report.key /etc/cron.d/server-report
```

Then delete the check in healthchecks.io, or it will alert that the server stopped reporting.

## Accounts

- healthchecks.io: company account `<email>`, Slack integration → #notifications
- Slack: #notifications
