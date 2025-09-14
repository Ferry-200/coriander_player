use flutter_rust_bridge::frb;

#[cfg(target_os = "windows")]
use windows::UI::ViewManagement::{UIColorType, UISettings};

use super::logger::log_to_dart;

pub struct SystemTheme {
    /// a, r, g, b
    pub fore: (u8, u8, u8, u8),
    /// a, r, g, b
    pub accent: (u8, u8, u8, u8),
}

impl SystemTheme {
    fn default() -> Self {
        SystemTheme {
            fore: (255, 255, 255, 255),
            accent: (0, 0, 0, 0),
        }
    }

    #[cfg(target_os = "windows")]
    fn from_ui_settings(ui_settings: UISettings) -> Result<Self, windows::core::Error> {
        let fore = ui_settings.GetColorValue(UIColorType::Foreground)?;
        let accent = ui_settings.GetColorValue(UIColorType::Accent)?;

        Ok(SystemTheme {
            fore: (fore.A, fore.R, fore.G, fore.B),
            accent: (accent.A, accent.R, accent.G, accent.B),
        })
    }

    #[cfg(target_os = "windows")]
    fn _get_system_theme() -> Result<SystemTheme, windows::core::Error> {
        SystemTheme::from_ui_settings(UISettings::new()?)
    }

    /// macOS和其他非Windows平台的默认实现
    #[cfg(not(target_os = "windows"))]
    fn _get_system_theme() -> Result<SystemTheme, String> {
        // 为macOS提供默认的亮色主题
        Ok(SystemTheme {
            // 黑色前景色 (适应macOS的浅色主题)
            fore: (255, 0, 0, 0),
            // macOS蓝色强调色
            accent: (255, 0, 122, 255),
        })
    }

    #[frb(sync)]
    pub fn get_system_theme() -> SystemTheme {
        #[cfg(target_os = "windows")]
        {
            match Self::_get_system_theme() {
                Ok(value) => value,
                Err(err) => {
                    log_to_dart(format!("fail to get sys theme: {}", err));
                    return SystemTheme::default();
                }
            }
        }
        
        #[cfg(not(target_os = "windows"))]
        {
            match Self::_get_system_theme() {
                Ok(value) => value,
                Err(err) => {
                    log_to_dart(format!("fail to get sys theme: {}", err));
                    return SystemTheme::default();
                }
            }
        }
    }
}
