use std::{
    fs::{self},
    io::{self, Write},
    path::{Path, PathBuf},
    time::{Duration, UNIX_EPOCH},
};

use lofty::prelude::{Accessor, AudioFile, ItemKey, TaggedFileExt};
use windows::{
    core::HSTRING,
    Storage::{FileProperties::ThumbnailMode, StorageFile, Streams::DataReader},
};

use crate::frb_generated::StreamSink;

const UNKNOWN_COW: std::borrow::Cow<'_, str> = std::borrow::Cow::Borrowed("UNKNOWN");
const UNKNOWN_STR: &str = "UNKNOWN";
/// 索引的最低版本。低于该版本或没有版本号的索引将被完全重建。现在是 1.1.0
const LOWEST_VERSION: u64 = 110;

/// K: extension, V: can read tags by using Lofty
static SUPPORT_FORMAT: phf::Map<&'static str, bool> = phf::phf_map! {
    "mp3" => true, "mp2" => false, "mp1" => false,
    "ogg" => true,
    "wav" => true, "wave" => true,
    "aif" => true, "aiff" => true, "aifc" => true,
    // 通过 Windows 系统支持
    "asf" => false, "wma" => false,
    "aac" => true, "adts" => true,
    "m4a" => true,
    "ac3" => false,
    "amr" => false, "3ga" => false,
    "flac" => true,
    "mpc" => true,
    // 插件支持
    "mid" => false,
    "wv" => true, "wvc" => true,
    "opus" => true,
    "dsf" => false, "dff" => false,
    "ape" => true,
};

pub struct IndexActionState {
    /// completed / total
    pub progress: f64,

    /// describe action state
    pub message: String,
}

#[derive(Debug)]
struct Audio {
    title: String,
    artist: String,
    album: String,
    track: Option<u32>,
    /// in secs
    duration: u64,
    /// kbps
    bitrate: Option<u32>,
    sample_rate: Option<u32>,
    /// absolute path
    path: String,
    /// secs since UNIX_EPOCH
    modified: u64,
    /// secs since UNIX_EPOCH
    created: u64,
    /// 标签获取方式
    by: Option<String>,
}

impl Audio {
    fn new_with_path(path: &Path, by: Option<String>) -> Option<Self> {
        Some(Audio {
            title: path.file_name()?.to_string_lossy().to_string(),
            artist: UNKNOWN_STR.to_string(),
            album: UNKNOWN_STR.to_string(),
            track: None,
            duration: 0,
            bitrate: None,
            sample_rate: None,
            path: path.to_string_lossy().to_string(),
            modified: 0,
            created: 0,
            by,
        })
    }

    fn to_json_value(&self) -> serde_json::Value {
        serde_json::json!({
            "title": self.title,
            "artist": self.artist,
            "album": self.album,
            "track": self.track,
            "duration": self.duration,
            "bitrate": self.bitrate,
            "sample_rate": self.sample_rate,
            "path": self.path,
            "modified": self.modified,
            "created": self.created,
            "by": self.by
        })
    }

    /// 不支持：None  
    /// Lofty 能获取到信息：read_by_lofty  
    /// 不能的话：read_by_win_music_properties  
    /// 再不能的话：title: filename 代替
    fn read_from_path(path: &Path) -> Option<Self> {
        let lofty_support: bool = *SUPPORT_FORMAT.get(&path.extension()?.to_string_lossy())?;

        let file_metadata = fs::metadata(path).unwrap();
        let modified = file_metadata
            .modified()
            .unwrap_or(UNIX_EPOCH)
            .duration_since(UNIX_EPOCH)
            .unwrap_or(Duration::ZERO)
            .as_secs();
        let created = file_metadata
            .created()
            .unwrap_or(UNIX_EPOCH)
            .duration_since(UNIX_EPOCH)
            .unwrap_or(Duration::ZERO)
            .as_secs();

        if lofty_support {
            if let Some(value) = Self::read_by_lofty(path, modified, created) {
                return Some(value);
            }

            return match Self::read_by_win_music_properties(path, modified, created) {
                Ok(value) => Some(value),
                Err(_) => Self::new_with_path(path, None),
            };
        } else {
            match Self::read_by_win_music_properties(path, modified, created) {
                Ok(value) => Some(value),
                Err(_) => Self::new_with_path(path, None),
            }
        }
    }

    /// 使用 lofty 获取音乐标签。只在文件名不正确、没有标签或包含不支持的编码时返回 None
    fn read_by_lofty(path: &Path, modified: u64, created: u64) -> Option<Self> {
        if let Ok(tagged_file) = lofty::read_from_path(path) {
            let properties = tagged_file.properties();

            if let Some(tag) = tagged_file.primary_tag().or(tagged_file.first_tag()) {
                return Some(Audio {
                    title: tag
                        .title()
                        .unwrap_or(path.file_name()?.to_string_lossy())
                        .to_string(),
                    artist: tag.artist().unwrap_or(UNKNOWN_COW).to_string(),
                    album: tag.album().unwrap_or(UNKNOWN_COW).to_string(),
                    track: tag.track(),
                    duration: properties.duration().as_secs(),
                    bitrate: properties.audio_bitrate(),
                    sample_rate: properties.sample_rate(),
                    path: path.to_string_lossy().to_string(),
                    modified,
                    created,
                    by: Some("Lofty".to_string()),
                });
            }

            return Some(Audio {
                title: path.file_name()?.to_string_lossy().to_string(),
                artist: UNKNOWN_COW.to_string(),
                album: UNKNOWN_COW.to_string(),
                track: None,
                duration: properties.duration().as_secs(),
                bitrate: properties.audio_bitrate(),
                sample_rate: properties.sample_rate(),
                path: path.to_string_lossy().to_string(),
                modified,
                created,
                by: Some("Lofty".to_string()),
            });
        }

        None
    }

    /// 使用 Windows Api 获取音乐标签。会因为各种原因返回 Err
    fn read_by_win_music_properties(
        path: &Path,
        modified: u64,
        created: u64,
    ) -> Result<Self, windows::core::Error> {
        let storage_file = StorageFile::GetFileFromPathAsync(&HSTRING::from(path))?.get()?;
        let music_properties = storage_file
            .Properties()?
            .GetMusicPropertiesAsync()?
            .get()?;

        let duration: Duration = music_properties.Duration()?.into();

        Ok(Audio {
            title: music_properties
                .Title()
                .or(storage_file.Name())?
                .to_string(),
            artist: music_properties
                .Artist()
                .unwrap_or(HSTRING::from(UNKNOWN_STR))
                .to_string(),
            album: music_properties
                .Album()
                .unwrap_or(HSTRING::from(UNKNOWN_STR))
                .to_string(),
            track: Some(music_properties.TrackNumber()?),
            duration: duration.as_secs(),
            bitrate: Some(music_properties.Bitrate()? / 1000),
            sample_rate: None,
            path: path.to_string_lossy().to_string(),
            modified,
            created,
            by: Some("Windows".to_string()),
        })
    }
}

#[derive(Debug)]
struct AudioFolder {
    path: String,
    /// secs since UNIX_EPOCH
    modified: u64,
    /// biggest created in audios. secs since UNIX_EPOCH
    latest: u64,
    audios: Vec<Audio>,
}

impl AudioFolder {
    fn to_json_value(&self) -> serde_json::Value {
        let mut audios_json: Vec<serde_json::Value> = vec![];
        for audio in &self.audios {
            audios_json.push(audio.to_json_value());
        }

        serde_json::json!({
            "path": self.path,
            "modified": self.modified,
            "latest": self.latest,
            "audios": audios_json,
        })
    }

    /// 扫描路径为 path 的文件夹
    fn read_from_folder(path: &Path) -> Result<AudioFolder, io::Error> {
        if let Ok(dir) = fs::read_dir(path) {
            let mut audios: Vec<Audio> = vec![];
            let mut latest: u64 = 0;

            for item in dir {
                let entry = item?;

                if entry.file_type()?.is_dir() {
                    continue;
                } else if let Some(metadata) = Audio::read_from_path(&entry.path()) {
                    if metadata.created > latest {
                        latest = metadata.created;
                    }

                    audios.push(metadata);
                }
            }

            if !audios.is_empty() {
                return Ok(AudioFolder {
                    path: path.to_string_lossy().to_string(),
                    modified: fs::metadata(path)?
                        .modified()?
                        .duration_since(UNIX_EPOCH)
                        .unwrap_or(Duration::ZERO)
                        .as_secs(),
                    latest,
                    audios,
                });
            }
        }

        Err(io::Error::new(
            io::ErrorKind::NotFound,
            path.to_string_lossy() + " has no music.",
        ))
    }

    /// 扫描路径为 path 的文件夹及其所有子文件夹。
    fn read_from_folder_recursively(
        folder: &Path,
        result: &mut Vec<Self>,
        scaned: &mut u64,
        total: u64,
        sink: &StreamSink<IndexActionState>,
    ) -> Result<(), io::Error> {
        if let Ok(dir) = fs::read_dir(folder) {
            sink.add(IndexActionState {
                progress: *scaned as f64 / total as f64,
                message: String::from("正在扫描 ") + &folder.to_string_lossy(),
            });
            let mut audios: Vec<Audio> = vec![];
            let mut latest: u64 = 0;

            for item in dir {
                let entry = item?;

                if entry.file_type()?.is_dir() {
                    Self::read_from_folder_recursively(
                        &entry.path(),
                        result,
                        scaned,
                        total + 1,
                        &sink,
                    )?;
                } else if let Some(metadata) = Audio::read_from_path(&entry.path()) {
                    if metadata.created > latest {
                        latest = metadata.created;
                    }

                    audios.push(metadata);
                }
            }

            if !audios.is_empty() {
                result.push(AudioFolder {
                    path: folder.to_string_lossy().to_string(),
                    modified: fs::metadata(folder)?
                        .modified()?
                        .duration_since(UNIX_EPOCH)
                        .unwrap_or(Duration::ZERO)
                        .as_secs(),
                    latest,
                    audios,
                });
            }

            *scaned += 1;
            sink.add(IndexActionState {
                progress: *scaned as f64 / total as f64,
                message: String::new(),
            });
        }

        Ok(())
    }
}

fn _get_picture_by_windows(path: String) -> Result<Vec<u8>, windows::core::Error> {
    let file = StorageFile::GetFileFromPathAsync(&HSTRING::from(path))?.get()?;
    let thumbnail = file
        .GetThumbnailAsyncOverloadDefaultSizeDefaultOptions(ThumbnailMode::MusicView)?
        .get()?;

    let mut buf: Vec<u8> = vec![];
    let reader = DataReader::CreateDataReader(&thumbnail)?;
    reader.ReadBytes(&mut buf)?;

    Ok(buf)
}

/// for Flutter  
/// 如果无法通过 Lofty 获取则通过 Windows 获取
pub fn get_picture_from_path(path: String) -> Option<Vec<u8>> {
    if let Ok(tagged_file) = lofty::read_from_path(&path) {
        let tag = tagged_file.primary_tag().or(tagged_file.first_tag())?;
        return Some(tag.pictures().first()?.data().to_vec());
    }

    if let Ok(pic) = _get_picture_by_windows(path) {
        return Some(pic);
    }

    None
}

/// for Flutter   
/// 只支持读取 ID3V2, VorbisComment, Mp4Ilst 存储的内嵌歌词
/// 以及相同目录相同文件名的 .lrc 外挂歌词（utf-8 or utf-16）
pub fn get_lyric_from_path(path: String) -> Option<String> {
    if let Ok(tagged_file) = lofty::read_from_path(&path) {
        let tag = tagged_file.primary_tag().or(tagged_file.first_tag())?;
        return Some(tag.get(&ItemKey::Lyrics)?.value().text()?.to_string());
    }

    let mut lrc_file_path = PathBuf::from(path);
    lrc_file_path.set_extension("lrc");

    if let Ok(lrc_bytes) = fs::read(lrc_file_path) {
        let is_le = lrc_bytes.starts_with(&[0xFF, 0xFE]);
        let is_utf16 = (is_le || lrc_bytes.starts_with(&[0xFE, 0xFF])) && lrc_bytes.len() % 2 == 0;

        if is_utf16 {
            let convert_fn = match is_le {
                true => u16::from_le_bytes,
                false => u16::from_be_bytes,
            };

            let mut u16_bytes: Vec<u16> = vec![];
            let chunk_iter = lrc_bytes.chunks_exact(2);
            for chunk in chunk_iter {
                u16_bytes.push(convert_fn([chunk[0], chunk[1]]));
            }
            if let Ok(lrc_str) = String::from_utf16(&u16_bytes) {
                return Some(lrc_str);
            }
        } else if let Ok(lrc_str) = String::from_utf8(lrc_bytes.clone()) {
            return Some(lrc_str);
        }
    }

    None
}

/// for Flutter  
/// 扫描给定的所有文件夹的音乐文件并把索引保存在 index_path/index.json。
/// 用在文件夹管理界面
pub fn build_index_from_folders(
    folders: Vec<String>,
    index_path: String,
    sink: StreamSink<IndexActionState>,
) -> Result<(), io::Error> {
    let mut audio_folders_json: Vec<serde_json::Value> = vec![];
    for item in &folders {
        sink.add(IndexActionState {
            progress: audio_folders_json.len() as f64 / folders.len() as f64,
            message: String::from("正在扫描 ") + item,
        });
        let folder_path = Path::new(item);
        audio_folders_json.push(AudioFolder::read_from_folder(folder_path)?.to_json_value());
        sink.add(IndexActionState {
            progress: audio_folders_json.len() as f64 / folders.len() as f64,
            message: String::new(),
        });
    }
    fs::File::create(index_path)?.write(
        serde_json::json!({
            "version": LOWEST_VERSION,
            "folders": audio_folders_json,
        })
        .to_string()
        .as_bytes(),
    )?;

    Ok(())
}

/// for Flutter  
/// 扫描给定路径下所有子文件夹（包括自己）的音乐文件并把索引保存在 index_path/index.json。
pub fn build_index_from_folders_recursively(
    folders: Vec<String>,
    index_path: String,
    sink: StreamSink<IndexActionState>,
) -> Result<(), io::Error> {
    let mut audio_folders: Vec<AudioFolder> = vec![];

    for item in &folders {
        let mut scaned: u64 = 0;
        AudioFolder::read_from_folder_recursively(
            Path::new(item),
            &mut audio_folders,
            &mut scaned,
            folders.len() as u64,
            &sink,
        )?;
    }

    let mut audio_folders_json: Vec<serde_json::Value> = vec![];
    for item in &audio_folders {
        audio_folders_json.push(item.to_json_value());
    }
    let json_value = serde_json::json!({
        "version": LOWEST_VERSION,
        "folders": audio_folders_json,
    });

    let mut index_path = PathBuf::from(index_path);
    index_path.push("index.json");
    fs::File::create(index_path)?.write(json_value.to_string().as_bytes())?;

    Ok(())
}

fn _update_index_below_1_1_0(
    index: &serde_json::Value,
    index_path: &PathBuf,
    sink: &StreamSink<IndexActionState>,
) -> Result<(), io::Error> {
    let mut audio_folders_json: Vec<serde_json::Value> = vec![];
    let folders = index.as_array().unwrap();
    for item in folders {
        let path = item["path"].as_str().unwrap();
        sink.add(IndexActionState {
            progress: audio_folders_json.len() as f64 / folders.len() as f64,
            message: String::from("正在扫描 ") + path,
        });
        let folder_path = Path::new(path);
        audio_folders_json.push(AudioFolder::read_from_folder(folder_path)?.to_json_value());
        sink.add(IndexActionState {
            progress: audio_folders_json.len() as f64 / folders.len() as f64,
            message: String::new(),
        });
    }
    fs::File::create(index_path)?.write(
        serde_json::json!({
            "version": LOWEST_VERSION,
            "folders": audio_folders_json,
        })
        .to_string()
        .as_bytes(),
    )?;

    Ok(())
}

/// for Flutter   
/// 读取 index_path/index.json，检查更新。不可能重新读取被修改的文件夹下所有的音乐标签，这样太耗时。  
///
/// [LOWEST_VERSION] 指定可以继承的 index 的最低版本。
/// 如果 index version < [LOWEST_VERSION] 或者是 index 根本没有 version 再或者格式不符合要求，就转到
/// [_update_index_below_1_1_0] 更新 index；
/// 如果 index version >= [LOWEST_VERSION] 则进行更新。
///
/// 如果文件夹不存在，删除记录。  
/// 如果文件夹被修改（再次读取到的 modified > 记录的 modified），就更新它。没有则跳过它
/// 1. 遍历该文件夹索引，判断文件是否存在，不存在则删除记录
/// 2. 遍历该文件夹索引，如果文件被修改（再次读取到的 modified > 记录的 modified），重新读取标签；没有则跳过它
/// 3. 遍历该文件夹，添加新增（读取到的 created > 记录的 latest）的音乐文件
pub fn update_index(
    index_path: String,
    sink: StreamSink<IndexActionState>,
) -> Result<(), io::Error> {
    let mut index_path = PathBuf::from(index_path);
    index_path.push("index.json");
    let index = fs::read(&index_path)?;
    let mut index: serde_json::Value = serde_json::from_slice(&index).unwrap();

    let version = index["version"].as_u64();
    if let None = version {
        return _update_index_below_1_1_0(&index, &index_path, &sink);
    }

    let folders = index["folders"].as_array_mut().unwrap();
    // 删除访问不到的文件夹的记录
    folders.retain(|item| {
        let path = item["path"].as_str().unwrap();

        Path::new(path).exists()
    });

    let mut updated = 0;
    let total = folders.len();

    for folder_item in folders {
        let folder_path = folder_item["path"].as_str().unwrap().to_string();
        let latest = folder_item["latest"].as_u64().unwrap();
        let old_folder_modified = folder_item["modified"].as_u64().unwrap();

        let new_folder_modified = fs::metadata(&folder_path)?
            .modified()?
            .duration_since(UNIX_EPOCH)
            .unwrap_or(Duration::ZERO)
            .as_secs();
        // 跳过没有被修改的文件夹
        if new_folder_modified <= old_folder_modified {
            updated += 1;
            continue;
        }

        sink.add(IndexActionState {
            progress: updated as f64 / total as f64,
            message: String::from("正在更新 ") + &folder_path,
        });

        folder_item["modified"] = serde_json::json!(new_folder_modified);

        // 删除访问不到的文件的记录
        let audios = folder_item["audios"].as_array_mut().unwrap();
        audios.retain(|item| {
            let path = item["path"].as_str().unwrap();

            Path::new(path).exists()
        });

        for audio_item in &mut *audios {
            let old_audio_modified = audio_item["modified"].as_u64().unwrap();
            let audio_path = audio_item["path"].as_str().unwrap();
            let new_audio_modified = fs::metadata(audio_path)?
                .modified()?
                .duration_since(UNIX_EPOCH)
                .unwrap_or(Duration::ZERO)
                .as_secs();
            // 跳过没有被修改的文件
            if new_audio_modified <= old_audio_modified {
                continue;
            }

            // 重新读取被修改的音乐文件的标签并更新
            if let Some(modified_audio) = Audio::read_from_path(Path::new(audio_path)) {
                *audio_item = modified_audio.to_json_value();
            }
        }

        // 添加新增的音乐文件
        let mut new_latest: u64 = latest;
        let dir = fs::read_dir(folder_path)?;
        for entry in dir {
            let entry = entry?;
            if entry.file_type()?.is_dir() {
                continue;
            }

            let entry_created = entry
                .metadata()?
                .created()?
                .duration_since(UNIX_EPOCH)
                .unwrap_or(Duration::ZERO)
                .as_secs();
            if entry_created > latest {
                if let Some(new_audio) = Audio::read_from_path(&entry.path()) {
                    if entry_created > new_latest {
                        new_latest = entry_created;
                    }

                    audios.push(new_audio.to_json_value());
                }
            }
        }

        folder_item["latest"] = serde_json::json!(new_latest);

        updated += 1;
        sink.add(IndexActionState {
            progress: updated as f64 / total as f64,
            message: String::new(),
        });
    }

    fs::File::create(index_path)?.write(index.to_string().as_bytes())?;

    Ok(())
}
