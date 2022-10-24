# Filehost Server

Simple filehosting server configuration that requires very little manual setup.
Built to only allow the server owner to upload files but anyone with the link can download the files.

## Modules

### [Single PHP Filehost](https://github.com/Rouji/single_php_filehost)

For uploading and sharing files with others

### Caddy

For securing your connection over HTTPS/TLS and add basic authentication

### Cloudflare Tunnel (Cloudflared)

For securing your local router, preventing your IP from being exposed and eliminating the need for opening up a port in your router

## Start Server

Once everything is set up you can use `sudo docker compose up` to start the server. I'd recommend doing this the first time so you can see potential error messages. Once it's working, I'd recommend only running it as a systemd service. Follow the steps at the end to set that up.

## Scripts

- `./caddy.sh` lets you quickly reload your Caddy config if you made changes to the Caddyfile by running `./caddy reload`.
- `./update.sh` will force rebuild (and update) all containers.
- `./configure-service.sh` will set up a systemd service that will start the server whenever the system boots.

## Setup

### Folder Structure

Make sure your folder structure looks like this before you do anything else. If it doesn't, create the missing folders

```
Caddy/
  config/
  data/
  site/

Cloudflared/
  config/

Filehost/
  files/
```

### Cloudflare

Make sure you setup Cloudflare with your domain. Log into [cloudflare](https://www.cloudflare.com/) and follow the setup in the domains tab.

You need to setup `cloudflared` once and copy over some files to get the tunnel working. You can follow [this](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/tunnel-guide/local/#set-up-a-tunnel-locally-cli-setup) guide to set it up locally. I'll summarise it here quickly but will skip how to install the `cloudflared` package as that varies by distro.

Run this command to generate required files

```sh
cloudflared tunnel login
```

Then this one to create a tunnel. The name can be anything you want that helps you recognise the server.

```sh
cloudflared tunnel create <NAME>
```

Run this for each of the subdomains, `files.domain.tld` and if you want a way to quickly test if Caddy is working, you can also add `ping.domain.tld`. Replace `domain.tld` with your own domain. You can use different subdomains by changing them in the `.env` file.

```sh
cloudflared tunnel route dns <UUID or NAME> <hostname>
```

An example of the command above could be

```sh
cloudflared tunnel route dns example-pc ping.example.com
```

Copy the credentials file to `./Cloudflared/config/` (it should be stored in `~/.cloudflared/`). Example:

```sh
sudo cp ~/.cloudflared/<UUID>.json ~/Documents/media-server/Cloudflared/config/
```

The name of the credentials file above is the UUID of the tunnel, put that in the `.env` file as instructed in the next step.

### Environment Variables

Create a `.env` file based on the content in `.env.example`. The example will include comments that will help with what value is needed there.

The CF_API_TOKEN requires you to follow [this guide](https://samjmck.com/en/blog/using-caddy-with-cloudflare/). You can either follow the second step or the third step. If you follow the second step, you can skip the part about downloading some Caddy packages as the Dockerfile handles that already. Just skip to the part about generating an API token

### Passwords

**Use a strong password!!** A strong password is one that is long, not one that uses lots of weird symbols.<br>
You can generate a password using `./caddy.sh hash-password --plaintext <password>` when the server is running. Restart the server after you've changed the default password.

### Fileshare

To delete a file you need to use the commandline with sudo priviledges. Example:

```sh
sudo rm ./files/Gn85SD4zzJdafRxgVd6ymvZxMzaquw.png
```

In case you want to make sure that when you delete a file, it won't be possible to fetch it anymore, you have to adjust Cloudflare caching rules. The way I set it up, it'll only cache stuff that is fetched through AniList, but otherwise require fetching directly, meaning it'll be gone the moment you delete it. If you don't do this, it'll take up to 4 hours by default until the cache is considered stale.

Expression:
`(http.host eq "files.domain.tld" and not http.referer contains "anilist.co")`

then set cache status to "Bypass cache"

### Make It Start With the System

Create a file `filehost.service` based on the `filehost.service.example` file. Then run `./configure-service.sh`.
