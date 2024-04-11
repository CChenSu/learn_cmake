# CMake Usage

## MSVC有些不一样
### 编译时总是需要lib
dll是动态库, lib是静态库。但是生成动态库时还会生成一个轻量级的lib, 因此MSVC编译必须要用到lib.
运行时需要dll
### __dllexport 和 __dllimport
[在 C++ 类中使用 dllimport 和 dllexport](https://learn.microsoft.com/zh-cn/cpp/cpp/using-dllimport-and-dllexport-in-cpp-classes?view=msvc-170)
常见的一个`export.h`
```c++
#ifdef Export
#define Project_API  __declspec( dllexport )
#else
#define Project_API  __declspec( dllimport )
#endif
```
通过Project目录下的cmake控制`Project_API`
```cmake
target_compile_definitions(Project_Name PRIVATE EXPORT)
```

