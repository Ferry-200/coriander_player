# desktop_lyric: Coriander Player 的桌面歌词组件

- [x] 支持普通歌词
- [x] 自定义歌词样式（字体大小、字体颜色）
- [x] 基本的播放控制（上一曲、暂停/播放、下一曲）
- [x] 主动退出
- [x] 跟随播放器的主题（可选）
- [x] 显示正在播放的曲目的基本信息

自定义字体颜色有三种情况：
1. 如果已经指定颜色，在取消指定颜色前不会跟随播放器主题色变化
2. 在指定颜色的情况下，再次点击被选中的颜色，会取消指定颜色。颜色继续跟随播放器变化。
3. 在指定颜色的情况下，点击其他颜色，指定颜色更改为选择的颜色。在取消指定颜色前不会跟随播放器主题色变化

这个桌面歌词组件也可以被其他音乐播放器使用。

编译方法可以从 Flutter 文档中找到。如果编译 Release，编译产物在 [`build\windows\x64\runner\Release`](build\windows\x64\runner\Release) 目录。整个 Release 目录都是。可以重命名 Release 目录。

使用类似于 `Process.start` 的方法启动编译出来的 `desktop_lyric.exe`，
只需向 `stdin` 发送当前播放曲目和歌词等信息，并监听 `stdout` 获取上一曲、暂停/播放、下一曲和关闭桌面歌词的请求。

启动时可以传递 List<Stirng> args 参数，每个参数也是以 JSON 形式传送
```
args[0]: now playing changed message
args[1]: theme mode changed message
args[2]: theme changed message
```
可以部分传送，但参数的位置不能改变。
合法的参数只能如下：
```
[NowPlayingChangedMessage]
[NowPlayingChangedMessage, ThemeModeChangedMessage]
[NowPlayingChangedMessage, ThemeModeChangedMessage, ThemeChangedMessage]
```

所有消息类型定义在 [`lib/message.dart`](lib/message.dart)。你需要以 JSON 形式通过 `stdin` 发送给该组件。构造方式可以通过 `toMap` 了解。各种消息的作用和发送时机都已在注释中标明。错误的消息会被完全忽略。