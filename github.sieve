require ["include", "environment", "variables", "relational", "comparator-i;ascii-numeric"];
require ["fileinto", "imap4flags", "vacation", "reject", "vnd.proton.expire"];

if allof(
    address :all :comparator "i;unicode-casemap" :contains "From" "notifications@github.com",
    header :matches "List-Archive" "https://github.com/*/*"
) {
  # parse user repo
  set "user" "${1}";
  set "repo" "${2}";

  # mark seen for irrelevant
  if header :matches "X-Github-Reason" ["author", "mention"] {
    fileinto "Todo";
  } else {
    addflag "\\Seen";
    expire "day" "7";
  }

  # bots
  if header :comparator "i;unicode-casemap" :contains "X-Github-Sender" ["bot"] {
    fileinto "Bot";
  }
  
  # issues
  if header :matches "Message-Id" ["*/issues/*", "*/issue/*"] {
    fileinto "Devsecops/Issues/${user}-${repo}";
  }

  # pull requests
  if header :matches "Message-Id" ["*/pull/*"] {
    fileinto "Devsecops/Pull Requests/${user}-${repo}";
  }

  # discussions
  if header :matches "Message-Id" ["*/repo-discussions/*"] {
    fileinto "Devsecops/Discussions/${user}-${repo}";
  }
}