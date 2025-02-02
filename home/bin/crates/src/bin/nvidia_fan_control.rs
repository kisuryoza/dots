#![deny(rust_2018_idioms, clippy::all)]

use std::process::Command;
use std::str;
use std::thread::sleep;
use std::time::Duration;

fn compute_rpm(curr_temp: f32) -> f32 {
    // [(temp, rpm)]
    const THRESHOLDS: [(f32, f32); 3] = [(40., 30.), (50., 60.), (60., 100.)];
    let mut rpm = 0.;

    if curr_temp <= THRESHOLDS[0].0 {
        // bellow min
        rpm = THRESHOLDS[0].1;
    } else if curr_temp >= THRESHOLDS.last().unwrap().0 {
        // above max
        rpm = THRESHOLDS.last().unwrap().1;
    } else {
        let mut iter = THRESHOLDS.iter();
        while let Some((target_temp, target_rpm)) = iter.next() {
            let Some((next_target_temp, next_target_rpm)) = iter.clone().next() else {
                break;
            };
            if curr_temp >= *target_temp && curr_temp <= *next_target_temp {
                let perc_between_ranges: f32 =
                    (curr_temp - target_temp) / (next_target_temp - target_temp);
                rpm = target_rpm + perc_between_ranges * (next_target_rpm - target_rpm);
            }
        }
    }
    rpm
}

fn run(iteration: usize) {
    let ret = Command::new("nvidia-smi")
        .args(["--query-gpu=temperature.gpu", "--format=csv,noheader"])
        .output()
        .expect("failed to get current temperature");
    let curr_temp: i32 = str::from_utf8(ret.stdout.trim_ascii())
        .unwrap()
        .parse()
        .unwrap();
    // let mut buf = String::new();
    // std::io::stdin().read_line(&mut buf).unwrap();
    // let curr_temp: i32 = buf.trim_end().parse().unwrap();

    let ret = Command::new("nvidia-smi")
        .args(["--query-gpu=fan.speed", "--format=csv,noheader,nounits"])
        .output()
        .expect("failed to get current rpm");
    let curr_rpm: i32 = str::from_utf8(ret.stdout.trim_ascii())
        .unwrap()
        .parse()
        .unwrap();

    let new_rpm = compute_rpm(curr_temp as f32) as i32;

    if new_rpm == curr_rpm {
        sleep(Duration::from_secs(10));
        return;
    }

    const OPT: &[u8; 29] = b"[fan:0]/GPUTargetFanSpeed=\0\0\0";
    let mut bytes: [u8; 29] = [0; 29];
    bytes.copy_from_slice(OPT);

    let mut digits: [u8; 3] = [0, 0, 0];

    let mut num_of_digits = 0;
    let mut rpm = new_rpm;
    while rpm > 0 {
        let digit: u8 = (rpm % 10).try_into().unwrap();
        digits[num_of_digits] = digit + b'0';
        rpm /= 10;
        num_of_digits += 1;
    }

    let start = bytes.len() - 3;
    let slice = &mut bytes[start..];
    num_of_digits -= 1;
    for byte in slice.iter_mut() {
        *byte = digits[num_of_digits];
        if num_of_digits == 0 {
            break;
        }
        num_of_digits -= 1;
    }
    let idx = bytes
        .iter()
        .enumerate()
        .find_map(|(i, v)| (*v == 0).then_some(i))
        .unwrap_or(bytes.len());

    println!("[{iteration}] temp={curr_temp}; old_rpm={curr_rpm}, new_rpm={new_rpm}");
    Command::new("nvidia-settings")
        .args(["-c", ":0", "-a", unsafe {
            str::from_utf8_unchecked(&bytes[0..idx])
        }])
        .stdout(std::process::Stdio::null())
        .stderr(std::process::Stdio::null())
        .status()
        .expect("failed to execute process");

    sleep(Duration::from_secs(5));
}

fn main() {
    Command::new("nvidia-settings")
        .args(["-c", ":0", "-a", "[gpu:0]/GPUFanControlState=1"])
        .status()
        .expect("failed to set GPUFanControlState");

    let mut i = 0;
    loop {
        run(i);
        i = i.wrapping_add(1);
    }
}
