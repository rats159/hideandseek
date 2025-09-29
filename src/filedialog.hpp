#pragma once
#include <string>
#include <optional>

// Wrapper over tinyfiledialogs 

namespace FileDialog {
    std::optional<std::string> open(const char * title, const char *filter);
}