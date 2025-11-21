cmake_minimum_required(VERSION 3.10.2)

project(audio_native)

# C++17を有効化
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 最適化フラグ
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -ffast-math -march=native")

# ソースファイル
add_library(audio_native SHARED
    audio_generator.cpp
)

# ログライブラリをリンク
find_library(log-lib log)
target_link_libraries(audio_native ${log-lib})
