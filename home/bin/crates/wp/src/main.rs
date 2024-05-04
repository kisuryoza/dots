#![warn(
    clippy::all,
    // clippy::nursery,
    // clippy::pedantic,
    missing_debug_implementations,
    // missing_docs,
    rust_2018_idioms,
    unreachable_pub
)]

mod cli;
mod daemonize;
mod start;
mod update_db;

use std::io::{stdout, Write};
use std::rc::Rc;

use clap::Parser;
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
const TABLE: TableDefinition<'_, &str, (u32, u32)> = TableDefinition::new("wallpapers");

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
        cli::Commands::Update { soft } => update_db::update_db(&cli.destination, *soft, &db),
        cli::Commands::Start { interval, .. } => start::start(&cli.destination, *interval, db),
        cli::Commands::PrintDB => print_db(&db),
        cli::Commands::ResetDB => unreachable!(),
    }?;
    Ok(())
}

fn setup() -> Result<cli::Cli> {
    let _ = dotenvy::dotenv();

    if std::env::var("RUST_LIB_BACKTRACE").is_err() {
        std::env::set_var("RUST_LIB_BACKTRACE", "1");
    }
    color_eyre::install()?;

    if std::env::var("RUST_LOG").is_err() {
        std::env::set_var("RUST_LOG", "info");
    }

    tracing_subscriber::fmt()
        .without_time()
        .with_env_filter(tracing_subscriber::filter::EnvFilter::from_default_env())
        .init();

    Ok(cli::Cli::parse())
}

fn print_db(db: &redb::Database) -> Result<()> {
    let read_txn = db.begin_read()?;
    let table = read_txn.open_table(TABLE)?;
    let mut entries = 0;
    let mut wide_images = 0;
    let mut lock = stdout().lock();
    for entry in table.iter()? {
        let item = entry.unwrap();
        let key = item.0.value();
        let values = item.1.value();
        entries += 1;
        if values.0 > values.1 {
            wide_images += 1;
        }
        writeln!(lock, "{}:{}:{}", key, values.0, values.1)?;
    }
    info!(entries, wide_images);
    Ok(())
}
