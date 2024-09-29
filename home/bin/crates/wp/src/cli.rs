use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
pub(crate) struct Cli {
    pub(crate) destination: std::path::PathBuf,
    #[command(subcommand)]
    pub(crate) command: Commands,
}

#[derive(Subcommand)]
pub(crate) enum Commands {
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
}
