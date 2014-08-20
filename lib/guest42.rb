require 'cinch'
require 'httparty'
require 'json'
require 'cgi'

begin
  bot = Cinch::Bot.new do
    configure do |c|
      c.server = 'irc.freenode.net'
      c.channels = ['#0x20xbot', '#0x20']
      c.nick = 'Guest42'
    end

    helpers do
        class NoRedirectHTTParty
          include HTTParty
          follow_redirects false
        end

        def help
          "Available functions:\n" \
          " !help            ->   show this helpfunction.\n"\
          " !gif <sublject>  ->   searches reddit /r/gifs for random gif with the specified subject.\n"\
          " !gifcat          ->   show a random gif with cat(s).\n"\
          " !octocat         ->   show github's random ascii octocat."
        end
        
        def searchreddit(gifquery)
          response = HTTParty.get("http://www.reddit.com/r/gifs/search.json?q=#{gifquery}&restrict_sr=yes")
          if JSON.parse(response.body)['data']['children'].count == 0
            "Sorry, no result"
          else
            url = JSON.parse(response.body)['data']['children'].sample['data']['url']
           until url =~ /(.*)\.gif/ 
              url = JSON.parse(response.body)['data']['children'].sample['data']['url']
            end
              CGI.unescape_html "[GIF] #{url}"
          end
        end

        def gifcat
          url = NoRedirectHTTParty.get('http://thecatapi.com/api/images/get?format=src&type=gif').headers["location"]
          CGI.unescape_html "[GIF] #{url}"
        end

        def octocat
          url = 'https://api.github.com/octocat'
          body = HTTParty.get(url, :headers => {"User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17" } ).response.body
        end
      end

      on :message, /^!gif (.+)/ do |m, gifquery|
        m.reply searchreddit(gifquery)
      end

      on :message, /^!gifcat/  do |m|
        m.reply gifcat
      end
    
      on :message, /^!octocat/ do |m|
        m.reply octocat
      end

      on :message, /^!help/ do |m|
        m.reply help
      end

      on :action, /(kick|slap)/ do |m|
        m.reply 'I\'ll kick you in the nutsack!!', true
      end
    end

rescue StandardError => e
    m.reply 'I\'m sorry, something went wrong. Monkeys showed us this: ' + e.message
end

bot.start
