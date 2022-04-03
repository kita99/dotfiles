# KITA's Amazeballs (.)files

Lo and behold the golden files, legend says that on the 7th day God did not rest, he actually pulled out his magnificent Thinkpad running
TempleOS and hacked away for many hours... the result of that historical session laid the foundation for this repository.

# Bootstrap

The bootstrap script will quickly install all the essential packages and clone this repo.

```
$ curl -sfL https://raw.githubusercontent.com/kita99/dotfiles/master/bootstrap.sh | bash -
```


# Configure

The configure script configures defaults and uses the wonderful GNU Stow utility to symlink
everything into the right place.

```
$ curl -sfL https://raw.githubusercontent.com/kita99/dotfiles/master/configure.sh | bash -
```

# Setup files

Make sure this repo is in `~/dotfiles`.
To setup manually on a one-by-one basis do:

`$ stow <something>`

or if you want to install everything use the setup scripts:

`$ ./setup_<os>.sh`
