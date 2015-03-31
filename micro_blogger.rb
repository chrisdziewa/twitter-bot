require 'jumpstart_auth'
require 'bitly'

# For shortening urls
Bitly.use_api_version_3

class MicroBlogger
    attr_reader :client

    def initialize
        @client = JumpstartAuth.twitter
    end

    def run
        puts "Welcome to the JSL Twitter Client!"
        command = ""
        while command != "q"
            printf "enter command: "
            input = gets.chomp
            parts = input.split(" ")
            command = parts[0]


            case command
                when 'q' then puts "Goodbye!"
                when 't'  then tweet(parts[1..-1].join(" "))
                when 'dm' then dm(parts[1], parts[2..-1].join(" "))
                when 'spam' then spam_my_followers(parts[1..-1].join(" "))
                when 'elt' then everyones_last_tweet
                when 's' then shorten(parts[1..-1].join(" "))
                when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
                else
                    puts "Sorry, I don't know how to #{command}"
            end
        end
    end

    def tweet(message)
        message = "".ljust(140, message) if message.length > 140
        @client.update(message)
    end

    def dm(target, message)
        screen_names = followers_list
        puts "Trying to send #{target} this direct message:"
        puts message
        message = "d @#{target} #{message}"
        if screen_names.include?(target)
            tweet(message)
        else
            puts "Error: You can only DM people who follow you."
        end
    end

    def followers_list
        screen_names = []
        @client.followers.each { |follower| screen_names << @client.user(follower).screen_name }
        screen_names
    end

    def spam_my_followers(message)
        "Now spamming all followers with the following message:"
        puts message
        all_followers = followers_list
        all_followers.each do |username|
            dm(username, message)
        end
        puts "---"
        puts "Followers have been successfully spammed."
    end

    def everyones_last_tweet
        screen_names = @client.friends.collect { |friend| @client.user(friend).screen_name }
        # put names in alphabetical order
        screen_names.sort_by! { |friend| friend.downcase}
        screen_names.each do |friend|
            status = @client.user(friend).status
            timestamp = status.created_at.strftime("%A, %b, %d")
            puts "#{friend} said this on #{timestamp}.."
            puts status.text
        #     # print each friend's screen_name
        #     # print each friend's last message
            puts "" # Just print a blank line to separate people
        end
    end

    def shorten(original_url)
        # shortening code
        puts "Shortening this URL: #{original_url}"
        bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
        shortened = bitly.shorten(original_url).short_url
    end
end

blogger = MicroBlogger.new
blogger.run