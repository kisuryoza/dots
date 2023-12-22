mod minecraft;
mod stalker;

use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Stalker,
    Minecraft,
}

fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Commands::Stalker => stalker::main(),
        Commands::Minecraft => minecraft::main(),
    }
    .unwrap()
}
