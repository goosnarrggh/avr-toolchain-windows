# tests/smoke/CMakeLists.txt
cmake_minimum_required(VERSION 3.20)
project(avr_smoke C)
add_executable(smoke.elf main.c)
target_compile_options(smoke.elf PRIVATE
  -mmcu=atmega328p
  -Os
  -ffunction-sections
  -fdata-sections
)
target_link_options(smoke.elf PRIVATE
  -mmcu=atmega328p
  -Wl,--gc-sections
)
add_custom_command(TARGET smoke.elf POST_BUILD
  COMMAND avr-objcopy -O ihex -R .eeprom $<TARGET_FILE:smoke.elf> smoke.hex
  COMMAND avr-size --format=avr --mcu=atmega328p $<TARGET_FILE:smoke.elf>
)
