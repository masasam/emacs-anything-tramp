# anything-tramp [![melpa badge][melpa-badge]][melpa-link] [![melpa stable badge][melpa-stable-badge]][melpa-stable-link]

Tramp with anything interface

## Screenshot

    M-x anything-tramp  

![anything-tramp1](image/image1.png)

Display server list from your ~/.ssh/config in anything interface  

![anything-tramp2](image/image2.png)

Filter by anything  

![anything-tramp3](image/image3.png)

You can connect your server with tramp  

![anything-tramp4](image/image4.png)

Selecting the list with sudo will lead to the server as root  

![anything-tramp5](image/image5.png)

You can edit your server's nginx.conf on your emacs!  

![anything-exit](image/exit.png)

When you finish editing nginx.conf you clean the tramp buffer with `tramp-cleanup-all-buffers` command.  
Since I can not remember `tramp-cleanup-all-buffers` command I set a defalias called `exit-tramp`.  

## Requirements

- Emacs 24 or higher
- anything 1.0 or higher

## Installation

You can install `anything-tramp.el` from [MELPA](http://melpa.org) with package.el
(`M-x package-install anything-tramp`).

## Sample Configuration

	(setq tramp-default-method "ssh")
    (defalias 'exit-tramp 'tramp-cleanup-all-buffers)
    (define-key global-map (kbd "C-c s") 'anything-tramp)

If the shell of the server is zsh it is recommended to connect with bash.  

    (eval-after-load 'tramp '(setenv "SHELL" "/bin/bash"))

[melpa-link]: http://melpa.org/#/anything-tramp
[melpa-badge]: http://melpa.org/packages/anything-tramp-badge.svg
[melpa-stable-link]: http://stable.melpa.org/#/anything-tramp
[melpa-stable-badge]: http://stable.melpa.org/packages/anything-tramp-badge.svg
