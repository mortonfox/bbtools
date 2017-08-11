#!/usr/bin/env ruby

require 'rest-client'
require 'fileutils'
require 'json'
require 'English'

REPOS_FOLDER = './repos'

def backup_repo name, url
  # Find a subfolder name that does not already exist.
  subfolder = name
  if Dir.exist? subfolder
    i = 1
    i += 1 while Dir.exist? "#{subfolder}-#{i}"
    subfolder = "#{subfolder}-#{i}"
  end

  got_warning = false

  result = system "git clone \"#{url}\" \"#{subfolder}\""
  unless result
    warn "git clone failed for url #{url}, subfolder #{subfolder}: exit code #{$CHILD_STATUS}"
    return
  end

  result = system "cd \"#{subfolder}\"; git bundle create \"../#{subfolder}.bundle\" --all"
  unless result
    warn "git bundle failed for subfolder #{subfolder}: exit code #{$CHILD_STATUS}"
    got_warning = true
  end

  result = system "cd \"#{subfolder}\"; git archive --format zip --prefix \"#{subfolder}/\" -9 -o \"../#{subfolder}.zip\" HEAD"
  unless result
    warn "git archive failed for subfolder #{subfolder}: exit code #{$CHILD_STATUS}"
    got_warning = true
  end

  FileUtils.rm_rf subfolder unless got_warning
end

def backup_repos username
  Dir.mkdir REPOS_FOLDER unless Dir.exist? REPOS_FOLDER
  Dir.chdir REPOS_FOLDER

  res = RestClient.get("https://api.bitbucket.org/2.0/repositories/#{username}")

  loop {
    json = JSON.parse(res.body)

    json['values'].each { |repo|
      name = repo['name']

      if repo['scm'] != 'git'
        warn "Skipping non-git repo '#{name}'"
        next
      end

      clone_link = repo['links']['clone'].find { |link| link['name'] == 'https' }
      unless clone_link
        warn "Can't find https clone link for repo '#{name}'"
        next
      end

      url = clone_link['href']

      backup_repo(name, url)
    }

    break unless json.key?('next')

    res = RestClient.get(json['next'])
  }
end

if ARGV.empty?
  puts <<-EOM
Usage: #{File.basename $PROGRAM_NAME} username
  EOM
  exit 1
end

backup_repos ARGV.first

__END__
