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
```

在WindowsMappings.ps1文件中可添加配置文件路径。
可在运行脚本中增加`-DryRun`，测试查看运行结果，但不实际运行。
```powershell
.\CreateSymlinks.ps1 -DryRun
.\RemoveSymlinks.ps1 -DryRun
```

### 安装

执行实际操作:
```powershell
.\CreateSymlinks.ps1
```

### 卸载

执行实际操作:
```powershell
.\RemoveSymlinks.ps1
```
