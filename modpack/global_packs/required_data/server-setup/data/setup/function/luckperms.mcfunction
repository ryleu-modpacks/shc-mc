# ignore the warnings from spyglass. it doesn't recognize the lp command and i don't feel like adding support
# create groups
lp creategroup moderator
lp creategroup admin

# default gets basic gameplay, voice chat, messaging
lp group default permission set voicechat.* true
lp group default permission set minecraft.command.msg true
lp group default permission set minecraft.command.tell true
lp group default permission set minecraft.command.me true
lp group default permission set minecraft.command.list true

# moderator gets kick, mute voice, teleport, inspection, grim alerts
lp group moderator parent add default
lp group moderator permission set minecraft.command.kick true
lp group moderator permission set minecraft.command.tp true
lp group moderator permission set minecraft.command.ban true
lp group moderator permission set minecraft.command.pardon true
lp group moderator permission set voicechat.manage true
lp group moderator permission set grim.alerts true
lp group moderator permission set grim.history true

# admin gets everything
lp group admin permission set * true
