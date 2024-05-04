use std::{path::Path, process::Command, thread::sleep, time::Duration};

use color_eyre::Result;
use rand::seq::SliceRandom;
use redb::ReadableTable;

#[allow(unused_imports)]
use tracing::{debug, error, info, trace, warn};

use crate::{File, TABLE};

pub(crate) fn start<P>(destination: P, interval: u64, db: redb::Database) -> Result<()>
where
    P: AsRef<Path>,
{
    let destination = destination.as_ref();
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

        files.push(File::new(path, width, height));
    }

    // Drop database and free fs
    drop(table);
    drop(read_txn);
    drop(db);

    let mut rng = rand::thread_rng();
    files.shuffle(&mut rng);

    iterate(interval, &files)
}

fn iterate(interval: u64, files: &[File]) -> ! {
    let mut iterator = files.iter().cycle();
    loop {
        if let Some(next_file) = iterator.next() {
            let path = next_file.path.as_ref();
            info!("Setting wallpaper: {}", path);
            set_it(path);

            let _ = std::fs::remove_file("/tmp/wallpaper");
            let _ = std::os::unix::fs::symlink(path, "/tmp/wallpaper");
        }

        sleep(Duration::from_secs(interval));
    }
}

fn set_it(next_path: &str) {
    if std::env::var("WAYLAND_DISPLAY").is_ok() {
        Command::new("swww")
            .args(["img", "-t", "none", next_path])
            .status()
            .expect("failed to execute process");

        return;
    }

    Command::new("feh")
        .args(["--no-fehbg", "--bg-fill", next_path])
        .status()
        .expect("failed to execute process");
}
