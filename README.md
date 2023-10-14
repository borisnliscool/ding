
![Ding logo](https://github.com/borisnliscool/ding/assets/60477582/45732f6e-0616-4ce0-87c6-ddc7501ee6fb)

<h2 align="center"><a href="https://docs.boris.foo/ding">For installation, configuration and usage visit the docs</a></h2>

For support please visit my [support discord](https://boris.foo/discord), or make an issue. Pull requests are welcome.

Ding is a utility for protecting FiveM events by utilizing random nonces to prevent replay attacks, thereby stopping cheaters from triggering your server events.

**Important Note:** While Ding provides protection against most cheating attempts, it is not a fix-all solution. Very experienced cheaters may still find ways to pass its security measures. That said, it's way better than not using it, and it'll stop pretty much any skid.


## Explanation

Ding overwrites the default `TriggerServerEvent`, `AddEventHandler` and `RegisterServerEvent` functions to implement nonces. 
A nonce is a partially random number generated through a function that relies on a seed and the previous nonce. The server generates the seed and shares it with the client upon connection. Each time an event is triggered, it requires a nonce. Both the server and the client independently compute this nonce using the seed and the previous nonce to ensure they arrive at the same value. If the calculated nonces match, the event proceeds as expected. If there's a mismatch, the event is canceled because an incorrect nonce was provided.

## License

Distributed under the GPL-3.0 License. See [LICENSE](https://github.com/borisnliscool/bnl-housing/blob/main/LICENSE) for more information.
