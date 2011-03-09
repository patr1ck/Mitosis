Mitosis
=======

Mitosis is a Google Chrome extension and small mac app that make it easier to clone source from github.com repositories. It adds a "Clone Now" link to github project pages which uses a custom URL scheme to open a mac app on your machine that fires up git, does the clone in the background, and opens the new directory when done.

TODO
----
*	Remove the octocat image in place of one that's not copyrighted.
*	Pack the Chrome extension.
*	Make a Safari extension.
*	Substatus bar that echos the last line of stdout
*	Clean up memory management in MitosisCloneHandler. We're probably leaking everywhere.
*	Better error handling / alerts