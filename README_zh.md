# Windows 开发环境引导

用几个脚本把一台全新的 Windows 机器变成可用的开发环境：安装
PowerShell 7、安装 Scoop、再按清单恢复你的工具链。

## 快速开始

在新机器上打开 **Windows PowerShell 5.1**（Windows 自带），运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\setup.ps1
```

这会依次执行：

| 脚本 | 作用 |
| --- | --- |
| `scripts/install-pwsh.ps1` | 通过 winget 安装 PowerShell 7（没有 winget 时回退到 MSI）。 |
| `scripts/install-scoop.ps1` | 缺少 git 时先装 git，再用官方安装器装 Scoop。 |
| `scripts/restore-dev-env.ps1` | 按 `config/dev-env.json` 添加 Scoop bucket 并安装软件包。 |

每个脚本都**幂等**：可安全重跑，已安装的会自动跳过。

## 单独执行

也可以单独运行某个脚本：

```powershell
# 只装 PowerShell 7
.\scripts\install-pwsh.ps1

# 只装 Scoop（需要 git）
.\scripts\install-scoop.ps1

# 只按清单恢复工具
.\scripts\restore-dev-env.ps1
```

## 自定义你的环境

编辑 `config/dev-env.json`：

- `buckets` —— 需要额外添加的 Scoop bucket（`main` 会自动添加，无需列出）。
- `apps` —— 要安装的 Scoop 软件包名，每行一个，按顺序安装。

如果需要维护多份清单，可以指向不同的文件：

```powershell
.\scripts\restore-dev-env.ps1 -Manifest .\config\dev-env-minimal.json
```

## 环境要求

- Windows 10/11，且带 **winget**（较新版本默认自带）。如果没有 winget，
  `install-pwsh.ps1` 会回退到下载 MSI，`install-scoop.ps1` 则会提示你手动安装 git。
- 需要联网。安装机器级工具时可能会弹出 UAC 授权提示。
