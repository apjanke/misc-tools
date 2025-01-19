# apjanke's generic bash boilerplate

# ===== Generic boilerplate and utilities =====

set -o errexit
set -o nounset
set -o pipefail
if [[ "${TRACE:-0}" == "1" ]]; then set -o xtrace; fi

readonly THIS_PROGRAM="$(basename "$0")"
DRY_RUN=0
VERBOSE=0

function now()     { echo $(date +'%Y-%m-%d %H:%M:%S'); }
function timenow() { echo $(date +'%H:%M:%S'); }
function info()    { echo >&2 "${THIS_PROGRAM:-???}: $(timenow): $*"; }
function verbose() { if is_verbose; then info "$@"; fi; }
function warning() { info "WARNING: $*"; }
function error()   { info "ERROR: $*"; }
function die()     { error "$@"; exit 1; }
function dry()     { info "dry-run: would:" "$@"; }
function wet() {
  # Run a command only if this is not a dry run, or just print it if this is a dry run.
  if is_dry_run; then dry "$@"; else verbose 'running:' "$@"; "$@"; fi;
}
function is_dry_run() { if [[ "${DRY_RUN:-0}" != 0 ]]; then return 0; else return 1; fi; }
function is_wet_run() { if [[ "${DRY_RUN:-0}" == 0 ]]; then return 0; else return 1; fi; }
function is_verbose() { if [[ "${VERBOSE:-0}" != 0 ]]; then return 0; else return 1; fi; }
function forbid_dry_run() {
  if is_dry_run; then
    die "dry-run is not implemented for this functionality yet. Aborted."
  fi
}


# ===== Script-specific code =====


function parse_cmdline() {
  local arg

  while [[ $# -ge 1 ]]; do
    arg="$1"; shift
    case "$arg" in
      -v | --verbose) VERBOSE=1 ;;
      --dry-run)      DRY_RUN=1 ;;
      *)
        die "Unexpected argument: ${arg}" ;;
    esac
  done

  readonly DRY_RUN VERBOSE
}

function main() {

}

# Main script code

parse_cmdline "$@"
main
