# tmux-vault

> Access your vault cubbyhole login items within tmux!

This plugin allows you to access your vault cubbyhole items within tmux, using vault's CLI.

## Requirements

This plugin relies on the following:

- [Vault CLI](https://www.vaultproject.io/downloads)
- [fzf](https://github.com/junegunn/fzf)
- [jq](https://stedolan.github.io/jq/)

## Key bindings

In any tmux mode:

- `prefix + u` - list login items in a bottom pane.

## Install

### Using [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm) (recommended)

1. Add plugin to the list of TPM plugins in `.tmux.conf`:

    ```
    set -g @plugin 'dbd/tmux-vault'
    ```

2. Hit `prefix + I` to fetch the plugin and source it. You should now be able to use the plugin.

### Manual Installation

1. Clone this repo:

    ```console
    $ git clone https://github.com/dbd/tmux-vault ~/some/path
    ```

2. Source the plugin in your `.tmux.conf` by adding the following to the bottom of the file:

    ```
    run-shell ~/some/path/plugin.tmux
    ```

3. Reload the environment by running:

    ```console
    $ tmux source-file ~/.tmux.conf
    ```

## Usage

On the initial use you will be prompted to login if you don't have a `~/.vault-token file`. Once
the file is created you will have no keys in the cubbyhole for that token. Credentials can be added
by running the following. Where `ldap` is the key for the account, `username` is the `ldap` username
and `password` is the ldap password. `username` is optional but `password` is a reqired field.

```
read -s pass
vault write cubbyhole/ldap username=jdoe password=$pass
```

## Configuration

Customize this plugin by setting these options in your `.tmux.conf` file. Make sure to reload the
environment afterwards.

#### Changing the default key-binding for this plugin

```
set -g @vault-key 'x'
```

Default: `'u'`

#### Setting the signin subdomain

```
set -g @vault-url 'https://vault.example.com'
```

Default: `'https://vault/'`

#### Setting the default vault

```
set -g @vault-login-method 'ldap'
```

Default: `'userpass'`

#### Copy the password to clipboard

By default, the plugin will use `send-keys` to send the selected password to the targeted pane. By
setting the following, the password will be copied to the system's clipboard, which will be cleared
after 30 seconds.

```
set -g @vault-copy-to-clipboard 'on'
```

Default: `'off'`


## Prior art

Also see:

- [tmux-1password](https://github.com/yardnsm/tmux-1password)

---

## License

MIT © [Yarden Sod-Moriah](http://yardnsm.net/)
