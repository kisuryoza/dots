mod cli;
mod daemonize;
mod start;
mod update_db;

use std::rc::Rc;

use redb::{ReadableTable, TableDefinition};
use tracing::Level;

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

fn main() {
    let _ = dotenvy::dotenv();
    let tracing_level = &std::env::var("DEBUG_LEVEL").unwrap_or("INFO".to_string());
    tracing_subscriber::fmt()
        .with_max_level(
            <Level as std::str::FromStr>::from_str(tracing_level).unwrap_or(Level::INFO),
        )
        .init();

    let cli = cli::cli();

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
        std::fs::remove_file(&path).unwrap();
        tracing::info!("Removed database file at {}", path.display());
        return;
    }

    let db = if let Ok(db) = redb::Database::open(&path) {
        db
    } else {
        redb::Database::create(path).unwrap()
    };

    match &cli.command {
        cli::Commands::Update { soft } => update_db::update_db(cli.destination, *soft, db),
        cli::Commands::Start { interval, .. } => start::start(cli.destination, *interval, db),
        cli::Commands::PrintDB => print_db(db),
        cli::Commands::ResetDB => unreachable!(),
    }
    .unwrap()
}

fn print_db(db: redb::Database) -> Result<(), Box<dyn std::error::Error>> {
    let read_txn = db.begin_read()?;
    let table = read_txn.open_table(TABLE)?;
    let mut entries = 0;
    let mut wide_images = 0;
    table.iter()?.for_each(|entry| {
        let item = entry.unwrap();
        let key = item.0.value();
        let values = item.1.value();
        entries += 1;
        if values.0 > values.1 {
            wide_images += 1;
        }
        println!("{key} - {:?}", values)
    });
    tracing::info!(entries, wide_images);
    Ok(())
}

#[allow(unused)]
fn re_table(db: &redb::Database) -> Result<(), redb::Error> {
    let old_table: TableDefinition<&str, (u32, u32, u8)> = TableDefinition::new("wallpapers");
    let new_table: TableDefinition<&str, (u32, u32)> = TABLE;

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

/* fn main() {
    let _ = dotenvy::dotenv();
    let database_url: &str =
        &std::env::var("DATABASE_URL").unwrap_or("sqlite://data.db".to_owned());

    let db = async_std::task::block_on(async {
        sqlx::sqlite::SqlitePoolOptions::new()
            .connect(database_url)
            .await
            .unwrap()
    });

    let cli = Cli::parse();
    match &cli.command {
        Commands::Start => set_wallpaper::main(db),
        Commands::Update => async_std::task::block_on(async { update::main(db).await }),
    }
    .unwrap()
} */
