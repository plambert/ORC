= ORC

Object-oriented Role-playing-game Compiler

Scratchings around a dsl for tabletop paper role-playing game tools

= Example

This is an example of what *should* be supported someday:

    # ORC example

    # Capitalized names are globals
    Module=require("module") # load a hypothetical Pathfinder D20 rules module
    
    # Variable assignment -- capitalized first letter creates a global,
    # otherwise variables are not available outside their immediate
    # scope, not even inherited!

    D20={
      # a function is introduced with 'do'; it is always anonymous, so use
      # assignment to keep it around...
      modifier_for_attribute: do |attr|
        # an associative array is delimited by { ... } and can have ranges as keys
        lookup attr {
            2..3:  -4,
            4..5:  -3,
            6..7:  -2,
            8..9:  -1,
          10..11:  +0,
          12..13:  +1,
          14..15:  +2,
          16..17:  +3,
          18..19:  +4,
          20..21:  +5,
          22..23:  +6,
          24..25:  +7,
          26..27:  +8,
          28..29:  +9,
          30..31: +10,
          32..33: +11,
          34..35: +12,
          36..37: +13,
          38..39: +14,
          40..41: +15,
          42..43: +16,
          44..45: +17,
        }
      end,
      skill: {
        "Climb": {
          "attribute": "STR",
        },
        "Diplomacy": {
          "attribute": "CHR",
        },
        "Bluff": {
          "attribute": "CHR",
        },
      },
    }
    character={
      "attributes": {
        "STR": 18,
        "DEX": 16,
        "CON": 14,
        "INT": 16,
        "WIS": 18,
        "CHR": 12,
        },
      "classes": [
          {
            "name": "Fighter",
            "short_name": "Ftr",
            "level": 3,
          }
        ),
          {
            "name": "Cleric",
            "short_name": "Clr",
            "level": 2,
          }
      ],
      "attacks": []
      # ...
    })
    # Address object attributes with 'object.{"name"}'
    character.{"skill_ranks"}={
      "diplomacy": 4,
      "climb": 6,
      "bluff": 4,
    }
    # For simple names (meeting the requirements for a valid variable name),
    # leave off the {} and ""
    character.name="Conan the Programmer"
    character.playername=if ENV{"USER"} then ENV{"USER"} else "unknown" end
    # Iterate through the attributes of an object with ".each do |k,v| ... end"
    # The 'do' implies () and a function call; normally calling a method
    # requires parens, otherwise the function itself is returned
    character.attributes.each do |attr, val|
      # To address an attribute of an object with the value of an expression,
      # use object.{expression}
      character.attribute_modifier.{attr}=D20.modifier_for_attribute(val)
    end

    # Any object can have a 'type' specified by following it immediately with `name-of-type`
    # The `` quoting is identical to "" and therefore allows interpolation
    # However the resulting value must meet the requirements for a valid variable name
    # Also, use the "object.keys()" method to return a list of attribute names for an object
    for skill_to_set (character.skill_ranks.keys()) {
      character.skills.{skill_to_set} = 10 
        + character.attribute_modifier.{D20.skill.{skill_to_set}.attribute} `attribute`
        + 2 * character.skill_ranks.{skill_to_set} `ranks`
    }
    # The "object.to_integer()" and "object.explain()" methods respectively return:
    # a plain integer (removing all the expression and log data) for an object
    # or a string describing the value, entire expression, and log data.
    return {
      "Diplomacy": character.skills.Diplomacy.to_integer(),
      "Explained": character.skills.Diplomacy.explain()
    }
    # Should return something like:
    # { "Diplomacy": 19, "Explained": "19 = 10 + 1 `attribute` + 8 `ranks`" }

