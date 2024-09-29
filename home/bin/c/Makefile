CC := clang

BUILD_DIR := build

OPT := -O3 -march=native
WARN := -Wall -Wextra -Wpedantic
CFLAGS := ${OPT} ${WARN} -std=c99

$(BUILD_DIR)/fork: $(BUILD_DIR)/fork.o
	$(CC) $^ -o $@

$(BUILD_DIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

.PHONY: all
all: $(BUILD_DIR)/fork

.PHONY: install
install: all
	install -vDm 744 $(BUILD_DIR)/fork ~/.local/bin/

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
