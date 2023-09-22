mod cli;
mod daemonize;
mod start;
mod update_db;

use std::io::{stdout, Write};
use std::rc::Rc;

use color_eyre::Result;
use redb::{ReadableTable, TableDefinition};

#[allow(unused_imports)]
use tracing::{debug, error, info, trace, warn};

#[allow(unused)]
#[derive(Debug)]
struct File {
    path: Rc<str>,
    width: u32,
    height: u32,
}

impl File {
    fn new(path: &str, width: u32, height: u32) -> Self {
        Self {
            path: path.into(),
            width,
            height,
        }
    }
}

const LOCAL_DATABASE: &str = "wallpapers.redb";
const TABLE: TableDefinition<&str, (u32, u32)> = TableDefinition::new("wallpapers");

fn main() -> Result<()> {
    let cli = setup()?;

    if let cli::Commands::Start {
        interval: _,
        daemon,
    } = &cli.command
    {
        if *daemon {
            daemonize::daemonize();
        }
    }

    let path = cli.destination.join(LOCAL_DATABASE);

    if let cli::Commands::ResetDB = &cli.command {
        std::fs::remove_file(&path)?;
        info!("Removed database file at {}", path.display());
        return Ok(());
    }

    let db = if let Ok(db) = redb::Database::open(&path) {
        db
    } else {
        redb::Database::create(path)?
    };

    match &cli.command {
        cli::Commands::Update { soft } => update_db::update_db(cli.destination, *soft, db),
        cli::Commands::Start { interval, .. } => start::start(cli.destination, *interval, db),
        cli::Commands::PrintDB => print_db(db),
        cli::Commands::ResetDB => unreachable!(),
    }?;
    Ok(())
}

fn setup() -> Result<cli::Cli> {
    let _ = dotenvy::dotenv();

    if std::env::var("RUST_LIB_BACKTRACE").is_err() {
        std::env::set_var("RUST_LIB_BACKTRACE", "1")
    }
    color_eyre::install()?;

    if std::env::var("RUST_LOG").is_err() {
        std::env::set_var("RUST_LOG", "info")
    }

    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::filter::EnvFilter::from_default_env())
        .init();

    Ok(cli::cli())
}

fn print_db(db: redb::Database) -> Result<()> {
    let read_txn = db.begin_read()?;
    let table = read_txn.open_table(TABLE)?;
    let mut entries = 0;
    let mut wide_images = 0;
    let mut lock = stdout().lock();
    table.iter()?.for_each(|entry| {
        let item = entry.unwrap();
        let key = item.0.value();
        let values = item.1.value();
        entries += 1;
        if values.0 > values.1 {
            wide_images += 1;
        }
        writeln!(lock, "{key} - {:?}", values).unwrap();
    });
    info!(entries, wide_images);
    Ok(())
}

#[allow(unused)]
fn re_table(db: &redb::Database) -> Result<(), redb::Error> {
    let old_table: TableDefinition<&str, (u32, u32, u8)> = TableDefinition::new("wallpapers");
    let new_table = TABLE;

    let mut old_items: Vec<_> = Vec::new();
    {
        let read_txn = db.begin_read()?;
        let old_table = read_txn.open_table(old_table)?;
        for entry in old_table.iter()? {
            let (key, value) = entry?;
            let key = key.value();
            let key: Rc<str> = Rc::from(key);
            let value = value.value();
            old_items.push((key, value))
        }
    }

    let write_txn = db.begin_write()?;
    write_txn.delete_table(old_table)?;

    {
        let mut new_table = write_txn.open_table(new_table)?;
        for entry in old_items {
            let key = entry.0.as_ref();
            let (v1, v2, _) = entry.1;
            new_table.insert(key, (v1, v2))?;
        }
    }
    write_txn.commit()?;

    std::process::exit(0)
}
