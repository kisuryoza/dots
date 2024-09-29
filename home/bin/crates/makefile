.PHONY: wp
wp:
	RUSTFLAGS="-C target-cpu=native" cargo build --release --bin=wp
	install -vDm 744 ./target/release/wp ~/.local/bin

.PHONY: gmods
gmods:
	RUSTFLAGS="-C target-cpu=native" cargo build --release --bin=gmods
	install -vDm 744 ./target/release/gmods ~/.local/bin

.PHONY: all
all: wp gmods

# vim: set ft=make ts=2 sw=2 sts=2 :
