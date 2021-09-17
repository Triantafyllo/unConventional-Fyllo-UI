local changelog_table = {
    ["Version 1.3.1"] = {
        "- Reverted to old Anti-AFK tick method, as the previous one is not safe"
    },
    ["Version 1.2.1"] = {
        "* Fixed a bug where the script would occasionally error"
    },
    ["Version 1.2.0"] = {
        "+ Addedd Iris Compatibility Script to the UI",
        "+ Updated Anti-AFK tick method to not rejoin you anymore, nor make your game become \"TouchEnabled\"",
        "* Optimized code by cleaning up a few things",
        "+ Added a rejoin time to the kick message"
    },
    ["Version 1.1.0"] = {
        "+ There's now a changelog accessible from directly within the UI!",
        "Unfortunately, it has to be printed :p"
    },
    ["Version 1.0.0"] = {
        "+ The script has been created!"
    }
}

return changelog_table
