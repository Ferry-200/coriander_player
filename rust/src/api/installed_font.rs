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
            let entry = match entry_result {
                Ok(value) => value,
                Err(_) => continue,
            };
            let path = entry.path();
            let extension = match path.extension() {
                Some(value) => match value.to_str() {
                    Some(value) => value,
                    None => continue,
                },
                None => todo!(),
            };
            match extension.to_lowercase().as_str() {
                "ttf" | "ttc" | "otf" => {
                    let font = match fs::read(path) {
                        Ok(value) => value,
                        Err(_) => continue,
                    };
                    let face = match ttf_parser::Face::parse(&font, 0) {
                        Ok(value) => value,
                        Err(_) => continue,
                    };
                    for name in face.names() {
                        if name.name_id == ttf_parser::name_id::FULL_NAME {
                            let full_name = match name.to_string() {
                                Some(value) => value,
                                None => continue,
                            };
                            installed_fonts.push(InstalledFont {
                                path: entry
                                    .path()
                                    .to_string_lossy()
                                    .to_string(),
                                full_name,
                            });
                            break;
                        }
                    }
                }
                _ => continue
            }
        }
    }

    let user_installed_fonts_path =
        PathBuf::from(env::var("USERPROFILE")?).join("AppData\\Local\\Microsoft\\Windows\\Fonts");
    if let Ok(user_installed_fonts) = read_dir(user_installed_fonts_path) {
        for entry_result in user_installed_fonts {
            let entry = match entry_result {
                Ok(value) => value,
                Err(_) => continue,
            };
            let path = entry.path();
            let extension = match path.extension() {
                Some(value) => match value.to_str() {
                    Some(value) => value,
                    None => continue,
                },
                None => todo!(),
            };
            match extension.to_lowercase().as_str() {
                "ttf" | "ttc" | "otf" => {
                    let font = match fs::read(path) {
                        Ok(value) => value,
                        Err(_) => continue,
                    };
                    let face = match ttf_parser::Face::parse(&font, 0) {
                        Ok(value) => value,
                        Err(_) => continue,
                    };
                    for name in face.names() {
                        if name.name_id == ttf_parser::name_id::FULL_NAME {
                            let full_name = match name.to_string() {
                                Some(value) => value,
                                None => continue,
                            };
                            installed_fonts.push(InstalledFont {
                                path: entry
                                    .path()
                                    .to_string_lossy()
                                    .to_string(),
                                full_name,
                            });
                            break;
                        }
                    }
                }
                _ => continue
            }
        }
    }

    Ok(installed_fonts)
}
