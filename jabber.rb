#
# Radiofall
# Released under Ruby's license (see the LICENSE file) or GPL, at your option

require 'rubygems'
require 'xmpp4r'
require 'xmpp4r/roster/helper/roster'
require 'xmpp4r/vcard/helper/vcard'
require 'json/pure'

pid = fork do
  Signal.trap('HUP', 'IGNORE') # Don't die upon logout

  stations = %w(radio1 radio2 radio3 radio4 5live 6music radio7 1xtra)
  events = []
  domain = 'hug.hellomatty.com'
  user, password = "mibly@#{domain}", 'password'

  jid = Jabber::JID.new(user)
  cl = Jabber::Client.new(jid)

  def connect(client, password)
    puts '************************************ connection *****************************'
    begin
      client.connect
      client.auth(password)
      client.send(Jabber::Presence.new.set_show(:dnd).set_status('Watching my roster change...'))
      client.allow_tls = false
    rescue => e
      puts "error: #{e}"
    end
  end

  connect(cl, password)
  cl.on_exception { sleep 5; connect(cl, password) }

  n = 0 

  # The roster instance
  roster = Jabber::Roster::Helper.new(cl)

  # Callback to handle updated roster items
  roster.add_update_callback { |olditem,item|
    if [:from, :none].include?(item.subscription) && item.ask != :subscribe
      puts("Subscribing to #{item.jid}")
      item.subscribe
    end
  
    # Print the item
    if olditem.nil?                                                    
      # We didn't knew before:                                       
      puts("#{item.iname} (#{item.jid}, #{item.subscription}) #{item.groups.join(', ')}")
    else                                                             
      # Showing whats different:                                     
      puts("#{olditem.iname} (#{olditem.jid}, #{olditem.subscription}) #{olditem.groups.join(', ')} -> #{item.iname} (#{item.jid}, #{item.subscription}) #{item.groups.join(', ')}")
    end
   }

  # Presence updates:
  roster.add_presence_callback { |item,oldpres,pres|
    # Can't look for something that just does not exist...
    if pres.nil?
      # ...so create it:
      pres = Jabber::Presence.new
    end
    if oldpres.nil?
      # ...so create it:
      oldpres = Jabber::Presence.new
    end
    # Print name and jid:
    name = "#{pres.from}"
    name = name.split('@').first
    unless oldpres.status.nil? && pres.status.nil?
      puts "#{name} - " + pres.status.to_s
      i = stations.index(name)
      unless pres.status.to_s == ''
        events << [i, pres.status.to_s]
        n += 1
      end
  
      if n > 7
        puts "\n Open file"
        fout = File.open("json/out.js", "w")
        fout.write events.to_json
        fout.close
        puts "\n Closed file"
        events = []
        n = 0
      end
     # puts("#{name} - #{pres.status.to_s}")
    end
    # Note: presences with type='error' will reflect our own show/status/priority
    # as it is mostly just a reply from a server. This is *not* a bug.
  }

  cl.send(Jabber::Presence.new.set_show(:dnd).set_status('Watching my roster change...'))

  Thread.stop

  cl.close

end

Process.detach(pid)

# Main loop:




