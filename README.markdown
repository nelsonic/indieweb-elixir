# [IndieWeb][] Helpers for Elixir

![Maintenance](https://img.shields.io/maintenance/yes/2019.svg?style=plastic)
[![Build Status](https://ci.jacky.wtf/api/badges/indieweb/elixir/status.svg?ref=refs/heads/develop)](https://ci.jacky.wtf/indieweb/elixir)
![Hex.pm](https://img.shields.io/hexpm/l/indieweb.svg?style=plastic)
![Liberapay patrons](https://img.shields.io/liberapay/patrons/koype.svg?style=plastic)
![Liberapay receiving](https://img.shields.io/liberapay/receives/koype.svg?style=plastic)
[![Hex.pm](https://img.shields.io/hexpm/v/indieweb.svg?style=plastic)](https://hex.pm/packages/indieweb)
[![Hex.pm](https://img.shields.io/hexpm/dt/indieweb.svg?style=plastic)](https://hex.pm/packages/indieweb)

This library provides common logic for handling [IndieWeb][] [building blocks][] 
in Elixir applications. This project is more commonly used in [Koype][],
[Fortress][] and other IndieWeb projects by [Jacky Alcine][jacky].

## Components

The following is a list of components that are intended to be exposed by this
library. Every component is meant to work abstractly from HTTP and caching tools
so you can bring what you prefer to work with.

* [x] Management for [IndieAuth tokens][1]
* [ ] Meta data for common scopes used in the IndieWeb
* [ ] Extraction of
 * [ ] [App information][h-x-app]
 * [ ] [Post Type Discovery][ptd]
* [x] [Webmentions][wm]
 * [x] [Sending][wm-send]
 * [x] [Receiving][wm-rec]

## Contributing

`elixir` is a free and open source software project. For guidelines on contributing to the project
as a developer, artist, translator, or however you wish to offer your time and skills, please
read the [`CONTRIBUTING`][contrib] document (_TODO_).

Participation in this project means adhering to our [Code of Conduct][coc].

## License

`indieweb` is licensed under the AGPLv3. The complete license text is available in the repository [here][license].

## Financial Support

This project is used in publicly open projects by [black.af](https://black.af). Become a backer 
on [Patreon][patreon] or [Liberapay][liberapay] to support this project financially. _Anything_ helps!

[indieweb]: https://indieweb.org
[koype]: https://koype.net
[fortress]: https://fortress.black.af
[jacky]: https://jacky.wtf
[h-x-app]: https://indieweb.org/h-x-app
[ptd]: https://indieweb.org/post-type-discovery
[wm]: http://webmention.net/
[wm-send]: https://www.w3.org/TR/webmention/#sending-webmentions
[wm-rec]: https://www.w3.org/TR/webmention/#receiving-webmentions
[1]: https://indieauth.spec.indieweb.org/#token-endpoint-0
[contrib]: ./CONTRIBUTING.markdown
[coc]: ./CODE_OF_CONDUCT.markdown
[building blocks]: http://indieweb.org/building-blocks
[license]: ./LICENSE
[patreon]: http://patreon.com/jackyalcine
[liberapay]: http://liberapay.com/jackyalcine/
