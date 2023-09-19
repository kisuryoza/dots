use serde::{Deserialize, Serialize};
use std::{
    env,
    error::Error,
    ffi::OsStr,
    fs,
    io::ErrorKind,
    path::{Path, PathBuf},
    process::Command,
};

#[derive(Debug, Serialize, Deserialize)]
struct Addons {
    mods: Vec<Addon>,
}

#[derive(Debug, Serialize, Deserialize)]
struct Addon {
    path: String,
    subdirs: Vec<String>,
}

pub fn main() -> Result<(), Box<dyn Error>> {
    let binding = env::current_dir().unwrap();
    let cwd = binding.to_str().unwrap();
    let path = Path::new(&cwd).join("links");
    if path.exists() {
        fs::remove_dir_all(path)?;
    }

    let config = Path::new("StalkerAnomalyMods.yml");
    let config = fs::read_to_string(config)?;
    let addons: Addons = serde_yaml::from_str(&config)?;
    // create_links(&addons.mods[0], cwd);
    addons.mods.iter().for_each(|addon| {
        println!("Looking at {}", addon.path);
        create_links(addon, cwd);
        let source = String::new() + &addon.path + "/links";
        Command::new("cp")
            .arg("-rf")
            .arg(source)
            .arg(".")
            .status()
            .unwrap();
    });

    Ok(())
}

fn create_links(addon: &Addon, cwd: &str) {
    let addon_path = Path::new(cwd).join(&addon.path);
    let dir_for_links = Path::new(&addon_path).join("links");

    if dir_for_links.exists() {
        fs::remove_dir_all(dir_for_links.clone()).unwrap();
    };
    fs::create_dir(dir_for_links.clone()).unwrap();

    for subdir in &addon.subdirs {
        let subdir_path = Path::new(cwd).join(&addon.path).join(subdir);
        let subdir_name = subdir_path.file_name().unwrap();

        env::set_current_dir(subdir_path.clone()).unwrap();
        create_dir(&dir_for_links.join(subdir_name));
        visit_dir(&Path::new("."), subdir_name, &dir_for_links);
        env::set_current_dir(cwd).unwrap();
    }
}

fn visit_dir<P>(source: &P, subdir_name: &OsStr, dir_for_links: &PathBuf)
where
    P: AsRef<Path>,
{
    for entry in fs::read_dir(source).unwrap() {
        let entry = entry.unwrap();
        let path = entry.path();

        if path.canonicalize().unwrap() == dir_for_links.canonicalize().unwrap() {
            continue;
        };

        let target = dir_for_links.join(subdir_name).join(&path);
        if path.is_dir() {
            create_dir(&target);
            visit_dir(&path, subdir_name, dir_for_links);
        } else {
            if target.exists() {
                fs::remove_file(&target).unwrap()
            };
            std::os::unix::fs::symlink(path.canonicalize().unwrap(), target).unwrap();
        }
    }
}

fn create_dir<P>(dir: &P)
where
    P: AsRef<Path>,
{
    if let Err(e) = fs::create_dir(dir) {
        match e.kind() {
            ErrorKind::AlreadyExists => (),
            _ => panic!("Errors acquried during creating folders {:?}", e),
        }
    }
}
