## Vikunja podman setup

A way to automate the process of launching your vikunja instance with podman and systemd. Currently supports only postgres as a db.

### Requirements:

- just
- systemd
- podman

Currently the installation directory is hard-coded to `/opt/vikunja`. Service files get installed into `~/.config/containers/systemd`.

### How-to:

Clone the repo and cd into it:

```sh
git clone https://github.com/pinklifeart/vikunja-pod.git
cd vikunja-pod
```

Create `/opt/vikunja` and grant ownership to current user:

```sh
sudo mkdir -p /opt/vikunja
sudo chown $(whoami):$(whoami) /opt/vikunja
```

(Optional) Set a `URL` environment variable containing FQDN/ip that the instance will be available at. If not set, defaults to `127.0.0.1`:

```sh
export URL=vikunja.example.com
```

You can also change it manually after the installation by editing the `VIKUNJA_SERVICE_PUBLICURL` variable in `/opt/vikunja/.env.server` and restarting the pod.

To install and automatically run the services use `just install_and_run`. It will automatically:

1. Create postgres and files directories in `/opt/vikunja`.
2. Download a sample config file into `/opt/vikunja`.
3. Generate env files into `/opt/vikunja`.
4. Copy service files to `~/.config/containers/systemd`.
5. Reload user systemd.
6. Launch the pod.

If you want to edit the config before launching, you can install the files first with `just install`, edit the files, then run `just start_services`. You can find available options in [Vikunja docs](https://vikunja.io/docs/config-options/).

To check for other available commands use `just` without arguments:

```sh
$ just
Available recipes:
    clean                # Cleans up installation_path and service files. Careful, it will remove your data.
    copy_service_files   # Copies service files to $HOME/.config/containers/systemd
    generate_env_files   # Generates .env.server and .env.db into selected installation directory with environment variables for the containers
    install              # Installs necessary configuration files without starting the pod
    install_and_run      # Installs configuration files and starts the pod
    remove_data          # Removes everything from the installation_path.
    remove_service_files # Removes service files from $HOME/.config/containers/systemd
    start_services       # Reloads systemd user daemon and starts the pod
    stop                 # Stops the pod
```

It's recommended to run Vikunja behind a reverse-proxy, like nginx, caddy or others, but that's out of scope of this repo. Thankfully, you can find that info in [the docs](https://vikunja.io/docs/reverse-proxy/).

Otheriwse you might need to open port 3456 in your firewall settings, for that check your firewall solution's manual.

### Roadmap (in no particular order):

- Figure out postgres changing dir ownership
- Add other db options
