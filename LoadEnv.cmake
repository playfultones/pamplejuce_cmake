# =============================================================================
# LoadEnv.cmake - Load environment variables from .env file
# =============================================================================
# This module reads a .env file and sets CMake variables from it.
# It handles quoted values, comments, and empty lines.
#
# Usage:
#   include(LoadEnv)
#   load_env_file("${CMAKE_SOURCE_DIR}/.env")
#
# After loading, you can use the variables like:
#   ${PLUGIN_NAME}, ${PRODUCT_NAME}, etc.
# =============================================================================

# Function to parse a .env file and set variables in parent scope
function(load_env_file ENV_FILE)
    if(NOT EXISTS "${ENV_FILE}")
        message(FATAL_ERROR
            "\n"
            "==================================================================\n"
            "LoadEnv: .env file not found at ${ENV_FILE}\n"
            "\n"
            "Please copy .env.example to .env and configure your settings:\n"
            "  cp .env.example .env\n"
            "==================================================================\n"
        )
    endif()

    message(STATUS "LoadEnv: Loading environment from ${ENV_FILE}")

    # Read the file
    file(STRINGS "${ENV_FILE}" ENV_LINES)

    foreach(LINE ${ENV_LINES})
        # Skip empty lines
        if("${LINE}" STREQUAL "")
            continue()
        endif()

        # Skip comment lines (starting with #)
        string(REGEX MATCH "^[ \t]*#" IS_COMMENT "${LINE}")
        if(IS_COMMENT)
            continue()
        endif()

        # Skip lines without = sign
        string(FIND "${LINE}" "=" HAS_EQUALS)
        if(HAS_EQUALS EQUAL -1)
            continue()
        endif()

        # Extract variable name (everything before first =)
        string(REGEX MATCH "^([A-Za-z_][A-Za-z0-9_]*)=" VAR_MATCH "${LINE}")
        if(NOT VAR_MATCH)
            continue()
        endif()

        # Get the variable name
        string(REGEX REPLACE "^([A-Za-z_][A-Za-z0-9_]*)=.*" "\\1" VAR_NAME "${LINE}")

        # Get the value (everything after first =)
        string(REGEX REPLACE "^[A-Za-z_][A-Za-z0-9_]*=(.*)" "\\1" VAR_VALUE "${LINE}")

        # Remove leading/trailing whitespace from value
        string(STRIP "${VAR_VALUE}" VAR_VALUE)

        # Remove surrounding quotes (both single and double)
        string(REGEX REPLACE "^\"(.*)\"$" "\\1" VAR_VALUE "${VAR_VALUE}")
        string(REGEX REPLACE "^'(.*)'$" "\\1" VAR_VALUE "${VAR_VALUE}")

        # Set the variable in parent scope
        set(${VAR_NAME} "${VAR_VALUE}" PARENT_SCOPE)

        # Also set in cache for visibility (but don't override command-line values)
        if(NOT DEFINED CACHE{${VAR_NAME}})
            set(${VAR_NAME} "${VAR_VALUE}" CACHE STRING "From .env file" FORCE)
        endif()

        message(STATUS "LoadEnv: ${VAR_NAME} = ${VAR_VALUE}")
    endforeach()
endfunction()

# Convenience macro to load from default location
macro(load_env)
    load_env_file("${CMAKE_SOURCE_DIR}/.env")
endmacro()
