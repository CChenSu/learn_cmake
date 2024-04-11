include_directories(../3rd/include)
link_directories(../3rd/lib/)

add_executable(import_opencv main.cpp)
target_link_libraries(import_opencv opencv_world490)