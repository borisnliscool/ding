# Ding

For support please visit my [support discord](https://boris.foo/discord), or make an issue. Pull requests are welcome.

Ding is a utility for protecting FiveM events by utilizing random nonces to prevent replay attacks, thereby stopping cheaters from triggering your server events.

**Important Note:** While Ding provides valuable protection against most cheating attempts, it is not a fix-all solution. Very experienced cheaters may still find ways to circumvent its security measures. Therefore, it is essential to implement additional layers of protection and security in your code to ensure the integrity of your server.

## Usage

Using Ding is straightforward. Simply import Ding into every script for which you want to protect events by including the following line of code:

1. **Resource Load Order**: Make sure to start the Ding resource before all other resources in your server configuration. This ensures that Ding is active and ready to protect your events.

2. **Import Order**: In your `fxmanifest.lua`, ensure that the `shared_script "@ding/import.lua"` line is the first script imported. This is crucial for Ding to set up its protection measures correctly.

Here's how you should structure your `fxmanifest.lua`:

```lua
fx_version '...'
game '...'

-- Ensure that Ding is loaded first
shared_script '@ding/import.lua'

client_scripts { ... }

server_scripts { ... }
```
