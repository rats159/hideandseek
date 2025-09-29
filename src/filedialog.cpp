#include "filedialog.hpp"
#include "tinyfiledialogs.h"
#include <string>
#include <optional>

std::optional<std::string> FileDialog::open(const char *title, const char *filter)
{
    char *rawFilename = tinyfd_openFileDialog(
        title,
        "",
        1,
        &filter, // addressing a parameter is weird, but I think this is okay
        nullptr,
        false);

    if (rawFilename == nullptr)
    {
        return std::nullopt;
    }

    return std::string(rawFilename);
}
