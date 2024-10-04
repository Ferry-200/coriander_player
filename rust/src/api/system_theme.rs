use flutter_rust_bridge::frb;
use windows::UI::ViewManagement::{UIColorType, UISettings};

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

    fn from_ui_settings(ui_settings: UISettings) -> Result<Self, windows::core::Error> {
        let fore = ui_settings.GetColorValue(UIColorType::Foreground)?;
        let accent = ui_settings.GetColorValue(UIColorType::Accent)?;

        Ok(SystemTheme {
            fore: (fore.A, fore.R, fore.G, fore.B),
            accent: (accent.A, accent.R, accent.G, accent.B),
        })
    }

    fn _get_system_theme() -> Result<SystemTheme, windows::core::Error> {
        SystemTheme::from_ui_settings(UISettings::new()?)
    }

    #[frb(sync)]
    pub fn get_system_theme() -> SystemTheme {
        match Self::_get_system_theme() {
            Ok(value) => value,
            Err(_) => SystemTheme::default(),
        }
    }
}
