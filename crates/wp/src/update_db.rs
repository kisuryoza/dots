use image::GenericImageView;
use redb::{Database, ReadableTable};
use std::{
    fs,
    io::{self, Write},
    path::{Path, PathBuf},
    process::Command,
    rc::Rc,
};

use crate::TABLE;

pub fn update_db(
    destination: PathBuf,
    soft: bool,
    db: Database,
) -> Result<(), Box<dyn std::error::Error>> {
    let files = visit_dirs(&destination).unwrap();

    init_table(&db).unwrap();

    let amount_of_new_entries = set_new_entries(&db, &destination, soft, &files).unwrap();
    let amount_of_obsolete_entries = remove_obsolete_entries(&db, &files).unwrap();

    tracing::info!("New entries: {}", amount_of_new_entries);
    tracing::info!("Obsolete entries: {}", amount_of_obsolete_entries);

    Ok(())
}

fn init_table(db: &Database) -> Result<(), Box<dyn std::error::Error>> {
    let write_txn = db.begin_write()?;
    let _ = write_txn.open_table(TABLE)?;
    write_txn.commit()?;
    Ok(())
}

/// INSERT files into DB that exist in Filesystem but not in DB
fn set_new_entries(
    db: &Database,
    destination: &Path,
    soft: bool,
    files: &[Rc<str>],
) -> Result<usize, Box<dyn std::error::Error>> {
    tracing::trace!("Setting new entries");

    let read_txn = db.begin_read()?;
    let table = read_txn.open_table(TABLE)?;

    let mut new_files: Vec<&str> = Vec::new();
    for file in files.iter() {
        let file = file.as_ref();
        if table.get(file).unwrap().is_some() {
            continue;
        }
        if !soft {
            compress(file)?;
        }
        new_files.push(file)
    }
    let amount_of_new_entries = new_files.len();

    let write_txn = db.begin_write()?;
    {
        let mut table = write_txn.open_table(TABLE)?;
        for file in new_files {
            let (width, height) = get_dimensions(destination.join(file));
            table.insert(file, (width, height))?;
        }
    }
    write_txn.commit()?;
    Ok(amount_of_new_entries)
}

/// DELETE files from DB that dont exist in Filesystem but do in DB
fn remove_obsolete_entries(
    db: &Database,
    files: &[Rc<str>],
) -> Result<usize, Box<dyn std::error::Error>> {
    tracing::trace!("Removing obsolete entries");

    let read_txn = db.begin_read()?;
    let table = read_txn.open_table(TABLE)?;

    let mut obsolete_keys: Vec<Rc<str>> = Vec::new();
    for entry in table.iter()? {
        let (key, _) = entry?;
        let key = key.value();
        if files.iter().any(|p| p.as_ref() == key) {
            continue;
        };
        let rc: Rc<str> = Rc::from(key);
        obsolete_keys.push(rc);
    }
    let amount_of_obsolete_entries = obsolete_keys.len();

    let write_txn = db.begin_write()?;
    {
        let mut table = write_txn.open_table(TABLE)?;
        obsolete_keys.into_iter().for_each(|key| {
            table.remove(key.as_ref()).unwrap();
        });
    }
    write_txn.commit()?;
    Ok(amount_of_obsolete_entries)
}

fn visit_dirs(path: &Path) -> std::io::Result<Vec<Rc<str>>> {
    tracing::trace!("Visiting directories");
    fn visit(prefix: &Path, path: &Path, buffer: &mut Vec<Rc<str>>) -> std::io::Result<()> {
        for entry in fs::read_dir(path)? {
            let path = entry?.path();

            if is_file_hidden(&path) {
                continue;
            }

            if path.is_dir() {
                visit(prefix, &path, buffer)?
            } else if let Some(ext) = path.extension() {
                if ext != "png" && ext != "jpg" {
                    continue;
                }

                let path = path.strip_prefix(prefix).unwrap().to_str().unwrap();
                let rc: Rc<str> = Rc::from(path);
                buffer.push(rc)
            };
        }
        Ok(())
    }

    let mut list = Vec::new();
    visit(path, path, &mut list)?;
    list.sort();
    Ok(list)

    /* fs::read_dir(path)?
    .filter(|entry| {
        if let Ok(entry) = entry {
            let path = entry.path();
            !is_file_hidden(&path)
        } else {
            false
        }
    })
    .map(|entry| entry.map(|e| e.path()))
    .take(10)
    .collect::<Result<Vec<_>, io::Error>>() */
}

fn is_file_hidden<P>(path: P) -> bool
where
    P: AsRef<Path>,
{
    if let Some(file_name) = path.as_ref().file_name() {
        if let Some(first_char) = file_name.to_str().unwrap_or_default().as_bytes().first() {
            if first_char == &b'.' {
                return true;
            }
        }
    }
    false
}

fn compress<P>(file: P) -> io::Result<()>
where
    P: AsRef<Path>,
{
    let file = file.as_ref();
    if let Some(ext) = file.extension() {
        let file_str = file.to_str().unwrap();
        match ext.to_str() {
            Some("png") => {
                let output = Command::new("oxipng")
                    .args(["-s", "--nb", "--nc", "--np", "--ng", "--nx", "--nz"])
                    .arg(file_str)
                    .output()?;
                io::stdout().write_all(&output.stdout)?;
            }
            Some("jpg") => {
                let output = Command::new("jpegoptim").arg(file_str).output()?;
                io::stdout().write_all(&output.stdout)?;
            }
            _ => (),
        };
    }
    tracing::info!("Compressed {}", file.display());

    Ok(())
}

fn get_dimensions<P>(file: P) -> (u32, u32)
where
    P: AsRef<Path>,
{
    let (width, height) = if let Ok(img) = image::open(&file) {
        img.dimensions()
    } else {
        (0, 0)
    };
    tracing::trace!(
        "Dimensions of {} - {width} {height}",
        file.as_ref().display()
    );
    (width, height)
}

// SQLx variant
/* pub async fn main(db: sqlx::Pool<sqlx::Sqlite>) -> Result<(), Box<dyn std::error::Error>> {
    let files = visit_dirs(Path::new(".")).unwrap();

    /* files.iter().for_each(|file| {
        let file = file.strip_prefix(".").unwrap();
        // let 'file' be '123/.../456.png' then 'parent' would be 'Some(123)'
        // let 'file' be '123.png' then 'parent' would be 'None'
        let mut components = file.components();
        let parent = match components.next() {
            Some(Component::Normal(first_component)) => {
                if components.next().is_some() {
                    Some(PathBuf::from(first_component))
                } else {
                    None
                }
            }
            _ => None,
        };

        if Some(parent) = parent {
            /* let folders: Vec<crate::Folder> =
                sqlx::query_as!(crate::Folder, "SELECT * FROM folders")
                    .fetch_all(&mut *conn)
                    .await
                    .unwrap(); */
        }
    }); */
    set_new_entries(&db, &files).unwrap();
    remove_obsolete_entries(&db, &files).unwrap();

    Ok(())
}

/// INSERT files into DB that exist in Filesystem but not in DB
fn set_new_entries(db: sqlx::Pool<sqlx::Sqlite>, files: &[PathBuf]) -> Result<(), Box<dyn std::error::Error>> {
    let mut conn = db.acquire().await?;
    for path in files.iter() {
        let path = path.to_str().unwrap();
        let row: sqlx::Result<File> = sqlx::query_as!(
            File,
            r#"
            SELECT path, width, height
            FROM files
            WHERE path = ?
            "#,
            path
        )
        .fetch_one(&mut *conn)
        .await;

        if row.is_ok() {
            continue;
        }

        let (width, height) = get_dimensions(file);
        sqlx::query!(
            r#"
            INSERT INTO files (path, width, height)
            VALUES (?, ?, ?)
            "#,
            path,
            width,
            height
        )
        .execute(&mut *conn)
        .await?;
    }
    Ok(())
}

/// DELETE files from DB that dont exist in Filesystem but do in DB
fn remove_obsolete_entries(db: sqlx::Pool<sqlx::Sqlite>, files: &[PathBuf]) -> Result<(), Box<dyn std::error::Error>> {
    let mut conn = db.acquire().await?;
    let rows: Vec<File> = sqlx::query_as!(File, "SELECT path, width, height FROM files")
        .fetch_all(&mut *conn)
        .await?;
    for row in rows.iter() {
        let path = &row.path;
        if files.contains(&PathBuf::from(path.clone())) {
            continue;
        }

        sqlx::query!(
            r#"
            DELETE FROM files
            WHERE path = ?
            "#,
            path
        )
        .execute(&mut *conn)
        .await?;
    }
    Ok(())
} */
