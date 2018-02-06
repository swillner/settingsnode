#  Copyright (C) 2017 Sven Willner <sven.willner@gmail.com>
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as published
#  by the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

if(TARGET settingsnode)
  return()
endif()

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_LIST_DIR}/cmake)

if(CMAKE_VERSION VERSION_LESS 3.3)
  add_library(settingsnode UNKNOWN IMPORTED)
else()
add_library(settingsnode INTERFACE)
endif()
set_property(TARGET settingsnode PROPERTY INTERFACE_COMPILE_DEFINITIONS "SETTINGSNODE_WITH_YAML")

if(EXISTS ${CMAKE_CURRENT_LIST_DIR}/lib/yaml-cpp/CMakeLists.txt)
  set(APPLE_UNIVERSAL_BIN OFF CACHE INTERNAL "")
  set(BUILD_SHARED_LIBS OFF CACHE INTERNAL "")
  set(MSVC_SHARED_RT ON CACHE INTERNAL "")
  set(MSVC_STHREADED_RT OFF CACHE INTERNAL "")
  set(YAML_CPP_BUILD_CONTRIB OFF CACHE INTERNAL "")
  set(YAML_CPP_BUILD_TOOLS OFF CACHE INTERNAL "")
  set(gmock_build_tests OFF CACHE INTERNAL "")
  set(gtest_build_samples OFF CACHE INTERNAL "")
  set(gtest_build_tests OFF CACHE INTERNAL "")
  set(gtest_disable_pthreads OFF CACHE INTERNAL "")
  set(gtest_force_shared_crt OFF CACHE INTERNAL "")
  if(CMAKE_VERSION VERSION_LESS 3.3)
    add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/lib/yaml-cpp ${CMAKE_CURRENT_BINARY_DIR}/yaml-cpp EXCLUDE_FROM_ALL)
    add_dependencies(settingsnode yaml-cpp)
    set(SETTINGSNODE_INCLUDE_DIRS ${CMAKE_CURRENT_LIST_DIR}/lib/yaml-cpp/include ${CMAKE_CURRENT_LIST_DIR}/include)
    set(SETTINGSNODE_LIBRARIES ${CMAKE_CURRENT_BINARY_DIR}/yaml-cpp/libyaml-cpp.a)
  else()
  add_subdirectory(${CMAKE_CURRENT_LIST_DIR}/lib/yaml-cpp ${CMAKE_CURRENT_BINARY_DIR}/yaml-cpp)
  target_include_directories(settingsnode INTERFACE ${CMAKE_CURRENT_LIST_DIR}/lib/yaml-cpp/include ${CMAKE_CURRENT_LIST_DIR}/include)
  endif()
else()
  find_package(YAML_CPP REQUIRED)
  message(STATUS "yaml-cpp include directory: ${YAML_CPP_INCLUDE_DIR}")
  message(STATUS "yaml-cpp library: ${YAML_CPP_LIBRARY}")
  if(CMAKE_VERSION VERSION_LESS 3.3)
    set(SETTINGSNODE_INCLUDE_DIRS ${YAML_CPP_INCLUDE_DIRS} ${CMAKE_CURRENT_LIST_DIR}/include)
    set(SETTINGSNODE_LIBRARIES ${YAML_CPP_LIBRARIES})
  else()
  target_include_directories(settingsnode INTERFACE ${YAML_CPP_INCLUDE_DIRS} ${CMAKE_CURRENT_LIST_DIR}/include)
endif()
endif()

if(CMAKE_VERSION VERSION_LESS 3.3)
  set_target_properties(settingsnode PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${SETTINGSNODE_INCLUDE_DIRS}")
  set_target_properties(settingsnode PROPERTIES IMPORTED_LINK_INTERFACE_LANGUAGES "CXX")
  set_target_properties(settingsnode PROPERTIES IMPORTED_LOCATION "${SETTINGSNODE_LIBRARIES}")
else()
add_dependencies(settingsnode yaml-cpp)
target_link_libraries(settingsnode INTERFACE yaml-cpp)
endif()
