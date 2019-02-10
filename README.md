# [IndieWeb][] Helpers for Elixir

This library provides common logic for handling [IndieWeb][] actions and facades
in Elixir applications. This project is more commonly used in [Koype][],
[Fortress][] and other IndieWeb projects by [Jacky Alcine][jacky].

## Components

The following is a list of components that are intended to be exposed by this
library. Every component is meant to work abstractly from HTTP and caching tools
so you can bring what you prefer to work with.

* [ ] Management for [IndieAuth tokens][1]
* [ ] Metadata for common scopes used in the IndieWeb
* [ ] Extraction of
 * [ ] [App information][h-x-app]
 * [ ] [Authorship][authorship]
 * [ ] [Post Type Discovery][ptd]
* [ ] [Webmentions][wm]
 * [ ] [Sending][wm-send]
 * [ ] [Receiving][wm-rec]

[indieweb]: https://indieweb.org
[koype]: https://koype.net
[fortress]: https://fortress.black.af
[jacky]: https://jacky.wtf
[h-x-app]: https://indieweb.org/h-x-app
[authorship]: https://indieweb.org/authorship
[ptd]: https://indieweb.org/post-type-discovery
[wm]: http://webmention.net/
[wm-send]: https://www.w3.org/TR/webmention/#sending-webmentions
[wm-rec]: https://www.w3.org/TR/webmention/#receiving-webmentions
[1]: https://indieauth.spec.indieweb.org/#token-endpoint-0
