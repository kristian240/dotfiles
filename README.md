# My dotfiles setup

1. Clone the repo and move all content to `~/` folder

2. Install all packages

```bash
xargs brew install < .dotfiles/.brewlist
```

3. Add oh-my-zsh

```bash
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
