#!/usr/bin/env bash
# sudofox/shell-mommy.sh

mommy() (
  local LEXIT="$?" # Capture Previous Exit Code

  if [[ "$*" =~ \$\(exit\ ([0-9]+)\) ]]; then
    # Value was $(exit NUM)
    #  Recommended usage for $PROMPT_COMMAND is
    #
    #  export PROMPT_COMMAND="mommy \\$\\(exit \$?\\); $PROMPT_COMMAND"
    #
    #  So we can reasonably assume it's being run from $PROMPT_COMMAND"
    local PROMPTED=1
  fi

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
  DEF_ONLY_NEGATIVE="false"

  NEGATIVE_RESPONSES=(
    "do you need MOMMYS_ROLE's help~? ❤️"
    "Don't give up, my love~ ❤️"
    "Don't worry, MOMMYS_ROLE is here to help you~ ❤️"
    "I believe in you, my sweet AFFECTIONATE_TERM~ ❤️"
    "It's okay to make mistakes, my dear~ ❤️"
    "just a little further, sweetie~ ❤️"
    "Let's try again together, okay~? ❤️"
    "MOMMYS_ROLE believes in you, and knows you can overcome this~ ❤️"
    "MOMMYS_ROLE believes in you~ ❤️"
    "MOMMYS_ROLE is always here for you, no matter what~ ❤️"
    "MOMMYS_ROLE is here to help you through it~ ❤️"
    "MOMMYS_ROLE is proud of you for trying, no matter what the outcome~ ❤️"
    "MOMMYS_ROLE knows it's tough, but you can do it~ ❤️"
    "MOMMYS_ROLE knows MOMMYS_PRONOUN little AFFECTIONATE_TERM can do better~ ❤️"
    "MOMMYS_ROLE knows you can do it, even if it's tough~ ❤️"
    "MOMMYS_ROLE knows you're feeling down, but you'll get through it~ ❤️"
    "MOMMYS_ROLE knows you're trying your best~ ❤️"
    "MOMMYS_ROLE loves you, and is here to support you~ ❤️"
    "MOMMYS_ROLE still loves you no matter what~ ❤️"
    "You're doing your best, and that's all that matters to MOMMYS_ROLE~ ❤️"
    "MOMMYS_ROLE is always here to encourage you~ ❤️"
  )

  POSITIVE_RESPONSES=(
    "*pets your head*"
    "awe, what a good AFFECTIONATE_TERM~\nMOMMYS_ROLE knew you could do it~ ❤️"
    "good AFFECTIONATE_TERM~\nMOMMYS_ROLE's so proud of you~ ❤️"
    "Keep up the good work, my love~ ❤️"
    "MOMMYS_ROLE is proud of the progress you've made~ ❤️"
    "MOMMYS_ROLE is so grateful to have you as MOMMYS_PRONOUN little AFFECTIONATE_TERM~ ❤️"
    "I'm so proud of you, my love~ ❤️"
    "MOMMYS_ROLE is so proud of you~ ❤️"
    "MOMMYS_ROLE loves seeing MOMMYS_PRONOUN little AFFECTIONATE_TERM succeed~ ❤️"
    "MOMMYS_ROLE thinks MOMMYS_PRONOUN little AFFECTIONATE_TERM earned a big hug~ ❤️"
    "that's a good AFFECTIONATE_TERM~ ❤️"
    "you did an amazing job, my dear~ ❤️"
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
  # allow overriding to true
  if [[ "${SHELL_MOMMYS_ONLY_NEGATIVE:-}" == "true" ]]; then
    DEF_ONLY_NEGATIVE="true"
  fi
  # if the array is set for positive/negative responses, overwrite it
  if [[ -n "${SHELL_MOMMYS_POSITIVE_RESPONSES:-}" ]]; then
    POSITIVE_RESPONSES=("${SHELL_MOMMYS_POSITIVE_RESPONSES[@]}")
  fi
  if [[ -n "${SHELL_MOMMYS_NEGATIVE_RESPONSES:-}" ]]; then
    NEGATIVE_RESPONSES=("${SHELL_MOMMYS_NEGATIVE_RESPONSES[@]}")
  fi
  
  # split a string on forward slashes and return a random element
  pick_word() {
    IFS='/' read -ra words <<<"$1"
    index=$(($RANDOM % ${#words[@]}))
    echo "${words[$index]}"
  }

  pick_response() { # given a response type, pick an entry from the array

    if [[ "$1" == "positive" ]]; then
      index=$(($RANDOM % ${#POSITIVE_RESPONSES[@]}))
      element=${POSITIVE_RESPONSES[$index]}
    elif [[ "$1" == "negative" ]]; then
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
      # if we're only supposed to show negative responses, return
      if [ "$DEF_ONLY_NEGATIVE" == "true" ]; then
        return 0
      fi
      # pick_response for the response type
      local response="$(pick_response "positive")"
      sub_terms "$response" >&2
    )
    return 0
  }
  failure() {
    local rc=$?
    if [[ "$rc" == "130" ]]; then
        return 0
    fi
    (
      local response="$(pick_response "negative")"
      sub_terms "$response" >&2
    )
    return $rc
  }

  # From PROMPT_COMMAND or not?
  if [ ! "$PROMPTED" ]; then
    # eval is used here to allow for alias resolution
    eval "$@" && success || failure
    return $?
  elif [ "$LEXIT" != "130" ]; then
    [ "$LEXIT" = "0" ] && success || failure
    return "$LEXIT"
  fi

)
