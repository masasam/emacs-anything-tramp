# anything-tramp

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



## Sample Configuration

	(setq tramp-default-method "ssh")
    (defalias 'exit-tramp 'tramp-cleanup-all-buffers)
    (define-key global-map (kbd "C-c s") 'anything-tramp)
