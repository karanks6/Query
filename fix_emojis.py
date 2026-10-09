import re

with open("lib/game/scenes/dashboard_scene.dart", "r", encoding="utf-8", errors="replace") as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if "_streakText.text =" in line and "streak" in line:
        new_lines.append("    if (streak != null) _streakText.text = \'🔥 $streak\';\n")
    elif "_xpText.text =" in line and "xp XP" in line:
        new_lines.append("    if (xp != null) _xpText.text = \'✨ $xp XP\';\n")
    elif "_achText.text =" in line and "achievements" in line:
        new_lines.append("    if (achievements != null) _achText.text = \'🏆 $achievements\';\n")
    elif "text: \'" in line and "$initialStreak\'" in line:
        new_lines.append("      text: \'🔥 $initialStreak\',\n")
    elif "text: \'" in line and "$initialXp XP\'" in line:
        new_lines.append("      text: \'✨ $initialXp XP\',\n")
    elif "text: \'" in line and "$initialAchievements\'" in line:
        new_lines.append("      text: \'🏆 $initialAchievements\',\n")
    else:
        new_lines.append(line)

with open("lib/game/scenes/dashboard_scene.dart", "w", encoding="utf-8") as f:
    f.writelines(new_lines)
