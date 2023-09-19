use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
pub struct Cli {
    pub destination: std::path::PathBuf,
    #[command(subcommand)]
    pub command: Commands,
}

#[derive(Subcommand)]
pub enum Commands {
    Start {
        /// Time interval
        #[arg(short, long)]
        interval: u64,
        // daemonize it
        #[arg(short, long)]
        daemon: bool,
    },
    Update {
        /// Disable compression
        #[arg(short, long)]
        soft: bool,
    },
    PrintDB,
    ResetDB,
}

pub fn cli() -> Cli {
    Cli::parse()
}
