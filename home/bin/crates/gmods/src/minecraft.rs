use std::{
    error::Error,
    fs::{self, File},
    io::Write,
    path::Path,
};

use curl::easy::{Easy2, Handler, WriteError};
use serde::{Deserialize, Serialize};
use serde_json::Value;
use sha2::{Digest, Sha512};

const MOD_LOADER: &str = "forge";
const VERSION: &str = "1.20.1";

struct Collector(Vec<u8>);

impl Handler for Collector {
    fn write(&mut self, data: &[u8]) -> Result<usize, WriteError> {
        self.0.extend_from_slice(data);
        Ok(data.len())
    }
}

#[derive(Serialize, Deserialize, Debug)]
struct Categories(Vec<Category>);

#[derive(Serialize, Deserialize, Debug)]
struct Category {
    pub category: String,
    pub mods: Vec<Mod>,
}

#[derive(Serialize, Deserialize, Debug)]
struct Mod {
    pub url: String,
}

fn get_request(url: &str) -> Vec<u8> {
    let mut easy = Easy2::new(Collector(Vec::new()));
    easy.url(url).unwrap();
    easy.get(true).unwrap();
    easy.useragent("Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0")
        .unwrap();
    easy.perform().unwrap();
    easy.get_ref().0.clone()
}

fn parse_modrinth_project_id_version(json: String, category: &str) {
    let json: Vec<Value> = match serde_json::from_str(&json) {
        Ok(json) => json,
        Err(err) => {
            println!("Failed to convert data to json: {:?}", err);
            return;
        }
    };
    let _easy = Easy2::new(Collector(Vec::new()));

    for obj in json {
        let loaders = obj["loaders"].as_array().unwrap();
        let game_versions = obj["game_versions"].as_array().unwrap();

        let is_forge = loaders.contains(&Value::String(MOD_LOADER.to_owned()));
        let is_right_version = game_versions.contains(&Value::String(VERSION.to_owned()));

        if !is_forge || !is_right_version {
            continue;
        }

        let files = obj["files"].as_array().unwrap();
        for file in files {
            let is_primary = file["primary"].as_bool().unwrap();
            if !is_primary {
                continue;
            }

            let url = file["url"]
                .as_str()
                .unwrap()
                .replace("cdn.modrinth.com", "cdn-raw.modrinth.com");
            let filename = file["filename"].as_str().unwrap();

            let path = Path::new(category).join(filename);
            if path.exists() {
                println!(r#"File "{}" exists. Comparing hashes."#, filename);

                let sha512_from_json = file["hashes"]["sha512"].as_str().unwrap();

                let contents_of_file = fs::read(path.clone()).unwrap();
                let calculated_hash = Sha512::digest(contents_of_file);
                let hash_in_hex = to_hex(&calculated_hash);

                if sha512_from_json.to_lowercase() != hash_in_hex {
                    println!(
                        r#"Wrong hash comparison for "{}". Re-downloading..."#,
                        filename
                    );
                    let mut output = File::create(path).unwrap();
                    let data = get_request(&url);
                    output.write_all(&data).unwrap();
                }
            } else {
                println!(r#"Downloading "{}" ..."#, filename);
                let mut output = File::create(path).unwrap();
                let data = get_request(&url);
                output.write_all(&data).unwrap();
            };
        }
        break;
    }
}

pub fn main() -> Result<(), Box<dyn Error>> {
    let mods = fs::read_to_string(Path::new("MinecraftMods.yml")).unwrap();
    let categories: Categories = match serde_yaml::from_str(&mods) {
        Ok(categories) => categories,
        Err(err) => panic!("Failed to convert file contents to yml: {:?}", err),
    };

    for category in categories.0 {
        let category_name = category.category;
        fs::DirBuilder::new()
            .recursive(true)
            .create(category_name.clone())
            .unwrap();

        for addon in category.mods {
            let url = addon.url;

            if !url.contains("modrinth.com") {
                continue;
            }

            let name = url.split('/').last().unwrap();
            println!("Requesting data for {}", name);

            let url = format!("https://api.modrinth.com/v2/project/{name}/version");
            let json = String::from_utf8_lossy(&get_request(&url)).to_string();
            parse_modrinth_project_id_version(json, &category_name);
        }
    }

    Ok(())
}

pub fn to_hex(blob: &[u8]) -> String {
    let mut buf = String::new();
    for ch in blob {
        fn hex_from_digit(num: u8) -> char {
            if num < 10 {
                (b'0' + num) as char
            } else {
                (b'A' + num - 10) as char
            }
        }
        buf.push(hex_from_digit(ch / 16));
        buf.push(hex_from_digit(ch % 16));
    }
    buf
}
