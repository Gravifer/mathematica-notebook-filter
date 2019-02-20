#!/usr/bin/bash

# Exit on any error
set -eux

# Run clippy and see if it has anything to say
clippy_lints() {
    cargo clippy
}

# Run rustfmt
check_format() {
    cargo fmt -- --check
}

# Run the standard build and test suite.
build_and_test() {
    cargo build
    cargo test
}

# Test the command line and make sure it works.
command_line() {
    # Try it once using `cargo run`
    cargo run -- -vvv -i ci/test_notebook.nb -o ci/test_notebook_min.nb
    if [[ $(wc -c < ci/test_notebook.nb) -le $(wc -c < ci/test_notebook_min.nb) ]]; then
        echo "No reduction in file size ($(wc -c < ci/test_notebook.nb) => $(wc -c < ci/test_notebook_min.nb))." >&2
        false
    fi

    # Try also by calling it manually
    ./target/debug/mathematica-notebook-filter -vvv -i ci/test_notebook.nb -o ci/test_notebook_min.nb
    if [[ $(wc -c < ci/test_notebook.nb) -le $(wc -c < ci/test_notebook_min.nb) ]]; then
        echo "No reduction in file size ($(wc -c < ci/test_notebook.nb) => $(wc -c < ci/test_notebook_min.nb))." >&2
        false
    fi
}

main() {
    clippy_lints
    check_format
    build_and_test
    command_line
}

main
