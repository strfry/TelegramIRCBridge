DEBUG = 1

--tg_channel = "PUBLIC"
tg_group = "CCCMZWI_NON-OFFICIAL_IRC-Bridge"
tg_group = "$02000000de61b80a0000000000000000"

tg_match = "CCCMZ"

irc_nick = "tgboT"
irc_channel = "#cccmz"
irc_server = "irc.hackint.org"

----------------------- GLOBALS

tg_last_msg = nil

----------------------- LuaIRC

require ("irc")

local irc_conn = irc.new{nick = irc_nick}
irc_conn:hook("OnChat", function (user, channel, message)
  --print(user, channel, message)
  --vardump(user)
  if channel == irc_channel then
  tg_forward_msg(user.nick, message)
  else
    print ("Ignoring message from wrong channel " .. channel)
  end

  --tg_test_msg('IRC')
end)


irc_conn:connect(irc_server)
irc_conn:join(irc_channel)


function irc_work()
  irc_conn:think()
end

function irc_forward_msg(from, text)
  line = ("[%s] %s"):format(from, text)
  -- print (line)
  irc_conn:sendChat(irc_channel, line)
end

----------------------- Telegram

function tg_forward_msg(from, text, to)
  line = ("[%s] %s"):format(from, text)
  --print (line)
--  if not post_msg(tg_channel, line, ok_cb, false) then
  if not send_msg(tg_group, line, ok_cb, false) then

    print("Something went wrong in send_msg to", to)
    print("Text: ", text)
    print("From: ", from)
    vardump(tg_last_msg)
  end
end

function tg_test_msg(context)
  result = send_msg(tg_channel, context, ok_cb, false)
  print ("tg_test_msg " .. context .. " = " .. tostring(result))
end

-------------------------------- Telegram Sample code

started = 0
our_id = 0

function vardump(value, depth, key)
  local linePrefix = ""
  local spaces = ""
  
  if key ~= nil then
    linePrefix = "["..key.."] = "
  end
  
  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do spaces = spaces .. "  " end
  end
  
  if type(value) == 'table' then
    mTable = getmetatable(value)
    if mTable == nil then
      print(spaces ..linePrefix.."(table) ")
    else
      print(spaces .."(metatable) ")
        value = mTable
    end		
    for tableKey, tableValue in pairs(value) do
      vardump(tableValue, depth, tableKey)
    end
  elseif type(value)	== 'function' or 
      type(value)	== 'thread' or 
      type(value)	== 'userdata' or
      value		== nil
  then
    print(spaces..tostring(value))
  else
    print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
  end
end

print ("HI, this is lua script")

function ok_cb(extra, success, result)
  --print("ok_cb, " .. tostring(extra) .. " success: " .. tostring(success) .. "  result ")
  --vardump(result)
end


-- Notification code {{{


function on_msg_receive (msg)
  if started == 0 then
    return
  end
  if msg.out then
    return
  end

  tg_last_msg = msg

  if DEBUG then
    vardump(msg)
  end
 
  -- msg.to.peer_type == "chat"
  if (msg.to.title:match(tg_match)) then
    irc_forward_msg(msg.from.username, msg.text, tg_group)
  else
    vardump(msg.to)
    print (string.format("Ignoring Message to channel %s", msg.to.title))
    print("msg.to.title:match(tg_group)", msg.to.title:match(tg_group))
    print("msg.to.peer_type == peer_type", msg.to.peer_type == peer_type)
  end

  --tg_test_msg('pong')  

if (1) then  
return
end

end

function on_our_id (id)
  our_id = id
end

function on_user_update (user, what)
  --vardump (user)
end

function on_chat_update (chat, what)
  print ("chat_update")
  vardump (chat)
  vardump (what)
end

function on_secret_chat_update (schat, what)
  --vardump (schat)
end

function on_get_difference_end ()
  print("on_get_difference_end")
  --tg_test_msg("on_get_difference_end")
end

function cron()
  -- do something
  postpone (cron, false, 1.0)
  irc_work()
end

function on_binlog_replay_end ()
  print ("on_binlog_replay_end")
  started = 1
  postpone (cron, false, 1.0)
  --tg_test_msg("on_binlog_replay_end")
end


