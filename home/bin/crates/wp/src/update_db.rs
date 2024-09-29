use std::{fs, io::{self, Write}, path::Path, process::Command, rc::Rc};

use color_eyre::Result;
use redb::{Database, ReadableTable};

#[allow(unused_imports)]
use tracing::{debug, error, info, trace, warn};

use crate::TABLE;

pub(crate) fn update_db<P>(destination: P, soft: bool, db: &Database) -> Result<()>
where
    P: AsRef<Path>,
{
    let destination = destination.as_ref();
    let files = visit_dirs(destination)?;

    init_table(db)?;

    let amount_of_new_entries = set_new_entries(db, destination, soft, &files)?;
    let amount_of_obsolete_entries = remove_obsolete_entries(db, &files)?;

    info!("New entries: {}", amount_of_new_entries);
    info!("Obsolete entries: {}", amount_of_obsolete_entries);

    Ok(())
}

fn init_table(db: &Database) -> Result<()> {
    let write_txn = db.begin_write()?;
    let _ = write_txn.open_table(TABLE)?;
    write_txn.commit()?;
    Ok(())
}

/// INSERT files into DB that exist in Filesystem but not in DB
fn set_new_entries<P, T>(db: &Database, destination: P, soft: bool, files: &[T]) -> Result<usize>
where
    P: AsRef<Path>,
    T: AsRef<str>,
{
    let read_txn = db.begin_read()?;
    let table = read_txn.open_table(TABLE)?;

    let new_files = files.iter().filter(|file| {
        let file = file.as_ref();
        table.get(file).unwrap().is_none()
    });

    let write_txn = db.begin_write()?;
    let mut table = write_txn.open_table(TABLE)?;

    let destination = destination.as_ref();
    let amount_of_new_entries = new_files
        .map(|file| -> Result<()> {
            let file = file.as_ref();
            let path = destination.join(file);
            if !soft {
                compress(&path)?;
            }
            let (width, height) = get_dimensions(path);
            table.insert(file, (width, height))?;
            Ok(())
        })
        .count();
    drop(table);

    write_txn.commit()?;
    Ok(amount_of_new_entries)
}

/// DELETE files from DB that dont exist in Filesystem but do in DB
fn remove_obsolete_entries<T>(db: &Database, files: &[T]) -> Result<usize>
where
    T: AsRef<str>,
{
    let read_txn = db.begin_read()?;
    let table = read_txn.open_table(TABLE)?;

    let obsolete_keys = table.iter()?.filter_map(|entry| {
        let (key, _) = entry.unwrap();
        let key = key.value();

        if files.iter().any(|p| p.as_ref() == key) {
            None
        } else {
            let rc: Rc<str> = Rc::from(key);
            Some(rc)
        }
    });

    let write_txn = db.begin_write()?;
    let mut table = write_txn.open_table(TABLE)?;

    let amount_of_obsolete_entries = obsolete_keys
        .map(|key| -> Result<()> {
            table.remove(key.as_ref())?;
            Ok(())
        })
        .count();
    drop(table);

    write_txn.commit()?;
    Ok(amount_of_obsolete_entries)
}

fn visit_dirs(path: &Path) -> Result<Vec<Rc<str>>> {
    fn visit(prefix: &Path, path: &Path, buffer: &mut Vec<Rc<str>>) -> Result<()> {
        for entry in fs::read_dir(path)? {
            let path = entry?.path();

            if is_file_hidden(&path) {
                continue;
            }

            if path.is_dir() {
                visit(prefix, &path, buffer)?;
            } else if let Some(ext) = path.extension() {
                if ext != "png" && ext != "jpg" {
                    continue;
                }

                let path = path.strip_prefix(prefix)?.to_str().unwrap();
                let rc: Rc<str> = Rc::from(path);
                buffer.push(rc);
            };
        }
        Ok(())
    }

    let mut list = Vec::new();
    visit(path, path, &mut list)?;
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
    let first_char = path
        .as_ref()
        .file_name()
        .and_then(|x| x.to_str())
        .and_then(|x| x.as_bytes().first());
    let Some(first_char) = first_char else {
        return false;
    };
    if first_char == &b'.' {
        return true;
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
                    .args(["-Z", "--opt=max", "--fast", file_str])
                    .output()?;
                io::stdout().write_all(&output.stdout)?;
                io::stdout().write_all(&output.stderr)?;
                io::stdout().flush()?
            }
            Some("jpg") => {
                let output = Command::new("jpegoptim").arg(file_str).output()?;
                io::stdout().write_all(&output.stdout)?;
                io::stdout().write_all(&output.stderr)?;
                io::stdout().flush()?
            }
            _ => unreachable!(),
        };
    }

    Ok(())
}

fn get_dimensions<P>(file: P) -> (u32, u32)
where
    P: AsRef<Path>,
{
    use image::GenericImageView;
    let (width, height) = image::open(&file).map_or((0, 0), |img| img.dimensions());
    info!(
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

#[cfg(test)]
mod tests {
    use super::*;

    fn generate_arrays() -> (Vec<String>, Vec<String>) {
        let more: Vec<_> = (0..10_000).map(|n| format!("file_{n}")).collect();
        let less: Vec<_> = more.iter().take(7_000).cloned().collect();
        (more, less)
    }

    fn create_db<T>(files: &[T]) -> Database
    where
        T: AsRef<str>,
    {
        let tmpfile = tempfile::NamedTempFile::new().unwrap();
        let db = Database::create(tmpfile.path()).unwrap();
        let write_txn = db.begin_write().unwrap();
        {
            let mut table = write_txn.open_table(TABLE).unwrap();
            for file in files {
                table.insert(file.as_ref(), (0, 0)).unwrap();
            }
        }
        write_txn.commit().unwrap();
        db
    }

    fn pre_build(for_db: &[String], as_files: Vec<String>) -> (Database, Vec<Rc<str>>) {
        let db = create_db(for_db);
        let files: Vec<Rc<str>> = as_files.into_iter().map(Rc::from).collect();
        (db, files)
    }

    #[test]
    fn new_entries() {
        let (more, less) = generate_arrays();
        let (db, files) = pre_build(&less, more);
        let amount_of_new_entries = set_new_entries(&db, Path::new(""), true, &files).unwrap();

        assert_eq!(amount_of_new_entries, 3000);
    }

    #[test]
    fn obsolete_entries() {
        let (more, less) = generate_arrays();
        let (db, files) = pre_build(&more, less);
        let amount_of_obsolete_entries = remove_obsolete_entries(&db, &files).unwrap();

        assert_eq!(amount_of_obsolete_entries, 3000);
    }
}
