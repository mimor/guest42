require 'cinch'

bot = Cinch::Bot.new do
  configure do |c|
    c.server = 'irc.freenode.net'
    c.channels = ['#0x20xbot', '#0x20']
    c.nick = 'Guest42'
  end
end

bot.start
