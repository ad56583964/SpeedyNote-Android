cmake_minimum_required(VERSION 3.16)
project(AndroidHello LANGUAGES CXX)
set(CMAKE_AUTOMOC ON)
find_package(Qt6 REQUIRED COMPONENTS Widgets)
qt_add_executable(AndroidHello
    main.cpp
)
target_link_libraries(AndroidHello PRIVATE Qt6::Widgets)
