

add_executable(import_cuda main.cu)
target_link_libraries(import_opencv cuda cudart_static)