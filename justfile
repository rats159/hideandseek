# Just wrapper over CMake
# use `just enable` to enable flags like EDITOR

set shell := ['powershell', '-c']


[working-directory: 'build']
enable *defines:
    cmake .. {{replace_regex(defines, "(\\S+)","-D$1=ON")}}

[working-directory: 'build']
disable *defines:
    cmake .. {{replace_regex(defines, "(\\S+)","-D$1=OFF")}}


[working-directory: 'build']
build:
    cmake --build .

[working-directory: 'out']
run: build
    ./hideandseek
    