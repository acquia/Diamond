# Packaging Repositories
Aptly is the default tooling used to create debian repositories.

## GPG Signed Packages
A GPG key is necessary for signing packages. If you generate a new key, you need to include the
`nemesis-ops --gpg-key` flag to use that key. If you don't provide a GPG key, the default key
(`23406CA7`) will be used.

    To generate a new key:
    ````
    gpg --gen-key
    gpg --keyserver pgp.mit.edu --send-keys <KEY ID>
    ````

### Using gpg-agent
If you want to avoid being prompted for your GPG key's password every
time you publish packages, you can run `gpg-agent`, the GPG equivalent
of `ssh-agent`.

1. Install the `gpg-agent` executable -- on the Mac, try `brew install gpg-agent`.
2. Edit `~/.gnupg/gpg-agent.conf`:

        allow-preset-passphrase
        max-cache-ttl 60480000
        default-cache-ttl 60480000
        pinentry-program /usr/local/bin/pinentry
        no-grab

3. Edit `~/.gnupg/gpg.conf`:

        use-agent  # Uncomment this line to enable it

4. Add to your `.bashrc`, or run manually:

        eval $(gpg-agent --daemon --allow-preset-passphrase)
