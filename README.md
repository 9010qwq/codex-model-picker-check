6.2 发布了，我的桌面模型菜单却还没收到消息

一次 Windows Codex / Work 模型菜单排查记录，附可自行运行的 PowerShell 检查工具。

![6.2 去哪了？概念封面](assets/cover.png)

先读「文章-可直接发布.txt」了解起因、经过和结果；自己动手请读「使用说明.txt」。

Inspect-ModelCatalog.ps1 默认离线只读，仅检查两份模型缓存的模型名、可见状态、记录版本与时间，不读取登录文件、密钥或聊天记录。

Refresh-ModelCatalog.ps1 是可选步骤，只有显式添加 -RunRefresh 才调用当前 Windows 应用包自带的 debug models；可能联网并更新目录缓存。

不需要 Dot、API key 或管理员权限。使用 GitHub 的 Code → Download ZIP 下载后，解压并在 Windows PowerShell 中进入解压目录，按使用说明运行。tests/ 是虚构数据自测，测试范围见「测试记录.txt」。

这次菜单已经恢复，触发恢复的具体步骤尚未定位。这里分享的是可复查的排查路径，不是保证成功的一键修复。文章中的既有排查发生在用户 Windows 电脑上；本包在云端整理并用虚构数据测试。

许可：MIT 仅适用于 .ps1 代码和 tests/ 下的虚构测试数据。文章、说明与封面不纳入 MIT，不另行授予开放内容许可；相关权利归各自权利人。封面是基于参考形象生成的概念插画，不是真实应用截图。详见 LICENSE.txt 与「图片说明.txt」。

