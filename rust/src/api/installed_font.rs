use std::{
    env,
    fs::{self, read_dir},
    path::{Path, PathBuf},
};

pub struct InstalledFont {
    pub path: String,
    pub full_name: String,
}

pub fn get_installed_fonts() -> Option<Vec<InstalledFont>> {
    // match _get_installed_fonts() {
    //     Ok(value) => Some(value),
    //     Err(_) => None,
    // }
    Some(_get_installed_fonts().unwrap())
}

fn _get_installed_fonts() -> Result<Vec<InstalledFont>, anyhow::Error> {
    let mut installed_fonts: Vec<InstalledFont> = vec![];

    let system_installed_fonts_path = Path::new("C:\\Windows\\Fonts");
    if let Ok(system_installed_fonts) = read_dir(system_installed_fonts_path) {
        for entry_result in system_installed_fonts {
            if let Ok(entry) = entry_result {
                if let Some(extension) = entry.path().extension() {
                    if let Some(extension) = extension.to_str() {
                        match extension.to_lowercase().as_str() {
                            "ttf" | "ttc" | "otf" => {
                                if let Ok(font) = fs::read(entry.path()) {
                                    if let Ok(face) = ttf_parser::Face::parse(&font, 0) {
                                        for name in face.names() {
                                            if name.name_id == ttf_parser::name_id::FULL_NAME {
                                                if let Some(full_name) = name.to_string() {
                                                    installed_fonts.push(InstalledFont {
                                                        path: entry
                                                            .path()
                                                            .to_string_lossy()
                                                            .to_string(),
                                                        full_name,
                                                    });
                                                }
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                            _ => {}
                        }
                    }
                }
            }
        }
    }

    let user_installed_fonts_path =
        PathBuf::from(env::var("USERPROFILE")?).join("AppData\\Local\\Microsoft\\Windows\\Fonts");
    if let Ok(user_installed_fonts) = read_dir(user_installed_fonts_path) {
        for entry_result in user_installed_fonts {
            if let Ok(entry) = entry_result {
                if let Some(extension) = entry.path().extension() {
                    if let Some(extension) = extension.to_str() {
                        match extension.to_lowercase().as_str() {
                            "ttf" | "ttc" | "otf" => {
                                if let Ok(font) = fs::read(entry.path()) {
                                    if let Ok(face) = ttf_parser::Face::parse(&font, 0) {
                                        for name in face.names() {
                                            if name.name_id == ttf_parser::name_id::FULL_NAME {
                                                if let Some(full_name) = name.to_string() {
                                                    installed_fonts.push(InstalledFont {
                                                        path: entry
                                                            .path()
                                                            .to_string_lossy()
                                                            .to_string(),
                                                        full_name,
                                                    });
                                                }
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                            _ => {}
                        }
                    }
                }
            }
        }
    }

    Ok(installed_fonts)
}
