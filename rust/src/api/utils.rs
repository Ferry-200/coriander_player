// show a file in explorer,
// select a directory path,
// open a link in browser, ...

use windows::{
    core::{h, Interface, HSTRING},
    Foundation::Uri,
    Storage::{Pickers::FolderPicker, StorageFile},
    System::{FolderLauncherOptions, Launcher},
    Win32::UI::{Shell::IInitializeWithWindow, WindowsAndMessaging::GetForegroundWindow},
};

/// path: 文件或文件夹的绝对路径。
/// 会打开父级目录并选择路径指向的项。
pub fn show_in_explorer(path: String) -> bool {
    _show_in_explorer(path).unwrap_or(false)
}

fn _show_in_explorer(path: String) -> Result<bool, windows::core::Error> {
    let file = StorageFile::GetFileFromPathAsync(&HSTRING::from(path))?.get()?;

    let options: FolderLauncherOptions = FolderLauncherOptions::new()?;
    let select_items = options.ItemsToSelect()?;
    select_items.Append(&file)?;

    Ok(Launcher::LaunchFolderPathWithOptionsAsync(
        &file.GetParentAsync()?.get()?.Path()?,
        &options,
    )?
    .get()?)
}

pub fn pick_single_folder() -> Option<String> {
    Some(_pick_single_folder().unwrap())
}

fn _pick_single_folder() -> Result<String, windows::core::Error> {
    let folder_picker = FolderPicker::new()?;

    unsafe {
        let hwnd = GetForegroundWindow();
        // see https://learn.microsoft.com/en-us/windows/apps/develop/ui-input/display-ui-objects#winui-3-with-c
        // see https://github.com/artiga033/winui_rust/blob/b90df60bfc18c33dfd63c380dcf0b615052105be/src/main.rs#L73
        let initialize_with_window = folder_picker.cast::<IInitializeWithWindow>()?;
        initialize_with_window.Initialize(hwnd)?;
    }

    folder_picker.FileTypeFilter()?.Append(h!("*"))?;
    let folder = folder_picker.PickSingleFolderAsync()?.get()?;

    Ok(folder.Path()?.to_string())
}

pub fn launch_in_browser(uri: String) -> bool {
    _launch_in_browser(uri).unwrap_or(false)
}

fn _launch_in_browser(uri: String) -> Result<bool, windows::core::Error> {
    Ok(Launcher::LaunchUriAsync(&Uri::CreateUri(&HSTRING::from(uri))?)?.get()?)
}
