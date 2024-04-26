use std::{
    borrow::Cow,
    fs::{self, File},
    io::{Read, Write},
    path::Path,
    time::{Duration, UNIX_EPOCH},
};

use lofty::{
    flac::FlacFile, id3::v2::FrameId, mpeg::MpegFile, Accessor, AudioFile, ParseOptions,
    TaggedFileExt,
};

const UNKNOWN: Cow<'_, str> = Cow::Borrowed("UNKNOWN");

struct Metadata {
    title: String,
    artist: String,
    album: String,
    track: u32,
    duration: u64,
    path: String,
    modified: u64,
    created: u64,
}

impl Metadata {
    fn to_json_value(from: Metadata) -> serde_json::Value {
        return serde_json::json!({
            "title": from.title,
            "artist": from.artist,
            "album": from.album,
            "track": from.track,
            "duration": from.duration,
            "path": from.path,
            "modified": from.modified,
            "created": from.created
        });
    }
}

impl Metadata {
    fn read_from_audio_path(path: &String) -> Option<Metadata> {
        let mut file = match File::open(&path) {
            Ok(value) => value,
            Err(_) => return None,
        };
        let tagged_file = match lofty::read_from(&mut file) {
            Ok(value) => value,
            Err(_) => return None,
        };

        let title: String;
        let artist: Cow<'_, str>;
        let album: Cow<'_, str>;
        let track: u32;
        let duration: u64 = tagged_file.properties().duration().as_secs();

        if let Some(primary_tag) = tagged_file.primary_tag() {
            title = match primary_tag.title() {
                Some(value) => value.to_string(),
                None => path.clone(),
            };
            artist = primary_tag.artist().unwrap_or(UNKNOWN);
            album = primary_tag.album().unwrap_or(UNKNOWN);
            track = primary_tag.track().unwrap_or(0);
        } else {
            if let Some(tag) = tagged_file.first_tag() {
                title = match tag.title(){
                    Some(value) => value.to_string(),
                    None => path.clone(),
                };
                artist = tag.artist().unwrap_or(UNKNOWN);
                album = tag.album().unwrap_or(UNKNOWN);
                track = tag.track().unwrap_or(0);
            } else {
                title = path.clone();
                artist = UNKNOWN;
                album = UNKNOWN;
                track = 0;
            }
        }

        let metadata = match file.metadata() {
            Ok(value) => value,
            Err(_) => return None,
        };
        let modified = metadata
            .modified()
            .unwrap_or(UNIX_EPOCH)
            .duration_since(UNIX_EPOCH)
            .unwrap_or(Duration::ZERO)
            .as_secs();
        let created = metadata
            .created()
            .unwrap_or(UNIX_EPOCH)
            .duration_since(UNIX_EPOCH)
            .unwrap_or(Duration::ZERO)
            .as_secs();

        return Some(Metadata {
            title,
            artist: artist.to_string(),
            album: album.to_string(),
            track,
            duration,
            path: path.clone(),
            modified,
            created,
        });
    }
}

struct AudioFolder {
    path: String,
    modified: u64,
    audios: Vec<Metadata>,
}

impl AudioFolder {
    fn to_json_value(from: AudioFolder) -> serde_json::Value {
        let mut audios_json_vec: Vec<serde_json::Value> = vec![];
        for audio in from.audios {
            audios_json_vec.push(Metadata::to_json_value(audio));
        }

        return serde_json::json!({
            "path": from.path,
            "modified": from.modified,
            "audios": audios_json_vec,
        });
    }
}

impl AudioFolder {
    fn read_from_folder_path(path: &String) -> Option<AudioFolder> {
        let mut audios: Vec<Metadata> = vec![];

        let dir = match fs::read_dir(&path) {
            Ok(value) => value,
            Err(_) => return None,
        };
        for item in dir {
            let entry = match item {
                Ok(value) => value,
                Err(_) => continue,
            };
            let entry_path = entry.path().to_string_lossy().to_string();
            let audio = match Metadata::read_from_audio_path(&entry_path) {
                Some(value) => value,
                None => continue,
            };
            audios.push(audio);
        }

        let modified: u64;
        let dir_metadata_result = fs::metadata(&path);
        match dir_metadata_result {
            Ok(dir_metadata) => {
                modified = dir_metadata
                    .modified()
                    .unwrap_or(UNIX_EPOCH)
                    .duration_since(UNIX_EPOCH)
                    .unwrap_or(Duration::ZERO)
                    .as_secs();
            }
            _ => {
                modified = 0;
            }
        }
        return Some(AudioFolder {
            path: path.clone(),
            modified,
            audios,
        });
    }
}

/// 扫描给定的多个目录，建立索引并导出到index_path/index.json
pub fn build_index_from_paths(paths: Vec<String>, index_path: String) {
    let index_path = Path::new(&index_path).join("index.json");
    let mut audio_folders_json_vec: Vec<serde_json::Value> = vec![];

    for item in paths {
        let audio_folder = match AudioFolder::read_from_folder_path(&item) {
            Some(value) => value,
            None => continue,
        };

        audio_folders_json_vec.push(AudioFolder::to_json_value(audio_folder));
    }

    let mut file = match File::create(&index_path) {
        Ok(value) => value,
        Err(_) => {
            return;
        }
    };
    let json = serde_json::json!(audio_folders_json_vec);
    let bytes = match serde_json::to_vec(&json) {
        Ok(value) => value,
        Err(_) => {
            return;
        }
    };
    match file.write(&bytes) {
        Ok(_) => {}
        Err(_) => {}
    }
}

/// 解析给定的MP3文件中id3v2，返回USLT帧的内容
pub fn load_lyric_from_mp3(path: String) -> Option<String> {
    let mut file = match File::open(&path) {
        Ok(value) => value,
        Err(_) => return None,
    };
    let mp3_file = match MpegFile::read_from(&mut file, ParseOptions::new()) {
        Ok(value) => value,
        Err(_) => return None,
    };

    let id3v2 = mp3_file.id3v2()?;
    let frame = id3v2.get(&FrameId::Valid(Cow::Borrowed("USLT")))?;
    match frame.content() {
        lofty::id3::v2::FrameValue::UnsynchronizedText(lyric_frame) => {
            return Some(lyric_frame.content.clone());
        }
        _ => return None,
    }
}

/// 解析给定flac文件中的vorbis comments，返回LYRICS字段的内容
pub fn load_lyric_from_flac(path: String) -> Option<String> {
    let mut file = match File::open(&path) {
        Ok(value) => value,
        Err(_) => return None,
    };
    let flac_file = match FlacFile::read_from(&mut file, ParseOptions::new()) {
        Ok(value) => value,
        Err(_) => return None,
    };

    let vc = flac_file.vorbis_comments()?;
    let lyric = vc.get("LYRICS")?;

    Some(lyric.to_string())
}

/// 给定音乐文件的路径，返回相同路径下同名的lrc文件的内容
pub fn load_lyric_from_lrc(path: String) -> Option<String> {
    let mut lyric: String = String::new();

    // convert test.mp3 to test.lrc
    let path_without_suffix = &path[..path.rfind(".").unwrap_or(path.len())];
    let lrc_path = path_without_suffix.to_string() + ".lrc";

    let mut lrc_file = match File::open(lrc_path) {
        Ok(value) => value,
        _ => return None,
    };

    match lrc_file.read_to_string(&mut lyric) {
        Ok(_) => return Some(lyric),
        Err(_) => return None,
    }
}

/// 给定音乐文件的路径，返回图像的数据
pub fn load_cover_bytes(path: String) -> Option<Vec<u8>> {
    let mut file = match File::open(&path) {
        Ok(file) => file,
        _ => return None,
    };
    let tagged_file = match lofty::read_from(&mut file) {
        Ok(tagged_file) => tagged_file,
        _ => return None,
    };
    let tag = tagged_file.primary_tag()?;
    let cover = tag.pictures().first()?;
    let data = cover.clone().into_data();
    Some(data)
}

/// 读取并更新index_path/index.json
pub fn update_index(index_path: String) {
    let index_path = Path::new(&index_path).join("index.json");
    let mut index_file = match fs::File::open(&index_path) {
        Ok(value) => value,
        Err(_) => {
            return;
        }
    };

    let mut index_str = String::new();
    match index_file.read_to_string(&mut index_str) {
        Ok(_) => {}
        Err(_) => return,
    }

    let mut index: serde_json::Value = match serde_json::from_str(&index_str) {
        Ok(value) => value,
        Err(_) => return,
    };
    let audio_folders = match index.as_array_mut() {
        Some(value) => value,
        None => return,
    };

    _remove_unreachable_dir(audio_folders);

    for item in audio_folders {
        let audio_folder = match item {
            serde_json::Value::Object(value) => value,
            _ => continue,
        };

        let path = match audio_folder["path"].as_str() {
            Some(value) => value.to_string(),
            _ => continue,
        };
        let metadata = match fs::metadata(&path) {
            Ok(value) => value,
            Err(_) => continue,
        };
        let modified = match audio_folder["modified"].as_u64() {
            Some(value) => value,
            None => continue,
        };
        let system_time = match metadata.modified() {
            Ok(value) => value,
            Err(_) => continue,
        };
        let duration = match system_time.duration_since(UNIX_EPOCH) {
            Ok(value) => value,
            Err(_) => continue,
        };
        let new_modified = duration.as_secs();
        if new_modified <= modified {
            continue;
        }

        // 重新扫描整个目录，而不是根据创建时间和修改时间更新。
        // Windows下创建时间和修改时间不随文件位置变化。
        let new_af = match AudioFolder::read_from_folder_path(&path) {
            Some(value) => value,
            None => continue,
        };

        *item = AudioFolder::to_json_value(new_af);
    }

    let mut output_index = match File::create(&index_path) {
        Ok(value) => value,
        Err(_) => {
            return;
        }
    };
    let output_json = index.to_string();
    match output_index.write(output_json.as_bytes()) {
        Ok(_) => {}
        Err(_) => {}
    }
}

/// part of [update_index]
fn _remove_unreachable_dir(audio_folders: &mut Vec<serde_json::Value>) {
    audio_folders.retain(|item| {
        let audio_folder = match item {
            serde_json::Value::Object(value) => value,
            _ => return false,
        };
        let path = match &audio_folder["path"] {
            serde_json::Value::String(value) => value,
            _ => return false,
        };
        if Path::new(path).exists() {
            return true;
        }

        return false;
    });
}
