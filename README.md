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

```powershell
cd dotfiles
. .\syncWindows.ps1
```

### 安装

可先测试查看运行结果，无实际操作:
```powershell
Sync-DotfilesFromRepo -DryRun
```

执行实际操作:
```powershell
Sync-DotfilesFromRepo
```

### 卸载

可先测试查看运行结果，无实际操作:
```powershell
Unlink-DotfilesFromRepo -DryRun
```

执行实际操作:
```powershell
Unlink-DotfilesFromRepo
```
