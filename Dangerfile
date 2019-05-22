warn 'PR is marked as Work In Progress.' if github.pr_title.include? "WIP"

warn 'This PR does not have any reviewers yet.' if github.pr_json['requested_reviewers'].empty?

warn 'This PR does not have any assignees yet.' unless github.pr_json['assignee']

warn 'Big PR - break it to smaller PRs.' if git.lines_of_code > 500

warn "#{git.commits.count} commits too many - please, squash them" if git.commits.count > 5

warn 'Please, set correct Jira link in the PR comment.' if 
github.pr_body.include? "[JIRA Ticket](xxx)"