use std::{path::PathBuf, process::Command, thread::sleep, time::Duration};

use color_eyre::Result;
use rand::seq::SliceRandom;
use redb::ReadableTable;

#[allow(unused_imports)]
use tracing::{debug, error, info, trace, warn};

use crate::{File, TABLE};

pub fn start(destination: PathBuf, interval: u64, db: redb::Database) -> Result<()> {
    let read_txn = db.begin_read()?;
    let table = read_txn.open_table(TABLE)?;

    let mut files: Vec<File> = Vec::new();
    for entry in table.iter()? {
        let (key, values) = entry?;
        let (width, height) = values.value();

        if width < height {
            continue;
        }

        let key = key.value();
        let path = destination.join(key);
        let path = path.to_str().unwrap();

        files.push(File::new(path, width, height))
    }

    // Drop database and free fs
    drop(table);
    drop(read_txn);
    drop(db);

    let mut rng = rand::thread_rng();
    files.shuffle(&mut rng);

    if std::env::var("WAYLAND_DISPLAY").is_ok() {
        Command::new("swww").arg("init").status()?;
    }
    set_wallpaper(interval, files)
}

fn command() -> Command {
    if std::env::var("WAYLAND_DISPLAY").is_ok() {
        let mut p = Command::new("swww");
        p.arg("img");
        p
    } else {
        let mut p = Command::new("feh");
        p.args(["--no-fehbg", "--bg-fill"]);
        p
    }
}

fn set_wallpaper(interval: u64, files: Vec<File>) -> ! {
    let mut iterator = files.iter().cycle();
    loop {
        if let Some(file) = iterator.next() {
            let path = file.path.as_ref();
            info!("Setting wallpaper: {}", path);
            let mut command = command();
            command
                .arg(path)
                .status()
                .expect("failed to execute process");

            let _ = std::fs::remove_file("/tmp/wallpaper");
            let _ = std::os::unix::fs::symlink(path, "/tmp/wallpaper");
        }

        sleep(Duration::from_secs(interval));
    }
}
