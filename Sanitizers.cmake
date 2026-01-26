option(WITH_ADDRESS_SANITIZER "Enable Address Sanitizer" OFF)
option(WITH_THREAD_SANITIZER "Enable Thread Sanitizer" OFF)

message(STATUS "Sanitizers: ASan=${WITH_ADDRESS_SANITIZER} TSan=${WITH_THREAD_SANITIZER}")

function(enable_sanitizers target)
    if(WITH_ADDRESS_SANITIZER AND APPLE AND NOT CMAKE_SYSTEM_NAME STREQUAL "iOS" AND CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        target_compile_options(${target} INTERFACE
                -fsanitize=address,undefined
                -fno-sanitize-recover=undefined
                -fno-omit-frame-pointer
                -g
        )
        target_link_options(${target} INTERFACE
                -fsanitize=address,undefined
                -fno-sanitize-recover=undefined
        )
        target_compile_definitions(${target} INTERFACE
                MallocScribble=1
                MallocPreScribble=1
        )
        set_target_properties(${target} PROPERTIES
                XCODE_SCHEME_ENVIRONMENT "ASAN_OPTIONS=detect_leaks=1:detect_stack_use_after_return=1:check_initialization_order=1:strict_init_order=1;MallocScribble=1;MallocPreScribble=1;MallocStackLogging=1"
        )

        message(STATUS "Enabled sanitizers for ${target}")
    endif()
endfunction()

if (WITH_THREAD_SANITIZER)
    if (CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
        add_compile_options(-fsanitize=thread -g -fno-omit-frame-pointer)
        link_libraries(-fsanitize=thread)
        message(WARNING "Thread Sanitizer enabled")
    endif ()
endif ()
