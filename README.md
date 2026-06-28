# settingsnode

`settingsnode` is a small convenience C++ wrapper for reading nested settings without
tying the rest of a program to one configuration backend.

The public API is a `SettingsNode`: you can ask whether a node is present, read
typed scalar values, walk maps and sequences, and get useful path information in
exceptions. The repository currently includes adapters for `yaml-cpp` and
`pybind11` objects.

## Basic use

```cpp
#include <fstream>
#include <memory>
#include <settingsnode.h>
#include <settingsnode/yaml.h>

int main() {
    std::ifstream stream("config.yaml");
    settings::SettingsNode config(std::make_unique<settings::YAML>(stream));

    const auto host = config["server"]["host"].as<std::string>("127.0.0.1");
    const auto port = config["server"]["port"].as<int>(8080);

    for (const auto& item : config["plugins"].as_sequence()) {
        const auto name = item["name"].as<std::string>();
        const auto enabled = item["enabled"].as<bool>(true);
    }
}
```

Missing required values throw `settings::exception` with the path that failed.
Fallback overloads such as `as<int>(8080)` return the fallback only when the node
is missing; type errors still come from the backend.

## Maps and sequences

```cpp
for (const auto& entry : config["limits"].as_map()) {
    const std::string& key = entry.first;
    const settings::SettingsNode& value = entry.second;
}

std::vector<int> ports = config["ports"].to_vector<int>();
std::unordered_map<std::string, double> weights = config["weights"].to_map<double>();
```

The iterators are single-pass input iterators. They are meant for direct
iteration, not for storing and revisiting later.

## CMake

Include `settingsnode.cmake` and link the interface target:

```cmake
include(path/to/settingsnode/settingsnode.cmake)
target_link_libraries(my_target PRIVATE settingsnode)
```

There is also a compatibility helper:

```cmake
include_settingsnode(my_target)
```

Backend libraries are still your responsibility. For YAML support, link
`yaml-cpp`; for Python object support, include and link `pybind11` as usual for
your project.

## Backends

YAML:

```cpp
#include <settingsnode/yaml.h>

settings::SettingsNode config(std::make_unique<settings::YAML>(stream));
```

Python objects through pybind11:

```cpp
#include <settingsnode/pybind.h>

settings::SettingsNode config(std::make_unique<settings::PyNode>(python_object));
```
