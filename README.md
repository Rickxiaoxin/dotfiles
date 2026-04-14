# Dotfiles使用教程

## Linux

使用 GNU Stow 管理系统配置

### 安装

```bash
cd dotfiles
stow -t ~ .
```

### 卸载

```bash
cd dotfiles
stow -D -t ~ .
```

## Windows

windows系统下使用Windows Terminal，考虑其profiles配置，选择手动管理。
