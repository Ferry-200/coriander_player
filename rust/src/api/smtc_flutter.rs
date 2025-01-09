use std::time::Duration;

use flutter_rust_bridge::frb;
use windows::{
    core::HSTRING,
    Foundation::{TimeSpan, TypedEventHandler},
    Media::{
        MediaPlaybackStatus, MediaPlaybackType, Playback::MediaPlayer,
        SystemMediaTransportControls, SystemMediaTransportControlsButton,
        SystemMediaTransportControlsButtonPressedEventArgs,
        SystemMediaTransportControlsTimelineProperties,
    },
    Storage::{FileProperties::ThumbnailMode, StorageFile, Streams::RandomAccessStreamReference},
};

use crate::frb_generated::StreamSink;

use super::logger::log_to_dart;

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

        let file = StorageFile::GetFileFromPathAsync(&path)?.get()?;
        let thumbnail = file
            .GetThumbnailAsyncOverloadDefaultSizeDefaultOptions(ThumbnailMode::MusicView)?
            .get()?;
        updater.SetThumbnail(&RandomAccessStreamReference::CreateFromStream(&thumbnail)?)?;

        updater.Update()?;

        if !(self._smtc.IsEnabled()?) {
            self._smtc.SetIsEnabled(true)?;
        }

        Ok(())
    }
}
