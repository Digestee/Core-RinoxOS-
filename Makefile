# Makefile для RinoxOS (финальная стабильная версия)

# Целевая архитектура для кросс-компиляции
TARGET = i386-elf
# Имя ядра
KERNEL = rinox.bin
# Образ дискеты с GRUB
FLOPPY = grub.img

# Инструменты
CC = clang
AS = nasm
LD = ld.lld

# Флаги компиляции
CFLAGS = --target=$(TARGET) -ffreestanding -g -Wall -Wextra
ASFLAGS = -f elf32

# Директории
SRC_DIR = src
BUILD_DIR = build

# Исходные файлы и объектные файлы (автоматический поиск)
C_SOURCES = $(wildcard $(SRC_DIR)/*.c)
S_SOURCES = $(wildcard $(SRC_DIR)/*.s)
OBJS = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(C_SOURCES)) \
       $(patsubst $(SRC_DIR)/%.s,$(BUILD_DIR)/%.o,$(S_SOURCES))

# Правило по умолчанию: собрать и запустить
all: run

# Правило для запуска в QEMU
run: $(BUILD_DIR)/$(KERNEL)
	@echo "Copying kernel to floppy image..."
	@mcopy -o -i $(FLOPPY) $(BUILD_DIR)/$(KERNEL) ::/boot/
	@echo "Starting QEMU with floppy image..."
	@qemu-system-x86_64 -fda $(FLOPPY)

# Правило для создания образа ядра
$(BUILD_DIR)/$(KERNEL): $(OBJS) $(SRC_DIR)/linker.ld
	@mkdir -p $(BUILD_DIR)
	@$(LD) -T $(SRC_DIR)/linker.ld -o $@ -m elf_i386 $(OBJS)
	@echo "Kernel '$(KERNEL)' created successfully!"

# Правило для компиляции объектных файлов C
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(BUILD_DIR)
	@$(CC) $(CFLAGS) -c $< -o $@
	@echo "CC $<"

# Правило для компиляции объектных файлов Asm
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.s
	@mkdir -p $(BUILD_DIR)
	@$(AS) $(ASFLAGS) $< -o $@
	@echo "AS $<"

# Правило для очистки
clean:
	@rm -rf $(BUILD_DIR)
	@echo "Cleanup complete."

.PHONY: all run clean
