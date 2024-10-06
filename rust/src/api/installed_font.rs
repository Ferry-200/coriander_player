use std::{
    env,
    fs::{self, read_dir},
    path::{Path, PathBuf},
};

use super::logger::log_to_dart;

pub struct InstalledFont {
    pub path: String,
    pub full_name: String,
}

pub fn get_installed_fonts() -> Option<Vec<InstalledFont>> {
    match _get_installed_fonts() {
        Ok(value) => Some(value),
        Err(_) => None,
    }
}

fn _read_fonts_in_folder(path: &Path, result: &mut Vec<InstalledFont>) -> anyhow::Result<()> {
    log_to_dart(format!("read fonts in: {}", path.to_string_lossy()));

    let dir = match read_dir(path) {
        Ok(val) => val,
        Err(err) => {
            log_to_dart(err.to_string());
            return Err(err.into());
        }
    };

    for entry_result in dir {
        let entry = match entry_result {
            Ok(value) => value,
            Err(err) => {
                log_to_dart(err.to_string());
                continue;
            }
        };
        let path = entry.path();
        let extension = match path.extension() {
            Some(value) => match value.to_str() {
                Some(value) => value,
                None => continue,
            },
            None => continue,
        };
        match extension.to_lowercase().as_str() {
            "ttf" | "ttc" | "otf" => {
                let font = match fs::read(path) {
                    Ok(value) => value,
                    Err(err) => {
                        log_to_dart(err.to_string());
                        continue;
                    }
                };
                let face = match ttf_parser::Face::parse(&font, 0) {
                    Ok(value) => value,
                    Err(err) => {
                        log_to_dart(err.to_string());
                        continue;
                    }
                };
                for name in face.names() {
                    if name.name_id == ttf_parser::name_id::FULL_NAME {
                        let full_name = match name.to_string() {
                            Some(value) => value,
                            None => continue,
                        };
                        result.push(InstalledFont {
                            path: entry.path().to_string_lossy().to_string(),
                            full_name,
                        });
                        break;
                    }
                }
            }
            _ => continue,
        }
    }

    Ok(())
}

fn _get_installed_fonts() -> Result<Vec<InstalledFont>, anyhow::Error> {
    let mut installed_fonts: Vec<InstalledFont> = vec![];

    let system_installed_fonts_path = Path::new("C:\\Windows\\Fonts");
    let _ = _read_fonts_in_folder(system_installed_fonts_path, &mut installed_fonts);

    let user_installed_fonts_path =
        PathBuf::from(env::var("USERPROFILE")?).join("AppData\\Local\\Microsoft\\Windows\\Fonts");
    let _ = _read_fonts_in_folder(&user_installed_fonts_path, &mut installed_fonts);

    Ok(installed_fonts)
}
