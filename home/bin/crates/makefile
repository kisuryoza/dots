.PHONY: wp
wp:
	cd ./wp/
	RUSTFLAGS="-C target-cpu=native" cargo build --release
	cd ..
	install -vDm 744 ./target/release/wp ~/.local/bin

.PHONY: onefiles
onefiles:
	RUSTFLAGS="-C target-cpu=native" cargo build --release --bin=nvidia_fan_control
	install -sD target/release/nvidia_fan_control ~/.local/bin/
# 	rustc -C opt-level=3 -C lto=true -C target-cpu=native -C strip=symbols --out-dir target/ src/nvidia_fan_control.rs

.PHONY: all
all: wp onefiles

# vim: set ft=make ts=2 sw=2 sts=2 :
