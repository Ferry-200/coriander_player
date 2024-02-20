# coriander_player

```
[
  {
    "folderPath" : "",
    /// 修改日期。如果该值比新读取的旧，文件夹被修改；和新读取的值相同，文件夹没被修改。
    "lastModified" : secs from UNIX EPOCH,
    "audios" : [
        {
            "title" : "",
            "artist" : "",
            "album" : "",
            "path" : "",
            /// 修改日期。如果该值比新读取的旧，文件被修改；和新读取的值相同，文件没被修改。
            "lastModified" : secs from UNIX EPOCH,
            "creationTime" : secs from UNIX EPOCH
        }, ...
    ],
  }, ...
]
```

第一次启动，建立索引（Rust）：
1. 给定多个扫描路径，逐个读取。
2. 存储文件夹路径和修改日期，扫描目录下所有音乐文件，不扫描子目录下的文件
3. 存储音乐文件的 `title`, `artist`, `album`, `path`, `last modified`, `creation time` ，导出到JSON   
   同时存储 cover 到缓存目录，以 id 命名

常规启动，更新索引（Rust）
1. 从先前存储的索引获取要更新的目录和修改时间
2. 从修改时间判断是否要更新
3. 要更新的直接重新构造AudioFolder并直接覆盖

随后，flutter端读取json索引加载界面

- [x] router
- [x] appShell
- [x] page scaffold
- [x] bass player
- [x] cache cover bytes
- [x] small now playing
- [x] audio page
- [x] lyric parser
- [x] combine lyric lines, separator: "┃"
- [x] horizontal lyric view
- [x] vertical liryc view
- [x] current playlist
- [x] now playing(only, with lyric view, with playlist view)
- [x] artist(separater: 、 or /), album collections
- [x] artist page and artist detail page
- [x] albums page and album detail page
- [x] search page(title -> audios_page, artist -> artist_detail, album -> album_detail). 
      分区域显示三种搜索结果，每种最多显示3个。显示跳转完整搜索结果的按钮，在页面顶部显示标题/艺术家/专辑中包含“搜索词”的项
- [x] folder page
- [x] playlist page
- [x] settings page
- [x] responsive design(width <= 640: small, 640 < width < 1100: medium, width >= 1100: large)
      ~~albums page(2)~~, ~~artists page(2)~~, ~~now playing page(2)~~,
      ~~side nav(3)~~, ~~title bar(3)~~, ~~app shell(2)~~, ~~mini now playing(2)~~
      MediaQuery
- [ ] welcoming

### Last.fm
1. now playing request  
   - send as soon as user play the music.  
   - update now playing   
2. scrobble request  
   - send when user has listen to the music for half the length(at least 15 secs) or for 4 minutes.  
   - record what user listened. the most important. can send it when the music ends.

playlist.json
确保playlist.json里的audio不会混到index.json里

[
   {
      "name": "name of playlist",
      "audios": [
         {
            "album":"25時、ナイトコードで。",
            "artist":"25時、ナイトコードで。",
            "created":1688962062,
            "modified":1705995277,
            "path":"C:\\Users\\ferry\\Music\\Music\\25時、ナイトコードで。 - カナデトモスソラ (奏明天空).flac",
            "title":"カナデトモスソラ (奏明天空)"
         }, ...
      ]
   }, ...
]

settings page
1. 管理文件夹（不用保存到settings.json）
2. 日/夜间模式 0: 日；1：夜
3. 是否根据歌曲封面切换主题色 1: 是；0：否
4. 设置当前歌曲主题色为默认 保存主题seed
5. 艺术家分隔符："/" "、"

settings.json

{
   "ThemeMode": 0,
   "DynamicTheme": 1,
   "DefaultTheme": 4290545753,
   "ArtistSeparator": ["/", "、"]
}

embedded theme:
1. 4292114089
2. 4282283161
3. 4286080703
4. 4290765296
5. 4287059351
6. 4292356666
7. 4293706294