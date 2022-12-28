#!/usr/bin/env bash
# sudofox/shell-mommy.sh

mommy() {
  MOMMY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

  # SHELL_MOMMYS_LITTLE - what to call you~ (default: "girl")
  # SHELL_MOMMYS_PRONOUNS - what pronouns mommy will use for themself~ (default: "her")
  # SHELL_MOMMYS_ROLES - what role mommy will have~ (default "mommy")

  COLORS_LIGHT_PINK='\e[38;5;217m'
  COLORS_LIGHT_BLUE='\e[38;5;117m'
  COLORS_FAINT='\e[2m'
  COLORS_RESET='\e[0m'

  DEF_WORDS_LITTLE="girl"
  DEF_WORDS_PRONOUNS="her"
  DEF_WORDS_ROLES="mommy"
  DEF_MOMMY_COLOR="${COLORS_LIGHT_PINK}"

  NEGATIVE_RESPONSES=(
    "just a little further, sweetie~ ❤️"
    "MOMMYS_ROLE knows MOMMYS_PRONOUN little AFFECTIONATE_TERM can do better~ ❤️"
    "oh no did MOMMYS_ROLE's little AFFECTIONATE_TERM make a big mess~? ❤️"
    "MOMMYS_ROLE still loves you no matter what~ ❤️"
    "do you need MOMMYS_ROLE's help~? ❤️"
    "MOMMYS_ROLE believes in you~ ❤️"
  )

  POSITIVE_RESPONSES=(
    "good AFFECTIONATE_TERM~\nMOMMYS_ROLE's so proud of you~ ❤️"
    "awe, what a good AFFECTIONATE_TERM~\nMOMMYS_ROLE knew you could do it~ ❤️"
    "that's a good AFFECTIONATE_TERM~ ❤️"
    "MOMMYS_ROLE thinks MOMMYS_PRONOUN litle AFFECTIONATE_TERM earned a big hug~ ❤️"
    "*pets your head*"
    "you're such a smart cookie~ ❤️"
  )

  # allow for overriding of default words (IF ANY SET)

  if [[ -n "${SHELL_MOMMYS_LITTLE:-}" ]]; then
    DEF_WORDS_LITTLE="${SHELL_MOMMYS_LITTLE}"
  fi
  if [[ -n "${SHELL_MOMMYS_PRONOUNS:-}" ]]; then
    DEF_WORDS_PRONOUNS="${SHELL_MOMMYS_PRONOUNS}"
  fi
  if [[ -n "${SHELL_MOMMYS_ROLES:-}" ]]; then
    DEF_WORDS_ROLES="${SHELL_MOMMYS_ROLES}"
  fi
  if [[ -n "${SHELL_MOMMYS_COLOR:-}" ]]; then
    DEF_MOMMY_COLOR="${SHELL_MOMMYS_COLOR}"
  fi

  # split a string on forward slashes and return a random element
  pick_word() {
    IFS='/' read -ra words <<<"$1"
    index=$(($RANDOM % ${#words[@]}))
    echo "${words[$index]}"
  }

  pick_response() { # given a response type, pick an entry from the array

    if [ "$1" == "positive" ]; then
      index=$(($RANDOM % ${#POSITIVE_RESPONSES[@]}))
      element=${POSITIVE_RESPONSES[$index]}
    elif [ "$1" == "negative" ]; then
      index=$(($RANDOM % ${#NEGATIVE_RESPONSES[@]}))
      element=${NEGATIVE_RESPONSES[$index]}
    else
      echo "Invalid response type: $1"
      exit 1
    fi

    # Return the selected response
    echo "$element"

  }

  sub_terms() { # given a response, sub in the appropriate terms
    local response="$1"
    # pick_word for each term
    local affectionate_term="$(pick_word "${DEF_WORDS_LITTLE}")"
    local pronoun="$(pick_word "${DEF_WORDS_PRONOUNS}")"
    local role="$(pick_word "${DEF_WORDS_ROLES}")"
    # sub in the terms, store in variable
    local response="$(echo "${response//AFFECTIONATE_TERM/$affectionate_term}")"
    local response="$(echo "${response//MOMMYS_PRONOUN/$pronoun}")"
    local response="$(echo "${response//MOMMYS_ROLE/$role}")"
    # we have string literal newlines in the response, so we need to printf it out
    # print faint and colorcode
    echo -e "${DEF_MOMMY_COLOR}$response${COLORS_RESET}"
  }

  success() {
    (
      # pick_response for the response type
      local response="$(pick_response "positive")"
      sub_terms "$response" >&2
    )
    return 0
  }
  failure() {
    local rc=$?
    (
      local response="$(pick_response "negative")"
      sub_terms "$response" >&2
    )
    return $rc
  }
  # eval is used here to allow for alias resolution

  # TODO: add a way to check if we're running from PROMPT_COMMAND to use the previous exit code instead of doing things this way
  eval "$@" && success || failure
  return $?
}
