use std::time::Duration;

use flutter_rust_bridge::frb;
use windows::{
    core::{HSTRING, Interface},
    Foundation::{TimeSpan, TypedEventHandler},
    Media::{
        MediaPlaybackStatus, MediaPlaybackType, Playback::MediaPlayer,
        SystemMediaTransportControls, SystemMediaTransportControlsButton,
        SystemMediaTransportControlsButtonPressedEventArgs,
        SystemMediaTransportControlsTimelineProperties,
    },
    Storage::{
        FileProperties::ThumbnailMode,
        StorageFile,
        Streams::{DataWriter, InMemoryRandomAccessStream, RandomAccessStreamReference, IRandomAccessStream}
    },
};

use crate::frb_generated::StreamSink;

use super::{logger::log_to_dart, tag_reader};

pub struct SMTCFlutter {
    _smtc: SystemMediaTransportControls,
    _player: MediaPlayer,
}

pub enum SMTCControlEvent {
    Play,
    Pause,
    Previous,
    Next,
    Unknown,
}

pub enum SMTCState {
    Paused,
    Playing,
}

/// Apis for Flutter
impl SMTCFlutter {
    #[frb(sync)]
    pub fn new() -> Self {
        Self::_new().unwrap()
    }

    pub fn subscribe_to_control_events(&self, sink: StreamSink<SMTCControlEvent>) {
        self._smtc
            .ButtonPressed(&TypedEventHandler::<
                SystemMediaTransportControls,
                SystemMediaTransportControlsButtonPressedEventArgs,
            >::new(move |_, event| {
                let event = event.as_ref().unwrap().Button().unwrap();
                let event = match event {
                    SystemMediaTransportControlsButton::Play => SMTCControlEvent::Play,
                    SystemMediaTransportControlsButton::Pause => SMTCControlEvent::Pause,
                    SystemMediaTransportControlsButton::Next => SMTCControlEvent::Next,
                    SystemMediaTransportControlsButton::Previous => SMTCControlEvent::Previous,
                    _ => SMTCControlEvent::Unknown,
                };
                sink.add(event).unwrap();

                Ok(())
            }))
            .unwrap();
    }

    pub fn update_state(&self, state: SMTCState) {
        if let Err(err) = self._update_state(state) {
            log_to_dart(format!("fail to update state: {}", err));
        }
    }

    /// progress, duration: ms
    pub fn update_time_properties(&self, progress: u32) {
        if let Err(err) = self._update_time_properties(progress) {
            log_to_dart(format!("fail to update state: {}", err));
        }
    }

    pub fn update_display(&self, title: String, artist: String, album: String, duration: u32, path: String) {
        if let Err(err) = self._update_display(
            HSTRING::from(title),
            HSTRING::from(artist),
            HSTRING::from(album),
            duration,
            HSTRING::from(path),
        ) {
            log_to_dart(format!("fail to update display: {}", err));
        }
    }

    pub fn close(self) {
        self._player.Close().unwrap();
    }
}

impl SMTCFlutter {
    fn _init_controls(smtc: &SystemMediaTransportControls) -> Result<(), windows::core::Error> {
        // 下一首
        smtc.SetIsNextEnabled(true)?;
        // 暂停
        smtc.SetIsPauseEnabled(true)?;
        // 播放（恢复）
        smtc.SetIsPlayEnabled(true)?;
        // 上一首
        smtc.SetIsPreviousEnabled(true)?;

        Ok(())
    }

    fn _new() -> Result<Self, windows::core::Error> {
        let _player = MediaPlayer::new()?;
        _player.CommandManager()?.SetIsEnabled(false)?;

        let _smtc = _player.SystemMediaTransportControls()?;
        Self::_init_controls(&_smtc)?;

        Ok(Self { _smtc, _player })
    }

    fn _update_state(&self, state: SMTCState) -> Result<(), windows::core::Error> {
        let state = match state {
            SMTCState::Playing => MediaPlaybackStatus::Playing,
            SMTCState::Paused => MediaPlaybackStatus::Paused,
        };
        self._smtc.SetPlaybackStatus(state)?;

        Ok(())
    }

    /// progress, duration: ms
    fn _update_time_properties(&self, progress: u32) -> Result<(), windows::core::Error> {
        let time_properties = SystemMediaTransportControlsTimelineProperties::new()?;
        time_properties.SetPosition(TimeSpan::from(Duration::from_millis(progress.into())))?;
        self._smtc.UpdateTimelineProperties(&time_properties)?;

        Ok(())
    }

    /// 将图片数据转换为 Windows 缩略图流
    fn _create_thumbnail_from_picture_data(picture_data: &[u8]) -> Result<InMemoryRandomAccessStream, windows::core::Error> {
        log_to_dart(format!("Creating thumbnail stream from {} bytes of picture data...", picture_data.len()));

        let stream = InMemoryRandomAccessStream::new()?;
        log_to_dart(format!("Stream created, initial size: {:?}", stream.Size()));

        let writer = DataWriter::CreateDataWriter(&stream)?;
        log_to_dart("DataWriter created".to_string());

        if let Err(err) = writer.WriteBytes(picture_data) {
            log_to_dart(format!("WriteBytes failed: {}", err));
            return Err(err);
        }
        log_to_dart("WriteBytes succeeded".to_string());

        if let Err(err) = writer.StoreAsync()?.get() {
            log_to_dart(format!("StoreAsync failed: {}", err));
            return Err(err);
        }
        log_to_dart("StoreAsync succeeded".to_string());

        if let Err(err) = writer.FlushAsync()?.get() {
            log_to_dart(format!("FlushAsync failed: {}", err));
            return Err(err);
        }
        log_to_dart("FlushAsync succeeded".to_string());

        // 关键：在丢弃writer之前尝试DetachStream，防止流被关闭
        log_to_dart("Attempting to detach stream from writer...".to_string());
        match writer.DetachStream() {
            Ok(detached_stream) => {
                log_to_dart("Stream detached successfully".to_string());
                drop(writer);

                let random_access_stream: IRandomAccessStream = detached_stream.cast::<IRandomAccessStream>()?;
                random_access_stream.Seek(0)?;

                let final_stream = random_access_stream.cast::<InMemoryRandomAccessStream>()?;
                let final_size = final_stream.Size()?;
                log_to_dart(format!("Final stream size: {} bytes", final_size));
                Ok(final_stream)
            }
            Err(err) => {
                log_to_dart(format!("Failed to detach stream: {}. The stream will be closed.", err));
                Err(err)
            }
        }
    }

    fn _update_display(
        &self,
        title: HSTRING,
        artist: HSTRING,
        album: HSTRING,
        duration: u32,
        path: HSTRING,
    ) -> Result<(), windows::core::Error> {
        let updater = self._smtc.DisplayUpdater()?;
        updater.SetType(MediaPlaybackType::Music)?;

        let time_properties = SystemMediaTransportControlsTimelineProperties::new()?;
        time_properties.SetStartTime(TimeSpan { Duration: 0 })?;
        time_properties.SetEndTime(TimeSpan::from(Duration::from_millis(duration.into())))?;
        time_properties.SetMinSeekTime(TimeSpan { Duration: 0 })?;
        time_properties.SetMaxSeekTime(TimeSpan::from(Duration::from_millis(duration.into())))?;
        self._smtc.UpdateTimelineProperties(&time_properties)?;

        let music_properties = updater.MusicProperties()?;
        music_properties.SetTitle(&title)?;
        music_properties.SetArtist(&artist)?;
        music_properties.SetAlbumTitle(&album)?;

        // 优先从音频标签获取封面（与软件内部一致）
        let mut thumbnail_set = false;

        if let Some(picture_data) = tag_reader::get_picture_from_path(path.to_string(), 256, 256) {
            log_to_dart(format!("Audio tag picture data size: {} bytes", picture_data.len()));
            let result: Result<(), windows::core::Error> = (|| {
                let stream = Self::_create_thumbnail_from_picture_data(&picture_data)?;
                log_to_dart("Created thumbnail stream from audio tag".to_string());
                let stream_ref = RandomAccessStreamReference::CreateFromStream(&stream)?;
                updater.SetThumbnail(&stream_ref)?;
                Ok(())
            })();

            if result.is_ok() {
                thumbnail_set = true;
                log_to_dart("SMTC thumbnail set from audio tag".to_string());
            } else if let Err(err) = result {
                log_to_dart(format!("Failed to set thumbnail from audio tag: {}", err));
            }
        } else {
            log_to_dart("No picture data from audio tag".to_string());
        }

        // 如果从标签获取失败，回退到 Windows 系统缩略图
        if !thumbnail_set {
            let file = StorageFile::GetFileFromPathAsync(&path)?.get()?;
            let thumbnail = file
                .GetThumbnailAsyncOverloadDefaultSizeDefaultOptions(ThumbnailMode::MusicView)?
                .get()?;
            updater.SetThumbnail(&RandomAccessStreamReference::CreateFromStream(&thumbnail)?)?;
            log_to_dart("SMTC thumbnail set from Windows system thumbnail".to_string());
        }

        log_to_dart("Calling updater.Update()...".to_string());
        updater.Update()?;
        log_to_dart("updater.Update() succeeded".to_string());

        if !(self._smtc.IsEnabled()?) {
            log_to_dart("SMTC not enabled, enabling...".to_string());
            self._smtc.SetIsEnabled(true)?;
            log_to_dart("SMTC enabled".to_string());
        }

        Ok(())
    }
}
