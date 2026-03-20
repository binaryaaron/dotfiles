#! /usr/bin/env bash

alias bb='bazel build '
alias bbd='bazel build --config=debug '

alias brd='bazel run --config=debug '
alias br='bazel run '

alias bq='bazel query '
alias bq-ob='bazel query --output=build '
alias bq-oj='bazel query --output=streamed_jsonproto '
alias bq-op='bazel query --output=streamed_proto '
alias bq-olk='bazel query --output=label_kind '
alias bq-o='bazel query --output '
alias bcq='bazel cquery '
alias bcq-o='bazel cquery --output '
