# shell-hagenees.sh

hagenees() (

  # SHELL_HAGENEES_LITTLE - what to call you~ (default: "gauzertsje")
  # SHELL_HAGENEES_PRONOUNS - what pronouns hagenees will use for themself~ (default: "hem")
  # SHELL_HAGENEES_ROLES - what role hagenees will have~ (default "hagenees")

  COLORS_LIGHT_PINK='\e[38;5;217m'
  COLORS_LIGHT_BLUE='\e[38;5;117m'
  COLORS_FAINT='\e[2m'
  COLORS_RESET='\e[0m'

  DEF_WORDS_LITTLE="gauzertsje"
  DEF_WORDS_PRONOUNS="her"
  DEF_WORDS_ROLES="hagenees"
  DEF_HAGENEES_COLOR="${COLORS_LIGHT_PINK}"
  DEF_ONLY_NEGATIVE="false"

  NEGATIVE_RESPONSES="Jah jah kèkhe kèkhe maar nie kopûh hè
Wàt loop ie nâh allemaal te lopen verhèuzen man️"

  POSITIVE_RESPONSES="Lekkâh bezag pik
Ziet d'r goed ùit hoâh
Dit ziet d'r prachtag ùit, ga zau doâh"

  # allow for overriding of default words (IF ANY SET)

  if [ -n "$SHELL_HAGENEES_LITTLE" ]; then
    DEF_WORDS_LITTLE="${SHELL_HAGENEES_LITTLE}"
  fi
  if [ -n "$SHELL_HAGENEES_PRONOUNS" ]; then
    DEF_WORDS_PRONOUNS="${SHELL_HAGENEES_PRONOUNS}"
  fi
  if [ -n "$SHELL_HAGENEES_ROLES" ]; then
    DEF_WORDS_ROLES="${SHELL_HAGENEES_ROLES}"
  fi
  if [ -n "$SHELL_HAGENEES_COLOR" ]; then
    DEF_HAGENEES_COLOR="${SHELL_HAGENEES_COLOR}"
  fi
  # allow overriding to true
  if [ "$SHELL_HAGENEES_ONLY_NEGATIVE" = "true" ]; then
    DEF_ONLY_NEGATIVE="true"
  fi
  # if the variable is set for positive/negative responses, overwrite it
  if [ -n "$SHELL_HAGENEES_POSITIVE_RESPONSES" ]; then
    POSITIVE_RESPONSES="$SHELL_HAGENEES_POSITIVE_RESPONSES"
  fi
  if [ -n "$SHELL_HAGENEES_NEGATIVE_RESPONSES" ]; then
    NEGATIVE_RESPONSES="$SHELL_HAGENEES_NEGATIVE_RESPONSES"
  fi

  # split a string on forward slashes and return a random element
  pick_word() {
    echo "$1" | tr '/' '\n' | shuf | sed 1q
  }

  pick_response() { # given a response type, pick an entry from the list
    if [ "$1" = "positive" ]; then
      element=$(echo "$POSITIVE_RESPONSES" | shuf | sed 1q)
    elif [ "$1" = "negative" ]; then
      element=$(echo "$NEGATIVE_RESPONSES" | shuf | sed 1q)
    else
      echo "Invalid response type: $1"
      exit 1
    fi

    # Return the selected response
    echo "$element"
  }

  sub_terms() { # given a response, sub in the appropriate terms
    response="$1"
    # pick_word for each term
    affectionate_term="$(pick_word "${DEF_WORDS_LITTLE}")"
    pronoun="$(pick_word "${DEF_WORDS_PRONOUNS}")"
    role="$(pick_word "${DEF_WORDS_ROLES}")"
    # sub in the terms, store in variable
    response="$(echo "$response" | sed "s/AFFECTIONATE_TERM/$affectionate_term/g")"
    response="$(echo "$response" | sed "s/HAGENEES_PRONOUN/$pronoun/g")"
    response="$(echo "$response" | sed "s/HAGENEES_ROLE/$role/g")"
    # we have string literal newlines in the response, so we need to printf it out
    # print faint and colorcode
    printf "${DEF_HAGENEES_COLOR}$response${COLORS_RESET}\n"
  }

  success() {
    (
      # if we're only supposed to show negative responses, return
      if [ "$DEF_ONLY_NEGATIVE" = "true" ]; then
        return 0
      fi
      # pick_response for the response type
      response="$(pick_response "positive")"
      sub_terms "$response" >&2
    )
    return 0
  }
  failure() {
    rc=$?
    (
      response="$(pick_response "negative")"
      sub_terms "$response" >&2
    )
    return $rc
  }
  # eval is used here to allow for alias resolution

  # TODO: add a way to check if we're running from PROMPT_COMMAND to use the previous exit code instead of doing things this way
  eval "$@" && success || failure
  return $?
)
