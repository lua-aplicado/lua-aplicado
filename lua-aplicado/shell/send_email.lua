--------------------------------------------------------------------------------
-- git.lua: dumb ad-hoc code to work with git
--------------------------------------------------------------------------------

local assert
    = assert

--------------------------------------------------------------------------------

local arguments,
      optional_arguments,
      method_arguments
      = import 'lua-nucleo/args.lua'
      {
        'arguments',
        'optional_arguments',
        'method_arguments'
      }

local fill_placeholders
      = import 'lua-nucleo/string.lua'
      {
        'fill_placeholders'
      }

local shell_exec,
      shell_read
      = import 'lua-aplicado/shell.lua'
      {
        'shell_exec',
        'shell_read'
      }

--------------------------------------------------------------------------------

local send_email = function(from, to, cc, bcc, subject, body)
  arguments(
      "string", from,
      "string", to,
      "string", subject,
      "string", body
    )
  optional_arguments(
      "table",  cc,
      "table",  bcc
    )

  local cmd_template = [[
generate_email()
{
#header
cat <<-EOF
From: $(from)
$(rcpt)Subject: $(subject)
Content-Type: text/plain; charset=utf-8

$(body)
EOF
}
generate_email | /usr/sbin/sendmail -t
]]

  local rcpt = "To: " .. to .. "\n"

  if cc then
    rcpt = rcpt .. "Cc: " .. table.concat(cc, ", ") .. "\n"
  end

  if bcc then
    rcpt = rcpt .. "Bcc: " .. table.concat(bcc, ", ") .. "\n"
  end

  local values =
  {
    from = from;
    rcpt = rcpt;
    subject = subject;
    body = body;
  }

  return os.execute(assert(fill_placeholders(cmd_template, values)))
end

--------------------------------------------------------------------------------

return
{
  send_email = send_email;
}
